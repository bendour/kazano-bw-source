/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}

zpn.Sounds = {
	["Explosion"] = Sound("ambient/explosions/explode_4.wav"),
	["Bounce"] = Sound("garrysmod/balloon_pop_cute.wav"),
	["FireExplo"] = Sound("ambient/fire/gascan_ignite1.wav"),
	["projectile_explosion"] = Sound("zpn/sfx/zpn_partypopper_projectile_explosion.wav"),
	["IceExplo"] = Sound("zpn/sfx/zpn_ice_explo.wav")
}

-- Generic
sound.Add({
	name = "zpn_ui_click",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {100, 100},
	sound = {"UI/buttonclick.wav"}
})

for k, v in pairs(zpn.config.Boss.MusicPaths) do
	sound.Add({
		name = "zpn_boss_music" .. k,
		channel = CHAN_STATIC,
		volume = 0.6,
		level = 90,
		pitch = {100, 100},
		sound = {v}
	})
end

sound.Add({
	name = "zpn_projectile_fly",
	channel = CHAN_STATIC,
	volume = 0.15,
	level = 65,
	pitch = {45, 45},
	sound = {"weapons/crossbow/bolt_fly4.wav"}
})

sound.Add({
	name = "zpn_slapper_bounce",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_slapper_bounce.wav"}
})

sound.Add({
	name = "zpn_slapper_open",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_slapper_open.wav"}
})

sound.Add({
	name = "zpn_slapper_trigger",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_slapper_trigger.wav"}
})

sound.Add({
	name = "zpn_boss_death",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_boss_death.wav"}
})

sound.Add({
	name = "zpn_boss_howl_fast",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {90, 100},
	sound = {"zpn/sfx/zpn_boss_howl_fast.wav"}
})

sound.Add({
	name = "zpn_boss_howl_slow",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {90, 100},
	sound = {"zpn/sfx/zpn_boss_howl_slow.wav"}
})

sound.Add({
	name = "zpn_boss_shieldbroken",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {90, 100},
	sound = {"zpn/sfx/zpn_boss_shieldbroken.wav"}
})

sound.Add({
	name = "zpn_boss_spawn",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_boss_spawn.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

sound.Add({
	name = "zpn_boss_smash",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {90, 100},
	sound = {"zpn/sfx/zpn_boss_smash.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

sound.Add({
	name = "zpn_boss_spell",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {90, 100},
	sound = {"zpn/sfx/zpn_boss_spell.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

sound.Add({
	name = "zpn_boss_heal",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 90,
	pitch = {90, 100},
	sound = {"zpn/sfx/zpn_boss_heal01.wav", "zpn/sfx/zpn_boss_heal02.wav", "zpn/sfx/zpn_boss_heal03.wav"}
})

sound.Add({
	name = "zpn_tornado_sfx",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 90,
	pitch = {100, 100},
	sound = {"ambient/wind/wind1.wav"}
})

sound.Add({
	name = "zpn_candy_collect",
	channel = CHAN_STATIC,
	volume = 0.6,
	level = 75,
	pitch = {95, 105},
	sound = {"zpn/sfx/zpn_candy_collect01.wav", "zpn/sfx/zpn_candy_collect02.wav", "zpn/sfx/zpn_candy_collect03.wav"}
})

sound.Add({
	name = "zpn_partypopper",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {95, 105},
	sound = {"zpn/sfx/zpn_partypopper.wav"}
})

sound.Add({
	name = "zpn_partypopper_heavy",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {95, 105},
	sound = {"zpn/sfx/zpn_partypopper_heavy.wav"}
})

sound.Add({
	name = "zpn_pumpkin_smash",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 60,
	pitch = {95, 105},
	sound = {"physics/flesh/flesh_squishy_impact_hard1.wav", "physics/flesh/flesh_squishy_impact_hard2.wav", "physics/flesh/flesh_squishy_impact_hard3.wav", "physics/flesh/flesh_squishy_impact_hard4.wav"}
})

sound.Add({
	name = "zpn_present_smash",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 60,
	pitch = {95, 105},
	sound = {"physics/cardboard/cardboard_box_break1.wav", "physics/cardboard/cardboard_box_break2.wav", "physics/cardboard/cardboard_box_break3.wav"}
})

sound.Add({
	name = "zpn_ghost_hide",
	channel = CHAN_STATIC,
	volume = 1,
	level = 70,
	pitch = {95, 105},
	sound = {"zpn/sfx/zpn_ghost_hide.wav"}
})

sound.Add({
	name = "zpn_ghost_puff",
	channel = CHAN_STATIC,
	volume = 1,
	level = 70,
	pitch = {95, 105},
	sound = {"zpn/sfx/zpn_ghost_puff.wav"}
})

sound.Add({
	name = "zpn_ghost_woow",
	channel = CHAN_STATIC,
	volume = 1,
	level = 70,
	pitch = {95, 105},
	sound = {"zpn/sfx/zpn_ghost_woow.wav"}
})

sound.Add({
	name = "zpn_ghost_warn",
	channel = CHAN_STATIC,
	volume = 0.7,
	level = 60,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_ghost_warn.wav"}
})

sound.Add({
	name = "zpn_bomb_explode",
	channel = CHAN_STATIC,
	volume = 0.6,
	level = 75,
	pitch = {95, 105},
	sound = {"ambient/explosions/explode_4.wav"}
})

sound.Add({
	name = "zpn_candy_bounce",
	channel = CHAN_STATIC,
	volume = 1,
	level = 60,
	pitch = {95, 105},
	sound = {"garrysmod/balloon_pop_cute.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000


sound.Add({
	name = "zpn_mask_on",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_mask_on.wav"}
})

sound.Add({
	name = "zpn_mask_off",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {"zpn/sfx/zpn_mask_off.wav"}
})

sound.Add({
	name = "zpn_loot_collect",
	channel = CHAN_STATIC,
	volume = 0.7,
	level = 50,
	pitch = {99, 101},
	sound = {"zpn/sfx/zpn_loot_collect.wav"}
})
