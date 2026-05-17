util.AddNetworkString("ashop_notify")

function ashop.Notify(plys, txt, type, length, ...)
    net.Start("ashop_notify")
        // Flux shenanigans
        if ashop.lang.StrToID[txt] then
            net.WriteBool(true)
            net.WriteUInt(ashop.lang.StrToID[txt], math.log(#ashop.lang.IDToStr)+1, 2)
            local args = {...}

            net.WriteUInt(#args, 3)

            for _, v in ipairs(args) do
                net.WriteString(v)
            end
        else
            net.WriteBool(false)
            net.WriteString(txt)
        end

        net.WriteInt(type or 0, 5)
        net.WriteInt(length or 4, 5)
    net.Send(plys)
end