local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('PlayerModelClass')
OBJECT_TYPE.UniqueIdentifier = "PlayerModel"

local vec = Vector(15, 0, 0)

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local m = vgui.Create( "DModelPanel" , parent ) -- SpawnIcon
    m:SetSize(parent:GetSize())
    m:SetModel( item.metadata[1] ) -- Model we want for this spawn icon
    m:SetMouseInputEnabled(false)
    m:SetPaintedManually(true)

    local fov = LocalPlayer():GetFOV()
    m:SetFOV(fov)
    m.FarZ = 4096*10

    function m:LayoutEntity() end

    local ent = m:GetEntity()
    local b = ent:LookupBone("ValveBiped.Bip01_Head1")
    local eyepos = b and ent:GetBonePosition(b) or Vector(0, 0, 60)

    m:SetLookAt(eyepos)
    m:SetCamPos(eyepos+vec)

    return true, {m}
end

// Rendering
function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    if ply.DModelPanel and ply.DModelPanel:GetModel() != ashop.GetItemAttribute(plyItem, item, 1) then
        ply.ashop_oldmodel = ply:GetModel()
        ply.DModelPanel:SetModel(ashop.GetItemAttribute(plyItem, item, 1))
    elseif !ply.DModelPanel then
        ply.ashop_oldmodel = ply:GetModel()
        ply:SetModel(ashop.GetItemAttribute(plyItem, item, 1))
    end
end

function OBJECT_TYPE.OnLocalRemove(ply, plyItem, item)
    if ply.ashop_oldmodel and ply:GetModel() == ashop.GetItemAttribute(plyItem, item, 1) then
        if ply.DModelPanel then
            ply.DModelPanel:SetModel(ply.ashop_oldmodel)
        else
            ply:SetModel(ply.ashop_oldmodel)
        end
    end
end

function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if ply.DModelPanel and metadataKey == 1 then
        ply.DModelPanel:SetModel(newValue)
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)