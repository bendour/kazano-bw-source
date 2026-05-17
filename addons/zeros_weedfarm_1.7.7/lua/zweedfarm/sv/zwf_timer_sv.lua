if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.SetupTimers()

	zwf.f.Timer_Remove("zwf_MainTick_id")
	zwf.f.Timer_Create("zwf_MainTick_id", 1, 0, function()
		zwf.f.Lamp_Logic()
		zwf.f.Ventilator_Logic()
		zwf.f.Flowerpot_Logic()
	end)


	zwf.f.Timer_Remove("zwf_GeneratorTick_id")
	zwf.f.Timer_Create("zwf_GeneratorTick_id", zwf.config.Generator.Power_intarval, 0, function()
		zwf.f.Generator_Logic()
	end)


	zwf.f.Timer_Remove("zwf_PowerWaterTick_id")
	zwf.f.Timer_Create("zwf_PowerWaterTick_id", zwf.config.Cable.transfer_interval, 0, function()
		zwf.f.PowerWater_Logic()
	end)
end

zwf.f.SetupTimers()
