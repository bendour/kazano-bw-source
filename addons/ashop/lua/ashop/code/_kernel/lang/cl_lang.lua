net.Receive("ashop_notify", function()
    local str
    if net.ReadBool() then
        local uid = net.ReadUInt(math.log(#ashop.lang.IDToStr, 2)+1)
        local tbl = {}

        for i = 1, net.ReadUInt(3) do
            table.insert(tbl, net.ReadString())
        end

        local good, res = pcall(function()
            return ashop.FormatLanguage(uid, unpack(tbl))
        end)

        if !good then
            notification.AddLegacy("[ashop] Issue while getting formatted string of: " .. ashop.lang.IDToStr[uid], 1, 4)
            return
        else
            str = res
        end
    else
        str = net.ReadString()
    end

    notification.AddLegacy(str, net.ReadInt(5) or 0, net.ReadInt(5) or 4)
end)