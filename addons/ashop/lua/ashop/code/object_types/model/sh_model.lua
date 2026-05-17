local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('PlayerModelClass')
OBJECT_TYPE.DefaultRender = "Accessories"
OBJECT_TYPE.UniqueIdentifier = "PlayerModel"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('PlayerModel1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },
}

OBJECT_TYPE.SlotDefault = 1

// All players
function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if !plyItem.ent then return end

    if ply:GetModel() == oldValue then
        ply:SetModel(newValue)
    end
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if ply.DModelPanel then
        if string.lower(ply.DModelPanel:GetModel()) != string.lower(ashop.GetItemAttribute(plyItem, item, 1)) then
            ply.ashop_oldmodel = ply:GetModel()
            ply.DModelPanel:SetModel(ashop.GetItemAttribute(plyItem, item, 1))
        end
    else
        ply.ashop_oldmodel = ply:GetModel()
        ply:SetModel(ashop.GetItemAttribute(plyItem, item, 1))
    end
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if ply.ashop_oldmodel then
        local oldModel = ply.ashop_oldmodel
        ply.ashop_oldmodel = nil

        if ply:GetModel() == ashop.GetItemAttribute(plyItem, item, 1) then
            if ply.DModelPanel then
                ply.DModelPanel:SetModel(oldModel)
            else
                ply:SetModel(oldModel)
            end
        end
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)