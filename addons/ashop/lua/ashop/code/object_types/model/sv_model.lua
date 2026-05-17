local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('PlayerModelClass')
OBJECT_TYPE.UniqueIdentifier = "PlayerModel"

hook.Add('PlayerSetModel', 'ashop_pm_setmodel', function(ply, _, now)
    if !ply.ashop_data then return end

    // Read warning: https://wiki.facepunch.com/gmod/GM:PlayerSpawn
    timer.Simple(0, function()
        ply.ashop_oldmodel = ply:GetModel()
        local b = ashop.GetObjectTypeIDByUID('PlayerModel')
        local itemID = ply:AShop_SlotStateGet(b)[1]
        if !itemID then return end
    
        local plyItem = ply.ashop_data.items[itemID]
        local item = ashop.items[plyItem.item_id]
    
        local model = ashop.GetItemAttribute(plyItem, item, 1)
    
        // Shouldn't happens
        if !model then return end
    
        ply:SetModel(model)
        if IsValid(ply:GetHands()) then
            hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
        end
        return true
    end)
end)

function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if metadataKey == 1 then
        ply:SetModel(newValue)

        if IsValid(ply:GetHands()) then
            hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
        end
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)