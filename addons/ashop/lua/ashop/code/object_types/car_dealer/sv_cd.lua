local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Cars"
OBJECT_TYPE.UniqueIdentifier = "Cars"

function OBJECT_TYPE.OnUse(ply, plyItem, item)
    local ct = concommand.GetTable()

    if ct['mcd_givecar'] then
        RunConsoleCommand('mcd_givecar', ply:SteamID64(), "AShop", item.metadata[1])
    elseif ct['acd_givevehicle'] then
        RunConsoleCommand('acd_givevehicle', ply:SteamID64(), item.metadata[1])
    elseif Flux then
        Flux.CarDealerAdd(ply:SteamID64(), tonumber(item.metadata[1]))
    elseif ct['rcd_give_vehicle'] then
        RunConsoleCommand('rcd_give_vehicle', ply:SteamID64(), item.metadata[1])
    else
        error('[AShop] Trying to buy a car, without any supported car dealer')
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)