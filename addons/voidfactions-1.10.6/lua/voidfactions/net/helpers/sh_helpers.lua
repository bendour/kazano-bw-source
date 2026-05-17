-- Enums

VoidFactions.Transactions = VoidFactions.Transactions or {}
VoidFactions.Rewards = VoidFactions.Rewards or {}

VoidFactions.Faction.Enums = {
	RANKS_UPDATE = 1,
	MEMBERS_UPDATE = 2,
	DEPOSITS_UPDATE = 3,
	XP_UPDATE = 4,
	UPGRADES_UPDATE = 5,
	REWARDS_UPDATE = 6
}

VoidFactions.Member.PromoteEnums = {
	PROMOTE = 1,
	DEMOTE = 2,
	RANK_UPDATE = 3
}

VoidFactions.CapturePoints.UpdateEnums = {
	CAPTURE_CHANGE = 1,
	CAPTURE_RESULT = 2,
	POINT_CONTESTED = 3,
	POINT_PAUSED = 4,
	CAPTURE_FACTIONCHANGE = 5
}

-- Helper functions

local function shallowCopy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

-- Point relationships

function VoidFactions.Upgrades:WriteRelationships(relations)
	net.WriteUInt(#relations, 10)
	for k, v in ipairs(relations) do
		net.WriteUInt(v.id, 10)
	end
end

function VoidFactions.Upgrades:ReadRelationships()
	local length = net.ReadUInt(10)
	local relations = {}
	for i = 1, length do
		relations[i] = net.ReadUInt(10)
	end

	return relations
end


-- Upgrade points

function VoidFactions.Upgrades:WritePoint(point)
	net.WriteUInt(point.id, 10)
	net.WriteUInt(point.upgrade.id, 10)
	net.WriteUInt(point.posX, 16)
	net.WriteUInt(point.posY, 16)

	VoidFactions.Upgrades:WriteRelationships(point.to)
end

function VoidFactions.Upgrades:ReadPoint()
	local id = net.ReadUInt(10)
	local upgradeId = net.ReadUInt(10)

	local posX = net.ReadUInt(16)
	local posY = net.ReadUInt(16)

	local upgrade = VoidFactions.Upgrades.Custom[upgradeId]

	local point = nil
	if (VoidFactions.UpgradePoints.List and VoidFactions.UpgradePoints.List[id]) then
		point = VoidFactions.UpgradePoints.List[id]
		point:SetPos(posX, posY)
	else
		point = VoidFactions.UpgradePoints:New(id, upgrade, posX, posY)
	end

	local relations = VoidFactions.Upgrades:ReadRelationships()
	point.toIds = relations

	return point
end

-- Global rewards

function VoidFactions.Rewards:WriteReward(reward)
	net.WriteUInt(reward.id, 10)
	net.WriteString(reward.name)
	net.WriteString(reward.module.name)

	net.WriteInt(reward.requiredValue, 32)

	net.WriteUInt(reward.money, 32)
	net.WriteUInt(reward.xp, 32)

	net.WriteString(reward.icon)
end

function VoidFactions.Rewards:ReadReward()
	local id = net.ReadUInt(10)
	local name = net.ReadString()
	local moduleName = net.ReadString()
	local requiredValue = net.ReadInt(32)
	local money = net.ReadUInt(32)
	local xp = net.ReadUInt(32)

	local icon = net.ReadString()

	local module = VoidFactions.RewardModules.List[moduleName]

	local reward = nil
	if (VoidFactions.Rewards.List and VoidFactions.Rewards.List[id]) then
		reward = VoidFactions.Rewards.List[id]

		reward:SetName(name)
		reward:SetModule(module)
		reward:SetRequiredValue(requiredValue)
		reward:SetMoneyReward(money)
		reward:SetXPReward(xp)
		reward:SetIcon(icon)
	else
		reward = VoidFactions.Rewards:New(id, name, module, requiredValue, money, xp, icon)
	end

	return reward
end

-- Faction reward values

function VoidFactions.FactionRewards:WriteReward(reward)
	net.WriteString(reward.module.name)
	net.WriteInt(reward.value, 32)
end

function VoidFactions.FactionRewards:ReadReward(faction)
	local name = net.ReadString()
	local value = net.ReadInt(32)

	local module = VoidFactions.RewardModules.List[name]

	local reward = nil
	if (faction.rewardValues and faction.rewardValues[name]) then
		reward = faction.rewardValues[name]
		reward:SetValue(value)
	else
		reward = VoidFactions.FactionRewards:New(module, value)
	end

	return reward
end

-- Upgrades (custom)

function VoidFactions.Upgrades:WriteUpgrade(upgrade)
	net.WriteUInt(upgrade.id, 10)
	net.WriteString(upgrade.name)
	net.WriteString(upgrade.module.name)
	net.WriteString(upgrade.value)
	net.WriteString(upgrade.currency.name)
	net.WriteUInt(upgrade.cost, 32)
	net.WriteString(upgrade.icon)
end

function VoidFactions.Upgrades:ReadUpgrade()
	local id = net.ReadUInt(10)
	local name = net.ReadString()
	local moduleName = net.ReadString()
	local value = net.ReadString()
	local currencyName = net.ReadString()
	local cost = net.ReadUInt(32)
	local icon = net.ReadString()

	local module = VoidFactions.Upgrades.Modules[moduleName]
	local currency = VoidFactions.Currencies.List[currencyName]

	local upgrade = nil
	if (VoidFactions.Upgrades.Custom and VoidFactions.Upgrades.Custom[id]) then
		upgrade = VoidFactions.Upgrades.Custom[id]

		upgrade:SetName(name)
		upgrade:SetModule(module)
		upgrade:SetValue(value)
		upgrade:SetCurrency(currency)
		upgrade:SetCost(cost)
		upgrade:SetIcon(icon)
	else
		upgrade = VoidFactions.CustomUpgrades:New(id, name, module, value, currency, cost, icon)
	end

	return upgrade
end

-- Transactions

function VoidFactions.Transactions:WriteTransaction(transaction)
	net.WriteUInt(transaction.time or 0, 32)
	net.WriteString(transaction.sid)
	net.WriteInt(transaction.difference, 32)
	net.WriteString(transaction.itemClass or "")
end

function VoidFactions.Transactions:ReadTransaction(faction)
	local time = net.ReadUInt(32)
	local sid = net.ReadString()
	local diff = net.ReadInt(32)
	local itemClass = net.ReadString()

	local transaction = VoidFactions.TransactionHistory:New(time, faction, sid, diff, itemClass)
	if (itemClass == "money") then
		transaction:SetIsMoney()
	end

	faction.transactions[#faction.transactions + 1] = transaction
	return transaction
end

-- Deposit items

function VoidFactions.DepositItem:WriteItem(item)
	net.WriteUInt(item.id, 20)
	net.WriteString(item.class)
	net.WriteString(item.dropEnt)
	net.WriteString(item.model or "")
	net.WriteTable(item.data or {})
	net.WriteBool(item.isExternal or false)
end

function VoidFactions.DepositItem:ReadItem(faction)
	local id = net.ReadUInt(20)
	local class = net.ReadString()
	local dropEnt = net.ReadString()
	local model = net.ReadString()
	local data = net.ReadTable()
	local isExternal = net.ReadBool()

	return VoidFactions.DepositItem:New(id, faction, class, dropEnt, model, data, isExternal)
end

-- Capture points

function VoidFactions.CapturePoints:WriteCapturePoint(point)
	net.WriteUInt(point.id, 6) -- 63 capture points is more than enough
	net.WriteUInt(point.radius, 16)
	net.WriteVector(point.pos)

	net.WriteUInt(point.captureStart or 0, 32)

	net.WriteBool(point.captureFaction and true or false)
	if (point.captureFaction) then
		net.WriteUInt(point.captureFaction.id, 20)
	end

	net.WriteUInt(#point.capturingPlayers, 7)
	for k, v in ipairs(point.capturingPlayers) do
		net.WriteEntity(v)
	end
end

function VoidFactions.CapturePoints:ReadCapturePoint()
	local id = net.ReadUInt(6)
	local radius = net.ReadUInt(16)
	local pos = net.ReadVector()

	local captureStart = net.ReadUInt(32)

	local captureFaction = nil
	if (net.ReadBool()) then
		local factionId = net.ReadUInt(20)
		captureFaction = VoidFactions.LoadedFactions[factionId]
	end

	local capturingPlayers = {}
	local capturingPlayersCount = net.ReadUInt(7)
	for i = 1, capturingPlayersCount do
		local ply = net.ReadEntity()
		capturingPlayers[#capturingPlayers + 1] = ply
	end

	local pointsTable = VoidFactions.PointsTable[id]
	if (pointsTable) then
		pointsTable:SetRadius(radius)
		pointsTable:SetPos(pos)
	else
		local capturePoint = VoidFactions.CapturePoints:InitCapturePoint(id, pos, radius)
		VoidFactions.PointsTable[id] = capturePoint

		pointsTable = capturePoint
	end

	pointsTable:SetCapturingPlayers(capturingPlayers)
	pointsTable:SetFaction(captureFaction)
	pointsTable:SetCaptureStart(captureStart)

	VoidFactions.PrintDebug("Read capture point ID " .. id .. "!")

	return pointsTable
end

-- Factions

function VoidFactions.Faction:WriteFaction(faction, noRanksMembers, onlyRanks, dontWriteParentFactions, ply, bPromoteIteration)
	net.WriteUInt(faction.id, 20)
	net.WriteString(faction.name)

	net.WriteBool(faction.isPreloaded and true or false)

	net.WriteBool(faction.description and true or false)
	if (faction.description) then
		net.WriteString(faction.description)
	end

	net.WriteBool(faction.logo and true or false)
	if (faction.logo) then
		net.WriteString(faction.logo)
	end

	net.WriteColor(faction.color)
	net.WriteString(faction.tag or "")

	net.WriteUInt(faction.memberCount or 0, 16)
	net.WriteUInt(faction.lowestRankMemberCount or 0, 16)

	if (VoidFactions.Settings:IsDynamicFactions()) then
		net.WriteUInt(faction.xp or 0, 32)
		net.WriteUInt(faction.level or 0, 10)

		net.WriteUInt(faction.money or 0, 32)
		net.WriteUInt(faction.spentUpgradePoints or 0, 24)
	end

	if (VoidFactions.Settings:IsStaticFactions()) then
		net.WriteUInt(faction.maxMembers or 0, 16)

		net.WriteUInt(#faction.requiredUsergroups, 16)
		for k, v in ipairs(faction.requiredUsergroups) do
			net.WriteString(v)
		end
	end

	local shouldWriteParentFaction = faction.parentFaction and !dontWriteParentFactions
	net.WriteBool(shouldWriteParentFaction and true or false)
	if (shouldWriteParentFaction) then
		-- net.WriteUInt(faction.parentFaction.id, 20)
		VoidFactions.Faction:WriteFaction(faction.parentFaction, false, true)
	end

	net.WriteBool(faction.inviteRequired)
	if (VoidFactions.Settings:IsStaticFactions()) then
		net.WriteBool(faction.canCaptureTerritory)
		net.WriteBool(faction.showBoard)
		net.WriteBool(faction.isDefaultFaction)
	end

	net.WriteBool(false)
	net.WriteBool(!noRanksMembers)

	if (!noRanksMembers) then

		-- Write ranks
		net.WriteUInt(table.Count(faction.ranks or {}), 7)
		for id, rank in pairs(faction.ranks or {}) do
			VoidFactions.Rank:WriteRank(rank, bPromoteIteration)
		end

		-- Custom upgrades
		net.WriteUInt(table.Count(VoidFactions.Upgrades.Custom or {}), 10)
		for k, upgrade in pairs(VoidFactions.Upgrades.Custom or {}) do
			VoidFactions.Upgrades:WriteUpgrade(upgrade)
		end

		-- Rewards
		net.WriteUInt(table.Count(faction.rewardValues or {}), 10)
		for k, reward in pairs(faction.rewardValues or {}) do
			VoidFactions.FactionRewards:WriteReward(reward)
		end

		-- Points
		net.WriteUInt(table.Count(VoidFactions.UpgradePoints.List or {}), 10)
		for k, point in pairs(VoidFactions.UpgradePoints.List or {}) do
			VoidFactions.Upgrades:WritePoint(point)
		end

		-- Unlocked upgrades
		net.WriteUInt(table.Count(faction.upgrades or {}), 10)
		for upgrade, _ in pairs(faction.upgrades or {}) do
			net.WriteUInt(upgrade, 10)
		end

		net.WriteBool(!onlyRanks)
		if (!onlyRanks) then
			-- Write members
			local membersToWrite = {}

			if (!faction.isPreloaded) then
				for k, v in ipairs(faction.members or {}) do
					if (!IsValid(v.ply)) then continue end
					table.insert(membersToWrite, v)
				end
			else
				membersToWrite = faction.members
			end

			net.WriteUInt(membersToWrite and #membersToWrite or 0, 16)
			for k, member in ipairs(membersToWrite or {}) do
				VoidFactions.Member:WriteMember(member, true)
			end
		end

	end
	
end

function VoidFactions.Faction:ReadFaction(noUpdate)
	local id = net.ReadUInt(20)
	local name = net.ReadString()

	local isPreloaded = net.ReadBool()

	local description = nil
	if (net.ReadBool()) then
		description = net.ReadString()
	end

	local logo = nil
	if (net.ReadBool()) then
		logo = net.ReadString()
	end

	local color = net.ReadColor()
	local tag = net.ReadString()

	local memberCount = net.ReadUInt(16)
	local lowestRankMemberCount = net.ReadUInt(16)

	local xp = nil
	local level = nil
	local money = nil
	local upgrPoints = 0
	if (VoidFactions.Settings:IsDynamicFactions()) then
		xp = net.ReadUInt(32)
		level = net.ReadUInt(10)
		money = net.ReadUInt(32)
		upgrPoints = net.ReadUInt(24)
	end

	local maxMembers = nil
	local tblRequiredGroups = {}
	if (VoidFactions.Settings:IsStaticFactions()) then
		maxMembers = net.ReadUInt(16)

		local intLen = net.ReadUInt(16)
		for i = 1, intLen do
			tblRequiredGroups[i] = net.ReadString()
		end
	end

	local parentFaction = nil
	if (net.ReadBool()) then
		-- parentFaction = net.ReadUInt(20)
		parentFaction = VoidFactions.Faction:ReadFaction()
	end

	local inviteRequired = net.ReadBool()

	local canCaptureTerritory = nil
	local showBoard = nil
	local isDefaultFaction = nil
	if (VoidFactions.Settings:IsStaticFactions()) then
		canCaptureTerritory = net.ReadBool()
		showBoard = net.ReadBool()
		isDefaultFaction = net.ReadBool()
	end

	-- If we already have a reference, use it
	local faction = VoidFactions.PlayerMember and VoidFactions.PlayerMember.faction
	if (faction and faction.id != id) then
		faction = nil
	end

	if (!faction) then
		faction = VoidFactions.LoadedFactions[id]
	end

	if (!faction or noUpdate) then
		faction = VoidFactions.Faction:InitFaction(id, name, logo, color, xp, level, nil, maxMembers, tag, inviteRequired, canCaptureTerritory, showBoard, isDefaultFaction, description, money)
		faction:SetMemberCount(memberCount)
		faction:SetSpentUpgradePoints(upgrPoints)
		faction:SetRequiredUsergroups(tblRequiredGroups)
		faction:SetLowestRankMemberCount(lowestRankMemberCount)
	else
		VoidFactions.PrintDebug("Faction object already exists, using it")
		faction:ChangeName(name)
		faction:ChangeLogo(logo)
		faction:ChangeColor(color)
		faction:SetXP(xp)
		faction:SetLevel(level)
		faction:SetMaxMembers(maxMembers)
		faction:SetTag(tag)
		faction:SetMemberCount(memberCount)
		faction:SetInviteRequired(inviteRequired)
		faction:SetCanCaptureTerritory(canCaptureTerritory)
		faction:SetShowBoard(showBoard)
		faction:SetIsDefaultFaction(isDefaultFaction)
		faction:SetDescription(description)
		faction:SetMoney(money)
		faction:SetSpentUpgradePoints(upgrPoints)
		faction:SetRequiredUsergroups(tblRequiredGroups)
		faction:SetLowestRankMemberCount(lowestRankMemberCount)
	end
	faction.parentFaction = parentFaction or faction.parentFaction
	faction.isPreloaded = isPreloaded

	if (net.ReadBool()) then
		-- only ranks
		local rankCount = net.ReadUInt(7)
		VoidFactions.PrintDebug("Received rank count: " .. rankCount)
		local ranks = {}
		for i = 1, rankCount do
			local rank = VoidFactions.Rank:ReadRank(faction)
			ranks[tonumber(rank.id)] = rank

			VoidFactions.PrintDebug("Read rank id " .. rank.id .. "!")
		end

		faction:SetRanks(ranks)
	end

	-- Is sending ranks and factions?
	if (net.ReadBool()) then

		-- Read ranks
		local rankCount = net.ReadUInt(7)
		VoidFactions.PrintDebug("Received rank count: " .. rankCount)
		local ranks = {}
		for i = 1, rankCount do
			local rank = VoidFactions.Rank:ReadRank(faction)
			ranks[tonumber(rank.id)] = rank

			VoidFactions.PrintDebug("Read rank id " .. rank.id .. "!")
		end

		faction:SetRanks(ranks)

		-- Upgrades
		local upgradeLength = net.ReadUInt(10)

		local upgrades = {}
		for i = 1, upgradeLength do
			local upgrade = VoidFactions.Upgrades:ReadUpgrade()
			upgrades[upgrade.id] = upgrade
		end

		VoidFactions.Upgrades.Custom = upgrades

		-- Reward values
		local rewardsLength = net.ReadUInt(10)

		local rewards = {}
		for i = 1, rewardsLength do
			local reward = VoidFactions.FactionRewards:ReadReward(faction)
			rewards[reward.module.name] = reward
		end

		faction:SetRewardValues(rewards)


		-- Points
		local pointLength = net.ReadUInt(10)

		local points = {}
		local pointsKeys = {}
		for i = 1, pointLength do
			local point = VoidFactions.Upgrades:ReadPoint()
			points[i] = point
			pointsKeys[point.id] = point
		end

		-- Assign the to's Tables
		for k, v in ipairs(points) do
			v.to = {}
			for _, to in ipairs(v.toIds) do
				local toPoint = pointsKeys[to]
				v:AddTo(toPoint)
			end
		end

		VoidFactions.UpgradePoints.List = pointsKeys

		local upgradeCount = net.ReadUInt(10)
		local upgrades = {}
		for i = 1, upgradeCount do
			local upgrade = net.ReadUInt(10)
			upgrades[upgrade] = true
		end

		faction:SetUpgrades(upgrades)

		

		if (net.ReadBool()) then
			-- Read members
			local memberCount = net.ReadUInt(16)
			local members = {}
			for i = 1, memberCount do
				local member = VoidFactions.Member:ReadMember(false, faction)
				members[i] = member
			end

			faction:SetMembers(members)
		end

	end

	return faction
end

-- Members

function VoidFactions.Member:WriteMember(member, onlyMember)

	if (member.lastPromotion == "NULL") then
		member.lastPromotion = 0
	end

	net.WriteString(member.sid)

	if (!VoidFactions.Settings:IsDynamicFactions()) then
		net.WriteUInt(member.xp or 0, 32)
		net.WriteUInt(member.level or 0, 10)
	end

	net.WriteUInt(member.playtime or 0, 20)
	net.WriteUInt(member.lastPromotion or 0, 32)
	net.WriteUInt(member.factionJoined or 0, 32)
	net.WriteEntity(member.ply)

	net.WriteUInt(member.lastSeen or 0, 32)
	
	if (!VoidFactions.Settings:IsDynamicFactions()) then
		net.WriteBool(member.defaultFactionId and true or false)
		if (member.defaultFactionId) then
			net.WriteUInt(member.defaultFactionId, 20)
		end
	end

	if (!VoidFactions.Settings:IsDynamicFactions()) then
		net.WriteBool(member.name and true or false)
		if (member.name) then
			net.WriteString(member.name)
		end
	end

	net.WriteBool(member.faction and member.faction.id and member.rank and true or false)
	if (member.faction and member.faction.id and member.rank) then
		net.WriteUInt(member.rank.id, 20)
		if (!VoidFactions.Settings:IsDynamicFactions()) then
			net.WriteUInt(member.job or 0, 20)
		end
	end

	net.WriteBool(member.faction and member.faction.id and !onlyMember and true or false) -- Is sending faction?
	if (member.faction and member.faction.id and !onlyMember) then
		VoidFactions.PrintDebug("Writing member's faction!")
		VoidFactions.Faction:WriteFaction(member.faction)
	end

	net.WriteBool(!onlyMember and true or false)
end

function VoidFactions.Member:ReadMember(member, faction)
	local sid = net.ReadString()

	local xp = 0
	local level = 0
	if (!VoidFactions.Settings:IsDynamicFactions()) then
		xp = net.ReadUInt(32)
		level = net.ReadUInt(10)
	end

	local playtime = net.ReadUInt(20)

	local lastPromotion = net.ReadUInt(32)
	local factionJoined = net.ReadUInt(32)
	local ply = net.ReadEntity()

	local lastSeen = net.ReadUInt(32)

	local defaultFactionId = nil
	if (!VoidFactions.Settings:IsDynamicFactions() and net.ReadBool()) then
		defaultFactionId = net.ReadUInt(20)
	end

	local name = nil
	if (!VoidFactions.Settings:IsDynamicFactions() and net.ReadBool()) then
		name = net.ReadString()
	end


	local readingFromFaction = faction and true or false

	-- Is sending rank?
	local rank = nil
	local readingRank = net.ReadBool()
	local rankId = nil
	local job = nil

	local wasReadingFaction = false

	if (readingRank) then
		VoidFactions.PrintDebug("Reading rank from member....")
		rankId = net.ReadUInt(20)
		if (!VoidFactions.Settings:IsDynamicFactions()) then
			job = net.ReadUInt(20)
		end
	end
	
	if (net.ReadBool()) then -- If is sending faction, load it
		VoidFactions.PrintDebug("Reading faction from member!")
		faction = VoidFactions.Faction:ReadFaction()
	end

	if (net.ReadBool()) then
		wasReadingFaction = true
	end

	if (faction and faction.ranks and readingRank) then
		rank = faction.ranks[rankId]
	end

	-- Try to find a reference to update
	if (!member) then
		if (VoidFactions.PlayerMember and VoidFactions.PlayerMember.sid == sid) then
			member = VoidFactions.PlayerMember
		else
			for k, _member in ipairs(faction and (faction.members or {}) or {}) do
				if (_member.sid == sid) then
					member = _member
				end
			end
		end
	end


	-- If reference found, then update it
	if (member) then
		member:SetXP(xp)
		member:SetLevel(level)
		member:SetPlaytime(playtime)
		member:SetLastPromotion(lastPromotion)
		member:SetLastSeen(lastSeen)
		member:SetDefaultFactionId(defaultFactionId)
		member:SetFactionJoined(factionJoined)

		if (wasReadingFaction) then
			member:SetFaction(faction)
			member:SetRank(rank)
			member:SetJob(job)
		end

		if (name) then
			member:SetName(name)
		end

		return member
	else
		-- Otherwise just make a new reference
		local member = VoidFactions.Member:InitMember(sid, ply, faction, xp, level, playtime, lastPromotion, rank, job, name, lastSeen, defaultFactionId, nil, factionJoined)
		return member
	end

end

-- Jobs

function VoidFactions.Rank:WriteJobs(tbl)
	net.WriteUInt(#tbl, 5)
	for k, v in ipairs(tbl) do
		net.WriteUInt(v, 20)
	end
end

function VoidFactions.Rank:ReadJobs()
	local length = net.ReadUInt(5)
	local jobs = {}
	for i = 1, length do
		jobs[i] = net.ReadUInt(20)
	end
	return jobs
end

-- Ranks

function VoidFactions.Rank:WriteRank(rank, bDontWritePromotes)
	net.WriteUInt(rank.id, 20)
	net.WriteUInt(rank.weight, 32)
	net.WriteString(rank.name)
	net.WriteString(rank.tag or "")

	net.WriteBool(rank.canInvite)
	net.WriteUInt(rank.canPromote, 2)
	net.WriteBool(rank.canPurchasePerks)
	net.WriteUInt(rank.kickMembers, 2)
	net.WriteBool(rank.manageFaction)
	net.WriteUInt(rank.canDemote or 0, 2)


	net.WriteUInt(rank.maxMembers or 0, 16)
	net.WriteUInt(rank.minLevel or 0, 12)

	net.WriteBool(rank.jobs and true or false)
	if (rank.jobs) then
		VoidFactions.Rank:WriteJobs(rank.jobs)
	end

	if (VoidFactions.Settings:IsStaticFactions()) then
		net.WriteUInt(rank.autoPromoteLevel, 12)

		net.WriteBool(!bDontWritePromotes and true or false)
		if (!bDontWritePromotes) then
			local promoteDefaults = shallowCopy(rank.promoteDefault or {})
			local shouldPromoteDefault = rank.faction != nil and (rank.faction != "template" and promoteDefaults[rank.faction.id] or false) or false
			net.WriteBool(shouldPromoteDefault and true or false) -- is the same faction??
			if (shouldPromoteDefault) then
				table.remove(promoteDefaults, rank.faction.id)
			end
			net.WriteUInt(table.Count(promoteDefaults), 20)
			for k, faction in pairs(promoteDefaults) do
				VoidFactions.Faction:WriteFaction(faction, false, true, true, nil, true)
			end
		end
	end

	if (VoidFactions.Settings:IsDynamicFactions() or VoidFactions.Config.DepositEnabled) then
		net.WriteBool(rank.canWithdrawMoney)
		net.WriteBool(rank.canDepositMoney)
		net.WriteBool(rank.canWithdrawItems)
		net.WriteBool(rank.canDepositItems)
	end
end


-- If called without faction, the existing members faction will be used!!!
function VoidFactions.Rank:ReadRank(faction, noPass)
	local id = net.ReadUInt(20)
	local weight = net.ReadUInt(32)
	local name = net.ReadString()
	local tag = net.ReadString()

	local canInvite = net.ReadBool()
	local canPromote = net.ReadUInt(2)
	local canPurchasePerks = net.ReadBool()
	local kickMembers = net.ReadUInt(2)
	local manageFaction = net.ReadBool()
	local canDemote = net.ReadUInt(2)


	local maxMembers = net.ReadUInt(16)
	local minLevel = net.ReadUInt(12)

	local jobs = nil
	if (net.ReadBool()) then
		jobs = VoidFactions.Rank:ReadJobs()
	end
	
	if (!faction and !noPass) then
		VoidFactions.PrintDebug("Faction not passed to ReadRank, using members current faction")
		faction = VoidFactions.PlayerMember.faction
	end

	local autoPromoteLevel = 0
	local bWritePromotes = false

	local promoteDefault = {}
	if (VoidFactions.Settings:IsStaticFactions()) then
		autoPromoteLevel = net.ReadUInt(12)
		bWritePromotes = net.ReadBool()

		if (bWritePromotes) then
			local isSameFaction = net.ReadBool()
			if (isSameFaction) then
				promoteDefault[faction.id] = faction
			end

			local facLen = net.ReadUInt(20)
			for i = 1, facLen do
				local fac = VoidFactions.Faction:ReadFaction()
				promoteDefault[fac.id] = fac
			end
		end
	end


	local canWithdrawMoney = nil 
	local canDepositMoney = nil
	local canWithdrawItems = nil 
	local canDepositItems = nil
	if (VoidFactions.Settings:IsDynamicFactions() or VoidFactions.Config.DepositEnabled) then
		canWithdrawMoney = net.ReadBool()
		canDepositMoney = net.ReadBool()
		canWithdrawItems = net.ReadBool()
		canDepositItems = net.ReadBool()
	end

	local rankRef = nil
	if (!noPass) then
		rankRef = faction.ranks and faction.ranks[id]
		if (!rankRef) then
			rankRef = VoidFactions.PlayerMember and VoidFactions.PlayerMember.rank
		end
	else
		rankRef = VoidFactions.RankTemplates and VoidFactions.RankTemplates[id]
	end

	-- Use the reference if it exists
	local rank = nil
	if (rankRef and rankRef.id == id) then
		VoidFactions.PrintDebug("Reusing rank reference")
		rank = rankRef
		rank:SetWeight(weight)
		rank:SetName(name)
		rank:SetTag(tag)

		if (bWritePromotes) then
			rank:SetPromoteDefault(promoteDefault)
		end

		rank.canInvite = canInvite
		rank.canPromote = canPromote
		rank.canPurchasePerks = canPurchasePerks
		rank.kickMembers = kickMembers
		rank.manageFaction = manageFaction
		rank.canDemote = canDemote

		rank.canWithdrawItems = canWithdrawItems
		rank.canDepositItems = canDepositItems
		rank.canWithdrawMoney = canWithdrawMoney
		rank.canDepositMoney = canDepositMoney

		rank.autoPromoteLevel = autoPromoteLevel

		rank.maxMembers = maxMembers
		rank:SetJobs(jobs)
		rank:SetMinLevel(minLevel)
	else
		VoidFactions.PrintDebug("Creating new rank object!")
		rank = VoidFactions.Rank:InitRank(id, faction, name, weight, tag, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, jobs, maxMembers, minLevel, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault)
	end

	return rank
	
end
