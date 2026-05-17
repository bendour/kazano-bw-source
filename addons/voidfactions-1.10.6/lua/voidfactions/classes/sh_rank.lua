VoidFactions.Rank = VoidFactions.Rank or {}

-- Validators

function VoidFactions.Rank:ValidateRank(name, maxMembers, jobs)
	if (#name < 3) then return false, "nameShort" end
	if (VoidFactions.Settings:IsStaticFactions()) then
		if (maxMembers > 65534) then return false, "maxMembersLimit" end
		if (!jobs or #jobs < 1) then return false, "noJobs" end
	end

	return true
end

-- Classes

local RANK_CLASS = {}
RANK_CLASS.__index = RANK_CLASS

function RANK_CLASS:New(id, faction, name, weight, tag, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, jobs, maxMembers, minLevel, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault)
	local newObject = setmetatable({}, RANK_CLASS)
		newObject.id = id
		newObject.faction = faction
		newObject.weight = weight
		newObject.name = name
		newObject.tag = tag

		newObject.maxMembers = maxMembers

		newObject.minLevel = minLevel

		-- Permissions
		newObject.canInvite = canInvite
		newObject.canPromote = canPromote
		newObject.canDemote = canDemote

		newObject.kickMembers = kickMembers
		newObject.manageFaction = manageFaction

		newObject.canPurchasePerks = canPurchasePerks
		newObject.canWithdrawMoney = canWithdrawMoney
		newObject.canDepositMoney = canDepositMoney
		newObject.canDepositItems = canDepositItems
		newObject.canWithdrawItems = canWithdrawItems

		newObject.autoPromoteLevel = autoPromoteLevel or 0
		newObject.isTemplate = false

		newObject.promoteDefault = promoteDefault or {}

		-- Jobs
		newObject.jobs = jobs

	return newObject
end

-- Class functions

function RANK_CLASS:SetPromoteDefault(promDefault)
	self.promoteDefault = promDefault
end

function RANK_CLASS:SetAutoPromoteLevel(level)
	self.autoPromoteLevel = level
end

function RANK_CLASS:SetTemplate(isTemplate)
	self.isTemplate = isTemplate
end

function RANK_CLASS:SetWeight(weight)
	self.weight = weight
end

function RANK_CLASS:SetName(name)
	self.name = name
end

function RANK_CLASS:SetTag(tag)
	self.tag = tag
end

function RANK_CLASS:SetJobs(jobs)
	self.jobs = jobs
end

function RANK_CLASS:GetJobs()
	return self.jobs
end

function RANK_CLASS:SetMinLevel(level)
	self.minLevel = level
end

-- Util functions

-- Get all the ranks below this rank
function RANK_CLASS:GetRanksBelow()
	local weight = self.weight
	local tbl = {}
	for k, rank in pairs(self.faction.ranks or {}) do
		if (rank.weight > weight) then
			tbl[#tbl + 1] = rank
		end
	end

	return tbl
end

-- Is the rank the rank with the lowest weight (highest position)
function RANK_CLASS:IsTopRank()
	local weight = self.weight
	for k, rank in pairs(self.faction.ranks or {}) do
		if (weight > rank.weight) then return false end
	end

	return true
end

-- Get all members inside a rank
function RANK_CLASS:GetMembers()
	local tbl = {}
	for k, member in ipairs(self.faction.members or {}) do
		if (member.rank == self) then
			tbl[#tbl + 1] = member
		end
	end
	return tbl
end

-- Permission functions

-- Compares weight of another rank. Returns boolean (if THIS rank is higher in hiearchy, then returns true)
function RANK_CLASS:CompareWeight(rank)
	return rank.weight > self.weight
end

function RANK_CLASS:CanInvite()
	return self.canInvite
end

function RANK_CLASS:CanChangeRank(member, requester, rank)
	if (!member) then return false, true end
	if (rank) then
		if (!rank) then return false, true end
		if (!self.faction.ranks[rank.id]) then return false, true end

		if (self.canPromote == 1) then return false end
		if (rank.id == self.id) then return false end
		if (member.sid == requester.sid) then return false end

		if (!requester.faction) then return false end
		if (member.faction.id != requester.faction.id) then return false end

		return self:CompareWeight(member.rank)
	else
		if (self.canPromote == 1) then return false end
		if (member.sid == requester.sid) then return false end
		if (!requester.faction) then return false end
		if (member.faction.id != requester.faction.id) then return false end

		return self:CompareWeight(member.rank)
	end
end

function RANK_CLASS:CanPromote(member, requester)
	if (member) then
		local nextRank = member.faction:GetNextRank(member.rank)
		if (!nextRank) then
			-- Check if can promote to a different faction
			if (VoidFactions.Settings:IsStaticFactions() and member.faction.parentFaction) then
				nextRank = member.faction.parentFaction:GetLowestRank()
				if (!nextRank) then return false, true end
			else
				return false, true
			end
		end
		if (VoidFactions.Settings:IsStaticFactions()) then
			if (nextRank.maxMembers and nextRank.maxMembers != 0 and #nextRank:GetMembers() + 1 > nextRank.maxMembers) then return false, true end
		end

		local isPromoteDefault = requester.rank.promoteDefault[member.faction.id] and member.rank.id == member.faction:GetLowestRank().id

		if (self.canPromote == 1 and !isPromoteDefault) then return false end
		if (nextRank.id == self.id) then return false end -- Don't promote to same ranks
		if (member.sid == requester.sid) then return false end
		if (VoidFactions.Settings:IsStaticFactions()) then
			if (nextRank.minLevel and nextRank.minLevel != 0 and member.level < nextRank.minLevel) then return false end
		end

		if (!requester.faction) then return false end

		local isSameFaction = member.faction.id == requester.faction.id
		
		local isSubfaction = self.faction:GetSubfactions()[member.faction.id] and true or false
		if (!isSameFaction and !isSubfaction and !isPromoteDefault) then return false end
		if (!isSameFaction and !isPromoteDefault and self.canPromote != 3) then return false end
		return !isSameFaction and true or self:CompareWeight(member.rank)
	else
		if (self.canPromote == 1) then return false end
		return true
	end
end

function RANK_CLASS:CanDemote(member, requester, subfaction)
	if (member) then
		local prevRank = member.faction:GetPrevRank(member.rank)
		if (!prevRank) then
			local subfactions = member.faction:GetSubfactions()
			if (!subfaction or !subfactions[subfaction.id]) then return false, true end
			
			prevRank = subfaction:GetLowestRank()
			if (!prevRank) then return false, true end
		end
		if (prevRank.maxMembers and prevRank.maxMembers != 0 and #prevRank:GetMembers() + 1 > prevRank.maxMembers) then return false, true end

		local isPromoteDefault = requester.rank.promoteDefault[member.faction.id]

		if (self.canDemote == 1 and !isPromoteDefault) then return false end
		if (member.rank.id == self.id) then return false end -- Don't demote from same ranks
		if (member.sid == requester.sid) then return false end
		if (prevRank.minLevel and prevRank.minLevel != 0 and member.level < prevRank.minLevel) then return false end -- this doesn't make much sense but whatever

		if (!requester.faction) then return false end
		
		local isSameFaction = member.faction.id == requester.faction.id
		local isSubfaction = self.faction:GetSubfactions()[member.faction.id] and true or false

		if (!isSameFaction and !isSubfaction and !isPromoteDefault) then return false end
		if (!isSameFaction and isPromoteDefault and prevRank.id != member.faction:GetLowestRank().id) then return false end

		if (!isSameFaction and !isPromoteDefault and self.canDemote != 3) then return false end
		return !isSameFaction and true or self:CompareWeight(member.rank)
	else
		if (self.canDemote == 1) then return false end
		return true
	end
end

function RANK_CLASS:CanPurchasePerks()
	return self.canPurchasePerks
end

function RANK_CLASS:CanKick(member, requester)
	if (member) then
		if (VoidFactions.Settings:IsStaticFactions()) then
			if (!member.defaultFactionId) then return false, true end
			if (member.defaultFactionId == member.faction.id) then return false, true end
		end

		if (member.sid == requester.sid) then return false, true end
		if (self.kickMembers == 1) then return false end

		if (member.rank.id == self.id) then return false end
		if (!requester.faction) then return false end

		local isSameFaction = member.faction.id == requester.faction.id
		if (!isSameFaction and self.kickMembers != 3) then return false end

		if (isSameFaction and member.rank.weight == self.weight) then return false end

		if (isSameFaction and !self:CompareWeight(member.rank)) then return false end
		return true
	else
		if (self.kickMembers == 1) then return false end
		
		return true
	end
end

function RANK_CLASS:CanDepositItems()
	return self.canDepositItems
end

function RANK_CLASS:CanWithdrawItems()
	return self.canWithdrawItems
end

function RANK_CLASS:CanDepositMoney()
	return self.canDepositMoney
end

function RANK_CLASS:CanWithdrawMoney()
	return self.canWithdrawMoney
end

function RANK_CLASS:CanManageFaction()
	return self.manageFaction
end

-- Save functions

function RANK_CLASS:Save()
	if (!SERVER) then return end
	VoidFactions.SQL:SaveRank(self)
end

-- Global functions

function VoidFactions.Rank:InitRank(...)
	local rank = RANK_CLASS:New(...)
	return rank
end