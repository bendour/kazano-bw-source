if CLIENT then return end
zrush = zrush or {}
zrush.Player = zrush.Player or {}

-- zclib.Player.CleanUp_Add("zrush_barrel")
-- zclib.Player.CleanUp_Add("zrush_drillpipe_holder")
-- zclib.Player.CleanUp_Add("zrush_machinecrate")
-- zclib.Player.CleanUp_Add("zrush_drilltower")
-- zclib.Player.CleanUp_Add("zrush_burner")
-- zclib.Player.CleanUp_Add("zrush_pump")
-- zclib.Player.CleanUp_Add("zrush_refinery")
-- zclib.Player.CleanUp_Add("zrush_drillhole")
-- zclib.Player.CleanUp_Add("zrush_palette")

zclib.Gamemode.AssignOwnerOnBuy("zrush_barrel")
zclib.Gamemode.AssignOwnerOnBuy("zrush_drillpipe_holder")
zclib.Gamemode.AssignOwnerOnBuy("zrush_machinecrate")
zclib.Gamemode.AssignOwnerOnBuy("zrush_palette")

////////////////////////////////////////////
////////// Player Functions ////////////////
////////////////////////////////////////////
// Meta Tables
local meta_ply = FindMetaTable("Player")

// This adds the drillhole id too the player
function meta_ply:zrush_CreatedDrillHole(drillhole_entindex)
    self.zrush_ActiveDrillholes = self.zrush_ActiveDrillholes or {}
    table.insert(self.zrush_ActiveDrillholes, drillhole_entindex)
end

// Return active drillhole count
function meta_ply:zrush_ReturnActiveDrillHoleCount()
    local activedrillholes = 0

    for k, v in pairs(ents.FindByClass("zrush_drillhole")) do
        if (IsValid(v) and zclib.Player.GetOwnerID(v) == self:SteamID() and v.Closed == false) then
            activedrillholes = activedrillholes + 1
        end
    end

    return activedrillholes
end

// This adds the specific fuel do our inv
function meta_ply:zrush_AddFuelBarrel(fID, fAmount)
    self.zrush_INV_FuelBarrels = self.zrush_INV_FuelBarrels or {}
    self.zrush_INV_FuelBarrels[fID] = self.zrush_INV_FuelBarrels[fID] or 0
    self.zrush_INV_FuelBarrels[fID] = self.zrush_INV_FuelBarrels[fID] + fAmount
end

// This removes the specific fuel from our inv
function meta_ply:zrush_RemoveFuelBarrel(fID, fAmount)
    self.zrush_INV_FuelBarrels = self.zrush_INV_FuelBarrels or {}
    self.zrush_INV_FuelBarrels[fID] = self.zrush_INV_FuelBarrels[fID] or 0
    self.zrush_INV_FuelBarrels[fID] = self.zrush_INV_FuelBarrels[fID] - fAmount

    if self.zrush_INV_FuelBarrels[fID] <= 0 then
        self.zrush_INV_FuelBarrels[fID] = nil
    end
end

// This gives us a table of all the fuel barrels the player has in his inv
function meta_ply:zrush_GetFuelBarrels()
    self.zrush_INV_FuelBarrels = self.zrush_INV_FuelBarrels or {}

    return self.zrush_INV_FuelBarrels
end

// This returns true if we have fuel in our inv
function meta_ply:zrush_HasFuelBarrels()
    self.zrush_INV_FuelBarrels = self.zrush_INV_FuelBarrels or {}
    local hasBarrels = false

    for k, v in pairs(self.zrush_INV_FuelBarrels) do
        if (v > 0) then
            hasBarrels = true
            break
        end
    end

    return hasBarrels
end

// This returns the amount of barrels in our inventory
function meta_ply:zrush_GetFuelBarrelCount()
    local b_Count = 0
    if self.zrush_INV_FuelBarrels and table.Count(self.zrush_INV_FuelBarrels) > 0 then
        for k, v in pairs(self.zrush_INV_FuelBarrels) do
            if (v > 0) then
                b_Count = b_Count + math.Round(v / zrush.config.Barrel.Storage, 0)
            end
        end
    end
    return b_Count
end

function meta_ply:zrush_SoldFuelBarrel(fID, fAmount)
    self.zrush_SOLD_FuelBarrels = self.zrush_SOLD_FuelBarrels or {}
    self.zrush_SOLD_FuelBarrels[fID] = self.zrush_SOLD_FuelBarrels[fID] or 0
    self.zrush_SOLD_FuelBarrels[fID] = self.zrush_SOLD_FuelBarrels[fID] + fAmount
end

// This gives us a table of all the fuel barrels the player sold
function meta_ply:zrush_GetFuelBarrelsSold()
    self.zrush_SOLD_FuelBarrels = self.zrush_SOLD_FuelBarrels or {}

    return self.zrush_SOLD_FuelBarrels
end


////////////////////////////////////////////
////////////// Player Death ////////////////
////////////////////////////////////////////
zclib.Hook.Add("PostPlayerDeath", "zrush.PostPlayerDeath", function(ply, text)
    // Closes any zrush interface which the player has currently open
    zrush.vgui.ForceClose(ply)
end)

zclib.Hook.Add("PlayerSilentDeath", "zrush.PlayerSilentDeath", function(ply, text)
    // Closes any zrush interface which the player has currently open
    zrush.vgui.ForceClose(ply)
end)

zclib.Hook.Add("PlayerDeath", "zrush.DropFuel", function(victim, inflictor, attacker)
    if (zrush.config.Player.DropFuelOnDeath) then
        zrush.Player.DropFuel(victim)
    end

    // Closes any zrush interface which the player has currently open
    zrush.vgui.ForceClose(victim)
end)
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////// Fuel Inventory ////////////////
////////////////////////////////////////////
local function spawn_FuelBarrel(pos, fuelId, amount, ply)
    local ent = ents.Create("zrush_barrel")
    ent:SetAngles(Angle(0, 0, 0))
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetFuelTypeID(fuelId)
    ent:SetFuel(amount)

    zrush.Barrel.UpdateVisual(ent)

    zclib.Player.SetOwner(ent, ply)

    return ent
end

function zrush.Player.DropFuel(ply)
    if (IsValid(ply)) then
        local fuelBarrels = ply:zrush_GetFuelBarrels()

        for k, v in pairs(fuelBarrels) do
            // Do we have fuel in this id?
            if (v > 0) then
                // Do we have more fuel of this type in the inv as the max capacity of a barrel can hold?
                if (v > zrush.config.Barrel.Storage) then
                    local totalFuel = v
                    local barrelCount = totalFuel / zrush.config.Barrel.Storage
                    local fullBarrelCount = math.floor(barrelCount)

                    // This spawns the full barrels
                    for i = 1, fullBarrelCount do
                        spawn_FuelBarrel(ply:GetPos() + ply:GetForward() * 50 + ply:GetUp() * 25 * i, k, zrush.config.Barrel.Storage, ply)
                        ply:zrush_RemoveFuelBarrel(k, zrush.config.Barrel.Storage)
                    end

                    local restamount = totalFuel - (fullBarrelCount * zrush.config.Barrel.Storage)

                    if (restamount > 0) then
                        // This spawns the rest amount in a barrel
                        spawn_FuelBarrel(ply:GetPos() + ply:GetForward() * 50 + ply:GetUp() * 25, k, restamount, ply)
                        ply:zrush_RemoveFuelBarrel(k, restamount)
                    end
                else
                    spawn_FuelBarrel(ply:GetPos() + ply:GetForward() * 50 + ply:GetUp() * 25, k, v, ply)
                    ply:zrush_RemoveFuelBarrel(k, v)
                end
            end
        end
    end
end

zclib.Hook.Add("PlayerSay", "zrush.DropFuel", function(ply, text)
    if string.sub(string.lower(text), 1, 9) == "!dropfuel" then
        if (ply:zrush_HasFuelBarrels()) then
            zrush.Player.DropFuel(ply)
        else
            zrush.Notify(ply, zrush.language["InvEmpty"], 1)
        end
    end
end)

// Tells the player its fuel inventory
zclib.Hook.Add("PlayerSay", "zrush.FuelInv", function(ply, text)
    if string.sub(string.lower(text), 1, 8) == "!fuelinv" then
        if (ply:zrush_HasFuelBarrels()) then
            local fueltabl = ply:zrush_GetFuelBarrels()
            local sortedTable = {}

            for k, v in pairs(fueltabl) do
                if (v > 0) then
                    local info = "| " .. zrush.FuelTypes[k].name .. ": " .. math.Round(v) .. " |"
                    table.insert(sortedTable, info)
                end
            end

            sortedTable = table.concat(sortedTable, " ")
            zrush.Notify(ply, sortedTable, 0)
            zrush.Notify(ply, zrush.language["FuelInv"], 3)
        else
            zrush.Notify(ply, zrush.language["InvEmpty"], 1)
        end
    end
end)
////////////////////////////////////////////
////////////////////////////////////////////
