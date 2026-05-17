local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Badges"
OBJECT_TYPE.UniqueIdentifier = "Badges"

function ashop.GetPlayerBadges(ply)
    local t = {}

    assert(IsValid(ply), 'Calling ashop.GetPlayerBadges without valid ply')

    if !ply.ashop_data or !ply.ashop_data.equipped then return t end

    local succ, id, tbl = pcall(ashop.GetObjectTypeIDByUID, "Badges")
    if !succ then return t end
    if !ply.ashop_data or !ply.ashop_data.equipped or !ply.ashop_data.equipped[id] then return t end


    for _, plyItemID in pairs(ply.ashop_data.equipped[id][0]) do
        local plyItem = ply.ashop_data.items[plyItemID]
        assert(plyItem, "Missing plyItem, while being equipped")

        local item = ashop.items[plyItem.item_id]
        local mat

        local ptrTbl = {
            name = item.name,
            desc = item.metadata[2],
            mat = function()
                return mat
            end,
        }

        ashop.ui.setMaterialByLink(item.metadata[1], nil, function(m)
            // Be cool with devs, don't make a painful api, even if this is a bit ugly
            if isfunction(m) then
                ptrTbl.mat = m
            else
                mat = m
            end
        end, 'UnlitGeneric')

        table.insert(t, ptrTbl)
    end

    return t
end

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)

    local c = math.min(math.max(w, h) * 0.6, 64)
    local sub = vgui.Create("EditablePanel", circleParent)
    sub:SetSize(c, c)
    sub:Center()

    local mat
    ashop.ui.setMaterialByLink(item.metadata[1], nil, function(m)
        mat = m
    end, 'UnlitGeneric')

    local r1
    function sub:Paint(w, h)
        if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, 0, 0, w, h)
        end

        if !mat then return end

        ashop.StartStencil()
            surface.SetDrawColor(1,1,1,1)
            draw.NoTexture()
            surface.DrawPoly(r1)
        ashop.ReplaceStencil(1)
            surface.SetDrawColor(255, 255, 255)
            local m = isfunction(mat) and mat() or mat
            surface.SetMaterial(m)
            surface.DrawTexturedRect(0, 0, w, h)
        ashop.EndStencil()
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)