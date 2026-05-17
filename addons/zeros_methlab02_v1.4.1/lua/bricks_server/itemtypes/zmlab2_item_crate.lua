/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

local ITEM = BRICKS_SERVER.Func.CreateItemType( "zmlab2_item_crate" )

ITEM.GetItemData = function(ent)
    if (not IsValid(ent)) then return end
    local itemData = {"zmlab2_item_crate", "models/zerochain/props_methlab/zmlab2_crate.mdl", ent:GetMethType(),ent:GetMethQuality(),ent:GetMethAmount()}

    return itemData, 1
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

ITEM.OnSpawn = function(ply, pos, itemData, itemAmount)
    local ent = ents.Create("zmlab2_item_crate")
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetMethType(itemData[3])
    ent:SetMethQuality(itemData[4])
    ent:SetMethAmount(itemData[5])
    zclib.Player.SetOwner(ent, ply)
end

ITEM.GetInfo = function( itemData )
    local itemDescription = ""
    local itemtitle = ""

    local MethType = itemData[3]
    local MethQuality = itemData[4]
    if zmlab2.config.MethTypes[MethType] and zmlab2.config.MethTypes[MethType].desc then
        itemDescription = zmlab2.config.MethTypes[MethType].desc
    end

    if zmlab2.config.MethTypes[MethType] and zmlab2.config.MethTypes[MethType].name then
        itemtitle = zmlab2.config.MethTypes[MethType].name .. " " .. (MethQuality or 0) .. "%" .. " " .. itemData[5] .. zmlab2.config.UoM
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    return { itemtitle, itemDescription, "" }
end

ITEM.ModelDisplay = function( Panel, itemtable )
    if ( not Panel.Entity or not IsValid( Panel.Entity ) ) then return end

    local mn, mx = Panel.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    Panel:SetFOV( 40 )
    Panel:SetCamPos( Vector( size, size, size * 0.8 ) )
    Panel:SetLookAt( (mn + mx) * 0.5 )
    Panel.Entity:SetAngles(Angle(0,100,0))

    if itemtable[5] and itemtable[5] > 0 then
        local MethMat = zmlab2.Meth.GetMaterial(itemtable[3], itemtable[4])
        if MethMat then
            Panel.Entity:SetSubMaterial(0, "!" .. MethMat)
        end
    end
end

ITEM.CanCombine = function(itemData1, itemData2)
    return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

ITEM:Register()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

if BRICKS_SERVER and BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.INVENTORY and BRICKS_SERVER.CONFIG.INVENTORY.Whitelist then
    BRICKS_SERVER.CONFIG.INVENTORY.Whitelist["zmlab2_item_crate"] = {false,true}
end
