local OBJECT_TYPE = {}

OBJECT_TYPE.UniqueIdentifier = "Commandes"

local function ExecuteCommand(ply, plyItem, item)
    local cmd = item.metadata[1]

    if cmd then
        // Format it
        cmd = string.gsub(cmd, "%S+", {
            ['{PLAYER_STEAMID}'] = ply:SteamID(),
            ['{PLAYER_NAME}'] = ply:Nick(),
            ['{PLAYER_STEAMID64}'] = ply:SteamID64(),
            ['{PLAYER_USERID}'] = ply:UserID()
        })

        game.ConsoleCommand(cmd .. "\n")
    end

    local code = item.metadata[3]

    if code then
        code = string.gsub(code, "%b{}", {
            ['{PLAYER_STEAMID}'] = "'" .. ply:SteamID() .. "'",
            ['{PLAYER_NAME}'] = "'" .. ply:Nick() .. "'",
            ['{PLAYER_STEAMID64}'] = "'" .. ply:SteamID64() .. "'",
            ['{PLAYER_USERID}'] = ply:UserID()
        })

        RunString(code)
    end
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if item.metadata[2] == 3 then
        ExecuteCommand(ply, plyItem, item)
        ashop.actions.DeletePlayerItem(ply, plyItem.id)
    elseif !plyItem.command_alreadyUsed or plyItem.command_alreadyUsed < ply.ashop_spawncounter then
        plyItem.command_alreadyUsed = ply.ashop_spawncounter
        ExecuteCommand(ply, plyItem, item)
    end
end

function OBJECT_TYPE.OnPlayerSpawn(ply, plyItem, item)
    // Read warning: https://wiki.facepunch.com/gmod/GM:PlayerSpawn

    // If this is 'on first spawn'
    timer.Simple(0, function()
        if item.metadata[2] == 1 then
            ExecuteCommand(ply, plyItem, item)
            plyItem.command_alreadyUsed = ply.ashop_spawncounter
        end
    end)
end

OBJECT_TYPE.Name = "Commandes"

ashop.RegisterObjectType(OBJECT_TYPE)