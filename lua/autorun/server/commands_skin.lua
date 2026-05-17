-- Function to give a skin to a player
function GiveSkinToPlayer(player_id64, skin)
    if not player_id64 or not skin then
        print("Usage: GiveSkinToPlayer(<player_id64>, <skin>)")
        return
    end

    local ply = BaseWars:FindPlayer(player_id64)
    if not IsValid(ply) then
        print("Player not found: " .. player_id64)
        return
    end

    -- Here you should add the logic to give the skin to the player
    -- This part depends on how skins are managed in your server.
    -- Assuming you have a function BaseWars.PW:AddSkin similar to AddWeapon
    if BaseWars.PW and BaseWars.PW.AddSkin then
        BaseWars.PW:AddSkin(player_id64, "0", skin)
    else
        print("AddSkin function not found or not implemented.")
    end
end

-- Register the command to be used from the console
concommand.Add("give_skin", function(ply, cmd, args)
    -- Check if the command is run by a player and if they are an admin
    if IsValid(ply) then
        if not ply:IsSuperAdmin() then
            ply:ChatPrint("You do not have permission to use this command.")
            return
        end
    end

    local player_id64 = args[1]
    local skin = args[2]

    if not player_id64 or not skin then
        print("Usage: give_skin <player_id64> <skin>")
        return
    end

    GiveSkinToPlayer(player_id64, skin)
end)