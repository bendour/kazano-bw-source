util.AddNetworkString('ashop_CarMaterial_Delete')
util.AddNetworkString('ashop_CarMaterial_Edit')
util.AddNetworkString('ashop_CarMaterial_Create')
util.AddNetworkString('ashop_CarMaterial_Ping')

local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('CarSkins')
OBJECT_TYPE.UniqueIdentifier = "CarSkin"

ashop.RegisterObjectType(OBJECT_TYPE)

// Hook
local function sendSkin(ply, veh)
    if !IsValid(veh) then return end

    net.Start('ashop_CarMaterial_Ping')
        net.WriteEntity(ply)
        net.WriteUInt(veh:EntIndex(), 13)
        net.WriteString(veh:GetVehicleClass())
    net.Broadcast()
end

// TODO: Resend to connecting players
hook.Add("PlayerEnteredVehicle", "ashop_carskin", sendSkin)

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if !item.metadata[1] then return end
    if ply:InVehicle() then sendSkin(ply, ply:GetVehicle()) end
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    ply.ashop_carskin = nil
    if ply:InVehicle() then sendSkin(ply, ply:GetVehicle()) end
end

// Car nets
ashop.SafeNet('CarMaterial_Delete', function(ply)
    local id = net.ReadString()

    if !ashop.carmaterials[id] then return end
    ashop.carmaterials[id] = nil

    net.Start('ashop_CarMaterial_Delete')
        net.WriteString(id)
    net.Broadcast()

    ashop.SQL.query("DELETE FROM ashop_carmaterials WHERE car = " .. ashop.SQL.escape(id))
    ashop.Logs.PushLog(ashop.Logs.IDs.CarMaterial_Delete, ply, wep)
end, 0.15, true)

ashop.SafeNet('CarMaterial_Create', function(ply)
    local car = net.ReadString()
    if ashop.carmaterials[car] then return end

    ashop.carmaterials[car] = {}

    net.Start('ashop_CarMaterial_Create')
        net.WriteString(car)
        ashop.Network.W_CarMaterials(ashop.carmaterials[car])
    net.Broadcast()

    ashop.SQL.query("INSERT INTO ashop_carmaterials(car, data) VALUES(" .. ashop.SQL.escape(car) .. ", '[]')")

    ashop.Logs.PushLog(ashop.Logs.IDs.CarMaterial_Create, ply, car)
end, 0.5, true)

ashop.SafeNet('CarMaterial_Edit', function(ply)
    local car = net.ReadString()
    local b = net.ReadBool()
    local id = net.ReadUInt(8)

    if !ashop.carmaterials[car] then return end

    ashop.carmaterials[car] = ashop.carmaterials[car] or {}
    ashop.carmaterials[car][id] = b and true or nil

    // This is only number, they can't sql injection that
    ashop.SQL.query("UPDATE ashop_carmaterials SET data = '" .. util.TableToJSON(ashop.carmaterials[car]) .. "' WHERE car = " .. ashop.SQL.escape(car))
    net.Start('ashop_CarMaterial_Edit')
        net.WriteString(car)
        net.WriteBool(ashop.carmaterials[car][id])
        net.WriteUInt(id, 8)
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.CarMaterial_Update, ply, car)
end, 0.15, true)

/*

    net.Start('ashop_CarMaterial_Edit')
        net.WriteString(car)
        net.WriteBool(ashop.carmaterials[car][id])
        net.WriteUInt(id, 8)
    net.SendToServer()
*/