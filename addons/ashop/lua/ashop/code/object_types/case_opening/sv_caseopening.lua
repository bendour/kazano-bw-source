local methods = include('sh_hiddenmethods.lua')

local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Case Opening"
OBJECT_TYPE.UniqueIdentifier = "CaseOpening"

util.AddNetworkString('AShop_CaseOpening')
util.AddNetworkString('AShop_CaseOpeningAlert')

function OBJECT_TYPE.OnUse(ply, plyItem, item)
    // Pick a item
    local id = methods.GetCaseLuck(item.metadata[2])[1]
    ashop.actions.Give(ply, id, nil, 0, false)

    // Check if this rarity deserves a notification
    local getRarity = ashop.items[id].rarity

    local randTime = math.random(6, 12)
    if ashop.rarity[getRarity].notif_unbox then
        timer.Simple(randTime + 2, function()
            ashop.sendDataToIgnorants({[id] = ashop.items[id]}, 'items')

            net.Start("AShop_CaseOpeningAlert")
                net.WritePlayer(ply)
                net.WriteUInt(id, ashop.Config.BitsItemID)
            net.Broadcast()
        end)
    end

    net.Start('AShop_CaseOpening')
        net.WriteUInt(id, ashop.Config.BitsItemID)
        net.WriteFloat(randTime)
    net.Send(ply)
end

ashop.RegisterObjectType(OBJECT_TYPE)