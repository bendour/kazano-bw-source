VoidFactions.Utils = VoidFactions.Utils or {}
VoidFactions.Utils.SyncedFactionPlayers = VoidFactions.Utils.SyncedFactionPlayers or {}

if (SERVER) then
	util.AddNetworkString("VoidFactions.Utils.SyncFactionInfo")
	util.AddNetworkString("VoidFactions.Utils.InitialSyncFactionInfo")

	local function syncPlayer(pPlayer, tbl)
		net.Start("VoidFactions.Utils.SyncFactionInfo")
			net.WriteEntity(pPlayer)
			net.WriteBool(!!tbl)
			if (tbl) then
				net.WriteTable(tbl)
			end
		net.Broadcast()
	end
	
	local function playerMakeStruct(pPlayer)
		local strFactionName = pPlayer:GetVFFaction() and pPlayer:GetVFFaction().name
		local strRankName = strFactionName and pPlayer:GetVFMember().rank.name
		local intRankId = strRankName and pPlayer:GetVFMember().rank.id
		local colFactionColor = strFactionName and pPlayer:GetVFFaction().color
		local tag = strFactionName and pPlayer:GetVFFaction().tag
		local rankTag = strFactionName and pPlayer:GetVFMember().rank.tag
		local factionLogo = pPlayer:GetVFFaction() and pPlayer:GetVFFaction().logo

		return { faction = strFactionName, rank = strRankName, rankId = intRankId, factionColor = colFactionColor, tag = tag, rankTag = rankTag, factionLogo = factionLogo }
	end

	local function syncFaction(facFaction)
		for k, memMember in pairs(facFaction.members or {}) do
			if (IsValid(memMember.ply)) then
				local tblStruct = playerMakeStruct(memMember.ply)

				VoidFactions.Utils.SyncedFactionPlayers[memMember.ply] = tblStruct
				syncPlayer(memMember.ply, tblStruct)
			end
		end
	end

	hook.Add("VoidLib.PlayerFullLoad", "VoidFactions.Utils.InitialNameSync", function (pPlayer)
		net.Start("VoidFactions.Utils.InitialSyncFactionInfo")
			net.WriteTable(VoidFactions.Utils.SyncedFactionPlayers)
		net.Send(pPlayer)
	end)

	hook.Add("VoidFactions.SQL.MemberLoaded", "VoidFactions.Utils.SyncFactionNames", function (pPlayer)
		local tblStruct = playerMakeStruct(pPlayer)

		VoidFactions.Utils.SyncedFactionPlayers[pPlayer] = tblStruct
		syncPlayer(pPlayer, tblStruct)
	end)

	hook.Add("VoidFactions.UpdatedFactionMembers", "VoidFactions.Utils.SyncFactionMembersUpdate", function (facFaction, tblMembers)
		syncFaction(facFaction)
	end)

	hook.Add("VoidFactions.UpdateFactionInfo", "VoidFactions.Utils.UpdateInfoSync", function (facFaction)
		syncFaction(facFaction)
	end)

	hook.Add("VoidFactions.UpdateRankInfo", "VoidFactions.Utils.UpdateRankInfoSync", function (rankRank, facFaction)
		if (!facFaction) then return end
		syncFaction(facFaction)
	end)

	hook.Add("VoidFactions.MemberLeft", "VoidFactions.Utils.SyncDeleteMember", function (memMember)
		local pPlayer = memMember.ply
		if (!IsValid(pPlayer)) then return end

		VoidFactions.Utils.SyncedFactionPlayers[pPlayer] = nil
		syncPlayer(pPlayer)
	end)

	hook.Add("PlayerDisconnected", "VoidFactions.Utils.SyncFactionNamesDelete", function (pPlayer)
		VoidFactions.Utils.SyncedFactionPlayers[pPlayer] = nil
		syncPlayer(pPlayer)
	end)
end

if (CLIENT) then
	net.Receive("VoidFactions.Utils.SyncFactionInfo", function (intLen)
		local pPlayer = net.ReadEntity()
		local bNewData = net.ReadBool()
		local tblStruct = nil

		if (bNewData) then
			tblStruct = net.ReadTable()
		end

		if (!IsValid(pPlayer)) then return end

		VoidFactions.Utils.SyncedFactionPlayers[pPlayer] = tblStruct
	end)

	net.Receive("VoidFactions.Utils.InitialSyncFactionInfo", function (intLen)
		local tbl = net.ReadTable()
		VoidFactions.Utils.SyncedFactionPlayers = tbl
	end)
end

VoidFactions.Utils.NetCooldownTime = 2

function VoidFactions.Utils:BuildSubfactions(factions)
    -- holy shit
    local rootFactions = {}

	for _, faction in pairs(table.Copy(factions)) do
		if (rootFactions[faction.id]) then continue end
		-- Root faction -> factions -> faction -> subfactions
		local isRoot = !faction.parentFaction
		local isFaction = !isRoot and !faction.parentFaction.parentFaction or false 
		local isSubfaction = !isFaction and !isRoot

		if (isRoot) then
			rootFactions[faction.id] = faction
		end
		if (isFaction) then
			local parentFaction = rootFactions[faction.parentFaction.id]
			if (!parentFaction) then
				parentFaction = faction.parentFaction
			end
			if (!rootFactions[faction.parentFaction.id] or !rootFactions[faction.parentFaction.id].subfactions) then
				parentFaction.subfactions = {}
			end
			parentFaction.subfactions[faction.id] = faction
		end
		if (isSubfaction) then
			local rootFaction = rootFactions[faction.parentFaction.parentFaction.id]
			if (!rootFaction) then
				rootFaction = faction.parentFaction.parentFaction
			end
			if (!rootFaction.subfactions) then
				rootFaction.subfactions = {}
			end
			if (!rootFaction.subfactions[faction.parentFaction.id]) then
				rootFaction.subfactions[faction.parentFaction.id] = faction.parentFaction
			end
			if (!rootFaction.subfactions[faction.parentFaction.id].subfactions) then
				rootFaction.subfactions[faction.parentFaction.id].subfactions = {}
			end
			rootFaction.subfactions[faction.parentFaction.id].subfactions[faction.id] = faction
		end
	end

    return rootFactions
end

function VoidFactions.Utils:NetMessageCooldown(ply, time)
	if (VoidFactions.Utils:IsOnNetCooldown(ply)) then return true end
	VoidFactions.Utils:ActivateNetCooldown(ply, time)
	return false
end

function VoidFactions.Utils:IsOnNetCooldown(ply)
	return ply.vf_cooldownEnd and ply.vf_cooldownEnd > SysTime()
end

function VoidFactions.Utils:ActivateNetCooldown(ply, time)
	ply.vf_cooldownEnd = SysTime() + (time or VoidFactions.Utils.NetCooldownTime)
end
