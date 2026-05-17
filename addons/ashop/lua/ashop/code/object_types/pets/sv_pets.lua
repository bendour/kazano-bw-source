local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('PetClass')
OBJECT_TYPE.UniqueIdentifier = "Pets"

util.AddNetworkString('ashop_pet')

/*
Three tricks were available, to avoid the entity not being SetPos by the client anymore, if its outside PVS.
One: Use a clientside model, and put the "real" entity as a child of the owner.
Second: Use CalcAbsolutePosition and Refresh only the pos, if the entity is outside the pvs
Third: SetParent + SetLocalPos/LocalAngles

I choose the first one.
*/
function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    plyItem.ent = ents.Create('ashop_pet')
    if !IsValid(plyItem.ent) then return end
    plyItem.ent:SetPos(ply:GetPos())
    plyItem.ent:Spawn()
    plyItem.ent:SetParent(ply)

    plyItem.ent.owner = ply
    plyItem.ent.plyItemObject = plyItem.id

    net.Start('ashop_pet')
        net.WriteUInt(plyItem.ent:EntIndex(), 16)
        net.WriteUInt(plyItem.id, ashop.Config.BitsPlyItemID)
        net.WriteEntity(ply)
    net.Broadcast()
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if IsValid(plyItem.ent) then
        plyItem.ent:Remove()
    end
end

hook.Add("ashop_playerInit", "loadPets", function(ply)
    for k, v in ipairs(ents.FindByClass('ashop_pet')) do
        if IsValid(v.owner) then
            net.Start('ashop_pet')
                net.WriteUInt(v:EntIndex(), 16)
                net.WriteUInt(v.plyItemObject, ashop.Config.BitsPlyItemID)
                net.WriteEntity(v.owner)
            net.Send(ply)
        end
    end
end)

ashop.RegisterObjectType(OBJECT_TYPE)