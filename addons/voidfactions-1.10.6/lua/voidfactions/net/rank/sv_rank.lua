local L = VoidFactions.Lang.GetPhrase

VoidFactions.RankTemplates = VoidFactions.RankTemplates or {}

util.AddNetworkString("VoidFactions.Rank.CreateRank")
util.AddNetworkString("VoidFactions.Rank.UpdateRank")
util.AddNetworkString("VoidFactions.Rank.DeleteRank")
util.AddNetworkString("VoidFactions.Rank.UpdateRankWeight")

util.AddNetworkString("VoidFactions.Rank.SendRankTemplates")

function VoidFactions.Rank:SendRankTemplates(ply)

	net.Start("VoidFactions.Rank.SendRankTemplates")
		net.WriteUInt(table.Count(VoidFactions.RankTemplates), 7)
		for k, rank in pairs(VoidFactions.RankTemplates) do
			VoidFactions.Rank:WriteRank(rank)
		end
	if (ply) then
		net.Send(ply)
	else
		local players = {}
		for k, ply in ipairs(player.GetHumans()) do
			if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[0]) then
				players[#players + 1] = ply
			end
		end

		net.Send(players)
	end
end


net.Receive("VoidFactions.Rank.UpdateRank", function (len, ply)

	local rankId = net.ReadUInt(20)
	local factionId = net.ReadUInt(20)

	local name = net.ReadString()
	local tag = net.ReadString()
	local maxMembers = net.ReadUInt(16)

	local canInvite = net.ReadBool()
	local canPromote = net.ReadUInt(2)
	local canDemote = net.ReadUInt(2)
	local canPurchasePerks = net.ReadBool()
	local kickMembers = net.ReadUInt(2)
	local manageFaction = net.ReadBool()
	local minLevel = net.ReadUInt(12)
	local jobs = net.ReadTable()

	local autoPromoteLevel = 0
	local promoteDefault = {}
	if (VoidFactions.Settings:IsStaticFactions()) then
		autoPromoteLevel = net.ReadUInt(12)
		local promoteDefaultTbl = net.ReadTable()

		for k, v in pairs(promoteDefaultTbl) do
			local fac = VoidFactions.Factions[v]
			if (!fac) then continue end

			promoteDefault[fac.id] = fac
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
	
	local faction = VoidFactions.Factions[factionId]
	local rank = nil
	local isTemplate = false

	if (factionId == 0 and VoidFactions.Settings:IsStaticFactions() and CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then
		local rankTemplates = VoidFactions.RankTemplates
		rank = rankTemplates[rankId]
		if (!rank) then return end

		rank.faction = "template"
		isTemplate = true
	else
		if (!faction) then
			VoidFactions.PrintWarning(ply:Name() .. " tried to create a rank, but the supplied faction doesn't exist!")
			return
		end

		local member = ply:GetVFMember()
		if (!member:Can("ManageFaction", faction)) then return end

		rank = faction.ranks[rankId]
		if (!rank) then
			VoidFactions.PrintWarning(ply:Name() .. " tried to update a rank, but the supplied rank doesn't exist!")
			return
		end

		local validation, msg = VoidFactions.Rank:ValidateRank(name, maxMembers, jobs)
		if (!validation) then
			VoidFactions.PrintError("Server-side validation of rank data failed! (" .. msg .. ")")
			return
		end

		if (VoidFactions.Settings:IsDynamicFactions()) then
			local isHigher = member.rank:CompareWeight(rank)
			if (!isHigher and member.rank != rank) then
				return
			end
		end
	end

	rank:SetName(name)

	if (!VoidFactions.Settings:IsDynamicFactions() or !rank:IsTopRank()) then
		rank:SetTag(tag)
		rank.maxMembers = maxMembers

		rank:SetPromoteDefault(promoteDefault)

		rank.canInvite = canInvite
		rank.canPromote = canPromote
		rank.canDemote = canDemote
		rank.canPurchasePerks = canPurchasePerks
		rank.kickMembers = kickMembers
		rank.manageFaction = manageFaction

		rank.canWithdrawItems = canWithdrawItems
		rank.canDepositItems = canDepositItems
		rank.canWithdrawMoney = canWithdrawMoney
		rank.canDepositMoney = canDepositMoney

		rank.autoPromoteLevel = autoPromoteLevel
		
		rank:SetJobs(jobs)
		rank:SetMinLevel(minLevel)
	end

	rank:Save()

	if (!isTemplate) then
		VoidFactions.Faction:UpdateFactionRanks(faction)

		local membersTbl = {}
		local members = rank:GetMembers()
		for k, v in ipairs(rank:GetMembers()) do
			if (IsValid(v.ply)) then
				membersTbl[#membersTbl + 1] = v
			end
		end

		VoidFactions.NameTags:UpdateFactionTags(faction)

		-- Network to members inside faction
		VoidFactions.Member:UpdateMemberFields(membersTbl, {
			{"faction", rank.faction},
		})
	else
		VoidFactions.Rank:SendRankTemplates()
	end
	
	VoidLib.Notify(ply, L"success", L("rankUpdated", name), VoidUI.Colors.Green, 5)

end)

net.Receive("VoidFactions.Rank.DeleteRank", function (len, ply)

	local factionId = net.ReadUInt(20)
	
	local rankId = net.ReadUInt(20)

	local isTemplate = factionId == 0 and VoidFactions.Settings:IsStaticFactions() and CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")

	local faction = VoidFactions.Factions[factionId]
	if (!faction and !isTemplate) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to delete a rank, but the supplied faction doesn't exist!")
		return
	end

	local member = ply:GetVFMember()
	if (!member:Can("ManageFaction", faction)) then return end

	local rank = isTemplate and VoidFactions.RankTemplates[rankId] or faction.ranks[rankId]
	if (!rank) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to delete a rank, but the supplied rank doesn't exist!")
		return
	end

	if (VoidFactions.Settings:IsDynamicFactions() and rank:IsTopRank()) then return end
	
	local phrase = L("rankDeleted", rank.name)

	if (!isTemplate) then
		local rankMembers = rank:GetMembers()
		if (#rankMembers > 0) then
			local thisIteration = false
			local lowerRank = nil
			for k, v in SortedPairsByMemberValue(faction.ranks, "weight") do
				if (v == rank) then 
					thisIteration = true 
					continue 
				end
				if (thisIteration) then
					lowerRank = v
				end
			end

			if (!lowerRank) then
				VoidLib.Notify(ply, L"error", L("membersInRankErr", rank.name), VoidUI.Colors.Red, 10)
				return
			end

			phrase = phrase .. " " .. L("memberCountDemoted", #rankMembers)
			for _, member in ipairs(rankMembers) do
				member:SetRank(lowerRank)
				VoidFactions.PrintDebug("Demoting member to " .. lowerRank.id)
				member:SaveStatic()
			end
		end
	end

	
	VoidFactions.SQL:DeleteRank(rank)
	VoidLib.Notify(ply, L"success", phrase, VoidUI.Colors.Red, 5)

end)

net.Receive("VoidFactions.Rank.UpdateRankWeight", function (len, ply)

	local factionId = net.ReadUInt(20)
	
	local rankId = net.ReadUInt(20)
	local weight = net.ReadUInt(16)

	local isTemplate = factionId == 0 and VoidFactions.Settings:IsStaticFactions() and CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")

	local faction = VoidFactions.Factions[factionId]
	if (!faction and !isTemplate) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to update rank weight, but the supplied faction doesn't exist!")
		return
	end

	local member = ply:GetVFMember()
	if (!member:Can("ManageFaction", faction)) then return end

	local rank = isTemplate and VoidFactions.RankTemplates[rankId] or faction.ranks[rankId]
	if (!rank) then
		VoidFactions.PrintWarning(ply:Name() .. " tried to update rank weight, but the supplied rank doesn't exist!")
		return
	end

	rank.weight = weight
	rank:Save()
	if (isTemplate) then
		VoidFactions.Rank:SendRankTemplates()
	else
		VoidFactions.Faction:UpdateFactionRanks(faction)
	end
end)

net.Receive("VoidFactions.Rank.CreateRank", function (len, ply)

	local factionId = net.ReadUInt(20)

	local name = net.ReadString()
	local tag = net.ReadString()
	local maxMembers = net.ReadUInt(16)

	local canInvite = net.ReadBool()
	local canPromote = net.ReadUInt(2)
	local canDemote = net.ReadUInt(2)
	local canPurchasePerks = net.ReadBool()
	local kickMembers = net.ReadUInt(2)
	local manageFaction = net.ReadBool()
	local minLevel = net.ReadUInt(12)
	local jobs = net.ReadTable()

	local autoPromoteLevel = 0
	local promoteDefault = {}
	if (VoidFactions.Settings:IsStaticFactions()) then
		autoPromoteLevel = net.ReadUInt(12)

		local promoteDefaultTbl = net.ReadTable()
		for k, v in ipairs(promoteDefaultTbl) do
			local fac = VoidFactions.Factions[v]
			if (!fac) then continue end

			promoteDefault[fac.id] = fac
		end
	end

	local canWithdrawMoney = nil 
	local canDepositMoney = nil
	local canWithdrawItems = nil 
	local canDepositItems = nil
	if (VoidFactions.Settings:IsDynamicFactions()) then
		canWithdrawMoney = net.ReadBool()
		canDepositMoney = net.ReadBool()
		canWithdrawItems = net.ReadBool()
		canDepositItems = net.ReadBool()
	end

	if (factionId == 0 and VoidFactions.Settings:IsStaticFactions() and CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then
		local rankTemplates = VoidFactions.RankTemplates

		
		local validation, msg = VoidFactions.Rank:ValidateRank(name, maxMembers, jobs)
		if (!validation) then
			VoidFactions.PrintError("Server-side validation of rank data failed! (" .. msg .. ")")
			return
		end

		local maxAmount = VoidFactions.Settings.Hardcoded.MaxRanksInFaction
		if (rankTemplates and table.Count(rankTemplates) >= maxAmount) then
			VoidLib.Notify(ply, L"error", L("maxRanksCreated", {["name"] = name, ["limit"] = maxAmount}), VoidUI.Colors.Red, 5)
			return
		end

		VoidFactions.SQL:CreateRank("template", name, table.Count(rankTemplates or {})+1, tag, maxMembers, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, jobs, minLevel, nil, nil, nil, nil, autoPromoteLevel, promoteDefault)
		VoidLib.Notify(ply, L"success", L("rankCreated", name), VoidUI.Colors.Green, 5)

	else
		local faction = VoidFactions.Factions[factionId]
		if (!faction) then
			VoidFactions.PrintWarning(ply:Name() .. " tried to create a rank, but the supplied faction doesn't exist!")
			return
		end

		local member = ply:GetVFMember()
		if (!member:Can("ManageFaction", faction)) then return end

		local validation, msg = VoidFactions.Rank:ValidateRank(name, maxMembers, jobs)
		if (!validation) then
			VoidFactions.PrintError("Server-side validation of rank data failed! (" .. msg .. ")")
			return
		end

		local maxAmount = VoidFactions.Settings.Hardcoded.MaxRanksInFaction
		if (faction.ranks and table.Count(faction.ranks) >= maxAmount) then
			VoidLib.Notify(ply, L"error", L("maxRanksCreated", {["name"] = name, ["limit"] = maxAmount}), VoidUI.Colors.Red, 5)
			return
		end

		VoidFactions.SQL:CreateRank(faction, name, table.Count(faction.ranks or {})+1, tag, maxMembers, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, jobs, minLevel, nil, nil, nil, nil, autoPromoteLevel, promoteDefault)
		VoidLib.Notify(ply, L"success", L("rankCreated", name), VoidUI.Colors.Green, 5)
	end

end)
