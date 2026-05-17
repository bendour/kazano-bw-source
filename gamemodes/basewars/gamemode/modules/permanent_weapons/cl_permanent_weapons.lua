function BaseWars.PW:HasWeapon(weaponClass)
    if not LocalPlayer().basewarsPermanentWeapons then
        return false
    end

    return LocalPlayer().basewarsPermanentWeapons[weaponClass] != nil
end

function BaseWars.PW:GetWeapons()
    return LocalPlayer().basewarsPermanentWeapons
end

function BaseWars.PW:SetWeaponActive(weaponClass, bool)
    if LocalPlayer().basewarsPermanentWeapons[weaponClass] then
        LocalPlayer().basewarsPermanentWeapons[weaponClass].active = bool
    end
end