ashop.pac3 = ashop.pac3 or {}

util.AddNetworkString('ashop_Pac3_New')

function ashop.Pac3Create(name, txt, model_attach)
    if !name then
        return "Pac3 must have a name"
    end

    if !txt then
        return "Empty pac3 text"
    end

    ashop.SQL.query("INSERT INTO ashop_pac3(outfit, name, model_attach) VALUES(" .. ashop.SQL.escape(txt) .. ", " .. ashop.SQL.escape(name) .. ", " .. (model_attach and 1 or 0) .. ")", function(_, qO)
       local sqlID = qO:lastInsert()
       ashop.pac3[sqlID] = {
            outfit = txt,
            name = name,
            model_attach = model_attach
        }

        net.Start('ashop_Pac3_New')
            net.WriteUInt(sqlID, ashop.Config.BitsPac3)
            ashop.Network.W_Pac3(ashop.pac3[sqlID])
        net.Broadcast()
    end)
end

util.AddNetworkString('ashop_Pac3_Edit')

function ashop.Pac3Update(pac3, id, paramValue)
    local paramName

    if id == 0 then
        paramName = "outfit"
        ashop.SQL.query("UPDATE ashop_pac3 SET outfit = " .. ashop.SQL.escape(paramValue) .. " WHERE id = " .. pac3)
    elseif id == 1 then
        paramName = "name"
        assert(string.len(paramValue) <= 32, "Too long name")
        ashop.SQL.query("UPDATE ashop_pac3 SET name = " .. ashop.SQL.escape(paramValue) .. " WHERE id = " .. pac3)
    elseif id == 2 then
        paramName = "model_attach"
        ashop.SQL.query("UPDATE ashop_pac3 SET " .. paramName .. " = " .. (paramValue and "1" or "0") .. " WHERE id = " .. pac3)
    else
        error("Not a valid ID")
    end
    
    ashop.pac3[pac3][paramName] = paramValue

    net.Start('ashop_Pac3_Edit')
        net.WriteUInt(id, 2)
        net.WriteUInt(pac3, ashop.Config.BitsPac3)

        if id == 0 then
            ashop.Network.W_Compress(paramValue)
        elseif id == 1 then
            net.WriteString(paramValue)
        else
            net.WriteBool(paramValue)
        end
    net.Broadcast()
end

util.AddNetworkString('ashop_Pac3_Delete')
ashop.SafeNet('Pac3_Delete', function(ply)
    local id = net.ReadUInt(ashop.Config.BitsPac3)
    if !ashop.pac3[id] then return end
    local name = ashop.pac3[id].name
    ashop.DeletePac3(id)
    ashop.Logs.PushLog(ashop.Logs.IDs.Pac3_Delete, name, ply)
end, 1, true)



hook.Add("PrePACConfigApply", "AShopPac3Restrict", function(ply, outfit_data)
    if ashop.BlockPac3Edit then
        return false, "Disable by AShop config"
	end
end)

hook.Add("PrePACEditorOpen", "AShopPac3Restrict", function(ply)
    if ashop.BlockPac3Edit then
        return false, "Disable by AShop config"
	end
end)