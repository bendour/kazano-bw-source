/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.config = zpn.config or {}
zpn.config.Themes = {}

// Styles defines how the Objects, Enemies and Effects should look
/*
    1 = Halloween
    2 = Christmas
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

local function CreateTheme(data)
    return table.insert(zpn.config.Themes,data)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

// Halloween
CreateTheme({
    Design = {
        color01 = Color(235, 120, 11),
        color02 = Color(138, 17, 8),
        color03 = Color(255, 135, 0),
        icon_health = Material("materials/zerochain/zpn/ui/halloween/zpn_health_icon.png", "smooth"),
        icon_armor = Material("materials/zerochain/zpn/ui/halloween/zpn_armor_icon.png", "smooth"),
        color_health = Color(148, 50, 63, 255),
        color_shield = Color(48, 51, 71),
        icon_health_bar_bg = Material("materials/zerochain/zpn/ui/halloween/zpn_healthbar_bg.png", "smooth"),
        icon_health_bar_alpha = Material("materials/zerochain/zpn/ui/halloween/zpn_healthbar_alpha.png", "smooth"),
    },
    Destructibles = {
        models = {
            "models/zerochain/props_pumpkinnight/zpn_pumpkin01.mdl",
            "models/zerochain/props_pumpkinnight/zpn_pumpkin02.mdl",
            "models/zerochain/props_pumpkinnight/zpn_pumpkin03.mdl",
            "models/zerochain/props_pumpkinnight/zpn_pumpkin04.mdl"
        },
        smash_effect = "zpn_pumpkinsmash",
        smash_sound = "zpn_pumpkin_smash",
        getcolor = function()
            return HSVToColor(math.random(28,42),0.7,1)
        end,
    },
    Candytypes = {
        ["models/zerochain/props_pumpkinnight/zpn_candy_corn.mdl"] = 3,
        ["models/zerochain/props_pumpkinnight/zpn_candy_lolipop.mdl"] = 10,
        ["models/zerochain/props_pumpkinnight/zpn_candy_puff.mdl"] = 5,
        ["models/zerochain/props_pumpkinnight/zpn_candy_pumpkin.mdl"] = 7,
        ["models/zerochain/props_pumpkinnight/zpn_candy_bonbon.mdl"] = 5,
        ["models/zerochain/props_pumpkinnight/zpn_candy_skull.mdl"] = 7,
        ["models/zerochain/props_pumpkinnight/zpn_candy_smartie.mdl"] = 2,
        ["models/zerochain/props_pumpkinnight/zpn_candy_snake.mdl"] = 4,
        ["models/zerochain/props_pumpkinnight/zpn_candy_coco.mdl"] = 6,
        ["models/zerochain/props_pumpkinnight/zpn_candy_spiral02.mdl"] = 7,
        ["models/zerochain/props_pumpkinnight/zpn_candy_string.mdl"] = 4,
        ["models/zerochain/props_pumpkinnight/zpn_candy_fruit.mdl"] = 6
    },
    Bomb = {
        model = "models/zerochain/props_pumpkinnight/zpn_pumpkinbomb.mdl",
    },
    Projectile = {
        model = "models/zerochain/props_pumpkinnight/zpn_pumpkinbomb.mdl",
        fly_effect = "zpn_fireball",
        explo_effect = "zpn_fireexplosion",
        explo_sound = "FireExplo", // A sound which gets created at zpn.Sounds
        damagetype = DMG_BURN,
    },
    FireArea = {
        effect = "zpn_firearea",
        damagetype = DMG_BURN,
    },
    PartyPopper_Projectile = {
        effect_main = "zpn_ppp_head",
        effect_explo = "zpn_ppp",
        effect_burst = "zpn_ppp_burst",
    },
    Ghost = {
        model = "models/zerochain/props_pumpkinnight/zpn_ghost.mdl",
        anim = {
            ["idle"] = "idle",
            ["steal"] = "steal",
            ["death"] = "death",
            ["hit"] = "hit",
            ["spawn"] = "spawn",
            ["hide"] = "hide",
            ["paralize_loop"] = "paralize_loop",
			["chase"] = "chase_loop"
        },
        effects = {
            ["ghostbuff"] = "zpn_cloud01"
        }
    },
    Minions = {
        models = {
            "models/zerochain/props_pumpkinnight/zpn_minion_pumpkin01.mdl",
            "models/zerochain/props_pumpkinnight/zpn_minion_pumpkin02.mdl",
            "models/zerochain/props_pumpkinnight/zpn_minion_pumpkin03.mdl",
            "models/zerochain/props_pumpkinnight/zpn_minion_pumpkin04.mdl"
        },
        effects = {
            ["zpn_minion"] = "zpn_minion",
            ["zpn_minion_eye"] = "zpn_minion_eye"
        },
        getcolor = function()
            return HSVToColor(math.random(28,42),0.7,1)
        end,
    },
    Boss = {
        model_ground = "models/zerochain/props_pumpkinnight/zpn_pumpkinboss_ground.mdl",
        model_main = "models/zerochain/props_pumpkinnight/zpn_pumpkinboss.mdl",
        anim = {
            ["action_spawn"] = "action_spawn",
            ["action_despawned"] = "action_despawned",
            ["action_search"] = "action_search",
            ["action_idle"] = "action_idle",
            ["action_death"] = "action_death",
            ["attack_spell"] = "attack_spell",
            ["attack_smash"] = "attack_smash",
            ["attack_circlesmash"] = "attack_circlesmash",
            ["action_heal_start"] = "action_heal_start",
            ["action_heal_loop"] = "action_heal_loop",
            ["action_heal_end"] = "action_heal_end",
        },
        spotlight_color = Color(255, 75, 0, 255),
        tornado_effect = "zpn_leafstorm",
        HUD = {
            materials = {
                ["zpn_boss_head"] = Material("materials/zerochain/zpn/ui/halloween/zpn_pumpkin_head.png", "smooth"),
                ["bar_mask"] = "materials/zerochain/zpn/ui/halloween/zpn_healthbar_mask.png",
                ["bar_bg"] = Material("materials/zerochain/zpn/ui/halloween/zpn_healthbar_bg.png", "smooth"),
                ["bar_alpha"] = Material("materials/zerochain/zpn/ui/halloween/zpn_healthbar_alpha.png", "smooth")
            },
            HeadOffset = {
                x = 550,
                y = 45,
                w = 100,
                h = 100
            },
            PostDraw = function()
            end,
        },
    },
    NPC = {
        name = "Señor Calabaza",
        model = "models/zerochain/props_pumpkinnight/zpn_shopnpc.mdl",
    },
    Scoreboard = {
        title = zpn.language.General["PumpkinSmashers"],
        hud_pos = Vector(5, 0, 50),
        model = "models/zerochain/props_pumpkinnight/zpn_scoreboard.mdl",
        materials = {
            ["icon"] = Material("materials/zerochain/zpn/ui/halloween/zpn_scoreboard_pumpkin.png", "smooth"),
            ["item"] = Material("materials/zerochain/zpn/ui/halloween/zpn_scoreboard_item.png", "smooth"),
            ["first"] = Material("materials/zerochain/zpn/ui/halloween/zpn_scoreboard_first.png", "smooth"),
        },
        onthink = function(ent)
            if zclib.util.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 500) then
        		if ent.HasEffect == false then
        			zclib.Effect.ParticleEffectAttach("zpn_candle", PATTACH_POINT_FOLLOW, ent, 1)
        			zclib.Effect.ParticleEffectAttach("zpn_candle", PATTACH_POINT_FOLLOW, ent, 2)
        			ent.HasEffect = true
        		end
        	else
        		if ent.HasEffect == true then
        			ent.HasEffect = false
        			ent:StopParticles()
        		end
        	end
        end,
    },
    Shop = {
        itm_mdl_bg_color = Color(27,27,35,255),
        itm_bg_color = Color(39,32,65),
        itm_cmd_bg = Color(255, 255, 255, 5),
        materials = {
            ["close"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_close.png", "smooth"),
            ["close_hover"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_close_hover.png", "smooth"),
            ["pay"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_pay.png", "smooth"),
            ["pay_hover"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_pay_hover.png", "smooth"),
            ["bg"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_bg.png", "smooth"),
            ["item"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_item.png", "smooth"),
            ["vip"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_vip_star.png", "smooth"),
            ["candy"] = Material("materials/zerochain/zpn/ui/halloween/zpn_shopinterface_candy.png", "smooth"),
        }
    },
	LootSpawner = {
		model = "models/zerochain/props_pumpkinnight/zpn_scarecrow.mdl"
	}
})

// Christmas
CreateTheme({
    Design = {
        color01 = Color(11, 143, 235),
        color02 = Color(8, 84, 138),
        color03 = Color(232, 56, 98),
        icon_health = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_health.png", "smooth"),
        icon_armor = Material("materials/zerochain/zpn/ui/christmas/zcb_shield.png", "smooth"),
        color_health = Color(232, 56, 98, 255),
        color_shield = Color(51, 80, 101),
        icon_health_bar_bg = Material("materials/zerochain/zpn/ui/christmas/zcb_healtbar_bg.png", "smooth"),
        icon_health_bar_alpha = Material("materials/zerochain/zpn/ui/christmas/zcb_healtbar_alpha.png", "smooth"),
    },
    Destructibles = {
        models = {
            "models/zerochain/props_christmas/zpn_present01.mdl",
            "models/zerochain/props_christmas/zpn_present02.mdl",
            "models/zerochain/props_christmas/zpn_present03.mdl",
        },
        smash_effect = "zpn_presentsmash",
        smash_sound = "zpn_present_smash",
        getcolor = function()
            local colors = {128,216,0,346}
            local hue = colors[math.random(#colors)]
            return HSVToColor(hue,0.6,0.75)
        end,
    },
    Candytypes = {
        ["models/zerochain/props_christmas/zpn_candy_cane01.mdl"] = 3,
        ["models/zerochain/props_christmas/zpn_candy_cane02.mdl"] = 3,
        ["models/zerochain/props_christmas/zpn_candy_cookie01.mdl"] = 5,
        ["models/zerochain/props_christmas/zpn_candy_cookie02.mdl"] = 5,
        ["models/zerochain/props_christmas/zpn_candy_cookie03.mdl"] = 6,
        ["models/zerochain/props_christmas/zpn_candy_cookie04.mdl"] = 4,
        ["models/zerochain/props_christmas/zpn_candy_cookie05.mdl"] = 4,
        ["models/zerochain/props_christmas/zpn_candy_cookie06.mdl"] = 3,
        ["models/zerochain/props_pumpkinnight/zpn_candy_lolipop.mdl"] = 10,
        ["models/zerochain/props_pumpkinnight/zpn_candy_bonbon.mdl"] = 5,
        ["models/zerochain/props_pumpkinnight/zpn_candy_smartie.mdl"] = 2,
        ["models/zerochain/props_pumpkinnight/zpn_candy_spiral02.mdl"] = 7,
        ["models/zerochain/props_pumpkinnight/zpn_candy_string.mdl"] = 4,
        ["models/zerochain/props_pumpkinnight/zpn_candy_fruit.mdl"] = 6
    },
    Bomb = {
        model = "models/zerochain/props_christmas/zpn_presentbomb.mdl",
    },
    Projectile = {
        model = "models/zerochain/props_christmas/zpn_icicle.mdl",
        fly_effect = "zpn_iceball",
        explo_effect = "zpn_iceexplosion",
        explo_sound = "IceExplo",
        damagetype = DMG_SONIC,
    },
    PartyPopper_Projectile = {
        effect_main = "zpn_ipp_head",
        effect_explo = "zpn_ipp",
        effect_burst = "zpn_ipp_burst",
    },
    FireArea = {
        effect = "zpn_icearea",
        damagetype = DMG_SONIC,
    },
    Ghost = {
        model = "models/zerochain/props_christmas/zpn_santaghost.mdl",
        anim = {
            ["idle"] = "idle",
            ["steal"] = "steal",
            ["death"] = "death",
            ["hit"] = "hit",
            ["spawn"] = "spawn",
            ["hide"] = "hide",
            ["paralize_loop"] = "paralize_loop",
			["chase"] = "chase_loop"
        },
        effects = {
            ["ghostbuff"] = "zpn_cloud01"
        }
    },
    Minions = {
        models = {
            "models/zerochain/props_christmas/zpn_minion_snow01.mdl",
        },
        effects = {
            ["zpn_minion"] = "zpn_snowminion",
            ["zpn_minion_eye"] = "zpn_snowminion_eye"
        },
        getcolor = function()
            return nil
        end,
    },
    Boss = {
        model_ground = "models/zerochain/props_christmas/zpn_snowboss_ground.mdl",
        model_main = "models/zerochain/props_christmas/zpn_snowboss.mdl",
        anim = {
            ["action_spawn"] = "action_spawn",
            ["action_despawned"] = "action_despawned",
            ["action_search"] = "action_search",
            ["action_idle"] = "action_idle",
            ["action_death"] = "action_death",
            ["attack_spell"] = "attack_spell",
            ["attack_smash"] = "attack_smash",
            ["attack_circlesmash"] = "attack_circlesmash",
            ["action_heal_start"] = "action_heal_start",
            ["action_heal_loop"] = "action_heal_loop",
            ["action_heal_end"] = "action_heal_end",
        },
        spotlight_color = Color(0, 75, 255, 255),
        tornado_effect = "zpn_icestorm",
        HUD = {
            materials = {
                ["zpn_boss_head"] = Material("materials/zerochain/zpn/ui/christmas/zcb_snowman_head.png", "smooth"),
                ["bar_mask"] = "materials/zerochain/zpn/ui/christmas/zpn_healthbar_mask.png",
                ["bar_bg"] = Material("materials/zerochain/zpn/ui/christmas/zpn_healthbar_bg.png", "smooth"),
                ["bar_alpha"] = Material("materials/zerochain/zpn/ui/christmas/zpn_healthbar_alpha.png", "smooth"),
                ["icicle"] = Material("materials/zerochain/zpn/ui/christmas/zcb_icicle.png", "smooth"),
            },
            HeadOffset = {
                x = 520,
                y = 0,
                w = 130,
                h = 130
            },
            PostDraw = function()
                surface.SetDrawColor(color_white)
                surface.SetMaterial(zpn.Theme.Boss.HUD.materials["icicle"])
                surface.DrawTexturedRect(550 * zclib.wM, 58 * zclib.hM, zclib.wM * 195, zclib.hM * 114)
            end,

        },
    },
    NPC = {
        name = "Mr. Frosty",
        model = "models/zerochain/props_christmas/zpn_shopnpc_snow.mdl",
    },
    Scoreboard = {
        title = "Present Crashers",
        hud_pos = Vector(5, 0, 47),
        model = "models/zerochain/props_christmas/zpn_scoreboard_ice.mdl",
        materials = {
            ["icon"] = Material("materials/zerochain/zpn/ui/christmas/zcb_scoreboard_present.png", "smooth"),
            ["item"] = Material("materials/zerochain/zpn/ui/christmas/zcb_scoreboard.png", "smooth"),
            ["first"] = Material("materials/zerochain/zpn/ui/christmas/zcb_scoreboard_first.png", "smooth"),
        },
        onthink = function(ent)
        end,
    },
    Shop = {
        itm_mdl_bg_color = Color(32,50,63),
        itm_bg_color = Color(51,80,101),
        itm_cmd_bg = Color(0, 0, 0, 125),
        materials = {
            ["close"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_close.png", ""),
            ["close_hover"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_close_hover.png","" ),
            ["pay"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_pay.png", "smooth"),
            ["pay_hover"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_pay_hover.png", "smooth"),
            ["bg"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_bg.png", ""),
            ["item"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_item.png", "smooth"),
            ["vip"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_vip.png", "smooth"),
            ["candy"] = Material("materials/zerochain/zpn/ui/christmas/zcb_shopinterface_candy.png", ""),
        }
    },
	LootSpawner = {
		model = "models/zerochain/props_christmas/zpn_tree.mdl"
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

// Active Theme
zpn.Theme = zpn.config.Themes[zpn.config.Theme]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3
