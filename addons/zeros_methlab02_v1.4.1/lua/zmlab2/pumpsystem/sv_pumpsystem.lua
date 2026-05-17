/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if CLIENT then return end

zmlab2 = zmlab2 or {}
zmlab2.PumpSystem = zmlab2.PumpSystem or {}


/*

    The pump system will move liquid from one entity to another
        The duration will be determint by distance
        On client it will display a 3d hose

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

util.AddNetworkString("zmlab2_PumpSystem_EnablePointer")
function zmlab2.PumpSystem.EnablePointer(From,ply)

    zclib.Sound.EmitFromEntity("pumpsystem_start", From)

    net.Start("zmlab2_PumpSystem_EnablePointer")
    net.WriteEntity(From)
    net.Send(ply)
end

util.AddNetworkString("zmlab2_PumpSystem_Start")
net.Receive("zmlab2_PumpSystem_Start", function(len,ply)
    zclib.Debug_Net("zmlab2_PumpSystem_Start",len)
    if zclib.Player.Timeout(nil,ply) == true then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

    local Machine_From = net.ReadEntity()
    local Machine_To = net.ReadEntity()

    if not IsValid(Machine_From) then return end
    if not IsValid(Machine_To) then return end

    // Does Machine A needs the liquid from Machine B
    if zmlab2.PumpSystem.AllowConnection(Machine_From,Machine_To) == false then return end

    if zmlab2.Player.CanInteract(ply, Machine_From) == false then return end
    if zmlab2.Player.CanInteract(ply, Machine_To) == false then return end
    if zclib.util.InDistance(ply:GetPos(), Machine_From:GetPos(), 1000) == false then return end
    if zclib.util.InDistance(ply:GetPos(), Machine_To:GetPos(), 1000) == false then return end


    zclib.Sound.EmitFromEntity("pumpsystem_connected", Machine_To)
    zclib.Sound.EmitFromEntity("liquid_fill", Machine_From)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    zmlab2.PumpSystem.Start(Machine_From,Machine_To)
end)

util.AddNetworkString("zmlab2_PumpSystem_AddHose")
function zmlab2.PumpSystem.Start(From,To)
    zclib.Debug("zmlab2.PumpSystem.Start")

    // Creates a client side Hose / Cable
    net.Start("zmlab2_PumpSystem_AddHose")
    net.WriteEntity(From)
    net.WriteEntity(To)
    net.Broadcast()

    From:Unloading_Started()

    To:Loading_Started()

    local time = zmlab2.PumpSystem.GetTime(From:GetPos(),To:GetPos())

    local timerid = "zmlab2_pumpsystem_" .. From:EntIndex()
    zclib.Timer.Create(timerid,time,1,function()

        zclib.Debug("zmlab2.PumpSystem.Finished")
        // Finished Pumpin
        if IsValid(From) and IsValid(To) then
            To:Loading_Finished(From)
        end

        if IsValid(From) then
            From:Unloading_Finished()
        end

        zclib.Timer.Remove(timerid)
    end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf
