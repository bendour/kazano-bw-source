local skinsShop = {}
local playerSkins = {}
local creditShop = {
    {
        type = "vip",
        price = 10000,
        name = "VIP"
    },
    {
        type = "advent_calendar",
        price = 10000,
        name = "Calendrier de l'Avent"
    },
    {
        type = "weapon",
        weaponClass = "weapon_vape_american",
        price = 1500,
        name = "Americain Vape",
        model = "models/swamponions/vape.mdl",
    },
    {
        type = "weapon",
        weaponClass = "weapon_vape_juicy",
        price = 1500,
        name = "Juice Vape",
        model = "models/swamponions/vape.mdl",
    },
    {
        type = "weapon",
        weaponClass = "weapon_fists",
        price = 500,
        name = "Fists",
        model = "models/weapons/v_punchy.mdl",
    },
    {
        type = "weapon",
        weaponClass = "weapon_nyangun",
        price = 1500,
        name = "Nyan Gun",
        model = "models/weapons/w_smg1.mdl"
    },
    {
        type = "weapon",
        weaponClass = "mac_lara",
        price = 2500,
        name = "Mac Lara",
        model = "models/weapons/w_smg_macla.mdl",
        SetPrestige = 5
    },
    {
        type = "weapon",
        weaponClass = "m9k_dbarrel",
        price = 3000,
        name = "DB Shotgun",
        model = "models/weapons/w_double_barrel_shotgun.mdl",
		SetPrestige = 7
    },
    {
        type = "weapon",
        weaponClass = "weapon_m4a1_beast",
        price = 3000,
        name = "M4A1 Beast",
        model = "models/cf/w_m4a1_beast.mdl",
		SetPrestige = 10
    },
    {
        type = "weapon",
        weaponClass = "weapon_ak47_beast",
        price = 3000,
        name = "AK47 Iron Beast",
        model = "models/cf/w_ak47_beast.mdl",
		SetPrestige = 10
    },
    {
        type = "weapon",
        weaponClass = "m9k_spas12",
        price = 2500,
        name = "SPAS-12",
        model = "models/weapons/w_spas_12.mdl",
		SetPrestige = 12
    },
    {
        type = "weapon",
        weaponClass = "awpgradient",
        price = 3000,
        name = "AWP",
        model = "models/weapons/w_snip_awp.mdl",
        SetPrestige = 15
    },
    {
        type = "weapon",
        weaponClass = "ryry_msr",
        price = 5000,
        name = "MSR",
        model = "models/weapons/w_ryry_mwmsr.mdl",
        SetPrestige = 25
    }
}

util.AddNetworkString("BaseWars:Pointshop:PlayerRequestData")
util.AddNetworkString("BaseWars:Pointshop:AddSkin")
util.AddNetworkString("BaseWars:Pointshop:RemoveSkin")
util.AddNetworkString("BaseWars:Pointshop:PlayerBuySkin")
util.AddNetworkString("BaseWars:Pointshop:PlayerBuyCreditItem")
util.AddNetworkString("BaseWars:Pointshop:ChangeActiveSkin")

--[[-------------------------------------------------------------------------
	MARK: PLAYER Meta Table Functions
---------------------------------------------------------------------------]]
local PLAYER = FindMetaTable("Player")
function PLAYER:SetPointshop(num, skipSQL)
    num = math.Clamp(num, 0, BASEWARS_MAX_I32)

    self:SetNWInt("BaseWars.Pointshop", num)

    if not skipSQL then
        MySQLite.query(Format("UPDATE basewars_pointshop_player SET pointshop = %s WHERE player_id64 = %s", num, self:SteamID64()), function() end, BaseWarsSQLError)
    end
end

function PLAYER:AddPointshop(num)
    num = math.Clamp(self:GetPointshop() + num, 0, BASEWARS_MAX_I32)

    self:SetPointshop(num)
end

function PLAYER:SetCredit(num, skipSQL)
    num = math.Clamp(num, 0, BASEWARS_MAX_I32)

    self:SetNWInt("BaseWars.Credit", num)

    if not skipSQL then
        MySQLite.query(Format("UPDATE basewars_pointshop_player SET credits = %s WHERE player_id64 = %s", num, self:SteamID64()), function() end, BaseWarsSQLError)
    end
end

function PLAYER:AddCredit(num)
    num = math.Clamp(self:GetCredit() + num, 0, BASEWARS_MAX_I32)

    self:SetCredit(num)
end

--[[-------------------------------------------------------------------------
	MARK: Global Functions
---------------------------------------------------------------------------]]
function BaseWars.PS:GetPointshop()
    return table.Copy(skinsShop)
end

function BaseWars.PS:GetPlayerPointshop(ply)
    return IsValid(ply) and table.Copy(playerSkins[ply:SteamID64()]) or {}
end

function BaseWars.PS:GetPlayersPointshop()
    return table.Copy(playerSkins)
end

function BaseWars.PS:GetShopData(func)
    if not isfunction(func) then
        func = function() end
    end

    MySQLite.query("SELECT * FROM basewars_pointshop", function(result)
        if not result then
            skinsShop = {}
            func({})
            return
        end

        local temp = {}
        for k, v in ipairs(result) do
            -- Handle purchasable correctly: BIT returns "0" or "1" as string
            local isPurchasable = true
            if v.purchasable ~= nil then
                isPurchasable = (v.purchasable == 1 or v.purchasable == "1" or v.purchasable == true)
            end

            temp[tonumber(v.skin_id)] = {
                price = tonumber(v.price),
                model = v.model,
                is_vip = tobool(v.is_vip),
                reserved = util.JSONToTable(v.reserved, false, false),
                purchasable = isPurchasable
            }
        end

        skinsShop = temp
        func(temp)
    end, BaseWarsSQLError)
end

function BaseWars.PS:GetPlayerData(ply, func)
    local debugInfos = debug.getinfo(2)

    if not IsValid(ply) then
        ErrorNoHalt("Invalid arg #1 for BaseWars.PS:GetPlayerData(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    if not isfunction(func) then
        ErrorNoHalt("Invalid arg #2 for BaseWars.PS:GetPlayerData(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    local player_id64 = ply:SteamID64()
    MySQLite.query("SELECT credits, pointshop, skins, active_skin FROM basewars_pointshop_player WHERE player_id64 = " .. player_id64, function(result)
        if not IsValid(ply) then return end

        if not result or #result == 0 then
            playerSkins[player_id64] = {}
            func(0, 0, -1, {}, false) -- Default values

            return
        end

        result = result[1]

        result.credits = tonumber(result.credits) or 0
        result.pointshop = tonumber(result.pointshop) or 0
        result.active_skin = tonumber(result.active_skin) or -1
        result.skins = result.skins or ""

        local temp, removeFromPlayerDB, removeActiveSkin = {}, false, false
        
        if result.skins ~= "" then
            for k, v in ipairs(string.Explode(";", result.skins)) do
                local skinID = tonumber(v)

                if not skinID then continue end

                if not skinsShop[skinID] then
                    if skinID == ply.basewarsActiveSkin then
                        removeActiveSkin = true
                        ply.basewarsActiveSkin = -1
                    end

                    removeFromPlayerDB = true

                    continue
                end

                table.insert(temp, skinID)
            end
        end

        if removeFromPlayerDB then
            MySQLite.query(Format("UPDATE basewars_pointshop_player SET skins = %s%s WHERE player_id64 = %s", MySQLite.SQLStr(table.concat(temp, ";")), removeActiveSkin and ", active_skin = -1" or "", player_id64), function()
                if BaseWars.Config.Debug.Gamemode then
                    BaseWars:ServerLog("Removed all skins that are no longer valid from " .. (IsValid(ply) and ply:Name() or player_id64))
                end
            end, BaseWarsSQLError)
        end

        playerSkins[player_id64] = temp

        func(result.credits, result.pointshop, result.active_skin, temp, true)
    end, BaseWarsSQLError)
end

function BaseWars.PS:SendToClient(ply, whatToSend)
    local debugInfos = debug.getinfo(2)

    if not IsValid(ply) then
        ErrorNoHalt("Invalid arg #1 for BaseWars.PS:SendToClient(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    if not whatToSend or not (whatToSend == "all" or whatToSend == "client" or whatToSend == "active" or whatToSend == "shop") then
        ErrorNoHalt("Invalid arg #2 for BaseWars.PS:SendToClient(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    local player_id64 = ply:SteamID64()
    if playerSkins[player_id64] then
        local data = {}

        if whatToSend == "all" then
            data.skinsShop = skinsShop
            data.playerSkins = playerSkins[player_id64]
            data.activeSkinID = ply.basewarsActiveSkin or -1
        end

        if whatToSend == "client" then
            data.playerSkins = playerSkins[player_id64]
            data.activeSkinID = ply.basewarsActiveSkin or -1
        end

        if whatToSend == "active" then
            data.activeSkinID = ply.basewarsActiveSkin or -1
        end

        if whatToSend == "shop" then
            data.skinsShop = skinsShop
        end

        data = util.Compress(util.TableToJSON(data))
        net.Start("BaseWars:Pointshop:PlayerRequestData")
            net.WriteData(data, #data)
        net.Send(ply)
    end
end

function BaseWars.PS:RefreshShop()
    local data = util.Compress(util.TableToJSON({
        skinsShop = skinsShop
    }))

    net.Start("BaseWars:Pointshop:PlayerRequestData")
        net.WriteData(data, #data)
    net.Broadcast()
end

function BaseWars.PS:AddSkin(ply, model, price, vipOnly)
    local player_id64 = IsValid(ply) and ply:SteamID64() or "0"

    MySQLite.query(Format("INSERT INTO basewars_pointshop(model, price, reserved, is_vip) VALUES(%s, %s, %s, %s)", MySQLite.SQLStr(model), price, MySQLite.SQLStr(util.TableToJSON({})), vipOnly and 1 or 0), function()
        self:GetShopData(function(shopData)
            self:RefreshShop()

            if IsValid(ply) then
                BaseWars:Notify(ply, "#pointshop_addedSkin", NOTIFICATION_GENERIC, 5, BaseWars:FormatNumber(price), model, ply:GetLang(vipOnly and "yes" or "no"))
            end

            hook.Run("BaseWars:AddPointshopSkin", player_id64, model, price, vipOnly)
        end)
    end, BaseWarsSQLError)
end

function BaseWars.PS:RemoveSkin(ply, skinID)
    local player_id64 = IsValid(ply) and ply:SteamID64() or "0"

    MySQLite.query(Format("SELECT * FROM basewars_pointshop WHERE skin_id = " .. skinID), function(exists)
        if not exists then
            if IsValid(ply) then
                BaseWars:Notify(ply, "#pointshop_skinIDInvalid", NOTIFICATION_ERROR, 5, skinID)
            end

            return
        end

        MySQLite.query("DELETE FROM basewars_pointshop WHERE skin_id  = " .. skinID, function()
            RunConsoleCommand("bw_reload_pointshop")

            if IsValid(ply) then
                BaseWars:Notify(ply, "#pointshop_removedSkin", NOTIFICATION_WARNING, 5, skinID)
            end

            exists = exists[1]

            hook.Run("BaseWars:RemovedPointshopSkin", player_id64, exists.model, exists.price, tobool(exists.is_vip))
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end

--[[-------------------------------------------------------------------------
	MARK: Hooks
---------------------------------------------------------------------------]]
hook.Add("PlayerInitialSpawn", "BaseWars:Pointshop", function(ply)
    if ply:IsBot() then return end

    local player_id64 = ply:SteamID64()
    
    BaseWars.PS:GetPlayerData(ply, function(credits, pointshop, active_skin, skinList, hasData)
        if not IsValid(ply) then return end
        
        if hasData then
            ply:SetPointshop(pointshop, true)
            ply:SetCredit(credits, true)
            ply.basewarsActiveSkin = active_skin
            
            BaseWars.PS:SendToClient(ply, "all")
        else
            -- Initialize playerSkins BEFORE inserting into DB
            playerSkins[player_id64] = {}
            ply.basewarsActiveSkin = -1
            
            MySQLite.query(Format("INSERT INTO basewars_pointshop_player VALUES(%s, %s, %s, %s, %s)", player_id64, 0, 0, MySQLite.SQLStr(""), -1), function()
                if not IsValid(ply) then return end
                
                ply:SetPointshop(0, true)
                ply:SetCredit(0, true)
                
                BaseWars.PS:SendToClient(ply, "all")
            end, function(err)
                -- Error callback - player might already exist due to race condition
                BaseWarsSQLError(err)
                
                if not IsValid(ply) then return end
                
                -- Retry getting player data
                BaseWars.PS:GetPlayerData(ply, function(credits2, pointshop2, active_skin2, skinList2, hasData2)
                    if not IsValid(ply) then return end
                    
                    if hasData2 then
                        ply:SetPointshop(pointshop2, true)
                        ply:SetCredit(credits2, true)
                        ply.basewarsActiveSkin = active_skin2
                    else
                        ply:SetPointshop(0, true)
                        ply:SetCredit(0, true)
                        ply.basewarsActiveSkin = -1
                    end
                    
                    BaseWars.PS:SendToClient(ply, "all")
                end)
            end)
        end
    end)
end)

hook.Add("PlayerDisconnected", "BaseWars:Pointshop", function(ply)
    playerSkins[ply:SteamID64()] = nil
end)

hook.Add("BaseWars:SendNetToClient", "BaseWars:Pointshop", function(ply)
    BaseWars.PS:SendToClient(ply, "all")
end)

hook.Add("InitPostEntity", "BaseWars:Pointshop", function()
    BaseWars.PS:GetShopData()

    -- Lua Refresh
    hook.Add("BaseWars:Initialize", "BaseWars:Pointshop", function()
        RunConsoleCommand("bw_reload_pointshop")
    end)
end)

hook.Add("PlayerSpawn", "BaseWars:Pointshop", function(ply)
    if ply.basewarsActiveSkin and ply.basewarsActiveSkin >= 0 then
        local skinData = skinsShop[ply.basewarsActiveSkin]
        if not skinData then
            return
        end

        timer.Simple(0, function()
            ply:SetModel(skinData.model)
        end)
    end
end)

--[[-------------------------------------------------------------------------
	MARK: Nets
---------------------------------------------------------------------------]]

net.Receive("BaseWars:Pointshop:PlayerRequestData", function(len, ply)
    BaseWars.PS:SendToClient(ply, "all")
end)

net.Receive("BaseWars:Pointshop:AddSkin", function(len, ply)
    if not BaseWars:IsSuperAdmin(ply) then
        BaseWars:BanPlayer(ply:SteamID64(), "0", "Probably hacking (Add Skin)")

        return
    end

    local model = net.ReadString()
    local price = net.ReadUInt(31)
    local isVIP = net.ReadBool()

    BaseWars.PS:AddSkin(ply, model, price, isVIP)
end)

net.Receive("BaseWars:Pointshop:RemoveSkin", function(len, ply)
    local skinID = net.ReadUInt(31)

    if not BaseWars:IsSuperAdmin(ply) then
        BaseWars:BanPlayer(ply:SteamID64(), "0", "Probably hacking (Remove Skin)")

        return
    end

    if not skinsShop[skinID] then
        return
    end

    BaseWars.PS:RemoveSkin(ply, skinID)
end)

net.Receive("BaseWars:Pointshop:PlayerBuySkin", function(len, ply)
    local skinID = net.ReadUInt(31)
    local skinData = skinsShop[skinID]

    if not skinData then
        return
    end

    -- Check if skin is purchasable
    if not skinData.purchasable then
        BaseWars:Notify(ply, "Ce skin n'est pas achetable (événement/récompense uniquement)", NOTIFICATION_ERROR, 5)
        return
    end

    if skinData.is_vip and not BaseWars:IsVIP(ply) then
        BaseWars:Notify(ply, "#pointshop_vipSkin", NOTIFICATION_ERROR, 5)

        return
    end

    if ply:GetPointshop() < skinData.price then
        BaseWars:Notify(ply, "#pointshop_tooExpensive", NOTIFICATION_ERROR, 5)

        return
    end

    local hasSkin = false
    local player_id64 = ply:SteamID64()
    for k, v in ipairs(playerSkins[player_id64]) do
        if v == skinID then
            hasSkin = true

            break
        end
    end

    if hasSkin then
        return
    end

    ply:SetPointshop(ply:GetPointshop() - skinData.price)
    table.insert(playerSkins[player_id64], skinID)

    MySQLite.query(Format("UPDATE basewars_pointshop_player SET skins = %s WHERE player_id64 = %s", MySQLite.SQLStr(table.concat(playerSkins[player_id64], ";")), player_id64), function()
        if not IsValid(ply) then return end

        BaseWars.PS:SendToClient(ply, "client")
        BaseWars:Notify(ply, "#pointshop_boughtSkin", NOTIFICATION_PURCHASE, 5, skinData.price)

        hook.Run("BaseWars:PlayerBuySkin", player_id64, skinID, skinData)
    end, BaseWarsSQLError)
end)

--[[-------------------------------------------------------------------------
	Function to give a skin directly to a player (for rewards, events, etc.)
---------------------------------------------------------------------------]]
function BaseWars.PS:GiveSkinToPlayer(player_id64, skinID, admin_id64)
    if not player_id64 then
        ErrorNoHalt("BaseWars.PS:GiveSkinToPlayer - Invalid player_id64\n")
        return false
    end

    if not skinID then
        ErrorNoHalt("BaseWars.PS:GiveSkinToPlayer - Invalid skinID\n")
        return false
    end

    local skinData = skinsShop[skinID]
    if not skinData then
        ErrorNoHalt("BaseWars.PS:GiveSkinToPlayer - Skin ID " .. skinID .. " does not exist\n")
        return false
    end

    admin_id64 = admin_id64 or "0"

    -- Check if player already has the skin
    MySQLite.query("SELECT skins FROM basewars_pointshop_player WHERE player_id64 = " .. player_id64, function(result)
        if not result or #result == 0 then
            -- Player doesn't exist in database, create entry with this skin
            MySQLite.query(Format("INSERT INTO basewars_pointshop_player(player_id64, skins) VALUES(%s, %s)", player_id64, MySQLite.SQLStr(tostring(skinID))), function()
                local ply = BaseWars:FindPlayer(player_id64)
                if IsValid(ply) then
                    BaseWars.PS:GetPlayerData(ply, function()
                        BaseWars.PS:SendToClient(ply, "client")
                        BaseWars:Notify(ply, "Vous avez reçu un skin gratuit !", NOTIFICATION_GENERIC, 5)
                    end)
                end

                hook.Run("BaseWars:PointshopSkinGiven", player_id64, admin_id64, skinID, skinData)
            end, BaseWarsSQLError)
            return
        end

        local skins = result[1].skins or ""
        local hasSkin = false
        
        for k, v in ipairs(string.Explode(";", skins)) do
            if tonumber(v) == skinID then
                hasSkin = true
                break
            end
        end

        if hasSkin then
            -- Player already has this skin
            return false
        end

        -- Add skin to player
        local newSkins = skins == "" and tostring(skinID) or skins .. ";" .. skinID
        MySQLite.query(Format("UPDATE basewars_pointshop_player SET skins = %s WHERE player_id64 = %s", MySQLite.SQLStr(newSkins), player_id64), function()
            local ply = BaseWars:FindPlayer(player_id64)
            if IsValid(ply) then
                BaseWars.PS:GetPlayerData(ply, function()
                    BaseWars.PS:SendToClient(ply, "client")
                    BaseWars:Notify(ply, "Vous avez reçu un skin gratuit !", NOTIFICATION_GENERIC, 5)
                end)
            end

            hook.Run("BaseWars:PointshopSkinGiven", player_id64, admin_id64, skinID, skinData)
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)

    return true
end

net.Receive("BaseWars:Pointshop:ChangeActiveSkin", function(len, ply)
    local skinID = net.ReadInt(32)
    local skinData = skinsShop[skinID]

    if skinID >= 0 and not skinData then
        return
    end

    if ply.basewarsActiveSkin == skinID then
        return
    end

    ply.basewarsActiveSkin = skinID
    BaseWars.PS:SendToClient(ply, "active")

    if skinData then
        ply:SetModel(skinData.model)
    else
        hook.Call("PlayerSetModel", GAMEMODE, ply) -- reset to default when disabling skin
    end

    local player_id64 = ply:SteamID64()
    MySQLite.query(Format("UPDATE basewars_pointshop_player SET active_skin = %s WHERE player_id64 = %s", skinID, player_id64), function()
        if IsValid(ply) then
            BaseWars:Notify(ply, "#pointshop_changedActiveSkin", NOTIFICATION_GENERIC, 5)
        end

        hook.Run("BaseWars:PlayerChangedActiveSkin", player_id64, skinID, skinData)
    end, BaseWarsSQLError)
end)

net.Receive("BaseWars:Pointshop:PlayerBuyCreditItem", function(len, ply)
    local id = net.ReadUInt(4)
    local itemData = creditShop[id]
    local player_id64 = ply:SteamID64()

    if not itemData then
        return
    end

    if (itemData.type == "vip" and BaseWars:IsVIP(ply)) then
        return
    end

    if (itemData.type == "advent_calendar" and CH_Advent and CH_Advent.HasAccess and CH_Advent.HasAccess(ply)) then
        return
    end

    if (itemData.type == "weapon" and BaseWars.PW:HasWeapon(player_id64, itemData.weaponClass)) then
        return
    end

    if ply:GetCredit() < itemData.price then
        BaseWars:Notify(ply, "#pointshop_tooExpensive", NOTIFICATION_ERROR, 5)

        return
    end

    ply:SetCredit(ply:GetCredit() - itemData.price)

    if itemData.type == "weapon" then
        BaseWars.PW:AddWeapon(player_id64, "0", itemData.weaponClass)
    end

    if itemData.type == "vip" then
        RunConsoleCommand("sam", "setrankid", player_id64, "VIP")
    end

    if itemData.type == "advent_calendar" then
        if CH_Advent and CH_Advent.GiveAccess then
            CH_Advent.GiveAccess(player_id64, "Shop Credits")
        end
    end

    hook.Run("BaseWars:PlayerBuyCreditItem", player_id64, itemData)

    BaseWars:Notify(ply, "#pointshop_buyCreditItem", NOTIFICATION_PURCHASE, 5, itemData.name, BaseWars:FormatNumber(itemData.price))
end)

--[[-------------------------------------------------------------------------
	MARK: Timers & Console Commands
---------------------------------------------------------------------------]]
timer.Create("BaseWars.Pointshop", 600, 0, function()
    for k, v in player.Iterator() do
        local amount = BaseWars:IsVIP(v) and 150 or 75

        v:AddPointshop(amount)
        BaseWars:Notify(v, "#pointshop_playPointshop", NOTIFICATION_GENERIC, 5, amount)
    end
end)

timer.Create("BaseWars.Credit", 600, 0, function()
    for k, v in player.Iterator() do
        v:AddCredit(10)
        BaseWars:Notify(v, "#pointshop_playCredit", NOTIFICATION_GENERIC, 5)
    end
end)

BaseWars:AddConsoleCommand("bw_reload_pointshop", function(ply, args, argStr)
    BaseWars.PS:GetShopData(function(shopData)
        if BaseWars.Config.Debug.Gamemode then
            BaseWars:ServerLog("Resending pointshop info to players")
        end

        BaseWars:Notify(ply, "Reloaded the pointshop", NOTIFICATION_ADMIN, 10)

        for k, v in player.Iterator() do
            BaseWars.PS:GetPlayerData(v, function(_, _, _, skinList, hasData)
                if not IsValid(v) then return end
                playerSkins[v:SteamID64()] = skinList

                BaseWars.PS:SendToClient(v, "all")
            end)
        end
    end)
end, false, BaseWars:GetSuperAminGroups())

BaseWars:AddConsoleCommand("bw_giveskin", function(ply, args, argStr)
    local target_id64 = args[1]
    if not target_id64 or not tonumber(target_id64) then
        BaseWars:Notify(ply, "#targetNotFound", NOTIFICATION_ERROR, 5)
        return
    end

    local skinID = tonumber(args[2])
    if not skinID then
        BaseWars:Notify(ply, "#invalidArgumentNumber", NOTIFICATION_ERROR, 5)
        return
    end

    -- Check if skin exists
    if not skinsShop[skinID] then
        BaseWars:Notify(ply, "Le skin ID " .. skinID .. " n'existe pas", NOTIFICATION_ERROR, 5)
        return
    end

    BaseWars:RequestSteamName(target_id64, function(targetName)
        if targetName == "Error" then
            BaseWars:Notify(ply, "#targetNotFound", NOTIFICATION_ERROR, 5)
            return
        end

        -- Use the new function to give the skin
        local admin_id64 = IsValid(ply) and ply:SteamID64() or "0"
        BaseWars.PS:GiveSkinToPlayer(target_id64, skinID, admin_id64)
        
        BaseWars:Notify(ply, "Vous avez donné le skin ID " .. skinID .. " à " .. targetName, NOTIFICATION_GENERIC, 5)
        BaseWars:ServerLog((IsValid(ply) and ply:Name() or "Console") .. " gave skin ID " .. skinID .. " to " .. targetName .. " (" .. target_id64 .. ")")
    end)
end, false, BaseWars:GetSuperAminGroups())

BaseWars:AddConsoleCommand("bw_toggleskinpurchase", function(ply, args, argStr)
    local skinID = tonumber(args[1])
    if not skinID then
        BaseWars:Notify(ply, "Usage: bw_toggleskinpurchase <skin_id>", NOTIFICATION_ERROR, 5)
        return
    end

    -- Check if skin exists
    if not skinsShop[skinID] then
        BaseWars:Notify(ply, "Le skin ID " .. skinID .. " n'existe pas", NOTIFICATION_ERROR, 5)
        return
    end

    local currentState = skinsShop[skinID].purchasable
    local newState = not currentState
    local newStateValue = newState and 1 or 0

    MySQLite.query(Format("UPDATE basewars_pointshop SET purchasable = %d WHERE skin_id = %d", newStateValue, skinID), function()
        skinsShop[skinID].purchasable = newState
        
        local stateText = newState and "ACHETABLE" or "NON-ACHETABLE (événement uniquement)"
        BaseWars:Notify(ply, "Skin ID " .. skinID .. " est maintenant " .. stateText, NOTIFICATION_ADMIN, 7)
        BaseWars:ServerLog((IsValid(ply) and ply:Name() or "Console") .. " set skin ID " .. skinID .. " purchasable to " .. tostring(newState))
        
        -- Update all clients
        for k, v in player.Iterator() do
            BaseWars.PS:SendToClient(v, "all")
        end
    end, BaseWarsSQLError)
end, false, BaseWars:GetSuperAminGroups())

-------------------
