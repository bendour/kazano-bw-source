-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

// Settings
SH_HADEZ.SETTINGS = {}
SH_HADEZ.SETTINGS.SYSLANG = "FR" -- Server console language

/* Logs & Notifications */
-- 0: No client logs.
-- 1: Send logs to everyone that has permission to that command.
-- 2: Send logs to everyone affected by the command + prev.
-- 3: Send logs to everyone. 
SH_HADEZ.SETTINGS.LOGMODE = 0

-- Entities the barrier can never remove
SH_HADEZ.SETTINGS.WHITELISTEDENTITIES = {

	-- Key elements
	["keyframe_rope"] = true,
	["player"] = true,
	["predicted_viewmodel"] = true,
	["physgun_beam"] = true,
	["gmod_hands"] = true,
	["phys_bone_follower"] = true,
	["manipulate_bone"] = true,
	["info_player_start"] = true,
	["shadow_control"] = true,
	["path_corner"] = true,
	
	-- Player model
	["hl2mp_ragdoll"] = true,
	
	-- Vehicles
	["gmod_sent_vehicle_fphysics_base"] = true,
	["gmod_sent_vehicle_fphysics_wheel"] = true,
	["info_particle_system"] = true,
	["prop_vehicle_prisoner_pod"] = true,
	["phys_spring"] = true,
	["gmod_sent_vehicle_fphysics_attachment"] = true,
	["gmod_sent_vehicle_fphysics_attachment"] = true,
	
	-- Map stuff
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["trigger_multiple"] = true,
	["func_door"] = true,
	["env_fire"] = true,
	["func_breakable_surf"] = true,
	["light_spot"] = true,
	["light"] = true,
	["point_spotlight"] = true,
	["spotlight_end"] = true,
	["beam"] = true,
	["func_button"] = true,
	["entity_blocker"] = true,
	["prop_dynamic_override"] = true,
	["prop_dynamic"] = true,
	["prop_physics"] = true,
	["prop_ragdoll"] = true,
	["trigger_soundscape"] = true,
	["color_correction"] = true,
	["ambient_generic"] = true,
	["env_steam"] = true,
	["env_shake"] = true,
	["env_soundscape"] = true,
	["env_laserdot"] = true
	
}

-- Entities the lava can never burn
SH_HADEZ.SETTINGS.WHITELISTEDBURNENTITIES = SH_HADEZ.SETTINGS.WHITELISTEDENTITIES
SH_HADEZ.SETTINGS.WHITELISTEDBURNENTITIES["prop_physics"] = nil