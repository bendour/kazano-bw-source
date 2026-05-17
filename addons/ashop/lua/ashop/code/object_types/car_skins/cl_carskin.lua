local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('CarSkins')
OBJECT_TYPE.UniqueIdentifier = "CarSkin"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle, fullSize)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local c = fullSize and math.max(w, h) or math.max(w, h) * 0.4

    // What an hack...
    local SpawnI = vgui.Create( "DPanel" , circleParent ) -- SpawnIcon
    SpawnI:SetSize(c, c)
    SpawnI:Center()
    
    local r1
    function SpawnI:Paint(w, h)
        if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, 0, 0, w, h)
        end

        ashop.StartStencil()
            surface.SetDrawColor(1,1,1,1)
            draw.NoTexture()
            surface.DrawPoly(r1)
        ashop.ReplaceStencil(1)
            surface.SetDrawColor(255, 255, 255)
            surface.SetTexture(surface.GetTextureID(item.metadata[1]))
            surface.DrawTexturedRect(0, 0, w, h)
        ashop.EndStencil()
    end
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if !item.metadata[1] then return end
    ply.ashop_carskin = item.metadata[1]
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    ply.ashop_carskin = nil
end


ashop.vehiclesSkinTrack = ashop.vehiclesSkinTrack or {}
hook.Add("PostRender", "ashop_setVehicleSkin", function()
    if table.IsEmpty(ashop.vehiclesSkinTrack) then return end

    for k, v in pairs(ashop.vehiclesSkinTrack) do
        v()
    end
end)

hook.Add('EntityRemoved', 'ashop_clearVehicleSkin', function(ent)
    ashop.vehiclesSkinTrack[ent] = nil
end)

net.Receive('ashop_CarMaterial_Ping', function()
    local ply = net.ReadEntity()
    local vehIndex = net.ReadUInt(13)
    local vehClass = net.ReadString()
    local n = 'ashop_waitveh_' .. ply:EntIndex()

    timer.Create(n, 0.25, 20, function()
        if !IsValid(ply) then
            timer.Remove(n)
            return
        end

        local veh = Entity(vehIndex)
        if IsValid(veh) and ashop.carmaterials then
            local vehSkinTable = ashop.carmaterials[vehClass]
            if !vehSkinTable then return end

            local b = ashop.GetObjectTypeIDByUID('CarSkin')
            local equipped = ply:AShop_SlotStateGet(b)
            local plyitemID = -1

            for k, v in pairs(equipped or {}) do
                local plyItem = ply.ashop_data.items[v]
                local item = ashop.items[plyItem.item_id]
    
                if !item.metadata[2] or table.IsEmpty(item.metadata[2]) then
                    plyitemID = v
                    break
                else
                    for _, d in ipairs(item.metadata[2]) do
                        if d[1] != vehClass then continue end
                        plyitemID = v
                        break
                    end
                end
            end

            // 00000000000000000
            local matToSet = plyitemID != -1 and ashop.items[ply.ashop_data.items[plyitemID].item_id].metadata[1] or ""

            if string.StartWith(matToSet, "ht") then
                ashop.ui.setMaterialByLink(matToSet, nil, function(m)
                    if isfunction(m) then
                        local oldMat

                        ashop.vehiclesSkinTrack[veh] = function()
                            local newMat = m()

                            if oldMat == newMat then return end

                            oldMat = newMat
                            local n = newMat:GetName()

                            for k, v in pairs(vehSkinTable) do
                                veh:SetSubMaterial(k, "!" .. n)
                            end
                        end
                    else
                        for i = 1, #veh:GetMaterials() do
                            veh:SetSubMaterial(i-1, vehSkinTable[i-1] and "!" .. m:GetName() or "")
                        end
                    end
                end, 'VertexLitGeneric')
            else
                for i = 1, #veh:GetMaterials() do
                    veh:SetSubMaterial(i-1, vehSkinTable[i-1] and matToSet or "")
                end
            end

            timer.Remove(n)
            return
        end
    end)
end)

ashop.RegisterObjectType(OBJECT_TYPE)