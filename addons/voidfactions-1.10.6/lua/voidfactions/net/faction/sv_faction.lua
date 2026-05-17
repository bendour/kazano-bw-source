local L = VoidFactions.Lang.GetPhrase

-- Creates or updates the static faction.
util.AddNetworkString("VoidFactions.Faction.UpdateStaticFaction")
util.AddNetworkString("VoidFactions.Faction.UpdateDynamicFaction")

util.AddNetworkString("VoidFactions.Faction.DeleteFaction")

util.AddNetworkString("VoidFactions.Faction.NetworkFactions")

util.AddNetworkString("VoidFactions.Faction.RequestFactionRanks")
util.AddNetworkString("VoidFactions.Faction.RequestFactionDeposits")

util.AddNetworkString("VoidFactions.Faction.SendFactionRanks")

util.AddNetworkString("VoidFactions.Faction.UpdateFactionData")

util.AddNetworkString("VoidFactions.Factions.RequestRankingPage")
util.AddNetworkString("VoidFactions.Factions.SendRankingPage")

util.AddNetworkString("VoidFactions.Factions.NetworkNewFaction")

util.AddNetworkString("VoidFactions.Factions.GetFactionRank")
util.AddNetworkString("VoidFactions.Factions.SendFactionRank")

-- Functions

-- This is used in board, settings page for admins and capture points
function VoidFactions.Faction:NetworkFactions(ply)
	-- For dynamic factions, only online factions will be networked, so it's okay
	net.Start("VoidFactions.Faction.NetworkFactions")
		net.WriteUInt(table.Count(VoidFactions.Factions), 20)
		for id, faction in pairs(VoidFactions.Factions) do
			VoidFactions.Faction:WriteFaction(faction, true, nil, nil, ply)
		end
		VoidFactions.PrintDebug("Written factions. Net size: " .. net.BytesWritten() .. " bytes")
	if (ply) then
		net.Send(ply)
	else
		-- Network to everyone
		net.Broadcast()
	end
end

function VoidFactions.Faction:NetworkNewFaction(faction)
	net.Start("VoidFactions.Factions.NetworkNewFaction")
		VoidFactions.Faction:WriteFaction(faction, true)
	net.Broadcast()
end


function VoidFactions.Faction:UpdateFactionUpgrades(faction)
	local players = {}
	for k, v in ipairs(faction.members or {}) do
		if (!IsValid(v.ply)) then continue end
		players[#players + 1] = v.ply
	end

	-- Network to players that already requested faction members/ranks 
	for k, ply in ipairs(player.GetHumans()) do
		if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[faction.id]) then
			players[#players + 1] = ply
		end
	end

	net.Start("VoidFactions.Faction.UpdateFactionData")
		net.WriteUInt(faction.id, 20)
		net.WriteUInt(VoidFactions.Faction.Enums.UPGRADES_UPDATE, 3)
		net.WriteUInt(faction.upgrades and table.Count(faction.upgrades) or 0, 10)
		for upgrade, _ in pairs(faction.upgrades or {}) do
			net.WriteUInt(upgrade, 10)
		end
		net.WriteUInt(faction.spentUpgradePoints, 24)
	net.Send(players)
end

function VoidFactions.Faction:UpdateFactionXP(faction, didLevelUp)
	local players = {}
	for k, v in ipairs(faction.members or {}) do
		if (!IsValid(v.ply)) then continue end
		players[#players + 1] = v.ply
	end

	-- Network to players that already requested faction members/ranks 
	for k, ply in ipairs(player.GetHumans()) do
		if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[faction.id]) then
			players[#players + 1] = ply
		end
	end

	net.Start("VoidFactions.Faction.UpdateFactionData")
		net.WriteUInt(faction.id, 20)
		net.WriteUInt(VoidFactions.Faction.Enums.XP_UPDATE, 3)
		net.WriteUInt(faction.xp, 32)
		net.WriteBool(didLevelUp)
		if (didLevelUp) then
			net.WriteUInt(faction.level, 14)
		end
	net.Send(players)
end

function VoidFactions.Faction:UpdateFactionReward(faction, reward)
	local players = {}
	for k, v in ipairs(faction.members or {}) do
		if (!IsValid(v.ply)) then continue end
		players[#players + 1] = v.ply
	end

	-- Network to players that already requested faction members/ranks 
	for k, ply in ipairs(player.GetHumans()) do
		if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[faction.id]) then
			players[#players + 1] = ply
		end
	end

	net.Start("VoidFactions.Faction.UpdateFactionData")
		net.WriteUInt(faction.id, 20)
		net.WriteUInt(VoidFactions.Faction.Enums.REWARDS_UPDATE, 3)
		VoidFactions.FactionRewards:WriteReward(reward)
	net.Send(players)
end

function VoidFactions.Faction:UpdateFactionMembers(faction)
	local players = {}
	for k, v in ipairs(faction.members or {}) do
		if (!IsValid(v.ply)) then continue end
		players[#players + 1] = v.ply
	end

	-- Network to players that already requested faction members/ranks 
	for k, ply in ipairs(player.GetHumans()) do
		if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[faction.id]) then
			players[#players + 1] = ply
		end
	end

	if (faction.isPreloaded) then
		net.Start("VoidFactions.Faction.UpdateFactionData")
			net.WriteUInt(faction.id, 20)
			net.WriteUInt(VoidFactions.Faction.Enums.MEMBERS_UPDATE, 3)
			net.WriteUInt(faction.members and #faction.members or 0, 16)
			for id, member in ipairs(faction.members or {}) do
				VoidFactions.Member:WriteMember(member, true)
			end
		net.Send(players)

		hook.Run("VoidFactions.UpdatedFactionMembers", faction, faction.members)
	else
		VoidFactions.SQL:GetFactionMembers(faction, function (members)
			VoidFactions.PrintDebug("Requested faction members from DB for updating")

			local realMembers = {}

			for k, v in ipairs(members or {}) do
				if (!IsValid(v.ply)) then continue end

				players[#players + 1] = v.ply
				table.insert(realMembers, v)
			end

			net.Start("VoidFactions.Faction.UpdateFactionData")
				net.WriteUInt(faction.id, 20)
				net.WriteUInt(VoidFactions.Faction.Enums.MEMBERS_UPDATE, 3)
				net.WriteUInt(#realMembers or 0, 16)
				for id, member in ipairs(realMembers or {}) do
					VoidFactions.Member:WriteMember(member, true)
				end
			net.Send(players)

			hook.Run("VoidFactions.UpdatedFactionMembers", faction, faction.members)
		end)
	end
end

function VoidFactions.Faction:UpdateFactionRanks(faction)

	local players = {}
	for k, v in pairs(faction.members or {}) do
		if (!IsValid(v.ply)) then continue end
		players[#players + 1] = v.ply
	end

	-- Network to players that already requested faction members/ranks 
	for k, ply in pairs(player.GetHumans()) do
		if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[faction.id]) then
			players[#players + 1] = ply
		end
	end

	net.Start("VoidFactions.Faction.UpdateFactionData")
		net.WriteUInt(faction.id, 20)
		net.WriteUInt(VoidFactions.Faction.Enums.RANKS_UPDATE, 3)
		net.WriteUInt(table.Count(faction.ranks), 16)
		for id, rank in pairs(faction.ranks or {}) do
			VoidFactions.Rank:WriteRank(rank)
		end
	net.Send(players)
	
end

-- Net handlers

net.Receive("VoidFactions.Factions.RequestRankingPage", function (len, ply)
	if (VoidFactions.Settings:IsStaticFactions()) then return end

	local page = net.ReadUInt(12)
	local totalEntries = 6
	local hasPerms = CAMI.PlayerHasAccess(ply, "VoidFactions_ManageFactions")
	local adminRequest = false
	if (net.ReadBool()) then
		local amt = net.ReadUInt(7)
		if (hasPerms) then
			totalEntries = amt
			adminRequest = true
		end
	end
 
	if (!ply.vfRequestedPagesCooldowns) then
		ply.vfRequestedPagesCooldowns = {}
	end

	if (!hasPerms and (ply.vfRequestedPagesCooldowns[page] and ply.vfRequestedPagesCooldowns[page] > CurTime())) then return end
	ply.vfRequestedPagesCooldowns[page] = CurTime() + 20


	-- Perform an SQL query sorted by level and xp and limit to top 6
	VoidFactions.SQL:GetFactionsRanking(page, function (result, total)

		local callbacksDone = 0
		local factions = {}

		local factionLen = #result


		for k, data in ipairs(result) do
			data.id = tonumber(data.id)
			data.faction_level = tonumber(data.faction_level)

			local faction = VoidFactions.Faction:InitFaction(data.id, data.name, data.logo, string.ToColor(data.color), data.faction_xp, data.faction_level, parentFaction, tonumber(data.max_members), data.tag, tobool(data.invite_required), data.can_capture_territory, data.show_board, data.is_default_faction, data.description, tonumber(data.money))
			faction.memberCount = data.memberCount

			VoidFactions.SQL:LoadFactionUpgrades(faction, function ()


				factions[k] = faction
				callbacksDone = callbacksDone + 1
				if (callbacksDone == factionLen) then
					net.Start("VoidFactions.Factions.SendRankingPage")
						net.WriteUInt(page, 12)
						net.WriteUInt(total, 20)
						net.WriteBool(totalEntries != 6)
						net.WriteUInt(#factions, 7)

						for k, faction in ipairs(factions) do
							local maxMembers = faction:GetMaxMembers()

							-- send only the required data
							local rank = page*totalEntries-totalEntries+k
							local name = faction.name
							local level = faction.level
							local count = faction.memberCount or 0
							local canJoin = faction.inviteRequired
							local id = faction.id

							if (adminRequest) then
								VoidFactions.Faction:WriteFaction(faction)
								net.WriteUInt(count, 8)
								net.WriteUInt(maxMembers, 10)
							else
								net.WriteUInt(rank, 20)
								net.WriteUInt(id, 20)
								net.WriteString(name)
								net.WriteUInt(level, 14)
								net.WriteUInt(count, 8)
								net.WriteBool(!canJoin)
								net.WriteUInt(maxMembers, 10)
							end
						end
						
					net.Send(ply)
				end
			end)
		end

		
	end, totalEntries)
end)

net.Receive("VoidFactions.Faction.RequestFactionDeposits", function (len, ply)
	if (VoidFactions.Settings:IsStaticFactions() and !VoidFactions.Config.DepositEnabled) then return end

	local member = ply:GetVFMember()
	if (!member) then return end

	local factionId = net.ReadUInt(20)
	local faction = VoidFactions.Factions[factionId]
	if (!faction) then
		VoidFactions.PrintWarning("Player " .. ply:Nick() .. " tried to request faction deposits from a faction that didn't exist!")
		return
	end

	if (member.faction != faction) then
		VoidFactions.PrintWarning("Player " .. ply:Nick() .. " tried to request faction deposits from a different faction!")
		return
	end

	net.Start("VoidFactions.Faction.UpdateFactionData")
		net.WriteUInt(faction.id, 20)
		net.WriteUInt(VoidFactions.Faction.Enums.DEPOSITS_UPDATE, 3)
		net.WriteUInt(faction.money or 0, 32)
		net.WriteUInt(faction.deposits and table.Count(faction.deposits or {}) or 0, 16)
		for id, item in pairs(faction.deposits or {}) do
			VoidFactions.DepositItem:WriteItem(item)
		end
		net.WriteUInt(faction.transactions and #faction.transactions or 0, 16)
        for _, transaction in ipairs(faction.transactions or {}) do
            VoidFactions.Transactions:WriteTransaction(transaction)
        end
	net.Send(ply)

end)


-- Create or edit dynamic faction
net.Receive("VoidFactions.Faction.UpdateDynamicFaction", function (len, ply)
	if (VoidFactions.Settings:IsStaticFactions()) then return end

	local factionId = nil

	local isEditing = net.ReadBool()
	if (isEditing) then
		factionId = net.ReadUInt(20)
	end

	local currency = VoidFactions.Currencies.List[VoidFactions.Config.FactionCreateCurrency]
	local factionCreateCost = tonumber(VoidFactions.Config.FactionCreateCost)

	if (!isEditing and !currency:CanAfford(ply, factionCreateCost)) then return end

	local name = net.ReadString()
	local tag = net.ReadString()
	local color = net.ReadColor()
	local logo = net.ReadString()
	local inviteRequired = net.ReadBool()

	name = string.Trim(name)
	tag = string.Trim(tag)

	if (#logo < 3) then
		-- default logo
		logo = "CFodqaC"
	end

	color = Color(color.r, color.g, color.b, 255)

	local validation, msg = VoidFactions.Faction:ValidateFaction(name, nil, tag)
	if (!validation) then
		VoidFactions.PrintWarning("Server-side validation of faction data failed! (" .. msg .. "), player: ", ply:Nick())
		return
	end

	local faction = nil
	if (isEditing) then
		faction = VoidFactions.Factions[factionId]
		if (!faction and !CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then
			VoidFactions.PrintWarning(ply:Name() .. " tried to edit a faction, but the supplied faction doesn't exist!")
			return
		end

		if (!faction) then
			VoidFactions.SQL:UpdateDynamicFactionOffline(factionId, name, tag, color, logo, inviteRequired)
			VoidLib.Notify(ply, L"success", L("factionUpdated", name), VoidUI.Colors.Green, 5)
			return
		end
	end

	VoidFactions.SQL:CheckDuplicateFactionNames(name, tag, factionId, function (duplicate)
		if (duplicate) then
			if (!isEditing) then
				VoidLib.Notify(ply, L"error", L("name_exists"), VoidUI.Colors.Red, 5)
				return
			end

			if (tonumber(duplicate.id) != faction.id) then
				VoidLib.Notify(ply, L"error", L("name_exists"), VoidUI.Colors.Red, 5)
				return
			end
		end

		local plyMember = ply:GetVFMember()
		if (!plyMember) then return end

		if (isEditing) then
			if (!plyMember.faction) then return end
			if (!plyMember:Can("ManageFaction", faction, nil)) then return end

			faction:ChangeName(name)
			faction:ChangeColor(color)
			faction:SetTag(tag)
			faction:SetLogo(logo)
			faction:SetInviteRequired(inviteRequired)

			faction:SaveStatic()

			VoidFactions.Faction:NetworkFactions()
			VoidFactions.NameTags:UpdateFactionTags(faction)

		else
			if (plyMember.faction) then return end
			VoidFactions.SQL:CreateFaction(name, tag, color, nil, nil, logo, inviteRequired, nil, nil, nil, nil, ply)

			currency:TakeMoney(ply, factionCreateCost)
		end

		if (isEditing) then
			local membersTbl = {}
			for k, v in ipairs(faction.members) do
				if (IsValid(v.ply)) then
					membersTbl[#membersTbl + 1] = v
				end
			end

			-- Network to members inside faction
			VoidFactions.Member:UpdateMemberFields(membersTbl, {
				{"faction", faction},
			})
		end

		VoidLib.Notify(ply, L"success", isEditing and L("factionUpdated", name) or L("factionCreated", name), VoidUI.Colors.Green, 5)
	end)
end)

net.Receive("VoidFactions.Factions.GetFactionRank", function (len, ply)
	local member = ply:GetVFMember()
	if (!member) then return end
	if (!member.faction) then return end

	local faction = member.faction

	if (ply.vf_cooldownFactionRank and ply.vf_cooldownFactionRank > CurTime()) then return end
	ply.vf_cooldownFactionRank = CurTime() + 60

	VoidFactions.SQL:GetFactionRank(faction, function (rank)
		net.Start("VoidFactions.Factions.SendFactionRank")
			net.WriteUInt(rank, 20)
		net.Send(ply)
	end)
end)

-- Create or edit static faction
net.Receive("VoidFactions.Faction.UpdateStaticFaction", function (len, ply)
	if (VoidFactions.Settings:IsDynamicFactions()) then return end
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then return end

	local factionId = nil

	local isEditing = net.ReadBool()
	if (isEditing) then
		factionId = net.ReadUInt(20)
	end

	local name = net.ReadString()
	local description = net.ReadString()
	local tag = net.ReadString()
	local color = net.ReadColor()
	local maxMembers = net.ReadUInt(20)

	color = Color(color.r, color.g, color.b, 255)


	local subfactionId = nil
	if (net.ReadBool()) then
		subfactionId = net.ReadUInt(20)
	end

	local logo = nil
	if (net.ReadBool()) then
		logo = net.ReadString()
	end

	local inviteRequired = net.ReadBool()
	local canCaptureTerritory = net.ReadBool()
	local showOnBoard = net.ReadBool()
	local isDefaultFaction = net.ReadBool()

	local usergroups = net.ReadTable()

	local subfaction = nil
	if (subfactionId) then
		subfaction = VoidFactions.Factions[subfactionId]
	end

	local validation, msg = VoidFactions.Faction:ValidateFaction(name, maxMembers)
	if (!validation) then
		VoidFactions.PrintWarning("Server-side validation of faction data failed! (" .. msg .. "), player: ", ply:Nick())
		return
	end

	local faction = nil
	if (isEditing) then
		faction = VoidFactions.Factions[factionId]
		if (!faction) then
			VoidFactions.PrintWarning(ply:Name() .. " tried to edit a faction, but the supplied faction doesn't exist!")
			return
		end
	end

	if (isEditing) then
		faction:ChangeName(name)
		faction:ChangeColor(color)
		faction:SetMaxMembers(maxMembers)
		faction:SetTag(tag)
		faction:SetLogo(logo)
		
		faction:SetInviteRequired(inviteRequired)
		faction:SetCanCaptureTerritory(canCaptureTerritory)
		faction:SetShowBoard(showOnBoard)
		faction:SetIsDefaultFaction(isDefaultFaction)
		faction:SetDescription(description)

		faction:ChangeParentFaction(subfaction)
		faction:SetRequiredUsergroups(usergroups)

		faction:SaveStatic()

		VoidFactions.Faction:NetworkFactions()
		VoidFactions.NameTags:UpdateFactionTags(faction)

	else
		local maxAmount = VoidFactions.Settings.Hardcoded.MaxStaticFactions
		if (table.Count(VoidFactions.Factions) >= maxAmount) then
			local phrase = L("maxFactionsCreated")
			VoidLib.Notify(ply, L"error", VoidLib.StringFormat(phrase, {["name"] = name, ["limit"] = maxAmount}), VoidUI.Colors.Red, 5)
			return
		end

		VoidFactions.SQL:CreateFaction(name, tag, color, maxMembers, subfaction, logo, inviteRequired, canCaptureTerritory, showOnBoard, isDefaultFaction, description, nil, usergroups)
	end


	if (isEditing) then
		local membersTbl = {}
		for k, v in ipairs(faction.members) do
			if (IsValid(v.ply)) then
				membersTbl[#membersTbl + 1] = v
			end
		end

		-- Network to members inside faction
		VoidFactions.Member:UpdateMemberFields(membersTbl, {
			{"faction", faction},
		})
	end

	VoidLib.Notify(ply, L"success", isEditing and L("factionUpdated", name) or L("factionCreated", name), VoidUI.Colors.Green, 5)
end)

net.Receive("VoidFactions.Faction.DeleteFaction", function (len, ply)

	local factionId = net.ReadUInt(20)


	if (VoidFactions.Settings:IsStaticFactions() and !CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then return end
	if (VoidFactions.Settings:IsDynamicFactions() and !CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then
        local member = ply:GetVFMember()
        if (!member or !member.faction) then return end
		if (member.faction.id != factionId) then return end
		if (!member.rank:IsTopRank()) then return end -- Only the owner can delete the faction
    end

	local faction = VoidFactions.Factions[factionId]

	if (!faction) then

		if (CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions") and VoidFactions.Settings:IsDynamicFactions()) then
			VoidFactions.SQL:DeleteDynamicFactionOffline(factionId)
			VoidLib.Notify(ply, L"success", L("factionDeleted", ""), VoidUI.Colors.Green, 5)
			return
		end
	
		VoidFactions.PrintWarning("Player " .. ply:Nick() .. " tried to delete a faction that didn't exist!")
		return
	end

	local name = faction.name

	for i=#faction.members,1,-1 do
		local v = faction.members[i]
			
		VoidFactions.SQL:KickMember(v)
		if (IsValid(v.ply)) then
			v:NetworkToPlayer()
		end
	end

	VoidFactions.SQL:DeleteFaction(faction)
	VoidFactions.Factions[factionId] = nil

	-- Remove all captured points
	for k, v in pairs(VoidFactions.PointsTable) do
		if (v.captureFaction and v.captureFaction.id == factionId) then
			v.captureInProgress = false
			v.captureStart = 0
			v.captureEnd = 0

			v.captureFaction = nil
			v.capturingPlayers = {}
			v.capturingBy = nil

			VoidFactions.CapturePoints:NetworkFactionChange(v, nil)
		end
	end

	VoidLib.Notify(ply, L"success", L("factionDeleted", name), VoidUI.Colors.Green, 5)

	-- Reset requested ranks factions (what if someone requested ranks from the old faction?)
	for _, p in ipairs(player.GetHumans()) do
		p.vf_requestedRanksFactions = nil
	end

	

	VoidFactions.Faction:NetworkFactions()

end)

net.Receive("VoidFactions.Faction.RequestFactionRanks", function (len, ply)
	local id = net.ReadUInt(20)

	if (id == 0 and VoidFactions.Settings:IsStaticFactions() and CAMI.PlayerHasAccess(ply, "VoidFactions_ManageFactions")) then
		VoidFactions.Rank:SendRankTemplates(ply)

		if (!ply.vf_requestedRanksFactions) then
			ply.vf_requestedRanksFactions = {}
		end

		ply.vf_requestedRanksFactions[0] = true
	else
		local faction = VoidFactions.Factions[id]
		if (!faction) then
			VoidFactions.PrintWarning("Player " .. ply:Nick() .. " tried to request faction ranks from a faction that didn't exist!")
			return
		end

		-- if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[faction.id]) then return end

		local function networkRanks()
			local ranks = faction.ranks or {}
			local members = faction.members or {}

			local membersToWrite = {}
			if (!faction.isPreloaded) then
				for k, v in ipairs(faction.members or {}) do
					if (!IsValid(v.ply)) then continue end
					table.insert(membersToWrite, v)
				end
			else
				membersToWrite = faction.members
			end

			net.Start("VoidFactions.Faction.SendFactionRanks")
				net.WriteUInt(id, 20)
				net.WriteUInt(table.Count(ranks), 5)
				for k, rank in pairs(ranks) do
					VoidFactions.Rank:WriteRank(rank)
				end
				net.WriteUInt(table.Count(membersToWrite), 16)
				for k, member in pairs(membersToWrite) do
					VoidFactions.Member:WriteMember(member, true)
				end
			net.Send(ply)
		end

		if (!ply.vf_requestedRanksFactions) then
			ply.vf_requestedRanksFactions = {}
		end

		ply.vf_requestedRanksFactions[faction.id] = true

		if (!faction.ranks or !faction.members) then
			VoidFactions.SQL:LoadFactionRanksAndMembers(faction, function ()
				if (!IsValid(ply)) then return end
				networkRanks()
			end)
		else
			networkRanks()
		end
	end
	
end)

