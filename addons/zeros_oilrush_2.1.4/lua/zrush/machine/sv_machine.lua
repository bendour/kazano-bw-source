if CLIENT then return end
zrush = zrush or {}
zrush.Machine = zrush.Machine or {}

local InteractionDistance = 200

// Add the player as listener
function zrush.Machine.UpdateListener_Add(ent,ply)
	if ent.UIListeners == nil then ent.UIListeners = {} end
	ent.UIListeners[ply] = true
end

// Remove the player from the listener list
function zrush.Machine.UpdateListener_Remove(ent,ply)
	if ent.UIListeners == nil then ent.UIListeners = {} end
	ent.UIListeners[ply] = nil
end

// Check which player from the list is valid to receive a machine UI Update
function zrush.Machine.UpdateListener_Get(ent)
	if ent.UIListeners == nil then ent.UIListeners = {} end

	local receivers = {}
	for ply,_ in pairs(ent.UIListeners) do
		if IsValid(ply) and ply:Alive() and zclib.util.InDistance(ply:GetPos(), ent:GetPos(), InteractionDistance) then
			table.insert(receivers,ply)
		else
			zrush.Machine.UpdateListener_Remove(ent,ply)
		end
	end

	return receivers
end

util.AddNetworkString("zrush_Machine_CloseUI")
function zrush.Machine.CloseUI(ent)
	zclib.Debug("zrush.Machine.CloseUI")
	net.Start("zrush_Machine_CloseUI")
	net.WriteEntity(ent)
	net.Broadcast()
end

util.AddNetworkString("zrush_Machine_OpenUI")
function zrush.Machine.OpenUI(ent,ply)
	zclib.Debug("zrush.Machine.OpenUI")

	if zclib.util.InDistance(ply:GetPos(), ent:GetPos(), InteractionDistance) == false then return end

	zrush.Machine.UpdateListener_Add(ent,ply)

	zclib.NetEvent.Create("zrush_action_command", {ent})

	net.Start("zrush_Machine_OpenUI")
	net.WriteEntity(ent)
	net.WriteTable(zrush.Modules.Get(ent))
	net.Send(ply)
end

// This updates the Machine UI
util.AddNetworkString("zrush_Machine_UpdateUI")
function zrush.Machine.UpdateUI(ent, UpdateShop,StatisticOnly)
	timer.Simple(0.1, function()
		if IsValid(ent) then
			if StatisticOnly == nil then StatisticOnly = false end
			zclib.Debug("zrush.Machine.UpdateUI")

			// Only send this out to players which are looking inside the interface
			local receivers = zrush.Machine.UpdateListener_Get(ent)
			if receivers == nil or table.Count(receivers) <= 0 then return end

			net.Start("zrush_Machine_UpdateUI")
			net.WriteEntity(ent)
			net.WriteTable(zrush.Modules.Get(ent))
			net.WriteBool(UpdateShop)
			net.WriteBool(StatisticOnly)
			net.Send(receivers)
		end
	end)
end

// This Updates the Machine Sound
// This is only used to update the sounds pitch for certain machines
util.AddNetworkString("zrush_Machine_UpdateSound")
function zrush.Machine.UpdateSound(ent)
	timer.Simple(0.1, function()
		if (IsValid(ent)) then
			net.Start("zrush_Machine_UpdateSound")
			net.WriteEntity(ent)
			net.SendPVS(ent:GetPos())
		end
	end)
end

// This gets called when we change the state of a entity
function zrush.Machine.SetState(state_id, Machine)
	if not IsValid(Machine) then return end
	if Machine.SetState == nil then return end
	if (state == Machine:GetState()) then return end
	zclib.Debug("(" .. Machine:EntIndex() .. ") Machine(" .. Machine:GetClass() .. ") State: " .. zrush.MachineState.GetName(state_id))
	Machine:SetState(state_id)
end
