-- Members table stores all the members
VoidFactions.Members = VoidFactions.Members or {}

VoidFactions.Member = VoidFactions.Member or {}

local L = VoidFactions.Lang.GetPhrase

-- Networking type table

VoidFactions.Member.FieldEnums = {
	["job"] = 1,
	["xp"] = 2,
	["level"] = 3,
	["lastPromotion"] = 4,
	["faction"] = 5,
	["rank"] = 6,
	["defaultFactionId"] = 7,
}

local fe = VoidFactions.Member.FieldEnums

VoidFactions.Member.FieldTypes = {
	[fe.job] = {"UInt", 20},
	[fe.xp] = {"UInt", 32},
	[fe.level] = {"UInt", 10},
	[fe.lastPromotion] = {"UInt", 32},
	[fe.faction] = {"Faction"},
	[fe.rank] = {"Rank"},
	[fe.defaultFactionId] = {"UInt", 20}
}

-- Classes

local MEMBER_CLASS = {}
MEMBER_CLASS.__index = MEMBER_CLASS

function MEMBER_CLASS:New(sid, ply, faction, xp, level, playtime, lastPromotion, rank, job, name, lastSeen, defaultFactionId, autoPromoteDisabled, factionJoined)
	local newObject = setmetatable({}, MEMBER_CLASS)
		newObject.sid = sid -- We have to have an ID here because of offline members and multi-character integrations
		newObject.ply = ply

		newObject.faction = faction

		newObject.job = job

		newObject.xp = xp
		newObject.level = level
		newObject.playtime = playtime
		newObject.lastPromotion = lastPromotion
		newObject.rank = rank

		newObject.lastSeen = lastSeen
		newObject.defaultFactionId = defaultFactionId

		newObject.autoPromoteDisabled = autoPromoteDisabled
		newObject.factionJoined = factionJoined

		-- This is here only for character system support
		newObject.name = name
	return newObject
end

-- Class functions

function MEMBER_CLASS:SetFactionJoined(joined)
	self.factionJoined = joined
end

function MEMBER_CLASS:SetAutoPromoteDisabled(promoteDisabled)
	self.autoPromoteDisabled = promoteDisabled
end

function MEMBER_CLASS:SetLastSeen(lastSeen)
	self.lastSeen = lastSeen
end

function MEMBER_CLASS:SetName(name)
	self.name = name
end

function MEMBER_CLASS:SetFaction(faction)
	self.faction = faction
end

function MEMBER_CLASS:SetJob(job)
	self.job = job
end

function MEMBER_CLASS:SetXP(xp)
	self.xp = xp
end

function MEMBER_CLASS:SetLevel(level)
	self.level = level
end

function MEMBER_CLASS:SetPlaytime(playtime)
	self.playtime = playtime
end

function MEMBER_CLASS:SetDefaultFactionId(id)
	self.defaultFactionId = id
end

function MEMBER_CLASS:SetLastPromotion(lastPromotion)
	self.lastPromotion = lastPromotion
end

function MEMBER_CLASS:SetRank(rank)
	self.rank = rank

	if (rank) then
		self:SetJob(rank.jobs and rank.jobs[1])
	else
		self:SetJob(nil)
	end
end

-- This could be probably implemented in a better way, but it works and it's understandable (for me)
function MEMBER_CLASS:AddXP(xp)
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
	
	local networkTbl = {{"xp", self.xp}}
	if (didLevelUp) then
		networkTbl[2] = {"level", self.level}
	end

	VoidFactions.Member:UpdateMemberFields(self, networkTbl)
	self:SaveDynamic()
	hook.Run("VoidFactions.Member.XPAdded", self, xp)
end

function MEMBER_CLASS:LevelUp(noAdd)
	if (!noAdd) then
		self:AddLevels(1)
	end

	local faction = self.faction
	local rank = self.rank
	if (faction) then
		local nextRank = faction:GetNextRank(rank)
		if (nextRank and rank != nextRank and nextRank.autoPromoteLevel != 0) then
			if (self.level >= nextRank.autoPromoteLevel and !self.autoPromoteDisabled) then
				-- Promote
				VoidFactions.PrintDebug("Promoting member " .. self.sid .. " by autopromote!")

				self:SetRank(nextRank)
				self:SaveStatic()

				VoidFactions.Faction:UpdateFactionMembers(self.faction)

				self:ChangeJob(self.job, true)
				self:NetworkToPlayer()

				VoidLib.Notify(self.ply, L"info", L("youPromoted", nextRank.name), VoidUI.Colors.Blue, 5)
			end
		end
	end

	if (SERVER) then
		VoidLib.Notify(self.ply, L"levelUp", L("levelUpMsg", {["level"] = self.level}), VoidUI.Colors.Blue, 5)
		hook.Run("VoidFactions.Member.LevelUp", self, !noAdd and 1)
	end
end

function MEMBER_CLASS:AddLevels(level)
	self.level = self.level + level
end

function MEMBER_CLASS:IncrementPlaytime()
	self.playtime = self.playtime + 1
end

-- Util functions

-- This changes the job of the member, don't confuse with SetJob
function MEMBER_CLASS:ChangeJob(job, force)
	if (SERVER) then
		local isPlyValid = IsValid(self.ply)

		local passed = false
		if ( (force and !isPlyValid) or self.ply:Team() == job ) then
			passed = true
		else
			passed = self.ply:changeTeam(job, force or false)
		end

		if (passed) then
			self:SetJob(job)
			self:SaveStatic()

			VoidFactions.Member:UpdateMemberFields(self, {
				{"job", job}
			})

			-- VoidChar 1 support
			if (VoidChar) then
				
				local charId = string.Split(self.sid, "-")[2]
				local jobInfo = RPExtraTeams[job]

				local jobModel = istable(jobInfo.model) and jobInfo.model[1] or jobInfo.model
				if (isPlyValid and self.ply:GetCharacterID() == charId) then
					VoidChar.Ply.Data[self.ply].character.job = job
					VoidChar.Ply.Data[self.ply].character.model = jobModel
				end
					
				local jobCommand = jobInfo.command
				VoidChar.SQL.UpdateValue(charId, "job", "\'".. jobCommand .. "\'")
				VoidChar.SQL.UpdateValue(charId, "model", "\'".. jobModel .. "\'")
				if (isPlyValid) then
					local characters = self.ply:GetCharacters()
			
					characters = util.TableToJSON(characters)
					characters = util.Compress(characters)

					net.Start("VoidChar.RequestCharacters")
						net.WriteUInt(#characters, 32)
						net.WriteData(characters, #characters)
						net.WriteBool(false)
					net.Send(self.ply)
				end
			end

		end
	else
		net.Start("VoidFactions.Member.ChangeJob")
			net.WriteUInt(job, 20)
		net.SendToServer()
	end
end

-- Permission functions

function MEMBER_CLASS:CanJoin(faction, bypass)
	local rank = faction:GetLowestRank()
	if (!rank) then return false end

	if (VoidFactions.Settings:IsStaticFactions() and !faction.isDefaultFaction) then
		if (faction.maxMembers and faction.maxMembers != 0 and (faction.memberCount or 0) + 1 > faction.maxMembers) then return false, "maxMembersErr" end
		if (rank.maxMembers and rank.maxMembers != 0 and ( (faction.lowestRankMemberCount or 0) + 1 > rank.maxMembers and #rank:GetMembers() + 1 > rank.maxMembers) ) then return false, "maxRankMembersErr" end
		if (!bypass and rank.minLevel and rank.minLevel != 0 and rank.minLevel > self.level) then return false, "minLevelErr" end
		
		if (!bypass and faction.requiredUsergroups and istable(faction.requiredUsergroups) and #faction.requiredUsergroups > 0) then
			local strUg = self.ply:GetUserGroup()
			local bMatches = false
			for k, v in pairs(faction.requiredUsergroups) do
				if (v == strUg) then
					bMatches = true
				end
			end
	
			if (!bMatches) then return false, "wrongUsergroup" end
		end
	end

	if (VoidFactions.Settings:IsDynamicFactions()) then
		if (table.Count(faction.ranks) < 2) then return false, "noRanksAvailable" end
	end

	return true
end

function MEMBER_CLASS:Can(perm, faction, desired, additional, ...)

	local isAdmin = IsValid(self.ply) and CAMI.PlayerHasAccess(self.ply, "VoidFactions_ManageFactions") or false
	if (SERVER and isAdmin) then return true end

	local rank = self.rank
	if (!rank) then return false end


	if (faction) then
		if (isnumber(faction) and self.faction.id != faction) then return false end
		if (istable(faction) and self.faction.id != faction.id) then
			if (VoidFactions.Settings:IsDynamicFactions()) then return end
			local isSubfactionOf = self.faction:GetSubfactions()[faction.id] and true or false
			local isPromoteDefault = self.rank.promoteDefault[faction.id] and true or false
			if (!isSubfactionOf and !isPromoteDefault) then return false end
		end
	end


	local func = rank["Can" .. perm]
	if (!func) then
		VoidFactions.PrintError("Invalid permission used in MEMBER:Can!")
		return false
	end

	-- Second returned value if even an admin can't do this
	local result, notPossible = func(rank, additional, self, ...)
	if (notPossible) then return false end

	if (!isbool(result)) then
		if (!desired) then
			VoidFactions.PrintError("Returned permission was not a bool and desired argument was not specified!")
			return false
		end

		return result == desired
	else
		return result
	end

end

-- Server functions

-- Kicks the member from his active faction.
function MEMBER_CLASS:Kick()
	if (!SERVER) then return end
	if (!self.faction) then return end



end

-- Network functions

function MEMBER_CLASS:NetworkToPlayer(...)
	if (CLIENT) then return end
	if (!IsValid(self.ply)) then return end
	
	VoidFactions.PrintDebug("Networking member info to player!")

	VoidFactions.Member:NetworkToOwner(self, ...)
end

-- Saving functions

function MEMBER_CLASS:SaveStatic()
	if (!SERVER) then return end
	VoidFactions.SQL:SaveMemberStatic(self)
end

function MEMBER_CLASS:SaveDynamic()
	if (!SERVER) then return end
	VoidFactions.SQL:SaveMemberDynamic(self)
end

-- Member init

function VoidFactions.Member:InitMember(...)
	local member = MEMBER_CLASS:New(...)

	if (CLIENT) then
		VoidFactions.Members[member.sid] = member
	end

	return member
end

-- Player meta table

local PLAYER = FindMetaTable("Player")

function PLAYER:GetVFMember()
	if (CLIENT) then return VoidFactions.PlayerMember end

	local sid = self:SteamID64()
	if (!sid) then return nil end
	if (VoidChar) then
		if (SERVER and !self:GetCharacterID()) then return nil end
		if (SERVER) then
			sid = sid .. "-" .. self:GetCharacterID()
		else
			local nwCharId = self:GetNWInt("VoidFactions.CharID")
			if (!nwCharId) then return nil end
			sid = sid .. "-" .. nwCharId
		end
	end

	return VoidFactions.Members[sid]
end

function PLAYER:GetVFFaction()
	if (CLIENT) then return VoidFactions.PlayerMember and VoidFactions.PlayerMember.faction end

	if (!self:IsValid()) then return nil end
	local sid = self:SteamID64()
	if (VoidChar) then
		sid = sid .. "-" .. self:GetCharacterID()
	end
	if (!sid) then return nil end
	return VoidFactions.Members[sid] and VoidFactions.Members[sid].faction
end
