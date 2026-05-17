hook.Add("PlayerSay", "VoidFactions.Menu.ChatCommand", function (ply, text)
    local cmd = string.lower(text)
    if (cmd == VoidFactions.Config.MenuCommand) then
        ply:ConCommand("voidfactions")
        return ""
    end
end)