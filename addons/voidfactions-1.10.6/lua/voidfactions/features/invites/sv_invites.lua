local L = VoidFactions.Lang.GetPhrase

VoidFactions.Invites = VoidFactions.Invites or {}
VoidFactions.Invites.ActiveInvites = VoidFactions.Invites.ActiveInvites or {}

util.AddNetworkString("VoidFactions.Invites.ShowInvite")
util.AddNetworkString("VoidFactions.Invites.Respond")

function VoidFactions.Invites:InviteMember(faction, member, inviter)

	if (!IsValid(member.ply)) then return end

	local sid = member.sid
	if (VoidFactions.Invites.ActiveInvites[sid]) then return false end

	VoidFactions.Invites.ActiveInvites[sid] = {faction.id, inviter}
	timer.Create("VoidFactions.Invites." .. sid, VoidFactions.Config.InviteDuration, 1, function ()
		-- Expire
		VoidFactions.Invites.ActiveInvites[sid] = nil
	end)

	net.Start("VoidFactions.Invites.ShowInvite")
		net.WriteString(faction.name)
		net.WriteUInt(faction.id, 20)
	net.Send(member.ply)
end


function VoidFactions.Invites:AcceptInvite(member)
	local invite = VoidFactions.Invites.ActiveInvites[member.sid]
	if (!invite) then return end

	if (!IsValid(member.ply)) then return end

	VoidFactions.Invites.ActiveInvites[member.sid] = nil
	if (timer.Exists("VoidFactions.Invites." .. member.sid)) then
		timer.Remove("VoidFactions.Invites." .. member.sid)
	end

	local factionId = invite[1]
	local inviter = invite[2]


	local faction = VoidFactions.Factions[tonumber(factionId)]
	if (!faction) then return end

	local canJoin, errPhrase = member:CanJoin(faction)
	if (!canJoin) then
		VoidLib.Notify(member.ply, L"error", L(errPhrase), VoidUI.Colors.Red, 5)
		return
	end

	local result = VoidFactions.Invites:JoinFaction(member, faction)
	if (result) then
		VoidLib.Notify(member.ply, L"success", L("memberJoinedFaction", faction.name), VoidUI.Colors.Green, 5)

		if (inviter and IsValid(inviter.ply)) then
			VoidLib.Notify(inviter.ply, L"success", L("memberInviteAccepted", member.ply:Nick()), VoidUI.Colors.Green, 5)
		end
	end
end

function VoidFactions.Invites:DeclineInvite(member)
	local invite = VoidFactions.Invites.ActiveInvites[member.sid]
	if (!invite) then return end

	VoidFactions.Invites.ActiveInvites[member.sid] = nil
	if (timer.Exists("VoidFactions.Invites." .. member.sid)) then
		timer.Remove("VoidFactions.Invites." .. member.sid)
	end
end

local function joinFaction(member, faction, rank)
	if (!rank) then
		rank = faction:GetLowestRank()
	end

	if (!rank) then
		VoidFactions.PrintError("Member " .. member.sid .. " tried to join a faction, but there are no ranks!") 
		return 
	end

	if (member.faction and member.faction.members) then
		-- We don't need to remove the member if it's not loaded
		for k, v in ipairs(member.faction.members) do
			if (v.sid == member.sid) then
				VoidFactions.PrintDebug("Removing member from old faction")
				table.remove(member.faction.members, k)
			end
		end

		VoidFactions.Faction:UpdateFactionMembers(member.faction)
	end

	member:SetFaction(faction)
	member:SetRank(rank)

	local nextJob = nil

	-- Does the new rank contain the same job?? If so, then don't change it
    for k, job in pairs(rank.jobs or {}) do
        if (job == member.job) then
            nextJob = job
        end
    end

	if (nextJob) then
		member:SetJob(nextJob)
	end

	if (VoidFactions.Settings:IsStaticFactions()) then
		member:ChangeJob(member.job, true)
		member:SetFactionJoined(os.time())
	end

	VoidFactions.NameTags:SetNameTag(member)
	
	if (faction.members) then
		faction.members[#faction.members + 1] = member
	end

	member:SaveStatic()

	VoidFactions.Member:UpdateMemberFields(member, {
		{"faction", faction},
		{"rank", rank},
		{"job", member.job}
	})

	-- We need to update the faction two times - one for the old faction, one for the new one
	VoidFactions.Faction:UpdateFactionMembers(faction)

	hook.Run("VoidFactions.Faction.MemberJoined", faction)
end

function VoidFactions.Invites:JoinFaction(member, faction, rank)

	if (VoidFactions.Settings:IsStaticFactions() and (!member.defaultFactionId or !VoidFactions.Factions[member.defaultFactionId])) then
		if (IsValid(member.ply)) then
			VoidLib.Notify(member.ply, L"error", L"cantJoinNoDefaultFactions", VoidUI.Colors.Red, 10)
		end
		VoidFactions.PrintError(L"cantJoinNoDefaultFactions")
		return false
	end

	if (VoidFactions.Settings:IsStaticFactions() and faction.requiredUsergroups and istable(faction.requiredUsergroups) and #faction.requiredUsergroups > 0 and IsValid(member.ply)) then
		local strUg = member.ply:GetUserGroup()
		local bMatches = false
		for k, v in pairs(faction.requiredUsergroups) do
			if (v == strUg) then
				bMatches = true
			end
		end

		if (!bMatches) then return end
	end

	if (!faction.ranks) then
		VoidFactions.SQL:LoadFactionRanksAndMembers(faction, function ()
			joinFaction(member, faction, rank)
		end)
	else
		joinFaction(member, faction, rank)
	end

	return true
end

-- Net messages

net.Receive("VoidFactions.Invites.Respond", function (len, ply)
	local bool = net.ReadBool()

	local member = ply:GetVFMember()
	if (!member) then return end

	-- 86280902610637923
	if (bool) then
		VoidFactions.Invites:AcceptInvite(member)
	else
		VoidFactions.Invites:DeclineInvite(member)
	end
end)
