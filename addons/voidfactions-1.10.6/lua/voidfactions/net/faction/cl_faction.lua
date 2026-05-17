
local L = VoidFactions.Lang.GetPhrase

VoidFactions.Faction = VoidFactions.Faction or {}
VoidFactions.LoadedFactions = VoidFactions.LoadedFactions or {}

-- Functions

function VoidFactions.Faction:CreateStaticFaction(...)
	return VoidFactions.Faction:UpdateStaticFaction(nil, ...)
end

-- These functions also create the factions
function VoidFactions.Faction:UpdateDynamicFaction(faction, name, factionTag, factionColor, logo, inviteRequired)
	name = string.Trim(name)
	factionTag = string.Trim(factionTag)

	local validation, msg = VoidFactions.Faction:ValidateFaction(name, nil, factionTag)
	if (!validation) then
		VoidLib.Notify(L"error", L(msg), VoidUI.Colors.Red, 5)
        return false
	end

	factionColor = Color(factionColor.r, factionColor.g, factionColor.b, 255)

	net.Start("VoidFactions.Faction.UpdateDynamicFaction")
		net.WriteBool(faction and true or false)
		if (faction) then
			net.WriteUInt(faction.id, 20)
		end
		net.WriteString(name)
		net.WriteString(factionTag)
		net.WriteColor(factionColor)
		net.WriteString(logo)
		net.WriteBool(inviteRequired)
	net.SendToServer()

	return true
end

function VoidFactions.Faction:UpdateStaticFaction(faction, name, factionTag, subfactionOf, factionColor, maxMembers, logo, inviteRequired, canCaptureTerritory, showOnBoard, isDefaultFaction, description, usergroups)
	local validation, msg = VoidFactions.Faction:ValidateFaction(name, maxMembers)
	if (!validation) then
		VoidLib.Notify(L"error", L(msg), VoidUI.Colors.Red, 5)
        return false
	end

	factionColor = Color(factionColor.r, factionColor.g, factionColor.b, 255)

	net.Start("VoidFactions.Faction.UpdateStaticFaction")
		net.WriteBool(faction and true or false)
		if (faction) then
			net.WriteUInt(faction.id, 20)
		end
		net.WriteString(name)
		net.WriteString(description)
		net.WriteString(factionTag)
		net.WriteColor(factionColor)
		net.WriteUInt(maxMembers, 20)
		net.WriteBool(subfactionOf and true or false)
		if (subfactionOf) then
			net.WriteUInt(subfactionOf, 20) -- ID
		end
		net.WriteBool(logo != "" and true or false)
		if (logo != "") then
			net.WriteString(logo)
		end
		net.WriteBool(inviteRequired)
		net.WriteBool(canCaptureTerritory)
		net.WriteBool(showOnBoard)
		net.WriteBool(isDefaultFaction)
		net.WriteTable(usergroups)
	net.SendToServer()

	return true
end

function VoidFactions.Faction:DeleteFaction(faction)
	net.Start("VoidFactions.Faction.DeleteFaction")
		net.WriteUInt(faction.id, 20)
	net.SendToServer()
end

function VoidFactions.Faction:RequestFactionRanks(id)
	net.Start("VoidFactions.Faction.RequestFactionRanks")
		net.WriteUInt(id, 20)
	net.SendToServer()
end

function VoidFactions.Faction:RequestFactionDeposits(id)
	net.Start("VoidFactions.Faction.RequestFactionDeposits")
		net.WriteUInt(id, 20)
	net.SendToServer()
end

function VoidFactions.Faction:RequestRankingPage(page, entryAmount)
	net.Start("VoidFactions.Factions.RequestRankingPage")
		net.WriteUInt(page, 12)
		net.WriteBool(entryAmount and true or false)
		if (entryAmount) then
			net.WriteUInt(entryAmount, 7)
		end
	net.SendToServer()
end

function VoidFactions.Faction:RequestFactionRank()
	net.Start("VoidFactions.Factions.GetFactionRank")
	net.SendToServer()
end

-- Net handlers

net.Receive("VoidFactions.Factions.NetworkNewFaction", function (len, ply)
	local faction = VoidFactions.Faction:ReadFaction()
	VoidFactions.LoadedFactions[faction.id] = faction

	VoidFactions.PrintDebug("Received new faction " .. faction.name .. "!")
end)

net.Receive("VoidFactions.Factions.SendRankingPage", function (len, ply)
	local page = net.ReadUInt(12)
	local entryCount = net.ReadUInt(20)
	local isAdmin = net.ReadBool()

	local length = net.ReadUInt(7)

	local factions = {}
	if (isAdmin) then
		for i = 1, length do
			local faction = VoidFactions.Faction:ReadFaction(true)
			factions[faction.id] = faction

			local count = net.ReadUInt(8)
			local maxMembers = net.ReadUInt(10)

			faction.count = count
			faction.maxMembers = maxMembers
		end
	else
		for i = 1, length do
			local rank = net.ReadUInt(20)
			local id = net.ReadUInt(20)
			local name = net.ReadString()
			local level = net.ReadUInt(14)
			local count = net.ReadUInt(8)
			local canJoin = net.ReadBool()
			local maxMembers = net.ReadUInt(10)


			factions[rank] = {
				id = id,
				name = name,
				rank = rank,
				level = level,
				count = count,
				canJoin = canJoin,
				maxMembers = maxMembers,
			}
		end
	end

	entryCount = entryCount or 0

	if (isAdmin) then
		hook.Run("VoidFactions.Factions.ReceivedFactionPage", page, factions, entryCount)
	else
		hook.Run("VoidFactions.Factions.ReceivedRankingPage", page, factions, math.ceil(entryCount / 6))
	end
end)

net.Receive("VoidFactions.Factions.SendFactionRank", function (len, ply)
	local rank = net.ReadUInt(20)

	local member = VoidFactions.PlayerMember
	local faction = member.faction
	if (faction) then
		faction:SetFactionRanking(rank)
	end
end)

net.Receive("VoidFactions.Faction.UpdateFactionData", function ()
	local factionId = net.ReadUInt(20)
	local type = net.ReadUInt(3)

	if (!VoidFactions.PlayerMember) then return end

	local faction = VoidFactions.PlayerMember and VoidFactions.PlayerMember.faction
	if ( (faction and faction.id != factionId) or !faction ) then
		VoidFactions.PrintDebug("Updating ranks info!")
		faction = VoidFactions.LoadedFactions[factionId]
	end

	
	if (!faction) then
		VoidFactions.PrintError("Tried to update faction data, but player's faction doesn't exist on clientside!")
		return
	end

	if (type == VoidFactions.Faction.Enums.UPGRADES_UPDATE) then
		local upgradeCount = net.ReadUInt(10)
		local upgrades = {}
		for i = 1, upgradeCount do
			local upgrade = net.ReadUInt(10)
			upgrades[upgrade] = true
		end

		local upgrPoints = net.ReadUInt(24)
		faction:SetUpgrades(upgrades)
		faction:SetSpentUpgradePoints(upgrPoints)
	end

	if (type == VoidFactions.Faction.Enums.REWARDS_UPDATE) then
		VoidFactions.PrintDebug("Received rewards update!")
		VoidFactions.FactionRewards:ReadReward(faction)
	end

	if (type == VoidFactions.Faction.Enums.XP_UPDATE) then
		local xp = net.ReadUInt(32)
		local level = nil
		if (net.ReadBool()) then
			level = net.ReadUInt(14)
		end

		VoidFactions.PrintDebug("Updating XP data!")
		faction:SetXP(xp)
		if (level) then
			faction:SetLevel(level)
		end
	end

	if (type == VoidFactions.Faction.Enums.DEPOSITS_UPDATE) then

		local money = net.ReadUInt(32)
		faction:SetMoney(money)

		local length = net.ReadUInt(16)

		VoidFactions.PrintDebug("Updating deposit items data! Length: " .. length)

		faction.deposits = {}
		faction.transactions = {}

		for i = 1, length do
			local item = VoidFactions.DepositItem:ReadItem(faction)
			faction.deposits[item.id] = item
		end

		local lengthTransaction = net.ReadUInt(16)

		for i = 1, lengthTransaction do
			VoidFactions.Transactions:ReadTransaction(faction)
		end

	end

	-- Update ranks
	if (type == VoidFactions.Faction.Enums.RANKS_UPDATE) then
		local length = net.ReadUInt(16)

		VoidFactions.PrintDebug("Updating rank data! Length: " .. length)

		-- Empty the table so deleted ranks won't show up
		faction.ranks = {}


		for i = 1, length do
			-- Reading the rank with the faction parameter automatically updates the rank
			local rank = VoidFactions.Rank:ReadRank(faction)
			faction.ranks[rank.id] = rank
		end
	end

	if (type == VoidFactions.Faction.Enums.MEMBERS_UPDATE) then
		local length = net.ReadUInt(16)

		VoidFactions.PrintDebug("Updating member data! Length: " .. length)

		-- Empty the table so removed members won't show up
		faction.members = {}

		for i = 1, length do
			-- Reading the member with the faction parameter automatically updates the rank
			local member = VoidFactions.Member:ReadMember(false, faction)
			faction.members[#faction.members + 1] = member
		end

		local menuPanel = VoidFactions.Menu.Panel
		if (IsValid(menuPanel) and menuPanel.sidebar.selectedPanel:GetName() == "VoidFactions.UI.SettingsPanel") then
			local settings = menuPanel.sidebar.selectedPanel
			local editFrame = settings.factions.panel.factionInfo.rankEditFrame

			if (IsValid(editFrame)) then

				-- For some reason, the reference to the rank differs in the panel. We need to replace it so it has the updated faction members
				local newRankRef = nil
				local editFrameRef = editFrame.editedRank
				if (!editFrameRef) then return end
				if (editFrameRef.faction.id != faction.id) then return end
				for k, v in pairs(faction.ranks) do
					if (v.id == editFrameRef.id) then
						newRankRef = v
					end
				end
				editFrame.editedRank = newRankRef
				
				-- This updates all the members
				editFrame.searchInput.entry:SetValue("")
			end
		end

	end

	hook.Run("VoidFactions.Faction.DataUpdated", faction)
end)

net.Receive("VoidFactions.Faction.SendFactionMemberChunk", function ()
	local factionId = net.ReadUInt(20)
	local intSize = net.ReadUInt(16)
	local skip = net.ReadUInt(32)

	local faction = VoidFactions.LoadedFactions[factionId]
	if (!faction) then
		VoidFactions.PrintError("Received member chunks for faction id " .. factionId .. ", but faction doesn't exist on client!")
		return
	end

	local memberCount = net.ReadUInt(16)
	local members = {}
	for i = 1, memberCount do
		local member = VoidFactions.Member:ReadMember(false, faction)
		members[i + skip] = member
	end

	PrintTable(members)
	faction:SetMembers(members)
end)

-- This actually sends the members too.
net.Receive("VoidFactions.Faction.SendFactionRanks", function ()
	local factionId = net.ReadUInt(20)
	local rankAmount = net.ReadUInt(5)

	local faction = VoidFactions.LoadedFactions[factionId]
	if (!faction) then
		VoidFactions.PrintError("Received ranks for faction id " .. factionId .. ", but faction doesn't exist on client!")
		return
	end

	VoidFactions.PrintDebug("Received " .. rankAmount .. " ranks from faction " .. faction.name)

	local ranks = {}
	for i = 1, rankAmount do
		local rank = VoidFactions.Rank:ReadRank(faction)
		ranks[rank.id] = rank
	end
	faction:SetRanks(ranks)

	local memberCount = net.ReadUInt(16)
	local members = {}
	for i = 1, memberCount do
		local member = VoidFactions.Member:ReadMember(false, faction)
		members[i] = member
	end
	faction:SetMembers(members)

	local menuPanel = VoidFactions.Menu.Panel
	if (IsValid(menuPanel) and menuPanel.sidebar.selectedPanel:GetName() == "VoidFactions.UI.SettingsPanel") then
		VoidFactions.PrintDebug("Refreshing settings faction ranks")
		local settings = menuPanel.sidebar.selectedPanel
		if (settings.factions.panel.factionInfo.selectedFaction.id == faction.id) then
			settings.factions.panel.factionInfo:SetRanks(faction)
		end
	end

	hook.Run("VoidFactions.Faction.RanksMembersReceived", faction, membersAvail)
	hook.Run("VoidFactions.Faction.DataUpdated", faction)

end)

net.Receive("VoidFactions.Faction.NetworkFactions", function ()
	local factionCount = net.ReadUInt(20)

	local factions = {}
	for i = 1, factionCount do
		local faction = VoidFactions.Faction:ReadFaction()
		factions[faction.id] = faction
		VoidFactions.PrintDebug("Loaded faction name " .. faction.name .. "!")
	end

	if (VoidFactions.Settings:IsStaticFactions()) then
		-- Now we have loaded the factions, let's build the subfactions
		for id, faction in pairs(factions) do
			if (faction.parentFactionId) then
				local parentFaction = factions[faction.parentFactionId]
				VoidFactions.PrintDebug("Assigning parent faction " .. parentFaction.name .. " to " .. faction.name)
				faction.parentFaction = parentFaction
			end
		end
	end

	VoidFactions.PrintDebug("Loaded " .. table.Count(factions) .. " factions!")

	VoidFactions.LoadedFactions = factions

	-- If the menu is open, refresh the factions for the admin
	local menuPanel = VoidFactions.Menu.Panel
	if (IsValid(menuPanel) and menuPanel.sidebar.selectedPanel:GetName() == "VoidFactions.UI.SettingsPanel") then
		if (VoidFactions.Settings:IsStaticFactions()) then
			VoidFactions.PrintDebug("Refreshing settings factions")
			local settings = menuPanel.sidebar.selectedPanel
			settings.factions.panel.factionSelection:SetFactions(factions)
		end
	end

	hook.Run("VoidFactions.Faction.StaticFactionsLoaded")
end)