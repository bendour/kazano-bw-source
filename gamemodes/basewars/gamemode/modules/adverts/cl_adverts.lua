net.Receive("BaseWars:Adverts:SendToClients", function()
    local ply = LocalPlayer()

    local message = net.ReadString()

    if message[1] == "#" then
        message = ply:GetLang(string.sub(message, 2))
    end

    chat.AddText(GetBaseWarsTheme("adverts_prefix"), "<clr:white>:advert0::advert1::advert2::advert3::advert4::advert5:<clr:white>", color_white, " » ", message)
end)