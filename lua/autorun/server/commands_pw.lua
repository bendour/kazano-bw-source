function GiveWeaponToPlayer(player_id64, weaponClass)
    if not player_id64 or not weaponClass then
        print("Usage: GiveWeaponToPlayer(<player_id64>, <weaponClass>)")
        return
    end

    -- Check if weaponClass is valid
    if not BaseWars.PW:IsValidWeapon(weaponClass) then
        print("Invalid weapon class: " .. weaponClass)
        return
    end

    -- Add weapon to player
    BaseWars.PW:AddWeapon(player_id64, "0", weaponClass)  -- "0" signifie que l'admin_id64 est inconnu ou non pertinent
end

-- Register the command to be used from the console
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