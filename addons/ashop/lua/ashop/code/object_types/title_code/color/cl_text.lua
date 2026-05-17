local OBJECT_TYPE = {}

// UI
OBJECT_TYPE.Name = ashop.L('ColorClass')
OBJECT_TYPE.BlockSlotEdit = true
OBJECT_TYPE.UniqueIdentifier = "TitleColor"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:Dock(FILL)
    circleParent:SetMouseInputEnabled(false)

    function circleParent:Paint(w, h)
        ashop.DrawTitle(nil, item.metadata[2] or item.metadata[1], nil, w/2, h/2, nil, TEXT_ALIGN_CENTER)
    end
end

// Rendering
function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    ply.ashop_titlecolor = nil
    if item.metadata then
        ply.ashop_titlecolor = item.metadata[2] or item.metadata[1]
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
    ply.ashop_titlecolor = nil
end

function OBJECT_TYPE.OnPostPlayerDraw(ply, plyItem, item, inModelPanel)
end

ashop.RegisterObjectType(OBJECT_TYPE)