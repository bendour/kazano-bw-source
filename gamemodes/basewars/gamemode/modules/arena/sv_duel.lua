util.AddNetworkString("OpenArenaMenu")
util.AddNetworkString("SendDuelRequest")
util.AddNetworkString("DuelRequest")
util.AddNetworkString("DuelResponse")
util.AddNetworkString("RequestLeaderboard")
util.AddNetworkString("UpdateLeaderboard")
util.AddNetworkString("DuelEndMessage")
util.AddNetworkString("StartDuelCountdown")
util.AddNetworkString("CloseDuelRequest")
local activeDuels = {}
local pendingDuels = {}
local isDuelInviteActive = false
local PLAYER = FindMetaTable("Player")
hook.Add("BaseWars:InitializeDatabase", "BaseWars:arena", function()
    MySQLite.tableExists("arena_leaderboard", function(bool)
        if bool then return end
        MySQLite.query([[
            CREATE TABLE arena_leaderboard(
            steamID64 VARCHAR(17) PRIMARY KEY,
            pseudo TEXT NOT NULL,
            wins INTEGER UNSIGNED NOT NULL
        )]], function() end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end)

local function SaveLeaderboardToMySQL(steamID64, pseudo, wins)
    MySQLite.query(Format([[
        INSERT OR REPLACE INTO arena_leaderboard (steamID64, pseudo, wins)
        VALUES (%s, %s, %d)
    ]], MySQLite.SQLStr(steamID64), MySQLite.SQLStr(pseudo), wins), function() end, BaseWarsSQLError)
end

local function LoadLeaderboardFromMySQL(callback)
    MySQLite.query("SELECT * FROM arena_leaderboard ORDER BY wins DESC", function(data)
        if data then
            callback(data)
        else
            callback({})
        end
    end, BaseWarsSQLError)
end

hook.Add("Initialize", "LoadLeaderboardOnStart", function() LoadLeaderboardFromMySQL(function(data) leaderboard = data or {} end) end)
local function UpdateLeaderboard(winner)
    local steamID64 = winner:SteamID64()
    local nick = winner:Nick()
    local wins = 0
    MySQLite.query(Format("SELECT wins, pseudo FROM arena_leaderboard WHERE steamID64 = %s", MySQLite.SQLStr(steamID64)), function(data)
        if data and data[1] then
            wins = data[1].wins + 1
            pseudo = nick
        else
            pseudo = nick
            wins = 1
        end

        SaveLeaderboardToMySQL(steamID64, pseudo, wins)
    end, BaseWarsSQLError)
end

--local function isPlayerInArena(ply)
--local pos = ply:GetPos()
--return pos:WithinAABox(ArenaConfig.ArenaArea.min, ArenaConfig.ArenaArea.max)
--end
local function startDuel(ply1, ply2)
    local initply1 = ply1:GetPos()
    local initply2 = ply2:GetPos()
    ply1:Freeze(true)
    ply2:Freeze(true)
    ply1:SetPos(ArenaConfig.SpawnPoints[1])
    ply2:SetPos(ArenaConfig.SpawnPoints[3])
    ply1:SetHealth(200)
    ply1:SetArmor(200)
    ply2:SetHealth(200)
    ply2:SetArmor(200)
    ply1:StripWeapons()
    ply2:StripWeapons()
    ply1:Give("arccw_bo2_peacekeeper")
    ply2:Give("arccw_bo2_peacekeeper")
    ply1:Give("weapon_physcannon")
    ply2:Give("weapon_physcannon")
    ply1:Give("weapon_physgun")
    ply2:Give("weapon_physgun")
    ply1:Give("gmod_camera")
    ply2:Give("gmod_camera")
    ply1:Give("gmod_tool")
    ply2:Give("gmod_tool")
    ply1:GiveAmmo(1000, "SMG1", true)
    ply2:GiveAmmo(1000, "SMG1", true)
    ply1:SetEyeAngles(ArenaConfig.SpawnPoints[2]:Angle())
    ply2:SetEyeAngles(ArenaConfig.SpawnPoints[4]:Angle())
    local compteur = 3
    net.Start("StartDuelCountdown")
    net.WriteInt(compteur, 32)
    net.Send({ply1, ply2})
    timer.Create("DuelCountdown", 1, compteur, function()
        compteur = compteur - 1
        if compteur <= 0 then
            ply1:Freeze(false)
            ply2:Freeze(false)
            timer.Remove("DuelCountdown")
        end
    end)

    activeDuels[ply1] = {
        opponent = ply2,
        initialPos = initply1
    }

    activeDuels[ply2] = {
        opponent = ply1,
        initialPos = initply2
    }
end

local function endDuel(winner, loser)
    local winnerData = activeDuels[winner]
    local loserData = activeDuels[loser]
    if winnerData and loserData then
        UpdateLeaderboard(winner)
        local compteur = 2
        timer.Create("EndDuelCountdown", 1, compteur, function()
            compteur = compteur - 1
            if compteur <= 0 then
                timer.Remove("EndDuelCountdown")
                winner:KillSilent()
                winner:Spawn()
                winner:SetPos(winnerData.initialPos)
                loser:Spawn()
                loser:SetPos(loserData.initialPos)
                activeDuels[winner] = nil
                activeDuels[loser] = nil
                net.Start("DuelEndMessage")
                net.WriteString(winner:Nick())
                net.WriteString(loser:Nick())
                net.Broadcast()
            end
        end)
    end
end

net.Receive("SendDuelRequest", function(len, ply)
    local target = net.ReadEntity()
    if target == ply then
       ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: Vous ne pouvez pas vous auto inviter.")
       return
    end
    if IsValid(target) and target:IsPlayer() then
        if next(activeDuels) ~= nil then
            ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: Un duel est déjà en cours.")
            return
        end
        if ply:InRaid() then
            ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: Vous ne pouvez pas inviter quelqu'un en raid.")
            return
        end
        if target:InRaid() then
            ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: " .. target:Nick() .. " est actuellement en raid.")
            return
        end
		if isDuelInviteActive then
    		ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: Une invitation de duel est déjà en cours, attendez que celle-ci soit terminée.")
    		return
		end
        if not pendingDuels[target] then
            pendingDuels[target] = ply
            net.Start("DuelRequest")
            net.WriteEntity(ply)
            net.Send(target)
            isDuelInviteActive = true

            ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: Requête de duel envoyée à " .. target:Nick())

            -- Démarrer un timer pour refuser automatiquement après 30 secondes
            local duelTimerID = "AutoDuelReject_" .. target:SteamID64()

            timer.Create(duelTimerID, 30, 1, function()
                if pendingDuels[target] then  -- Vérifie si la requête est toujours active
                    ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: " .. target:Nick() .. " n'a pas répondu.")
                    pendingDuels[target] = nil
                    net.Start("DuelResponse")
                    net.WriteBool(false)  -- Envoyer le refus
                    net.Send(ply)
                    net.Start("CloseDuelRequest")
                    net.Send(target)
                    isDuelInviteActive = false
                end
            end)
        else
            ply:ChatPrint(":duel1::duel2::duel3::duel4::duel5: " .. target:Nick() .. " a déjà une demande de duel en attente.")
        end
    end
end)

net.Receive("DuelResponse", function(len, ply)
    local accept = net.ReadBool()
    local requester = pendingDuels[ply]

    if accept and IsValid(requester) then
        startDuel(ply, requester)
        isDuelInviteActive = false
    else
        if IsValid(requester) then
            requester:ChatPrint(":duel1::duel2::duel3::duel4::duel5: " .. ply:Nick() .. " a refusé votre demande de duel.")
            isDuelInviteActive = false
        end
    end

    -- Annuler le timer d'auto-refus
    local duelTimerID = "AutoDuelReject_" .. ply:SteamID64()
    if timer.Exists(duelTimerID) then
        timer.Remove(duelTimerID)
    end

    pendingDuels[ply] = nil
end)

hook.Add("PlayerDeath", "ArenaPlayerDeath", function(victim, inflictor, attacker)
    if activeDuels[victim] then
        local duelData = activeDuels[victim]
        local opponent = duelData.opponent
        if IsValid(opponent) then endDuel(opponent, victim) end
    elseif activeDuels[attacker] then
        local duelData = activeDuels[attacker]
        local opponent = duelData.opponent
        if opponent == victim then endDuel(attacker, victim) end
    end
end)

net.Receive("RequestLeaderboard", function(len, ply)
    LoadLeaderboardFromMySQL(function(data)
        net.Start("UpdateLeaderboard")
        net.WriteTable(data)
        net.Send(ply)
    end)
end)

function PLAYER:InRaid()
    if not BaseWars:RaidGoingOn() then
        return false
    end

    if not raidData or not raidData.attacker or not raidData.defender then
        return false  -- Safeguard if raidData is nil or its subfields are not initialized
    end

    return raidData.attacker.players[self] ~= nil or raidData.defender.players[self] ~= nil
end