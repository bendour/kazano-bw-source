if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

if zmlab.DropOffPoints == nil then
	zmlab.DropOffPoints = {}
end

util.AddNetworkString("zmlab_AddDropOffHint")
util.AddNetworkString("zmlab_RemoveDropOffHint")

function zmlab.f.Dropoffpoint_Initialize(Dropoffpoint)
    zmlab.f.Debug("zmlab.f.Dropoffpoint_Initialize")
    zmlab.f.EntList_Add(Dropoffpoint)
    table.insert(zmlab.DropOffPoints, Dropoffpoint)
    Dropoffpoint.Deliver_Player = nil
end

function zmlab.f.Dropoffpoint_USE(Dropoffpoint, ply)
    zmlab.f.Debug("zmlab.f.Dropoffpoint_USE")
    if ply ~= Dropoffpoint.Deliver_Player then return end
    -- if zmlab.f.Player_CheckJob(ply) == false then return end
    if zmlab.f.GetSellMode(ply) ~= 3 then return end
    if zmlab.f.HasPlayerMeth(ply) == false then return end

	zmlab.f.SellMeth_DropOffPoint_USE(ply, Dropoffpoint)
end

local zmlab_dropents = {
	["zmlab_meth"] = true,
	["zmlab_collectcrate"] = true,
	["zmlab_palette"] = true
}

function zmlab.f.Dropoffpoint_Touch(Dropoffpoint, other)
	if not IsValid(Dropoffpoint) then return end

	if not IsValid(other) then return end

	if zmlab_dropents[other:GetClass()] == nil then return end

	if zmlab.f.CollisionCooldown(other) then return end

	zmlab.f.Debug("zmlab.f.Dropoffpoint_Touch")

	if other:GetMethAmount() <= 0 then return end

	if not IsValid(Dropoffpoint.Deliver_Player) then return end

	local owner = zmlab.f.GetOwner(other)
	if not IsValid(owner) then return end

	if owner ~= Dropoffpoint.Deliver_Player then return end

	zmlab.f.SellMeth_DropOffPoint(owner, Dropoffpoint, other)
end


function zmlab.f.Dropoffpoint_Open(Dropoffpoint, ply)
    zmlab.f.Debug("zmlab.f.Dropoffpoint_Open")

    net.Start("zmlab_AddDropOffHint")
    net.WriteVector(Dropoffpoint:GetPos())
    net.Send(ply)

    Dropoffpoint:SetDeliver_PlayerID(ply:SteamID64())
    Dropoffpoint.Deliver_Player = ply
    Dropoffpoint:SetIsClosed(false)

    timer.Create(Dropoffpoint:EntIndex() .. "_AutoCloseTimer_" .. ply:SteamID64(), zmlab.config.DropOffPoint.DeliverTime, 1, function()
        if IsValid(Dropoffpoint) then
            zmlab.f.Dropoffpoint_Close(Dropoffpoint)
        end
    end)
end

function zmlab.f.Dropoffpoint_Close(Dropoffpoint)
    zmlab.f.Debug("zmlab.f.Dropoffpoint_Close")

    net.Start("zmlab_RemoveDropOffHint")
    net.Send(Dropoffpoint.Deliver_Player)

    timer.Remove(Dropoffpoint:EntIndex() .. "_AutoCloseTimer_" .. Dropoffpoint.Deliver_Player:SteamID64())

    Dropoffpoint.Deliver_Player.DropOffPoint = nil
    Dropoffpoint:SetDeliver_PlayerID("nil")
    Dropoffpoint.Deliver_Player = nil
    Dropoffpoint:SetIsClosed(true)
end
