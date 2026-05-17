VoidFactions.PlayerMember = VoidFactions.PlayerMember or nil

-- Functions

function VoidFactions.Member:SetMemberRank(member, nick, rank)
	net.Start("VoidFactions.Member.ChangeRank")
		net.WriteUInt(VoidFactions.Member.PromoteEnums.RANK_UPDATE, 2)
		net.WriteString(member.sid)
		net.WriteString(nick)

		net.WriteUInt(rank.id, 20)
	net.SendToServer()
end

function VoidFactions.Member:PromoteMember(member, nick, faction)
	net.Start("VoidFactions.Member.ChangeRank")
		net.WriteUInt(VoidFactions.Member.PromoteEnums.PROMOTE, 2)
		net.WriteString(member.sid)
		net.WriteString(nick)

		net.WriteBool(faction and true or false)
		if (faction) then
			net.WriteUInt(faction.id, 20)
		end
	net.SendToServer()
end

function VoidFactions.Member:DemoteMember(member, nick, subfaction)
	net.Start("VoidFactions.Member.ChangeRank")
		net.WriteUInt(VoidFactions.Member.PromoteEnums.DEMOTE, 2)
		net.WriteString(member.sid)
		net.WriteString(nick)

		net.WriteBool(subfaction and true or false)
		if (subfaction) then
			net.WriteUInt(subfaction.id, 20)
		end
	net.SendToServer()
end

function VoidFactions.Member:KickMember(member, nick)
	net.Start("VoidFactions.Member.Kick")
		net.WriteString(member.sid)
		net.WriteString(nick)
	net.SendToServer()
end

function VoidFactions.Member:InvitePlayer(ply, faction)
	net.Start("VoidFactions.Member.Invite")
		net.WriteEntity(ply)
		if (faction) then
			net.WriteUInt(faction.id, 20)
		end
	net.SendToServer()
end

function VoidFactions.Member:LeaveFaction()
	net.Start("VoidFactions.Member.Leave")
	net.SendToServer()
end

function VoidFactions.Member:JoinFaction(faction)
	net.Start("VoidFactions.Member.JoinFaction")
		net.WriteUInt(isnumber(faction) and faction or faction.id, 20)
	net.SendToServer()
end

function VoidFactions.Member:SetFaction(faction, rank, ply)
	net.Start("VoidFactions.Member.Add")
		net.WriteUInt(faction.id, 20)
		net.WriteUInt(rank.id, 20)
		net.WriteEntity(ply)
	net.SendToServer()
end

-- Net handlers

net.Receive("VoidFactions.Member.UpdateFields", function ()
	if (!VoidFactions.PlayerMember) then
		VoidFactions.PrintDebug("[POSSIBLE ERROR] Received update field, but member instance not initialized!")
		return
	end

	VoidFactions.PrintDebug("Received update field net!")

	local fieldAmount = net.ReadUInt(3)
	for i = 1, fieldAmount do
		local fieldEnum = net.ReadUInt(4)
		local fieldTbl = VoidFactions.Member.FieldTypes[fieldEnum]

		local fieldType = fieldTbl[1]
		local fieldBits = fieldTbl[2]

		local tblKeys = {}
		for k, v in SortedPairsByValue(VoidFactions.Member.FieldEnums) do
			tblKeys[#tblKeys + 1] = k
		end

		local fieldName = tblKeys[fieldEnum]

		local val = nil
		local func = net["Read" .. fieldType]
		if (func) then
			val = net["Read" .. fieldType](fieldBits)
		else
			val = VoidFactions[fieldType]["Read" .. fieldType]()
		end
		
		VoidFactions.PlayerMember[fieldName] = val

		VoidFactions.PrintDebug("Updated field name " .. fieldName .. "!")
	end

	local panel = VoidFactions.Menu.Panel
	if (IsValid(panel)) then
		local profile = panel.sidebar.loadedPanels["VoidFactions.UI.ProfilePanel"]
		if (profile) then
			profile:InfoUpdated()
		end
	end

	if (VoidFactions.Menu.ReopenRequested) then
		VoidFactions.Menu:Open()
		VoidFactions.Menu.ReopenRequested = false
	end
end)

net.Receive("VoidFactions.Member.NetworkToOwner", function ()

	local isNewChar = false
	if (net.ReadBool()) then
		isNewChar = true
	end
	
	if (!VoidFactions.PlayerMember or isNewChar) then
		VoidFactions.PrintDebug("Received member network message, creating member instance!")
		local member = VoidFactions.Member:ReadMember()
		member.ply = LocalPlayer()
		if (!member.name) then
			member:SetName(member.ply:Name())
		end

		VoidFactions.PlayerMember = member

		hook.Run("VoidFactions.Members.MemberObjectInitialized", VoidFactions.PlayerMember)
	else
	 	local bWasInFaction = VoidFactions.PlayerMember.faction and true or false
		VoidFactions.PrintDebug("Received member update!")
		-- Passing a member to ReadMember updates the member
		VoidFactions.Member:ReadMember(VoidFactions.PlayerMember)
		
		if (bWasInFaction and !VoidFactions.PlayerMember.faction and IsValid(VoidFactions.Menu.Panel)) then
			VoidFactions.Menu.Panel:Remove()
		end
	end

	if (VoidFactions.Menu.ReopenRequested) then
		VoidFactions.Menu:Open()
		VoidFactions.Menu.ReopenRequested = false
	end

end)

