hook.Add("PlayerSay", "OuvrirLiens", function(ply, text)
    if text == "!boutique" then
        ply:SendLua("gui.OpenURL('https://kazano.fr')")
        return "" -- Empêche l'affichage du message dans le chat
    elseif text == "!collection" then
        ply:SendLua("gui.OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=3355620511')")
        return "" -- Empêche l'affichage du message dans le chat
    elseif text == "!discord" then
        ply:SendLua("gui.OpenURL('https://discord.gg/kazano')")
        return "" -- Empêche l'affichage du message dans le chat
    end
end)