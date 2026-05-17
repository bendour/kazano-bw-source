VoidFactions.Factions = VoidFactions.Factions or {}
VoidFactions.Faction = VoidFactions.Faction or {}

-- Validators

function VoidFactions.Faction:ValidateFaction(name, maxMembers, tag)
	local nameLength = utf8.len(name or "")
	local tagLength = utf8.len(tag or "")

	if (VoidFactions.Settings:IsDynamicFactions()) then
		local nameMatch = name:match(VoidFactions.Settings.Hardcoded.FactionNamePattern)
		if (nameMatch) then return false, "invalid_characters" end
		
		local tagMatch = tag:match(VoidFactions.Settings.Hardcoded.FactionTagPattern)
		if (tagMatch) then return false, "invalid_characters" end
	end

    if (nameLength < 3) then return false, "nameShort" end
	if (VoidFactions.Settings:IsStaticFactions()) then
    	if (maxMembers > 65534) then return false, "maxMembersLimit" end
	else
		if (nameLength > 25) then return false, "nameLong" end
		if (!VoidFactions.Config.NametagsDisabled and tagLength < 2) then return false, "tagShort" end
		if (!VoidFactions.Config.NametagsDisabled and tagLength > tonumber(VoidFactions.Config.MaxTagLength)) then return false, "tagLong" end
	end
    
    return true
end

-- Class

local FACTION_CLASS = {}
FACTION_CLASS.__index = FACTION_CLASS

function FACTION_CLASS:New(id, name, logo, color, xp, level, parentFaction, maxMembers, tag, inviteRequired, canCaptureTerritory, showBoard, isDefaultFaction, description, money)
	local newObject = setmetatable({}, FACTION_CLASS)
		newObject.id = id
		newObject.name = name
		newObject.description = description
		newObject.logo = logo
		newObject.color = color

		newObject.money = money or 0

		newObject.tag = tag

		newObject.ranks = nil
		newObject.members = nil
		newObject.upgrades = SERVER and {} or nil
		newObject.deposits = nil
		newObject.transactions = nil
		newObject.rewardValues = nil

		newObject.factionRewards = {} -- only serverside

		newObject.inviteRequired = inviteRequired or false
		newObject.canCaptureTerritory = canCaptureTerritory or false
		newObject.showBoard = showBoard or false
		newObject.isDefaultFaction = isDefaultFaction or false

		newObject.requiredUsergroups = {}

		newObject.maxMembers = maxMembers

		newObject.factionRank = nil -- nothing to do with member ranks - its the position in leaderboard
		
		newObject.xp = xp or 0
		newObject.level = level or 0
		newObject.spawnPos = spawnPos or nil
		newObject.parentFaction = parentFaction or nil

		newObject.spentUpgradePoints = 0
	return newObject
end

-- Static changers

function FACTION_CLASS:SetRequiredUsergroups(tbl)
	self.requiredUsergroups = tbl
end

function FACTION_CLASS:SetSpentUpgradePoints(n)
	self.spentUpgradePoints = n
end

function FACTION_CLASS:SetTag(tag)
	self.tag = tag
end

function FACTION_CLASS:SetFactionRanking(rank)
	self.factionRank = rank
end

function FACTION_CLASS:SetUpgrades(upgrades)
	self.upgrades = upgrades
end

function FACTION_CLASS:SetFactionRewards(rewards)
	self.factionRewards = rewards
end

function FACTION_CLASS:SetTransactions(transactions)
	self.transactions = transactions
end

function FACTION_CLASS:SetDeposits(deposits)
	self.deposits = deposits
end

function FACTION_CLASS:SetRewardValues(rewardValues)
	self.rewardValues = rewardValues
end

-- This is for preloading members!
function FACTION_CLASS:SetPreloaded(b)
	self.isPreloaded = b
end

function FACTION_CLASS:SetMaxMembers(max)
	self.maxMembers = max
end

function FACTION_CLASS:SetMemberCount(count)
	self.memberCount = count
end

function FACTION_CLASS:SetDescription(desc)
	self.description = desc
end

function FACTION_CLASS:SetMoney(money)
	self.money = money
end

function FACTION_CLASS:SetLowestRankMemberCount(count)
	self.lowestRankMemberCount = count
end

function FACTION_CLASS:SetMembers(members)
	self.members = members
end

function FACTION_CLASS:SetRanks(ranks)
	self.ranks = ranks
end

function FACTION_CLASS:SetLogo(logo)
	self.logo = logo
end

function FACTION_CLASS:ChangeName(newName)
	self.name = newName
end

function FACTION_CLASS:ChangeLogo(newLogo)
	self.logo = newLogo
end

function FACTION_CLASS:ChangeColor(newColor)
	self.color = newColor
end

function FACTION_CLASS:ChangeSpawnPos(newSpawnPos)
	self.spawnPos = newSpawnPos
end

function FACTION_CLASS:ChangeParentFaction(newParentFaction)
	self.parentFaction = newParentFaction
end

function FACTION_CLASS:SetInviteRequired(b)
	self.inviteRequired = b
end

function FACTION_CLASS:SetCanCaptureTerritory(b)
	self.canCaptureTerritory = b
end

function FACTION_CLASS:SetShowBoard(b)
	self.showBoard = b
end

function FACTION_CLASS:SetIsDefaultFaction(b)
	self.isDefaultFaction = b
end


-- Util functions

-- For dynamic factions
function FACTION_CLASS:GetMaxMembers()
	if (VoidFactions.Settings:IsStaticFactions()) then
		return self.maxMembers 
	end

	-- Calculate max members by upgrades
	return VoidFactions.Config.DefaultMaxMembers + self:SumOfUpgradeValues("upgr_maxmembers")
end

-- Don't confuse upgrade points (number) with upgrade points (skill tree) :D
function FACTION_CLASS:GetUpgradePoints()
	-- Calculate by current level and purchased upgrades
	return self.level - self.spentUpgradePoints - 1
end

function FACTION_CLASS:GetMaxItems()
	-- Calculate max items by upgrades
	return VoidFactions.Config.DefaultMaxItems + self:SumOfUpgradeValues("upgr_maxitems")
end

function FACTION_CLASS:GetSubfactions()
	if (VoidFactions.Settings:IsDynamicFactions()) then return {} end
	local tbl = SERVER and VoidFactions.Factions or VoidFactions.LoadedFactions
	local result = {}
	for k, v in pairs(tbl or {}) do
		if (v.parentFaction and v.parentFaction.id == self.id) then
			result[v.id] = v
		end
		if (v.parentFaction and v.parentFaction.parentFaction and v.parentFaction.parentFaction.id == self.id) then
			result[v.id] = v
		end
	end
	return result
end

function FACTION_CLASS:GetRootFaction()
	return self.parentFaction and self.parentFaction.parentFaction or self.parentFaction or self
end

-- Not to be confused with the faction XP level!!!! It depends on subfactions
function FACTION_CLASS:GetFactionLevel()
	local level = 0
	-- Root
	if (!self.parentFaction) then
		level = 1
	end
	-- Faction
	if (self.parentFaction) then
		level = 2
	end
	-- Subfaction
	if (self.parentFaction and self.parentFaction.parentFaction) then
		level = 3
	end
	return level
end

function FACTION_CLASS:GetLowestRank()
	local res = nil
	for id, rank in SortedPairsByMemberValue(self.ranks or {}, "weight") do
		res = rank
	end
	return res
end

function FACTION_CLASS:GetNextRank(_rank)
	local isNext = false
	for id, rank in SortedPairsByMemberValue(self.ranks or {}, "weight", true) do
		if (isNext) then
			if (rank.weight >= _rank.weight) then return nil end
			return rank
		end
		if (rank.id == _rank.id) then
			isNext = true
		end
	end
end

function FACTION_CLASS:GetPrevRank(_rank)
	local isNext = false
	for id, rank in SortedPairsByMemberValue(self.ranks or {}, "weight", false) do
		if (isNext) then
			if (rank.weight <= _rank.weight) then return nil end
			return rank
		end
		if (rank.id == _rank.id) then
			isNext = true
		end
	end
end

function FACTION_CLASS:NotifyMembers(upper, text, color, time)
	for k, member in pairs(self.members or {}) do
		local ply = member.ply
		if (IsValid(ply)) then
			VoidLib.Notify(ply, upper, text, color, time)
		end
	end
end

function FACTION_CLASS:GetUpgradeValue(id)
	for k, v in pairs(self.upgrades) do
		local upgradePoint = VoidFactions.UpgradePoints.List[k]
		if (!upgradePoint) then continue end

		if (k == id) then
			return upgradePoint.upgrade.value
		end
	end
end

function FACTION_CLASS:GetParentFactions()
	local factions = {}
	if (self.parentFaction) then
		factions[#factions + 1] = self.parentFaction

		local secondLevelFaction = self.parentFaction.parentFaction
		if (secondLevelFaction) then
			factions[#factions + 1] = secondLevelFaction

			local thirdLevelFaction = self.parentFaction.parentFaction.parentFaction
			if (thirdLevelFaction) then
				factions[#factions + 1] = thirdLevelFaction
			end
		end
	end

	return factions
end

function FACTION_CLASS:GetUpgradePointsByName(name)
	if (VoidFactions.Settings:IsStaticFactions() and !VoidFactions.Config.UpgradesEnabled) then return {} end
	local points = {}
	for k, v in pairs(self.upgrades or {}) do
		local upgradePoint = VoidFactions.UpgradePoints.List[k]
		if (!upgradePoint) then continue end
		if (!upgradePoint.upgrade) then continue end

		if (upgradePoint.upgrade.module.name == name) then
			points[#points + 1] = upgradePoint
		end
	end
	return points
end

function FACTION_CLASS:SumOfUpgradeValues(name)
	local sum = 0
	local points = self:GetUpgradePointsByName(name)
	for k, v in ipairs(points) do
		sum = sum + v.upgrade.value
	end
	return sum
end

function FACTION_CLASS:HasUpgrade(name)
	for k, v in pairs(self.upgrades) do
		local upgradePoint = VoidFactions.UpgradePoints.List[k]
		if (!upgradePoint) then continue end

		if (upgradePoint.upgrade and upgradePoint.upgrade.module.name == name) then
			return true
		end
	end

	return false
end

function FACTION_CLASS:HasMember(member)
	for k, _member in pairs(self.members) do
		if (member == _member) then return true end
	end
	return false
end

-- Dynamic changers

function FACTION_CLASS:AddXP(xp)
	if (!self.xp) then return end
	if (!xp) then return end
	if (VoidFactions.Config.DisableXP) then return end

	local intOverrideXP = hook.Run("VoidFactions.XP.OnGainXP", self, xp)
	if (intOverrideXP and isnumber(intOverrideXP)) then
		xp = intOverrideXP
	end
	
	local xpSum = self.xp + xp
	local requiredXP = 0

	-- Find how many times would the xp itself level up the member
	local allLevelsFound = false
	local totalXP = 0
	local prevLevel = self.level
	local remainingXP = 0
	while (!allLevelsFound) do
		local lvlRequiredXP = VoidFactions.XP:GetRequiredXP(prevLevel)

		requiredXP = requiredXP + lvlRequiredXP
		if (totalXP + lvlRequiredXP > xp) then
			remainingXP = (totalXP + lvlRequiredXP) - xp
			allLevelsFound = true
			break
		else
			totalXP = totalXP + lvlRequiredXP
			prevLevel = prevLevel + 1
		end
	end

	local lvlDiff = prevLevel - self.level
	if (lvlDiff > 0) then
		didLevelUp = true
		self:AddLevels(lvlDiff)
		self:LevelUp(true)

		self.xp = remainingXP
	else
		-- If the xp itself didn't level up the member, then the member can level up only once.
		if (xpSum >= requiredXP) then
			didLevelUp = true
			self:LevelUp()
			self.xp = xpSum - requiredXP
		else
			self.xp = xpSum
		end
	end

	VoidFactions.Faction:UpdateFactionXP(self, didLevelUp)
    self:SaveDynamic()
end

function FACTION_CLASS:SetXP(newXP)
	self.xp = newXP
end

function FACTION_CLASS:LevelUp()
	self:AddLevels(1)
end

function FACTION_CLASS:AddLevels(level)
	self.level = self.level + level
end

function FACTION_CLASS:SetLevel(newLevel)
	self.level = newLevel
end

-- Networking
function FACTION_CLASS:NetworkToPlayer(ply)
	if (CLIENT) then return end
	VoidFactions.PrintDebug("Networking faction info to player!")

	VoidFactions.Faction:NetworkToPlayer(ply, self)
end

-- NOT TO BE CONFUSED WITH STATIC AND DYNAMIC FACTIONS!
-- Save static info to database (name, logo, color, spawnPos, parentFaction)
function FACTION_CLASS:SaveStatic()
	if (!SERVER) then return end
	VoidFactions.SQL:SaveFactionInfo(self)
end

-- Save dynamic info to database (xp, level)
function FACTION_CLASS:SaveDynamic()
	if (!SERVER) then return end
	VoidFactions.SQL:SaveFactionXP(self)
end

-- Global functions

function VoidFactions.Faction:InitFaction(...)
	local faction = FACTION_CLASS:New(...)
	return faction
end
