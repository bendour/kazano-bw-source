local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('PermWeaponClass')
OBJECT_TYPE.UniqueIdentifier = "PermanentWeapons"

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    local countWeps = {}

    for k, v in ipairs(ply:GetWeapons()) do
        if v.ashop_permawep then
            table.insert(countWeps, {t = v.ashop_permawep, w = v})
        end
    end

    // Remove the oldest weapon, if he have no free slots
    local b = ashop.GetObjectTypeIDByUID('PermanentWeapons')
    local _, count = ply:AShop_SlotStateGet(b, item.sub_types)
    local toRemove = #countWeps - count

    if toRemove > 0 then
        for k, v in SortedPairsByMemberValue(countWeps, "t") do
            if toRemove <= 0 then break end
            ply:StripWeapon(v.w:GetClass())
        end
    end

    if !plyItem.weapon_alreadyUsed or plyItem.weapon_alreadyUsed < ply.ashop_spawncounter then
        plyItem.ashop_spawncounter = ply.ashop_spawncounter
        local wep = ply:Give(item.metadata[1])
        wep.ashop_permawep = CurTime()

        if !IsValid(wep) then return end

        if item.metadata[2] and item.metadata[2] > 0 then
            ply:GiveAmmo(item.metadata[2], wep:GetPrimaryAmmoType(), true)
        end

        if item.metadata[3] and item.metadata[3] > 0 then
            ply:GiveAmmo(item.metadata[3], wep:GetSecondaryAmmoType(), true)
        end
    end
end

hook.Add("canDropWeapon", "ashop_blockDropPermWeapon", function(ply, wep)
    if wep.ashop_permawep then return false end
end)

function OBJECT_TYPE.OnPlayerSpawn(ply, plyItem, item)
    // Read warning: https://wiki.facepunch.com/gmod/GM:PlayerSpawn
    // If this is 'on first spawn'

    timer.Simple(0, function()
        OBJECT_TYPE.OnEquip(ply, plyItem, item)
    end)
end

ashop.RegisterObjectType(OBJECT_TYPE)