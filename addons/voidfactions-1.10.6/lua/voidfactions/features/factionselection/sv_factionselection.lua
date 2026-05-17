local L = VoidFactions.Lang.GetPhrase

util.AddNetworkString("VoidFactions.FactionSelection.Select")
util.AddNetworkString("VoidFactions.FactionSelection.Open")

hook.Add("VoidFactions.SQL.MemberLoaded", "VoidFactions.FactionSelection.OnMemberLoaded", function (ply)
	local member = ply:GetVFMember()
	if (!member) then return end -- This shouldn't really happen but whatever
	if (!VoidFactions.Settings:IsStaticFactions()) then return end

	-- Count total default factions
	if (VoidChar) then
		local defFactions = 0
		for k, v in pairs(VoidFactions.Factions) do
			if (v.isDefaultFaction) then
				defFactions = defFactions + 1
			end
		end

		if (defFactions > 1) then return end
	end

	if (!member.defaultFactionId or !member.faction) then
		net.Start("VoidFactions.FactionSelection.Open")
		net.Send(ply)
	end
end)


net.Receive("VoidFactions.FactionSelection.Select", function (len, ply)
	local member = ply:GetVFMember()
	if (!member) then return end

	local factionId = net.ReadUInt(20)

	local faction = VoidFactions.Factions[factionId]
	if (!faction) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to select a default faction, but the supplied faction doesn't exist!")
		return
	end


	if (!faction.isDefaultFaction) then return end
	if (!member.defaultFactionId or (member.defaultFactionId and !VoidFactions.Factions[member.defaultFactionId])) then
		member:SetDefaultFactionId(factionId)
		member:SaveStatic()

		local networkTbl = {{"defaultFactionId", factionId}}
		VoidFactions.Member:UpdateMemberFields(member, networkTbl)
	end
	-- 86480918070603124

	if (!member.faction) then
		local b = VoidFactions.Invites:JoinFaction(member, faction)
		if (b) then
			VoidLib.Notify(ply, L"success", L("memberJoinedFaction", faction.name), VoidUI.Colors.Green, 5)
		end
	end
end)