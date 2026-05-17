if not SERVER then return end
zrush = zrush or {}
zrush.EventManager = zrush.EventManager or {}

concommand.Add("zrush_ResetEventManager", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zrush.EventManager.TimerExist()
	end
end)

function zrush.EventManager.TimerExist()
	local timerid = "zrush_eventmanager_id"
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid, zrush.config.ChaosEvents.Interval, 0, zrush.EventManager.TriggerEvent)
end

timer.Simple(0, function()
	zrush.EventManager.TimerExist()
end)

local eventEntity = {
	["zrush_drilltower"] = true,
	["zrush_pump"] = true,
	["zrush_refinery"] = true,
	["zrush_burner"] = true
}

function zrush.EventManager.TriggerEvent()
	for k, v in pairs(zclib.EntityTracker.GetList()) do
		if (IsValid(v) and eventEntity[v:GetClass()]) then
			zrush.EventManager.CheckEvent(v)
		end
	end
end

function zrush.EventManager.CheckEvent(ent)
	//zclib.Debug("zrush.EventManager.CheckEvent")
	local entClass = ent:GetClass()
	local EventPool = {}

	if ent:ReadyForEvent() then

		// First event we skip
		if ent.NextChaosEvent == nil then
			ent.NextChaosEvent = CurTime() + zrush.config.ChaosEvents.Cooldown
			return
		end

		if ent.NextChaosEvent and CurTime() < ent.NextChaosEvent then return end
		local eventChance

		if (entClass == "zrush_drilltower" or entClass == "zrush_pump") then
			eventChance = math.Round(ent:GetBoostValue("antijam"))
		elseif (entClass == "zrush_refinery" or entClass == "zrush_burner") then
			eventChance = math.Round(ent:GetBoostValue("cooling"))
		end

		for i = 1, eventChance do
			table.insert(EventPool, true)
		end

		for i = 1, (100 - eventChance) do
			table.insert(EventPool, false)
		end

		EventPool = zclib.table.randomize(EventPool)

		if table.Random(EventPool) then
			ent.NextChaosEvent = CurTime() + zrush.config.ChaosEvents.Cooldown

			if (entClass == "zrush_drilltower" or entClass == "zrush_pump") then
				zrush.EventManager.JamEvent(ent)
			elseif (entClass == "zrush_refinery" or entClass == "zrush_burner") then
				zrush.EventManager.HeatEvent(ent)
			end
		end
	end
end

function zrush.EventManager.JamEvent(ent)
	zclib.Debug("JamEvent (" .. ent:EntIndex() .. ")")
	zrush.Machine.SetState(ZRUSH_STATE_JAMMED, ent)

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(ent, true)

	// This Updates the Sound
	zrush.Machine.UpdateSound(ent)

	ent:OnJamEvent()
end

function zrush.EventManager.JamFix(ent)
	if (not ent:IsJammed()) then return end
	zclib.NetEvent.Create("zrush_action_unjam", {ent})

	zrush.Machine.SetState(ZRUSH_STATE_UNJAMMED, ent)

	ent:OnJamFixed()

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(ent, true)
end

function zrush.EventManager.HeatEvent(ent)
	zclib.Debug("HeatEvent (" .. ent:EntIndex() .. ")")

	zrush.Machine.SetState(ZRUSH_STATE_OVERHEAT, ent)

	zclib.NetEvent.Create("zrush_event_overheat", {ent})

	zclib.Timer.Remove("zrush_working_" .. ent:EntIndex())

	// Add Timer for big explosion
	local timerid = "zrush_explosiontimer_" .. ent:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid, zrush.config.Machine[ent.MachineID].OverHeat_Countown, 1, function()
		if (IsValid(ent)) then
			ent.IsDeconstructing = true
			ent:OnHeatFailed()
			zrush.Damage.EntityExplosion(ent, ent.MachineID, true)
		end
	end)

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(ent, true)

	ent:OnHeatEvent()
end

function zrush.EventManager.HeatFix(ent)
	if (not ent:IsOverHeating()) then return end
	zclib.NetEvent.Create("zrush_action_cooldown", {ent})

	zrush.Machine.SetState(ZRUSH_STATE_COOLED, ent)

	// Remove timer for big explosion
	zclib.Timer.Remove("zrush_explosiontimer_" .. ent:EntIndex())

	ent:OnHeatFixed()

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(ent, true)
end
