/*
    Mode:
    - 0, sequential
    - 1, int key
    - 2, string key
*/

ashop.Network = ashop.Network or {}

function ashop.Network.W_Bulk(t, f, mode, keySize, tblSize)
    net.WriteUInt(mode == 0 and #t or table.Count(t), tblSize)

    for k, v in (mode == 0 and ipairs or pairs)(t) do
        f(v)
        if mode > 0 then
            if mode == 1 then
                net.WriteUInt(k, keySize)
            else
                net.WriteString(k)
            end
        end
    end
end

function ashop.Network.R_Compress()
    local s = net.ReadUInt(16)
    local d = net.ReadData(s)

    return util.Decompress(d)
end

function ashop.Network.W_Compress(txt)
    txt = util.Compress(txt)
    net.WriteUInt(#txt, 16)
    net.WriteData(txt)
end

function ashop.Network.R_Bulk(f, mode, keySize, tblSize)
    local t = {}
    for i = 1, net.ReadUInt(tblSize) do
        local d = f()

        if mode == 1 then
            t[net.ReadUInt(keySize)] = d
        elseif mode == 2 then
            t[net.ReadString()] = d
        else
            table.insert(t, d)
        end
    end

    return t
end

// Type
function ashop.Network.GetReadFunction(item_type, options)
    if (!options or !options.required) and !net.ReadBool() then
        return
    end

    if item_type == TYPE_STRING then
        return net.ReadString()
    elseif item_type == TYPE_VECTOR then
        return net.ReadVector()
    elseif item_type == TYPE_ANGLE then
        return net.ReadAngle()
    elseif item_type == TYPE_COLOR then
        return net.ReadColor()
    elseif item_type == TYPE_BOOL then
        return net.ReadBool()
    elseif item_type == "FLOAT" then
        return net.ReadFloat()
    elseif string.StartWith(item_type, "UInt") then
        local n = tonumber(string.sub(item_type, 5))
        return net.ReadUInt(n)
    elseif item_type == 'ITEMID' then
        return net.ReadUInt(ashop.Config.BitsItemID)
    elseif item_type == 'DATE' then
        return net.ReadUInt(32)
    elseif item_type == 'SELECT' then
        return ashop.Network.GetReadFunction(options.outputType, options)
    elseif item_type == 'LIST' then
        // we are going recursive WOWOW
        local t = {}

        while(net.ReadBool()) do
            local t2 = {}
            for k, v in SortedPairs(options.listObjects) do
                t2[k] = ashop.Network.GetReadFunction(v[1], v[4])
            end
            table.insert(t, t2)
        end

        return t
    else
        error("Value empty, but it was specified from server")
    end
end

function ashop.Network.GetWriteFunction(item_type, value, options)
    if !options or !options.required then
        net.WriteBool(value != nil)
        if value == nil then return end
    end

    if item_type == TYPE_STRING then
        net.WriteString(value)
    elseif item_type == TYPE_VECTOR then
        net.WriteVector(value)
    elseif item_type == TYPE_ANGLE then
        net.WriteAngle(value)
    elseif item_type == TYPE_COLOR then
        net.WriteColor(value)
    elseif item_type == TYPE_BOOL then
        net.WriteBool(value)
    elseif item_type == 'ITEMID' then
        net.WriteUInt(value, ashop.Config.BitsItemID)
    elseif string.StartWith(item_type, "UInt") then
        local n = tonumber(string.sub(item_type, 5))
        net.WriteUInt(value, n)
    elseif item_type == "FLOAT" then
        net.WriteFloat(value)
    elseif item_type == 'SELECT' then
        ashop.Network.GetWriteFunction(options.outputType, value, options)
    elseif item_type == 'DATE' then
        net.WriteUInt(value, 32)
    elseif item_type == 'LIST' then
        // Array of OBJECT, explained by options.listObjects
        for k, v in SortedPairs(value) do
            net.WriteBool(true)

            for key, j in SortedPairs(v) do
                ashop.Network.GetWriteFunction(options.listObjects[key][1], j, options.listObjects[key][4])
            end
        end
        net.WriteBool(false)
    else
        assert("Unknown write function for type: ", item_type)
    end
end

function ashop.Network.GetNetSizeData(item_type, value, options)
    local sum = 0

    if !options or !options.required then
        sum = sum + 1/8
        if value == nil then return 1 end
    end

    if item_type == TYPE_STRING then
        sum = sum + 1 + string.len(value)
    elseif item_type == TYPE_VECTOR then
        sum = sum + 32/8 * 3
    elseif item_type == TYPE_ANGLE then
        sum = sum + 32/4 * 3
    elseif item_type == TYPE_COLOR then
        sum = sum + 4
    elseif item_type == TYPE_BOOL then
        sum = sum + 1/8
    elseif item_type == 'ITEMID' then
        sum = sum + ashop.Config.BitsItemID/8
    elseif string.StartWith(item_type, "UInt") then
        local n = tonumber(string.sub(item_type, 5))
        sum = sum + n/8
    elseif item_type == "FLOAT" then
        sum = sum + 32/8
    elseif item_type == 'SELECT' then
        sum = sum + ashop.Network.GetNetSizeData(options.outputType, value, options)
    elseif item_type == 'DATE' then
        sum = sum + 32/8
    elseif item_type == 'LIST' then
        // Array of OBJECT, explained by options.listObjects
        for k, v in SortedPairs(value) do
            sum = sum + 1/8

            for key, j in SortedPairs(v) do
                sum = sum + ashop.Network.GetNetSizeData(options.listObjects[key][1], j, options.listObjects[key][4])
            end
        end
        sum = sum + 1/8
    else
        assert("Unknown write function for type: ", item_type)
    end

    return math.ceil(sum)
end