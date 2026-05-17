if SERVER then
    timer.Create("DisableGrappleDamage", 180, 0, function()
        RunConsoleCommand("grapple_damage_enable", "0")
        RunConsoleCommand("sv_tfa_cmenu", "0")
        RunConsoleCommand("sv_tfa_damage_multiplier", "0.8")
        RunConsoleCommand("sv_tfa_damage_multiplier_npc", "0.8")
        RunConsoleCommand("sv_tfa_attachments_enabled", "0")
        RunConsoleCommand("sv_tfa_bullet_doordestruction", "0")
        RunConsoleCommand("sv_tfa_melee_doordestruction", "0")
    end)
end

hook.Add("PlayerSay", "ClanCommand", function(ply, text, teamChat)
    local msg = string.lower(string.Trim(text))

    if msg == "!clan" or msg == "!clans" then
        if IsValid(ply) then
            ply:ConCommand("voidfactions")
        end
        return ""
    end
end)

hook.Add("PlayerSay", "CFCommand", function(ply, text, teamChat)
    local msg = string.lower(string.Trim(text))

    if msg == "!cf" then
        if IsValid(ply) then
            ply:ConCommand("xenin_coinflip")
        end
        return ""
    end
end)