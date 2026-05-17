util.AddNetworkString("BaseWars:PermanentWeapons:AddWeapon")
util.AddNetworkString("BaseWars:PermanentWeapons:RemoveWeapon")
util.AddNetworkString("BaseWars:PermanentWeapons:RequestPlayerData")
util.AddNetworkString("BaseWars:PermanentWeapons:SendDataToClient")
util.AddNetworkString("BaseWars:PermanentWeapons:PlayerToggleWeapon")

--[[-------------------------------------------------------------------------
	MARK: Local Functions
---------------------------------------------------------------------------]]
local function strip(ply, weaponClass)
    ply:StripWeapon(weaponClass)
end

local function giveAmmo(ply, weaponClass)
    local weaponData = weapons.Get(weaponClass)

    if not weaponData then
        return
    end

    local primary = string.Trim(weaponData.Primary.Ammo or "")
    if primary != "" or primary != "none" then
        local amount = weaponData.Primary.ClipSize or weaponData.Primary.DefaultClip or 20
        ply:GiveAmmo(amount * 2, primary)
    end

    local secondary = string.Trim(weaponData.Secondary.Ammo or "")
    if secondary != "" or secondary != "none" then
        local amount = weaponData.Secondary.ClipSize or weaponData.Secondary.DefaultClip or 20
        ply:GiveAmmo(amount * 2, secondary)
    end
end

local function giveWeapon(ply, weaponClass, select, ammo)
    ply:Give(weaponClass)

    if select then
        ply:SelectWeapon(weaponClass)
    end

    if ammo then
        giveAmmo(ply, weaponClass)
    end
end

--[[-------------------------------------------------------------------------
	MARK: Global Functions
---------------------------------------------------------------------------]]
function BaseWars.PW:Notify(player_id64, text, type, ...)
    BaseWars:Notify(BaseWars:FindPlayer(player_id64), text, type, 5, ...)
end

function BaseWars.PW:GetWeapons(ply)
    return IsValid(ply) and ply.basewarsPermanentWeapons or {}
end

function BaseWars.PW:GetPlayerData(player_id64, func)
    local ply = BaseWars:FindPlayer(player_id64)

    if not isfunction(func) then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid  arg #2 for BaseWars.PW:GetPlayerData(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    MySQLite.query("SELECT * FROM basewars_permanent_weapons WHERE player_id64 = " .. player_id64, function(result)
        if not IsValid(ply) then
            return
        end

        if not result then
            ply.basewarsPermanentWeapons = {}
            func({})

            return
        end

        local temp  = {}
        for k, v in ipairs(result) do
            if not self:IsValidWeapon(v.weapon_class) then
                continue
            end

            temp[v.weapon_class] = {
                weapon_id = tonumber(v.weapon_id),
                player_id64 = v.player_id64,
                admin_id64 = v.admin_id64,
                date = tonumber(v.date),
                active = tobool(v.active)
            }
        end

        ply.basewarsPermanentWeapons = temp
        func(temp)
    end, BaseWarsSQLError)
end

function BaseWars.PW:SendToClient(player_id64, rebulid)
    local ply = BaseWars:FindPlayer(player_id64)

    if rebulid == nil then
        rebulid = true
    end

    self:GetPlayerData(player_id64, function(data)
        if not IsValid(ply) then
            return
        end

        local compressed = util.Compress(util.TableToJSON(ply.basewarsPermanentWeapons))
        net.Start("BaseWars:PermanentWeapons:SendDataToClient")
            net.WriteUInt(#compressed, 16)
            net.WriteData(compressed, #compressed)
            net.WriteBool(rebulid)
        net.Send(ply)
    end)
end

function BaseWars.PW:IsValidWeapon(weaponClass)
    return weapons.Get(weaponClass) != nil
end

function BaseWars.PW:HasWeapon(player_id64, weaponClass, func)
    local debugInfos = debug.getinfo(2)
    local ply = BaseWars:FindPlayer(player_id64)

    if not weaponClass then
        ErrorNoHalt("Invalid  arg #2 for BaseWars.PW:HasWeapon(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    if not isfunction(func) then
        ErrorNoHalt("Invalid  arg #3 for BaseWars.PW:HasWeapon(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    if IsValid(ply) then
        if not ply.basewarsPermanentWeapons then
            BaseWars:Warning(ply:Name() .. " doesn't have the table \"basewarsPermanentWeapons\"???")
            func(false)

            return
        end

        func(ply.basewarsPermanentWeapons[weaponClass] != nil)
    else
        MySQLite.query(Format("SELECT weapon_id FROM basewars_permanent_weapons WHERE player_id64 = %s AND weapon_class = %s", player_id64, MySQLite.SQLStr(weaponClass)), function(result)
            func(result != nil)
        end, BaseWarsSQLError)
    end
end

local addPending = {}
function BaseWars.PW:AddWeapon(player_id64, admin_id64, weaponClass)
    if not player_id64 then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.PW:AddWeapon(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    if not weaponClass then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #3 for BaseWars.PW:AddWeapon(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    admin_id64 = tostring(admin_id64)
    if admin_id64 == nil or admin_id64 == "nil" then
        admin_id64 = "0"
    end

    if addPending[player_id64 .. "-" .. weaponClass] then
        return
    end

    addPending[player_id64 .. "-" .. weaponClass] = true

    if not self:IsValidWeapon(weaponClass) then
        self:Notify(admin_id64, "#permanentWeapons_invalidWeaponClass", NOTIFICATION_ERROR, self:GetWeaponName(weaponClass))

        return
    end

    local ply = BaseWars:FindPlayer(player_id64)
    self:HasWeapon(player_id64, weaponClass, function(hasWeapon)
        if hasWeapon then
            BaseWars:RequestSteamName(player_id64, function(name)
                self:Notify(admin_id64, "#permanentWeapons_playerAlreadyHasWeapon", NOTIFICATION_ERROR, name, self:GetWeaponName(weaponClass))
            end)

            addPending[player_id64 .. "-" .. weaponClass] = nil

            return
        end

        MySQLite.query(Format("INSERT INTO basewars_permanent_weapons(player_id64, admin_id64, date, active, weapon_class) VALUES(%s, %s, %s, %s, %s)", MySQLite.SQLStr(player_id64), MySQLite.SQLStr(admin_id64), os.time(), 1, MySQLite.SQLStr(weaponClass)), function()
            addPending[player_id64 .. "-" .. weaponClass] = nil

            hook.Run("BaseWars:PermanentWeapons:AddWeaponToPlayer", player_id64, admin_id64, weaponClass, BaseWars.PW:GetWeaponName(weaponClass))

            if not IsValid(ply) then
                return
            end

            giveWeapon(ply, weaponClass, true, true)

            self:SendToClient(player_id64)
        end, BaseWarsSQLError)
    end)
end

local removePending = {}
function BaseWars.PW:RemoveWeapon(player_id64, admin_id64, weaponClass)
    if not weaponClass then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #3 for BaseWars.PW:RemoveWeapon(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    admin_id64 = tostring(admin_id64)
    if admin_id64 == nil or admin_id64 == "nil" then
        admin_id64 = "0"
    end

    if removePending[player_id64 .. "-" .. weaponClass] then
        return
    end

    removePending[player_id64 .. "-" .. weaponClass] = true

    if not self:IsValidWeapon(weaponClass) then
        self:Notify(admin_id64, "#permanentWeapons_invalidWeaponClass", NOTIFICATION_ERROR, self:GetWeaponName(weaponClass))

        return
    end

    local ply = BaseWars:FindPlayer(player_id64)
    self:HasWeapon(player_id64, weaponClass, function(hasWeapon)
        if not hasWeapon then
            BaseWars:RequestSteamName(player_id64, function(name)
                self:Notify(admin_id64, "#permanentWeapons_playerDontHaveWeapon", NOTIFICATION_ERROR, name, self:GetWeaponName(weaponClass))
            end)

            removePending[player_id64 .. "-" .. weaponClass] = nil

            return
        end

        MySQLite.query(Format("DELETE FROM basewars_permanent_weapons WHERE player_id64 = %s AND weapon_class = %s", player_id64, MySQLite.SQLStr(weaponClass)), function()
            removePending[player_id64 .. "-" .. weaponClass] = nil

            hook.Run("BaseWars:PermanentWeapons:RemoveWeaponToPlayer", player_id64, admin_id64, weaponClass, BaseWars.PW:GetWeaponName(weaponClass))

            if not IsValid(ply) then
                return
            end

            strip(ply, weaponClass)

            self:SendToClient(player_id64)
        end, BaseWarsSQLError)
    end)
end

function BaseWars.PW:GiveWeaponsToPlayer(ply)
    if not IsValid(ply) then
        local debugInfos = debug.getinfo(2)
        ErrorNoHalt("Invalid arg #1 for BaseWars.PW:GiveWeaponsToPlayer(), " .. debugInfos.short_src .. " @ line #" .. debugInfos.currentline .. "\n")

        return
    end

    for weaponClass, weaponData in pairs(self:GetWeapons(ply)) do
        if not weaponData.active then continue end

        giveWeapon(ply, weaponClass, false, true)
    end
end

function GiveWeaponToPlayer(player_id64, weaponClass)
    if not player_id64 or not weaponClass then
        print("Usage: luarun_sv GiveWeaponToPlayer(<player_id64>, <weaponClass>)")
        return
    end

    BaseWars.PW:AddWeapon(player_id64, "0", weaponClass)  -- "0" signifies the admin_id64 is unknown or irrelevant
end
--[[-------------------------------------------------------------------------
	MARK: Hooks
---------------------------------------------------------------------------]]
hook.Add("BaseWars:SendNetToClient", "BaseWars:PermanentWeapons", function(ply)
    BaseWars.PW:SendToClient(ply:SteamID64())
end)

hook.Add("PlayerSpawn", "BaseWars:PermanentWeapons", function(ply)
    timer.Simple(0, function()
        BaseWars.PW:GiveWeaponsToPlayer(ply)
    end)
end)

hook.Add("DoPlayerDeath", "BaseWars:PermanentWeapons", function(ply, attacker, dmginfo)
    for weaponClass, weaponData in pairs(BaseWars.PW:GetWeapons(ply)) do
        if not weaponData.active then continue end

        ply:StripWeapon(weaponClass)
    end
end)

hook.Add("BaseWars:PostPlayerChoseProfile", "BaseWars:PermanentWeapons", function(ply)
    timer.Simple(0, function()
        BaseWars.PW:GiveWeaponsToPlayer(ply)
    end)
end)


--[[-------------------------------------------------------------------------
	MARK: Nets
---------------------------------------------------------------------------]]
net.Receive("BaseWars:PermanentWeapons:PlayerToggleWeapon", function(len, ply)
    local weaponClass = net.ReadString()
    local state = net.ReadBool()
    local player_id64 = ply:SteamID64()


    if not BaseWars.PW:IsValidWeapon(weaponClass) then
        return
    end

    BaseWars.PW:HasWeapon(player_id64, weaponClass, function(hasWeapon)
        if not hasWeapon then
            return
        end

        MySQLite.query(Format("UPDATE basewars_permanent_weapons SET active = %s WHERE player_id64 = %s AND weapon_class = %s", state and 1 or 0, player_id64, MySQLite.SQLStr(weaponClass)), function()
            if not IsValid(ply) then
                return
            end

            if state then
                giveWeapon(ply, weaponClass, true, true)
            else
                strip(ply, weaponClass)
            end

            BaseWars.PW:Notify(player_id64, "#permanentWeapon_toggleWeapon_" .. (state and "on" or "off"), NOTIFICATION_GENERIC, BaseWars.PW:GetWeaponName(weaponClass))
            BaseWars.PW:SendToClient(player_id64, false)
        end, BaseWarsSQLError)
    end)
end)
--[[-------------------------------------------------------------------------
    MARK: Console Commands
---------------------------------------------------------------------------]]

concommand.Add("give_weapon", function(ply, cmd, args)
    -- Check if the command is run by a player and if they are an admin
    if IsValid(ply) then
        if not ply:IsSuperAdmin() then
            ply:ChatPrint("You do not have permission to use this command.")
            return
        end
    end

    local player_id64 = args[1]
    local weaponClass = args[2]

    if not player_id64 or not weaponClass then
        print("Usage: give_weapon <player_id64> <weaponClass>")
        return
    end

    GiveWeaponToPlayer(player_id64, weaponClass)
end)