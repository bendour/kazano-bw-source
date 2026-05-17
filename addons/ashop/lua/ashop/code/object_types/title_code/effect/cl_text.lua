local OBJECT_TYPE = {}

// UI
OBJECT_TYPE.Name = ashop.L('EffectClass')
OBJECT_TYPE.BlockSlotEdit = true
OBJECT_TYPE.UniqueIdentifier = "TitleEffect"

local circle = Material('akulla/circle.png', 'smooth')
function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:Dock(FILL)
    circleParent:SetMouseInputEnabled(false)

    local clrR, clrG, clrB, clrA = ColorAlpha(ashop.rarity[item.rarity], 20):Unpack()
    function circleParent:Paint(w, h)
        if !noCircle then
            surface.SetDrawColor(clrR, clrG, clrB, clrA)
            surface.SetMaterial(circle)
            surface.DrawTexturedRect(w*0.1, h*0.1, w*0.8, h*0.8)
        end

        ashop.DrawTitle(nil, nil, ashop.titles.styles[item.metadata[1]] and ashop.titles.styles[item.metadata[1]].draw or nil, w/2, h/2, nil, TEXT_ALIGN_CENTER)
    end
end

// Rendering
function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    ply.ashop_titlestyle = nil
    if item.metadata[1] and ashop.titles.styles[item.metadata[1]] then
        ply.ashop_titlestyle = ashop.titles.styles[item.metadata[1]].draw
    end
end

function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnLocalRemove(ply, plyItem, item)
    OBJECT_TYPE.OnRemove(ply, plyItem, item)
end

function OBJECT_TYPE.OnLocalFPDraw(ply)
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    ply.ashop_titlestyle = nil
end

ashop.RegisterObjectType(OBJECT_TYPE)