-- Server-side networking for HTML Admin Menu
-- Handles all net messages between client DHTML and server

util.AddNetworkString("BaseWars:AdminMenu:RequestPlayers")
util.AddNetworkString("BaseWars:AdminMenu:ReceivePlayers")
util.AddNetworkString("BaseWars:AdminMenu:RequestOnlinePlayers")
util.AddNetworkString("BaseWars:AdminMenu:ReceiveOnlinePlayers")
util.AddNetworkString("BaseWars:AdminMenu:RequestPlayerDetails")
util.AddNetworkString("BaseWars:AdminMenu:ReceivePlayerDetails")
util.AddNetworkString("BaseWars:AdminMenu:SearchPlayer")

util.AddNetworkString("BaseWars:AdminMenu:RequestWarnings")
util.AddNetworkString("BaseWars:AdminMenu:ReceiveWarnings")
util.AddNetworkString("BaseWars:AdminMenu:AddWarning")
util.AddNetworkString("BaseWars:AdminMenu:DeleteWarning")

util.AddNetworkString("BaseWars:AdminMenu:RequestFactions")
util.AddNetworkString("BaseWars:AdminMenu:ReceiveFactions")
util.AddNetworkString("BaseWars:AdminMenu:DisbandFaction")
util.AddNetworkString("BaseWars:AdminMenu:ChangeLeader")
util.AddNetworkString("BaseWars:AdminMenu:KickFromFaction")

util.AddNetworkString("BaseWars:AdminMenu:RequestLogs")
util.AddNetworkString("BaseWars:AdminMenu:ReceiveLogs")
util.AddNetworkString("BaseWars:AdminMenu:RequestLogCategories")
util.AddNetworkString("BaseWars:AdminMenu:ReceiveLogCategories")

util.AddNetworkString("BaseWars:AdminMenu:GotoPlayer")
util.AddNetworkString("BaseWars:AdminMenu:BringPlayer")
util.AddNetworkString("BaseWars:AdminMenu:KickPlayer")

--[[-------------------------------------------------------------------------
    Players Functions
---------------------------------------------------------------------------]]
net.Receive("BaseWars:AdminMenu:RequestPlayers", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local players = {}
    for _, p in ipairs(player.GetAll()) do
        local level = 1
        if p.GetLevel then level = p:GetLevel() end
        
        table.insert(players, {
            steamid64 = p:SteamID64(),
            name = p:Nick(),
            level = level,
            online = true,
            lastSeen = "En ligne"
        })
    end
    
    net.Start("BaseWars:AdminMenu:ReceivePlayers")
    net.WriteString(util.TableToJSON(players))
    net.Send(ply)
end)

net.Receive("BaseWars:AdminMenu:RequestOnlinePlayers", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local players = {}
    for _, p in ipairs(player.GetAll()) do
        table.insert(players, {
            steamid64 = p:SteamID64(),
            name = p:Nick()
        })
    end
    
    net.Start("BaseWars:AdminMenu:ReceiveOnlinePlayers")
    net.WriteString(util.TableToJSON(players))
    net.Send(ply)
end)

net.Receive("BaseWars:AdminMenu:RequestPlayerDetails", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local steamid64 = net.ReadString()
    local target = BaseWars:FindPlayer(steamid64)
    
    local level, money, playtime, prestige = 1, 0, 0, 0
    local credits, pointshop = 0, 0
    local name = "Hors ligne"
    local steamid = "N/A"
    local lastSeen = "Inconnu"
    local online = false
    
    if IsValid(target) then
        name = target:Nick()
        steamid = target:SteamID()
        lastSeen = "En ligne"
        online = true
        if target.GetLevel then level = target:GetLevel() end
        if target.GetMoney then money = target:GetMoney() end
        if target.GetTimePlayed then playtime = target:GetTimePlayed() end
        if target.GetPrestige then prestige = target:GetPrestige() end
        if target.GetCredit then credits = target:GetCredit() end
        if target.GetPointshop then pointshop = target:GetPointshop() end
    end
    
    local data = {
        steamid64 = steamid64,
        steamid = steamid,
        name = name,
        level = level,
        money = BaseWars:FormatMoney(money),
        playtime = playtime,
        prestige = prestige,
        credits = credits,
        pointshop = pointshop,
        lastSeen = lastSeen,
        online = online
    }
    
    net.Start("BaseWars:AdminMenu:ReceivePlayerDetails")
    net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end)

net.Receive("BaseWars:AdminMenu:SearchPlayer", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local query = net.ReadString():lower()
    local players = {}
    
    for _, p in ipairs(player.GetAll()) do
        if string.find(p:Nick():lower(), query) or string.find(p:SteamID64(), query) then
            local level = 1
            if p.GetLevel then level = p:GetLevel() end
            
            table.insert(players, {
                steamid64 = p:SteamID64(),
                name = p:Nick(),
                level = level,
                online = true,
                lastSeen = "En ligne"
            })
        end
    end
    
    net.Start("BaseWars:AdminMenu:ReceivePlayers")
    net.WriteString(util.TableToJSON(players))
    net.Send(ply)
end)

--[[-------------------------------------------------------------------------
    Warnings Functions
---------------------------------------------------------------------------]]
net.Receive("BaseWars:AdminMenu:RequestWarnings", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local steamid64 = net.ReadString()
    
    MySQLite.query("SELECT * FROM basewars_warnings WHERE player_id64 = " .. steamid64 .. " ORDER BY date DESC", function(data)
        local warnings = {}
        if data then
            for _, row in ipairs(data) do
                local adminPlayer = BaseWars:FindPlayer(row.admin_id64)
                table.insert(warnings, {
                    id = row.warning_id,
                    reason = row.reason,
                    date = os.date("%d/%m/%Y %H:%M", tonumber(row.date)),
                    adminName = IsValid(adminPlayer) and adminPlayer:Nick() or (row.admin_id64 == "0" and "Console" or "Admin hors ligne"),
                    admin_id64 = row.admin_id64
                })
            end
        end
        
        net.Start("BaseWars:AdminMenu:ReceiveWarnings")
        net.WriteString(util.TableToJSON(warnings))
        net.Send(ply)
    end, BaseWarsSQLError)
end)

net.Receive("BaseWars:AdminMenu:AddWarning", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local steamid64 = net.ReadString()
    local reason = net.ReadString()
    
    BaseWars.Warns:AddWarning(steamid64, ply:SteamID64(), reason)
end)

net.Receive("BaseWars:AdminMenu:DeleteWarning", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local warningId = net.ReadUInt(32)
    
    BaseWars.Warns:RemoveWarning(warningId, ply:SteamID64())
end)

--[[-------------------------------------------------------------------------
    Factions Functions
---------------------------------------------------------------------------]]
net.Receive("BaseWars:AdminMenu:RequestFactions", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local factions = {}
    
    if BaseWars.Factions and BaseWars.Factions.GetFactions then
        for name, factionData in pairs(BaseWars.Factions:GetFactions() or {}) do
            local leader = factionData.leader and BaseWars:FindPlayer(factionData.leader)
            local members = {}
            
            if factionData.members then
                for _, memberSteamID in ipairs(factionData.members) do
                    local memberPly = BaseWars:FindPlayer(memberSteamID)
                    if memberSteamID ~= factionData.leader then
                        table.insert(members, {
                            steamid64 = memberSteamID,
                            name = IsValid(memberPly) and memberPly:Nick() or "Hors ligne"
                        })
                    end
                end
            end
            
            table.insert(factions, {
                name = name,
                color = factionData.color and string.format("#%02x%02x%02x", factionData.color.r, factionData.color.g, factionData.color.b) or "#ffffff",
                leader = {
                    steamid64 = factionData.leader,
                    name = IsValid(leader) and leader:Nick() or "Hors ligne"
                },
                members = members
            })
        end
    end
    
    net.Start("BaseWars:AdminMenu:ReceiveFactions")
    net.WriteString(util.TableToJSON(factions))
    net.Send(ply)
end)

net.Receive("BaseWars:AdminMenu:DisbandFaction", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local factionName = net.ReadString()
    
    if BaseWars.Factions and BaseWars.Factions.Disband then
        BaseWars.Factions:Disband(factionName, ply)
    end
end)

net.Receive("BaseWars:AdminMenu:ChangeLeader", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local factionName = net.ReadString()
    -- Implementation depends on faction system
end)

net.Receive("BaseWars:AdminMenu:KickFromFaction", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local factionName = net.ReadString()
    local targetSteamID = net.ReadString()
    
    if BaseWars.Factions and BaseWars.Factions.KickMember then
        BaseWars.Factions:KickMember(factionName, targetSteamID, ply)
    end
end)

--[[-------------------------------------------------------------------------
    Logs Functions
---------------------------------------------------------------------------]]
net.Receive("BaseWars:AdminMenu:RequestLogCategories", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local loggers = BaseWars.Logs and BaseWars.Logs.GetLoggers and BaseWars.Logs:GetLoggers() or {}
    
    net.Start("BaseWars:AdminMenu:ReceiveLogCategories")
    net.WriteString(util.TableToJSON(loggers))
    net.Send(ply)
end)

net.Receive("BaseWars:AdminMenu:RequestLogs", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local module = net.ReadString()
    local page = net.ReadUInt(16)
    
    if page < 1 then page = 1 end
    
    local where = "WHERE module = " .. MySQLite.SQLStr(module)
    if module == "all" then
        where = ""
    elseif module[1] == "#" then
        where = "WHERE text LIKE '%" .. MySQLite.SQLStr(string.sub(module, 2)):sub(2, -2) .. "%'"
    end
    
    local itemPerPage = 50
    
    MySQLite.query("SELECT count(*) AS count FROM basewars_logs " .. where, function(countResult)
        local totalCount = tonumber(countResult and countResult[1] and countResult[1]["count"]) or 0
        
        MySQLite.query("SELECT text, time, module, involved FROM basewars_logs " .. where .. " ORDER BY id DESC LIMIT " .. (page - 1) * itemPerPage .. ", " .. itemPerPage, function(result)
            result = result or {}
            
            local logs = {}
            for _, row in ipairs(result) do
                -- Keep the log text as-is, just remove the curly braces but keep content
                local text = row.text or ""
                text = string.gsub(text, "{", "")
                text = string.gsub(text, "}", "")
                
                table.insert(logs, {
                    time = os.date("%H:%M:%S", tonumber(row.time) or 0),
                    date = os.date("%d/%m/%Y", tonumber(row.time) or 0),
                    category = row.module or "Unknown",
                    text = text,
                    involved = row.involved
                })
            end
            
            local response = {
                logs = logs,
                page = page,
                maxPage = math.max(1, math.ceil(totalCount / itemPerPage)),
                total = totalCount
            }
            
            net.Start("BaseWars:AdminMenu:ReceiveLogs")
            net.WriteString(util.TableToJSON(response))
            net.Send(ply)
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end)

--[[-------------------------------------------------------------------------
    Player Actions
---------------------------------------------------------------------------]]
net.Receive("BaseWars:AdminMenu:GotoPlayer", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local steamid64 = net.ReadString()
    local target = BaseWars:FindPlayer(steamid64)
    
    if IsValid(target) then
        ply:SetPos(target:GetPos() + Vector(0, 0, 50))
    end
end)

net.Receive("BaseWars:AdminMenu:BringPlayer", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local steamid64 = net.ReadString()
    local target = BaseWars:FindPlayer(steamid64)
    
    if IsValid(target) then
        target:SetPos(ply:GetPos() + ply:GetForward() * 100)
    end
end)

net.Receive("BaseWars:AdminMenu:KickPlayer", function(len, ply)
    if not BaseWars:IsAdmin(ply, true) then return end
    
    local steamid64 = net.ReadString()
    local target = BaseWars:FindPlayer(steamid64)
    
    if IsValid(target) then
        target:Kick("Kicked by admin")
    end
end)
