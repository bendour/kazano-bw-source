zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.sounds = zwf.sounds or {}

zwf.GlobalSounds = {
	["zwf_cash01"] = Sound("zwf/zwf_cash01.wav"),
}

zwf.SoundVolume = 1

// This packs the requested sound Data
function zwf.f.CatchSound(id)
	local soundData = {}
	local soundTable = zwf.sounds[id]
	soundData.sound = soundTable.paths[math.random(#soundTable.paths)]
	soundData.lvl = soundTable.lvl
	soundData.pitch = math.Rand(soundTable.pitchMin, soundTable.pitchMax)
	local vol = 1
	if CLIENT then
		vol = zwf.SoundVolume
	end
	soundData.volume = vol * soundTable.pref_volume

	return soundData
end

function zwf.f.EmitSoundENT(id, ent)
	local soundData = zwf.f.CatchSound(id)
	EmitSound(soundData.sound, ent:GetPos(), ent:EntIndex(), CHAN_STATIC, soundData.volume, soundData.lvl, 0, soundData.pitch)
end

// Gets called when the player changes the volume
function zwf.f.VolumeChanged(old_volume,new_volume)

	zwf.SoundVolume =  new_volume

	if timer.Exists( "zwf_loopedsound_updater" ) then
		timer.Remove( "zwf_loopedsound_updater" )
	end

	timer.Create( "zwf_loopedsound_updater", 0.25, 1, function()

		if timer.Exists( "zwf_loopedsound_updater" ) then
			timer.Remove( "zwf_loopedsound_updater" )
		end

		zwf.f.Update_LoopedSound_Volume()
	end )
end

// Updates the looped sounds for all entites near the player
function zwf.f.Update_LoopedSound_Volume()
	local ply_pos = LocalPlayer():GetPos()

	for k, v in pairs(zwf.EntList) do
		if IsValid(v) and zwf.f.InDistance(ply_pos, v:GetPos(), 1000) and zwf.f.FunctionValidater(v.OnVolumeChange) then
			v:OnVolumeChange()
		end
	end
end


// Generic
sound.Add({
	name = "zwf_cough",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {90, 110},
	sound = {"zwf/zwf_cough.wav"}
})

// Generic
sound.Add({
	name = "zwf_ui_click",
	channel = CHAN_STATIC,
	volume = 1,
	level = 60,
	pitch = {100, 100},
	sound = {"UI/buttonclick.wav"}
})

// Sniff Swep
zwf.sounds["zwf_sniff"] = {
	paths = {"zwf/zwf_sniff01.wav","zwf/zwf_sniff02.wav"},
	lvl = 60,
	pitchMin = 95,
	pitchMax = 105,
	pref_volume = 1
}


// NPC
zwf.sounds["zwf_selling"] = {
	paths = {"zwf/zwf_cash01.wav"},
	lvl = 70,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_npc_wrongjob"] = {
	paths = {"vo/npc/male01/pardonme01.wav", "vo/npc/male01/pardonme02.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_npc_sell"] = {
	paths = {"vo/NovaProspekt/eli_foundme02.wav", "vo/npc/male01/question02.wav", "vo/npc/male01/question03.wav", "vo/npc/male01/question04.wav", "vo/npc/male01/question05.wav", "vo/npc/male01/question06.wav", "vo/npc/male01/question09.wav", "vo/npc/male01/question10.wav", "vo/npc/male01/question13.wav", "vo/npc/male01/question16.wav", "vo/npc/male01/question17.wav", "vo/npc/male01/question18.wav", "vo/npc/male01/question19.wav", "vo/npc/male01/question23.wav", "vo/npc/male01/question25.wav", "vo/npc/male01/question27.wav", "vo/npc/male01/question28.wav", "vo/npc/male01/question29.wav", "vo/npc/male01/question30.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// WaterTank
zwf.sounds["zwf_water_refill"] = {
	paths = {"ambient/water/water_splash1.wav", "ambient/water/water_splash2.wav", "ambient/water/water_splash3.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// PackingStation
zwf.sounds["zwf_weed_pack"] = {
	paths = {"zwf/zwf_weed_pack.wav"},
	lvl = 60,
	pitchMin = 95,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_place_jar"] = {
	paths = {"zwf/zwf_place_jar.wav"},
	lvl = 60,
	pitchMin = 99,
	pitchMax = 100,
	pref_volume = 1
}


// Plants
zwf.sounds["zwf_cut_plant"] = {
	paths = {"zwf/zwf_plant_cut.wav"},
	lvl = 70,
	pitchMin = 90,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_plant_heal"] = {
	paths = {"zwf/zwf_plant_heal.wav"},
	lvl = 60,
	pitchMin = 90,
	pitchMax = 100,
	pref_volume = 1
}
sound.Add({
	name = "zwf_plant_plague",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_plant_plague.wav"}
})


// Buttons
zwf.sounds["zwf_button_on"] = {
	paths = {"buttons/button24.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_button_off"] = {
	paths = {"buttons/button16.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// Cable Swep
zwf.sounds["zwf_cable_select"] = {
	paths = {"UI/buttonclick.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_cable_connect"] = {
	paths = {"weapons/ar2/ar2_reload_push.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_cable_deconnect"] = {
	paths = {"weapons/357/357_reload4.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// High Music
for k, v in pairs(zwf.config.Plants) do
	if v.high_music ~= nil and v.high_music ~= "" and v.high_music ~= " " then
		sound.Add({
			name = "zwf_weedmusic0" .. k,
			channel = CHAN_STATIC,
			volume = 0.25,
			level = 80,
			pitch = {100, 100},
			sound = v.high_music
		})
	end
end


// SeedLab
sound.Add({
	name = "zwf_seedlab_scan",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 50,
	pitch = {100, 100},
	sound = {"npc/scanner/combat_scan_loop6.wav"}
})


// Ventilator
sound.Add({
	name = "zwf_ventilator_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 50,
	pitch = {100, 100},
	sound = {"zwf/zwf_ventilator_loop.wav"}
})


// Generator
sound.Add({
	name = "zwf_generator_running",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_generator_running.wav"}
})
sound.Add({
	name = "zwf_generator_damaged",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_generator_damaged.wav"}
})
zwf.sounds["zwf_generator_repair"] = {
	paths = {"zwf/zwf_generator_repair.wav"},
	lvl = 60,
	pitchMin = 90,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_generator_start_fail"] = {
	paths = {"zwf/zwf_generator_start_fail.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_generator_start_sucess"] = {
	paths = {"zwf/zwf_generator_start_sucess.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_generator_stop"] = {
	paths = {"zwf/zwf_generator_stop.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_fuel_fill"] = {
	paths = {"zwf/zwf_gas_can_fill_01.wav"},
	lvl = 50,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// Lamp
sound.Add({
	name = "zwf_lamp_sodium_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 45,
	pitch = {100, 100},
	sound = {"zwf/zwf_lamp_sodium_loop.wav"}
})
sound.Add({
	name = "zwf_lamp_led_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 45,
	pitch = {100, 100},
	sound = {"zwf/zwf_lamp_led_loop.wav"}
})
zwf.sounds["zwf_lamp_sodium_start"] = {
	paths = {"zwf/zwf_lamp_sodium_start.wav"},
	lvl = 45,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_lamp_sodium_stop"] = {
	paths = {"zwf/zwf_lamp_sodium_stop.wav"},
	lvl = 45,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// Bong
sound.Add({
	name = "zwf_igniter_lit",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_igniter_lit.wav"}
})
sound.Add({
	name = "zwf_bong_end",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_bong_end.wav"}
})
sound.Add({
	name = "zwf_bong_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_bong_loop.wav"}
})
zwf.sounds["zwf_bong_exhale_short"] = {
	paths = {"zwf/zwf_bong_exhale_short.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_bong_exhale_mid"] = {
	paths = {"zwf/zwf_bong_exhale_mid.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_bong_exhale_long"] = {
	paths = {"zwf/zwf_bong_exhale_long.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// WateringCan
sound.Add({
	name = "zwf_watering_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_watering.wav"}
})


// Joint
sound.Add({
	name = "zwf_joint_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_joint_loop.wav"}
})
zwf.sounds["zwf_joint_start"] = {
	paths = {"zwf/zwf_joint_start.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_joint_stop"] = {
	paths = {"zwf/zwf_joint_stop.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}


// DoobyTable
zwf.sounds["zwf_grab_weed"] = {
	paths = {"zwf/zwf_grab_weed.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}

zwf.sounds["zwf_grab_paper"] = {
	paths = {"zwf/zwf_grab_paper.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_paper_close"] = {
	paths = {"zwf/zwf_paper_close.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_paper_open"] = {
	paths = {"zwf/zwf_paper_open.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}

zwf.sounds["zwf_grinder_open"] = {
	paths = {"zwf/zwf_grinder_open.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_grinder_close"] = {
	paths = {"zwf/zwf_grinder_close.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_grinder_grind"] = {
	paths = {"zwf/zwf_grinder_grind.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}

zwf.sounds["zwf_joint_foldstage"] = {
	paths = {"zwf/zwf_joint_fold01.wav","zwf/zwf_joint_fold02.wav","zwf/zwf_joint_fold03.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_joint_fold_finish"] = {
	paths = {"zwf/zwf_joint_fold_finish.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}



// Muffin
zwf.sounds["zwf_muffin_eat"] = {
	paths = {"zwf/zwf_muffin_eat.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}



// Cooking
zwf.sounds["zwf_cooking_dough"] = {
	paths = {"zwf/zwf_cooking_dough.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_cooking_flour"] = {
	paths = {"zwf/zwf_cooking_flour.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_mixer_close"] = {
	paths = {"zwf/zwf_mixer_close.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
sound.Add({
	name = "zwf_mixer_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_mixer_loop.wav"}
})
zwf.sounds["zwf_mixer_open"] = {
	paths = {"zwf/zwf_mixer_open.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_mixerbowl_add"] = {
	paths = {"zwf/zwf_mixerbowl_add.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_mixerbowl_remove"] = {
	paths = {"zwf/zwf_mixerbowl_remove.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_oven_close"] = {
	paths = {"zwf/zwf_oven_close.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
zwf.sounds["zwf_oven_open"] = {
	paths = {"zwf/zwf_oven_open.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	pref_volume = 1
}
sound.Add({
	name = "zwf_oven_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"zwf/zwf_oven_loop.wav"}
})
