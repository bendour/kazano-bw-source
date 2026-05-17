function BaseWars.Warns:GetWarnings()
    return LocalPlayer().basewarsWarnings or {}
end

net.Receive("BaseWars:Warnings:ChatNotifyServer", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    local colors = {
        prefix = GetBaseWarsTheme("warnings_prefix"),
        info = GetBaseWarsTheme("warnings_info"),
        text = GetBaseWarsTheme("warnings_text")
    }

    local text = table.Copy(LocalPlayer():GetLang("warnings_playerWarnedChatNotify"))
    for k, v in ipairs(text) do
        if v == "{NAME}" then
            text[k] = data.name
        end

        if v == "{REASON}" then
            text[k] = data.reason
        end

        if v == "{COLOR_WARN}" then
            text[k] = colors.info
        end

        if v == "{COLOR_WARN2}" then
            text[k] = colors.text
        end
    end

    chat.AddText(colors.prefix, "[Warnings]", colors.text, " » ", unpack(text))
end)