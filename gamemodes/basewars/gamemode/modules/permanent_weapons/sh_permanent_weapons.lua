function BaseWars.PW:GetWeaponName(weapon_class)
    local weaponData = weapons.Get(weapon_class)
    if not weaponData then
        return weapon_class
    end

    if not weaponData.PrintName then
        return "N/A"
    end

    return weaponData.PrintName
end

function BaseWars.PW:GetWeaponModel(weapon_class)
    local weaponData = weapons.Get(weapon_class)
    if not weaponData or not weaponData.WorldModel then
        return "error.mdl"
    end

    return weaponData.WorldModel
end