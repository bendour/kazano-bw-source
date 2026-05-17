util.AddNetworkString("BaseWars:Warnings:AddWarn")
util.AddNetworkString("BaseWars:Warnings:RemoveWarn")
util.AddNetworkString("BaseWars:Warnings:DeleteAllWarn")
util.AddNetworkString("BaseWars:Warnings:EditWarn")
util.AddNetworkString("BaseWars:Warnings:RequestPlayerData")
util.AddNetworkString("BaseWars:Warnings:SendDataToClient")
util.AddNetworkString("BaseWars:Warnings:ChatNotifyServer")

--[[-------------------------------------------------------------------------
	MARK: Discord Webhook Configuration
---------------------------------------------------------------------------]]
local WARNINGS_WEBHOOK_URL = "https://discord.com/api/webhooks/1446780775365214411/ssqxjo8M7oSqpD-itTxLzLzbJgKm4e0M6YGWgFnCpbe_AUcLwoLUf9t4oP0Hif2yAtDR" -- Remplacez par votre URL de webhook Discord

local function SendWarningToDiscord(player_id64, admin_id64, reason, adminName, playerName)
    if WARNINGS_WEBHOOK_URL == "METTRE_VOTRE_WEBHOOK_ICI" then return end
    
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%S") -- Format ISO 8601 pour Discord
    
    -- Formater les noms avec SteamID
    local staffDisplay = admin_id64 ~= "0" and string.format("[%s](https://steamcommunity.com/profiles/%s) (`%s`)", adminName or "Inconnu", admin_id64, admin_id64) or "🖥️ Console"
    local playerDisplay = string.format("[%s](https://steamcommunity.com/profiles/%s) (`%s`)", playerName or "Inconnu", player_id64, player_id64)
    
    local payload = {
        username = "Kazano Warnings",
        embeds = {
            {
                title = "⚠️ Nouveau Warn",
                color = 16711680,
                fields = {
                    {
                        name = "👮 Staff",
                        value = staffDisplay,
                        inline = false
                    },
                    {
                        name = "🎮 Joueur Warn",
                        value = playerDisplay,
                        inline = false
                    },
                    {
                        name = "📝 Raison",
                        value = reason,
                        inline = false
                    }
                },
                timestamp = timestamp,
                footer = {
                    text = "Kazano - Système de Warnings"
                }
            }
        }
    }
    
    reqwest({
        method = "POST",
        url = WARNINGS_WEBHOOK_URL,
        timeout = 30,
        body = util.TableToJSON(payload),
        type = "application/json",
        headers = {
            ["User-Agent"] = "Garry's Mod Server",
        },
        success = function(status, body, headers)
        end,
        failed = function(err, errExt)
            BaseWars:Warning("Discord Webhook Warning failed: " .. tostring(err))
        end
    })
end

--[[-------------------------------------------------------------------------
	MARK: Local Functions
---------------------------------------------------------------------------]]

--[[-------------------------------------------------------------------------
	MARK: Global Functions
---------------------------------------------------------------------------]]
function BaseWars.Warns:GetWarnings(ply)
    return IsValid(ply) and ply.basewarsWarnings or {}
end

function BaseWars.Warns:Notify(player_id64, text, type, ...)
    BaseWars:Notify(BaseWars:FindPlayer(player_id64), text, type, 5, ...)
end

function BaseWars.Warns:AddWarning(player_id64, admin_id64, reason)
    if not player_id64 then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.Warns:AddWarning(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    local ply = BaseWars:FindPlayer(player_id64)
    local date = os.time()

    admin_id64 = string.Trim(tostring(admin_id64))
    if admin_id64 == nil or admin_id64 == "nil" or admin_id64 == "" then
        admin_id64 = "0"
    end

    reason = (reason and string.Trim(reason) != "") and reason or "no reason"

    MySQLite.query(Format("INSERT INTO basewars_warnings(player_id64, admin_id64, date, reason) VALUES(%s, %s, %s, %s)", player_id64, admin_id64, date, MySQLite.SQLStr(reason)), function()
        self:SendToClient(player_id64)
        self:SendToAdmin(admin_id64, player_id64)
        self:NotifyServerInChat(player_id64, reason)

        -- Récupérer les noms et envoyer le webhook Discord
        local adminPlayer = BaseWars:FindPlayer(admin_id64)
        local adminName = IsValid(adminPlayer) and adminPlayer:Nick() or nil
        local playerName = IsValid(ply) and ply:Nick() or nil
        
        -- Si le joueur n'est pas en ligne, récupérer son nom via Steam API
        if not playerName then
            BaseWars:RequestSteamName(player_id64, function(name)
                playerName = name
                if not adminName and admin_id64 ~= "0" then
                    BaseWars:RequestSteamName(admin_id64, function(aName)
                        SendWarningToDiscord(player_id64, admin_id64, reason, aName, playerName)
                    end)
                else
                    SendWarningToDiscord(player_id64, admin_id64, reason, adminName, playerName)
                end
            end)
        elseif not adminName and admin_id64 ~= "0" then
            BaseWars:RequestSteamName(admin_id64, function(aName)
                SendWarningToDiscord(player_id64, admin_id64, reason, aName, playerName)
            end)
        else
            SendWarningToDiscord(player_id64, admin_id64, reason, adminName, playerName)
        end

        if IsValid(ply) then
            self:Notify(player_id64, "#warnings_playerWarned", NOTIFICATION_GENERIC)
        end

        BaseWars:RequestSteamName(player_id64, function(name)
            self:Notify(admin_id64, "#warnings_adminWarnPlayer", NOTIFICATION_GENERIC, name)
        end)

        hook.Run("BaseWars:PlayerWarned", player_id64, admin_id64, reason)
    end, BaseWarsSQLError)
end

function BaseWars.Warns:RemoveWarning(warning_id, admin_id64)
    warning_id = warning_id
    if not warning_id then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.Warns:RemoveWarning(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    admin_id64 = string.Trim(tostring(admin_id64))
    if admin_id64 == nil or admin_id64 == "nil" or admin_id64 == "" then
        admin_id64 = "0"
    end

    MySQLite.query("SELECT player_id64, reason FROM basewars_warnings WHERE warning_id = " .. warning_id, function(exists)
        if not exists then
            self:Notify(admin_id64, "#warnings_invalidWarnID", NOTIFICATION_ERROR, warning_id)

            return
        end

        exists = exists[1]
        MySQLite.query("DELETE FROM basewars_warnings WHERE warning_id = " .. warning_id, function()
            self:SendToClient(exists.player_id64)

            BaseWars:RequestSteamName(exists.player_id64, function(name)
                self:Notify(admin_id64, "#warnings_adminRemoveWarn", NOTIFICATION_ERROR, name, exists.reason)
            end)

            hook.Run("BaseWars:AdminRemovePlayerWarn", exists.player_id64, admin_id64, exists.reason)
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end

function BaseWars.Warns:DeleteAllWarnings(player_id64, admin_id64)
    admin_id64 = string.Trim(tostring(admin_id64))
    if admin_id64 == nil or admin_id64 == "nil" or admin_id64 == "" then
        admin_id64 = "0"
    end

    if not player_id64 then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.Warns:AddWarning(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    local ply = BaseWars:FindPlayer(player_id64)
    MySQLite.query("DELETE FROM basewars_warnings WHERE player_id64 = " .. player_id64, function()
        self:SendToClient(player_id64)

        BaseWars:RequestSteamName(player_id64, function(name)
            self:Notify(admin_id64, "#warnings_adminDeleteAllWarn", NOTIFICATION_ERROR, name)
        end)

        hook.Run("BaseWars:AdminRemoveAllPlayerWarn", player_id64, admin_id64)
    end, BaseWarsSQLError)
end

function BaseWars.Warns:EditWarning(warning_id, newReason, admin_id64)
    warning_id = warning_id
    if not warning_id then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.Warns:EditWarning(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    newReason = string.Trim(newReason)
    if not newReason or newReason == "" then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.Warns:EditWarning(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    admin_id64 = string.Trim(tostring(admin_id64))
    if admin_id64 == nil or admin_id64 == "nil" or admin_id64 == "" then
        admin_id64 = "0"
    end

    MySQLite.query("SELECT player_id64, reason FROM basewars_warnings WHERE warning_id = " .. warning_id, function(exists)
        if not exists then
            self:Notify(admin_id64, "#warnings_invalidWarnID", NOTIFICATION_ERROR, warning_id)

            return
        end

        exists = exists[1]

        if exists.reason == newReason then
            self:Notify(admin_id64, "#warnings_sameWarningReason", NOTIFICATION_ERROR, warning_id)

            return
        end

        MySQLite.query(Format("UPDATE basewars_warnings SET reason = %s WHERE warning_id = %s", MySQLite.SQLStr(newReason), warning_id), function()
            self:SendToClient(exists.player_id64)

            BaseWars:RequestSteamName(exists.player_id64, function(name)
                self:Notify(admin_id64, "#warnings_adminEditWarn", NOTIFICATION_ERROR, name)
            end)

            hook.Run("BaseWars:AdminEditPlayerWarn", exists.player_id64, admin_id64, exists.reason, newReason, warning_id)
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end

function BaseWars.Warns:GetPlayerData(player_id64, func)
    local debugInfos = debug.getinfo(2)

    if not player_id64 then
        ErrorNoHalt("Invalid arg #1 for BaseWars.Warns:GetPlayerData(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    if not isfunction(func) then
        ErrorNoHalt("Invalid arg #2 for BaseWars.Warns:GetPlayerData(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    local ply = BaseWars:FindPlayer(player_id64)
    MySQLite.query("SELECT * FROM basewars_warnings WHERE player_id64 = " .. player_id64, function(result)
        if not result then
            if IsValid(ply) then
                ply.basewarsWarnings = {}
            end

            func({})

            return
        end

        local temp = {}
        for k, v in ipairs(result) do
            temp[k] = {
                warning_id = v.warning_id,
                player_id64 = v.player_id64,
                admin_id64 = v.admin_id64,
                date = tonumber(v.date),
                reason = v.reason
            }
        end

        if IsValid(ply) then
            ply.basewarsWarnings = temp
        end

        func(temp)
    end, BaseWarsSQLError)
end

function BaseWars.Warns:SendToClient(player_id64)
    local ply = BaseWars:FindPlayer(player_id64)

    if not player_id64 then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.Warns:SendToAdmin(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    if not IsValid(ply) then
        return
    end

    self:GetPlayerData(player_id64, function(data)
        if not IsValid(ply) then
            return
        end

        data = util.Compress(util.TableToJSON(data))
        net.Start("BaseWars:Warnings:SendDataToClient")
            net.WriteData(data, #data)
        net.Send(ply)
    end)
end

function BaseWars.Warns:SendToAdmin(admin_id64, player_id64)
    if admin_id64 == "0" then
        return
    end

    local admin = BaseWars:FindPlayer(admin_id64)

    if not IsValid(admin) then
        return
    end

    if not player_id64 then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #2 for BaseWars.Warns:SendToAdmin(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    self:GetPlayerData(player_id64, function(data)
        if not IsValid(admin) then
            return
        end

        data = util.Compress(util.TableToJSON(data))
        net.Start("BaseWars:Warnings:RequestPlayerData")
            net.WriteData(data, #data)
        net.Send(admin)
    end)
end

function BaseWars.Warns:NotifyServerInChat(player_id64, reason)
    BaseWars:RequestSteamName(player_id64, function(name)
        local data = util.Compress(util.TableToJSON({
            name = name,
            reason = reason
        }))

        net.Start("BaseWars:Warnings:ChatNotifyServer")
            net.WriteData(data, #data)
        net.Broadcast()
    end)
end

--[[-------------------------------------------------------------------------
	MARK: Hooks
---------------------------------------------------------------------------]]
hook.Add("BaseWars:SendNetToClient", "BaseWars:Warnings", function(ply)
    BaseWars.Warns:SendToClient(ply:SteamID64())
end)

--[[-------------------------------------------------------------------------
	MARK: Nets
---------------------------------------------------------------------------]]
net.Receive("BaseWars:Warnings:RequestPlayerData", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then
        return
    end

    local player_id64 = net.ReadString()
    BaseWars.Warns:SendToAdmin(ply:SteamID64(), player_id64)
end)

net.Receive("BaseWars:Warnings:DeleteAllWarn", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then
        return
    end

    local player_id64 = net.ReadString()
    BaseWars.Warns:DeleteAllWarnings(player_id64, ply:SteamID64())
end)

net.Receive("BaseWars:Warnings:RemoveWarn", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then
        return
    end

    local warning_id = net.ReadUInt(8)
    BaseWars.Warns:RemoveWarning(warning_id, ply:SteamID64())
end)

net.Receive("BaseWars:Warnings:AddWarn", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then
        return
    end

    local player_id64 = net.ReadString()
    local reason = net.ReadString()
    BaseWars.Warns:AddWarning(player_id64, ply:SteamID64(), reason)
end)

net.Receive("BaseWars:Warnings:EditWarn", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then
        return
    end

    local warning_id = net.ReadUInt(8)
    local reason = net.ReadString()
    BaseWars.Warns:EditWarning(warning_id, reason, ply:SteamID64())
end)

--[[-------------------------------------------------------------------------
	MARK: Console Commands
---------------------------------------------------------------------------]]
BaseWars:AddConsoleCommand("bw_warn", function(ply, args, argStr)
    local target_id64 = args[1]
    if not target_id64 or not tonumber(target_id64) then
        BaseWars:Notify(ply, "#targetNotFound", NOTIFICATION_ERROR, 5)

        return
    end

    local reason = string.sub(string.Trim(argStr), #target_id64 + 2)
    if not args[2]  or args[2] == "" then
        BaseWars:Notify(ply, "#invalidArguments", NOTIFICATION_ERROR, 5)

        return
    end

    BaseWars:RequestSteamName(target_id64, function(targetName)
        if targetName == "Error" then
            BaseWars:Notify(ply, "#targetNotFound", NOTIFICATION_ERROR, 5)

            return
        end

        BaseWars.Warns:AddWarning(target_id64, ply:IsPlayer() and ply:SteamID64() or "0", reason)
    end)
end, false, BaseWars:GetAdminGroups(true))

BaseWars:AddConsoleCommand("bw_removewarn", function(ply, args, argStr)
    local warnID = tonumber(args[1])
    if not args[1] then
        BaseWars:Notify(ply, "#invalidArgumentNumber", NOTIFICATION_ERROR, 5)

        return
    end

    BaseWars.Warns:RemoveWarning(warnID, ply:IsPlayer() and ply:SteamID64() or "0")
end, false, BaseWars:GetAdminGroups(true))