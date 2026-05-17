local L = VoidFactions.Lang.GetPhrase

util.AddNetworkString("VoidFactions.Member.NetworkToOwner")
util.AddNetworkString("VoidFactions.Member.UpdateFields")

util.AddNetworkString("VoidFactions.Member.ChangeRank")
util.AddNetworkString("VoidFactions.Member.Kick")
util.AddNetworkString("VoidFactions.Member.Add")
util.AddNetworkString("VoidFactions.Member.Invite")
util.AddNetworkString("VoidFactions.Member.Leave")
util.AddNetworkString("VoidFactions.Member.JoinFaction")

util.AddNetworkString("VoidFactions.Member.ChangeJob")

-- Net handlers

net.Receive("VoidFactions.Member.JoinFaction", function (len, ply)
	local member = ply:GetVFMember()
	if (!member) then return end

	if (VoidFactions.Settings:IsDynamicFactions()) then
		if (member.faction) then return end
	end

	local factionId = net.ReadUInt(20)

	local faction = VoidFactions.Factions[factionId]
	if (!faction) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to join a faction, but the supplied faction doesn't exist!")
		return
	end

	if (faction.inviteRequired) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to directly join a faction, but it requires an invite!")
		return
	end

	local canJoin, errPhrase = member:CanJoin(faction)
	if (!canJoin and VoidFactions.Settings:IsDynamicFactions()) then
		VoidLib.Notify(ply, L"error", L(errPhrase), VoidUI.Colors.Red, 5)
		return
	end

	local b = VoidFactions.Invites:JoinFaction(member, faction)
	if (b) then
		VoidLib.Notify(ply, L"success", L("memberJoinedFaction", faction.name), VoidUI.Colors.Green, 5)
	end
end)

net.Receive("VoidFactions.Member.Leave", function (len, ply)
	local member = ply:GetVFMember()
	if (!member or !member.faction) then return end

	local factionName = member.faction.name

	if (VoidFactions.Settings:IsStaticFactions()) then
		local defaultFaction = VoidFactions.Factions[member.defaultFactionId]
		if (!defaultFaction) then
			VoidFactions.PrintError("Member " .. member.sid .. "'s default faction does not exist!!'")
			return
		end

		if (defaultFaction.id == member.faction.id) then return end
	end

	VoidFactions.SQL:KickMember(member)
	member:NetworkToPlayer()

	VoidLib.Notify(ply, L"success", L("memberLeftFaction", factionName), VoidUI.Colors.Green, 5)
end)

local function changeMemberRank(member, plymember, ply, memberSid, desiredRank, promoteType, msgString, permString, memberNick, subfaction, memberLoaded)
	if (!member.faction) then return end

	if (!plymember:Can(permString, member.faction, nil, member, subfaction)) then return end

	local newRank = promoteType == VoidFactions.Member.PromoteEnums.PROMOTE and member.faction:GetNextRank(member.rank)
	if (promoteType == VoidFactions.Member.PromoteEnums.DEMOTE) then
		newRank = member.faction:GetPrevRank(member.rank)
	end
	if (promoteType == VoidFactions.Member.PromoteEnums.RANK_UPDATE) then
		newRank = member.faction.ranks[desiredRank]
	end

	-- Check validity
	if (subfaction) then
		if (promoteType == VoidFactions.Member.PromoteEnums.PROMOTE) then
			if (member.faction:GetFactionLevel() != subfaction:GetFactionLevel() + 1) then return end
			if (member.faction:GetRootFaction() != subfaction:GetRootFaction()) then return end
		end
		if (promoteType == VoidFactions.Member.PromoteEnums.DEMOTE) then
			if (member.faction:GetRootFaction() != subfaction:GetRootFaction()) then return end
			if (subfaction:GetFactionLevel() < member.faction:GetFactionLevel()) then return end
		end
	end

	if (promoteType == VoidFactions.Member.PromoteEnums.PROMOTE and !newRank and member.faction.parentFaction) then

		if (subfaction) then
			newRank = subfaction:GetLowestRank()
		else
			newRank = member.faction.parentFaction:GetLowestRank()
		end
	end

	if (promoteType == VoidFactions.Member.PromoteEnums.DEMOTE and !newRank and subfaction) then
		newRank = subfaction:GetLowestRank()
	end


	if (!newRank) then return end

	if (newRank.faction != member.faction) then
		VoidFactions.Invites:JoinFaction(member, newRank.faction)
	end

	if (promoteType == VoidFactions.Member.PromoteEnums.PROMOTE) then
		member:SetLastPromotion(os.time())
		member:SetAutoPromoteDisabled(false)
	end

	if (promoteType == VoidFactions.Member.PromoteEnums.DEMOTE and member.rank.autoPromoteLevel != 0) then
		member:SetAutoPromoteDisabled(true)
	end

	local nextJob = nil

    -- Does the new rank contain the same job?? If so, then don't change it
    for k, job in pairs(newRank.jobs) do
        if (job == member.job) then
            nextJob = job
        end
    end

	member:SetRank(newRank)
	if (nextJob) then
        member:SetJob(nextJob)
    end

	member:SaveStatic()

	if (!memberLoaded) then
		member:NetworkToPlayer()
		VoidFactions.NameTags:SetNameTag(member)
	end

	VoidFactions.Faction:UpdateFactionMembers(member.faction)

	VoidLib.Notify(ply, L"success", L("member" .. msgString, {
		["name"] = memberNick,
		["rank"] = newRank.name
	}), VoidUI.Colors.Green, 5)

	if (IsValid(member.ply)) then
		if (VoidChar and member.ply:GetCharacterID() != string.Split(member.sid, "-")[2]) then
			return
		end
		-- Notify the promoted player
		if (VoidFactions.Settings:IsStaticFactions()) then
			local msgType = promoteType == VoidFactions.Member.PromoteEnums.PROMOTE and "youPromoted" or "youDemoted"
			VoidLib.Notify(member.ply, L"info", L(msgType, member.rank.name), VoidUI.Colors.Blue, 5)

			-- Change job
			member:ChangeJob(member.job, true)
		else
			VoidLib.Notify(member.ply, L"info", L("youRankChanged", member.rank.name), VoidUI.Colors.Blue, 5)
		end
	end
end

net.Receive("VoidFactions.Member.ChangeRank", function (len, ply)

	if (VoidFactions.Utils:IsOnNetCooldown(ply)) then return end

	local plymember = ply:GetVFMember()

	local promoteType = net.ReadUInt(2)
	local memberSid = net.ReadString()

	-- We are passing the member nick so we don't need to query the steamworks api here to get the name from a steamid
	local memberNick = net.ReadString()

	local desiredRank = nil
	if (promoteType == VoidFactions.Member.PromoteEnums.RANK_UPDATE) then
		desiredRank = net.ReadUInt(20)
	end

	local subfaction = nil
	if (net.ReadBool()) then
		local subfactionId = net.ReadUInt(20)
		subfaction = VoidFactions.Factions[subfactionId]
		if (!subfaction) then
			VoidFactions.PrintWarning(ply:Name() .. " tried to demote a member to a specific faction, but the supplied faction doesn't exist!")
			return
		end
	end

	if (promoteType == VoidFactions.Member.PromoteEnums.RANK_UPDATE and !VoidFactions.Settings:IsDynamicFactions()) then
		VoidFactions.PrintWarning("Player " .. ply:Nick() .. " tried to directly update a players rank, but static factions are used!!")
		return
	end

	local msgString = promoteType == VoidFactions.Member.PromoteEnums.RANK_UPDATE and "RankChanged" or "Promoted"

	-- For dynamic factions, promoting = changing ranks
	local permString = "Promote"
	if (promoteType == VoidFactions.Member.PromoteEnums.DEMOTE) then
		permString = "Demote"
		msgString = "Demoted"
	end

	-- We need to load the member into the memory so we can check the faction and ranks
	local member = VoidFactions.Members[memberSid]
	if (!member) then
		VoidFactions.SQL:LoadPlayerData(nil, memberSid, function (member)
			if (!IsValid(ply)) then return end
			if (!member) then
				VoidFactions.PrintWarning(ply:Name() .. " tried to promote/demote an unexisting member!")
				VoidFactions.Utils:ActivateNetCooldown(ply, 10)
			else
				VoidFactions.Utils:ActivateNetCooldown(ply)
			end

			if (!member) then return end
			VoidFactions.PrintDebug("Loaded member " .. memberSid .. " into memory for promoting/demoting purposes")
			changeMemberRank(member, plymember, ply, memberSid, desiredRank, promoteType, msgString, permString, memberNick, subfaction, true)

			-- Member no longer required
			member = nil
		end)
	else
		changeMemberRank(member, plymember, ply, memberSid, desiredRank, promoteType, msgString, permString, memberNick, subfaction, false)
	end
end)

-- Only for admins, players can invite others
net.Receive("VoidFactions.Member.Add", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_ManageFactions")) then return end

	local factionId = net.ReadUInt(20)
	local rankId = net.ReadUInt(20)
	local plyM = net.ReadEntity()

	if (!IsValid(plyM)) then return end

	local faction = VoidFactions.Factions[factionId]
	if (!faction) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to add a member to a faction, but the supplied faction doesn't exist!")
		return
	end

	local rank = faction.ranks[rankId]
	if (!rank) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to add a member to a faction, but the supplied rank doesn't exist!")
		return
	end

	local member = plyM:GetVFMember()
	if (!member) then return end

	local canJoin, errPhrase = member:CanJoin(faction, true)
	if (!canJoin) then return end

	-- sssshhhh no-one needs to know that it's in the invites namespace
	local b = VoidFactions.Invites:JoinFaction(member, faction, rank)

	if (b) then
		VoidLib.Notify(ply, L"success", VoidLib.StringFormat(L("memberAdded"), {
			["name"] = plyM:Nick(),
			["faction"] = faction.name
		}), VoidUI.Colors.Green, 5)
	end
end)

-- Invites
net.Receive("VoidFactions.Member.Invite", function (len, ply)
	local plymember = ply:GetVFMember()
	if (!plymember:Can("Invite")) then return end

	if (!plymember.faction) then return end

	local plyM = net.ReadEntity()
	local faction = nil
	if (VoidFactions.Settings:IsStaticFactions()) then
		faction = VoidFactions.Factions[net.ReadUInt(20)]

		-- make sure the player has access
		local isSubfactionOf = plymember.faction:GetSubfactions()[faction.id] and true or false
		if (!isSubfactionOf and faction.id != plymember.faction.id) then return end
	else
		faction = plymember.faction
	end

	if (!IsValid(plyM)) then return end

	if (!faction) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to invite a member, but they are not in a faction!")
		return
	end

	local lowestRank = faction:GetLowestRank()
	if (!lowestRank) then return end

	local member = plyM:GetVFMember()
	if (!member) then return end

	if (member.faction and member.faction.id == plymember.faction.id) then return end
	if (plymember.sid == member.sid) then return end

	if (VoidFactions.Settings:IsStaticFactions()) then
		if (faction.maxMembers != 0 and #faction.members + 1 > faction.maxMembers) then return end
		if (lowestRank.maxMembers != 0 and #lowestRank:GetMembers() + 1 > lowestRank.maxMembers) then return end
	else
		if (#faction.members + 1 > faction:GetMaxMembers()) then return end
	end
	
	local invResult = VoidFactions.Invites:InviteMember(faction, member, plymember)
	-- Already invited somewhere
	if (invResult == false) then
		VoidLib.Notify(ply, L"error", VoidLib.StringFormat(L("memberInvitePending"), {
			["name"] = plyM:Nick(),
		}), VoidUI.Colors.Red, 5)
	else
		VoidLib.Notify(ply, L"success", VoidLib.StringFormat(L("memberInvited"), {
			["name"] = plyM:Nick(),
			["faction"] = faction.name
		}), VoidUI.Colors.Green, 5)
	end

end)

net.Receive("VoidFactions.Member.Kick", function (len, ply)

	if (VoidFactions.Utils:IsOnNetCooldown(ply)) then return end

	local plymember = ply:GetVFMember()
	if (!plymember:Can("Kick")) then return end -- Just an initial check of permissions. We need to check the permissions later once the member is loaded into the memory!
	
	-- We need to load the member into the memory so we can check the faction and ranks
	local memberSid = net.ReadString()
	local memberNick = net.ReadString()
	local member = VoidFactions.Members[memberSid]
	if (!member) then
		VoidFactions.SQL:LoadPlayerData(nil, sid, function (member)
			if (!IsValid(ply)) then return end

			if (!member) then
				VoidFactions.PrintWarning(ply:Name() .. " tried to kick an unexisting member!")
				VoidFactions.Utils:ActivateNetCooldown(ply, 10)
			else
				VoidFactions.Utils:ActivateNetCooldown(ply)
			end

			if (!member) then return end
			VoidFactions.PrintDebug("Loaded member " .. sid .. " into memory for kicking purposes")
			if (!member.faction) then return end
			if (!plymember:Can("Kick", member.faction, nil, member)) then return end

			if (member.defaultFactionId == member.faction.id) then return end

			VoidFactions.SQL:KickMember(member)
			VoidLib.Notify(ply, L"success", L("memberKicked", memberNick), VoidUI.Colors.Green, 5)

			-- Member no longer required
			member = nil
		end)
	else
		if (!member.faction) then return end
		if (!plymember:Can("Kick", member.faction, nil, member)) then return end

		if (member.defaultFactionId == member.faction.id) then return end
		
		VoidFactions.SQL:KickMember(member)
		member:NetworkToPlayer()

		VoidLib.Notify(ply, L"success", L("memberKicked", memberNick), VoidUI.Colors.Green, 5)
	end

end)

net.Receive("VoidFactions.Member.ChangeJob", function (len, ply)
	if (!VoidFactions.Settings:IsStaticFactions()) then return end
	local member = ply:GetVFMember()
	if (!member.faction or !member.rank) then return end

	local job = net.ReadUInt(20)

	if (!table.HasValue(member.rank.jobs, job)) then return end
	member:ChangeJob(job)
end)

-- Functions

-- Fields is a table with structure:
/*
	{
		{fieldName, value},
		{fieldName, value}
	}
*/
-- This only updates VoidFactions.PlayerMember
function VoidFactions.Member:UpdateMemberFields(member, fields)

	if (!IsValid(member.ply)) then return end

	-- Member may be a table of members
	if (VoidChar) then
		if (member.ply) then
			-- Single
			local charId = string.Split(member.sid, "-")[2]
			if (member.ply:GetCharacterID() != charId) then 
				VoidFactions.PrintDebug("Excluding " .. member.sid .. " from member field update")
				return
			end
		else
			-- Multiple (remove if not correct)
			for k, v in ipairs(member) do
				local charId = string.Split(v.sid, "-")[2]
				if (v.ply:GetCharacterID() != charId) then
					VoidFactions.PrintDebug("Excluding " .. v.sid .. " from member field update")
					table.remove(member, k)
				end
			end
		end
	end

	local membersTbl = {}
	if (!member.ply) then
		for k, v in ipairs(member) do
			membersTbl[k] = v.ply
		end
	end

	net.Start("VoidFactions.Member.UpdateFields")
		net.WriteUInt(#fields, 3) -- Max 7 fields to update at once
		for _, tbl in ipairs(fields) do
			local fieldName = tbl[1]
			local value = tbl[2]

			if (!value) then continue end

			local fieldEnum = VoidFactions.Member.FieldEnums[fieldName]
			if (!fieldEnum) then
				VoidFactions.PrintError("Tried to update member field, but field enum for " .. fieldName .. " does not exist!")
				continue
			end

			local fieldTbl = VoidFactions.Member.FieldTypes[fieldEnum]
			if (!fieldTbl) then
				VoidFactions.PrintError("Tried to update member field, but field type for enum does not exist! (" .. fieldEnum .. ")")
				continue
			end

			local fieldType = fieldTbl[1]
			local fieldBits = fieldTbl[2]

			net.WriteUInt(fieldEnum, 4)

			local func = net["Write" .. fieldType]
			if (!func) then
				func = VoidFactions[fieldType]["Write" .. fieldType]
				func(VoidFactions[fieldType], value)
			else
				func(value, fieldBits)
			end
			
		end

		VoidFactions.PrintDebug("Written member field update. Net size: " .. net.BytesWritten() .. " bytes")
	net.Send(member.ply or membersTbl)
end


function VoidFactions.Member:NetworkToOwner(member, onlyMember, newMember)

	if (VoidChar) then
		local charId = string.Split(member.sid, "-")[2]
		-- Don't network to nonactive members
		if (member.ply:GetCharacterID() != charId) then return end
	end

	net.Start("VoidFactions.Member.NetworkToOwner")
		net.WriteBool(newMember and true or false)
		VoidFactions.Member:WriteMember(member, onlyMember)
		VoidFactions.PrintDebug("Written member. Net size: " .. net.BytesWritten() .. " bytes")
	net.Send(member.ply)
end
