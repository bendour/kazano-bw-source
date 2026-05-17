local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TempWeaponClass')
OBJECT_TYPE.UniqueIdentifier = "TempWeapons"

function OBJECT_TYPE.OnUse(ply, plyItem, item)
    // Pick a item
    local wep = ply:Give(item.metadata[1])
    if !IsValid(wep) then return end

    if item.metadata[2] and item.metadata[2] > 0 then
        ply:GiveAmmo(item.metadata[2], wep:GetPrimaryAmmoType(), true)
    end

    if item.metadata[3] and item.metadata[3] > 0 then
        ply:GiveAmmo(item.metadata[3], wep:GetSecondaryAmmoType(), true)
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)