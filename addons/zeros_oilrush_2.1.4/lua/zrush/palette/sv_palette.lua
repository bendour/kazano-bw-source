if (not SERVER) then return end
zrush = zrush or {}
zrush.Palette = zrush.Palette or {}

util.AddNetworkString("zrush_Palette_AddBarrel")


function zrush.Palette.Initialize(Palette)
    zclib.Debug("zrush.Palette.Initialize")
    zclib.EntityTracker.Add(Palette)

    Palette.BarrelCount = 0
    Palette.FuelList = {}
end

function zrush.Palette.StartTouch(Palette, other)
    if not IsValid(Palette) then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zrush_barrel" then return end
    if zclib.util.CollisionCooldown(other) then return end
    zclib.Debug("zrush.Palette.StartTouch")

    zrush.Palette.AddBarrel(Palette, other)
end

function zrush.Palette.AddBarrel(Palette, barrel)
    if barrel:GetFuelTypeID() > 0 and barrel:GetFuel() > 0 and Palette.BarrelCount < zrush.config.Palette.Capacity then

        Palette.BarrelCount = Palette.BarrelCount + 1

        // Tell the palette which fuelid and how much got added
        Palette.FuelList[barrel:GetFuelTypeID()] = (Palette.FuelList[barrel:GetFuelTypeID()] or 0) + barrel:GetFuel()

        // Informas all cliPalettes that this palette Paletteitiy just got a fuel barrel added
        net.Start("zrush_Palette_AddBarrel")
        net.WriteEntity(Palette)
        net.WriteInt(barrel:GetFuelTypeID(),6)
        net.Broadcast()

        zclib.Entity.SafeRemove(barrel)
    end
end
