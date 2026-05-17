/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.config = zpn.config or {}
zpn.config.Shop = {}
local function AddItem(data) return table.insert(zpn.config.Shop,data) end

/*
    "type_entity" 					= Entity Class
    "type_weapon" 					= Weapon Class
    "type_health" 					= Health
    "type_armor" 					= Armor
    "type_sh_acc" 					= Accessory HatID
    "type_pointshop01" 				= Pointshop01 Points
    "type_pointshop02_standard" 	= Pointshop02 StandardPoints
    "type_pointshop02_premium" 		= Pointshop02 PremiumPoints
    "type_bu3" 						= Blues Unboxing 3
    "type_underdone" 				= Underdone
    "type_easyskins" 				= EasySkins https://www.gmodstore.com/market/view/easy-skins
    "type_mtokens" 					= MTokens https://www.gmodstore.com/market/view/6712
    "type_ass" 						= ASS https://www.gmodstore.com/market/view/advanced-accessory-the-most-advanced-accessory-system
    "type_santosrp_giveitem" 		= SantosRP - GiveItem (.class,.amount)
    "type_wos_item" 				= WOS - Item
    "type_wos_points" 				= WOS - Points
    "type_wos_xp" 					= WOS - XP
    "type_wos_level" 				= WOS - Level
    "type_vrondakis_xp" 			= Vrondakis - XP
    "type_vrondakis_level" 			= Vrondakis - Level
    "type_glorified_xp" 			= Glorified - XP
    "type_glorified_level" 			= Glorified - Level
    "type_essentials_xp" 			= Essentials - XP
    "type_essentials_level" 		= Essentials - Level
    "type_elite_xp" 				= Elite - XP
    "type_sreward_token" 			= sReward - Tokens
	"type_zpc2_coin" 				= ZerosPyrocrafter 2 - PyroCoins
	"type_lua" 						= LUA
	"type_voidcase_item" 		= Voidcases https://www.gmodstore.com/market/view/voidcases-unboxing-system
*/

AddItem({
    type = "type_entity",
    class = "zpn_beartrap",
    name = "Piège à Ours",
    desc = "Piégez la tête de vos amis!",
    model = "models/zerochain/props_saw/modern_beartrap.mdl",
    model_fov = 15,
    model_skin = 1,
    price = 150,
    permanent = false,
})

AddItem({
    type = "type_weapon",
    class = "zpn_partypopper",
    name = "Pumpkin Popper",
    desc = "Parfait pour célébrer Noël!",
    model = "models/zerochain/props_pumpkinnight/zpn_partypopper.mdl",
    model_skin = 0,
    model_fov = 13,
    icon = nil,
    price = 50,
    amount = 1,
    ranks = {},
    permanent = true,
})

AddItem({
    type = "type_weapon",
    class = "zpn_partypopper01",
    name = "Pumpkin Slayer",
    desc = "Une arme puissante contre les citrouilles!",
    model = "models/zerochain/props_pumpkinnight/zpn_partypopper.mdl",
    model_skin = 1,
    model_fov = 13,
    price = 200,
    amount = 1,
    ranks = {},
    permanent = true,
})

AddItem({
    type = "type_entity",
    class = "zpn_slapper_default",
    name = "Slapper - Rebond",
    desc = "Fait rebondir la victime!",
    model = "models/zerochain/props_pumpkinnight/zpn_slapper.mdl",
    model_fov = 15,
    model_skin = 0,
    price = 25,
    permanent = false,
})

AddItem({
    type = "type_entity",
    class = "zpn_slapper_fire",
    name = "Slapper - Feu",
    desc = "Enflamme la victime!",
    model = "models/zerochain/props_pumpkinnight/zpn_slapper.mdl",
    model_fov = 15,
    model_skin = 2,
    price = 100,
    permanent = false,
})

AddItem({
    type = "type_entity",
    class = "zpn_slapper_candy",
    name = "Slapper - Bonbons",
    desc = "Fait tomber les bonbons de la victime!",
    model = "models/zerochain/props_pumpkinnight/zpn_slapper.mdl",
    model_fov = 15,
    model_skin = 1,
    price = 150,
    permanent = false,
})

-- ================================
-- BaseWars Credits
-- ================================
AddItem({
    type = "type_lua",
    name = "50 Credits",
    desc = "Obtenez 50 credits BaseWars!",
    icon = Material("materials/zerochain/zpn/ui/zpn_p01_icon.png", "smooth"),
    price = 200,
    lua = function(ply)
        ply:AddCredit(50)
        zclib.Notify(ply, "Vous avez reçu 50 Credits!", 0)
    end,
})

AddItem({
    type = "type_lua",
    name = "200 Credits",
    desc = "Obtenez 200 credits BaseWars!",
    icon = Material("materials/zerochain/zpn/ui/zpn_p01_icon.png", "smooth"),
    price = 750,
    lua = function(ply)
        ply:AddCredit(200)
        zclib.Notify(ply, "Vous avez reçu 200 Credits!", 0)
    end,
})

-- ================================
-- BaseWars Pointshop
-- ================================
AddItem({
    type = "type_lua",
    name = "25,000 Pointshop",
    desc = "Obtenez 25,000 points Pointshop!",
    icon = Material("materials/zerochain/zpn/ui/zpn_p02_icon.png", "smooth"),
    price = 150,
    lua = function(ply)
        ply:AddPointshop(25000)
        zclib.Notify(ply, "Vous avez reçu 25,000 Pointshop!", 0)
    end,
})

AddItem({
    type = "type_lua",
    name = "100,000 Pointshop",
    desc = "Obtenez 100,000 points Pointshop!",
    icon = Material("materials/zerochain/zpn/ui/zpn_p02_icon.png", "smooth"),
    price = 500,
    lua = function(ply)
        ply:AddPointshop(100000)
        zclib.Notify(ply, "Vous avez reçu 100,000 Pointshop!", 0)
    end,
})

-- ================================
-- VoidCases Mystery Boxes
-- ================================
AddItem({
    type = "type_voidcase_item",
    name = "Mystery Box x1",
    desc = "Une Mystery Box VoidCases!",
    price = 500,
    item_id = 181,
    amount = 1,
})

AddItem({
    type = "type_voidcase_item",
    name = "Mystery Box x3",
    desc = "Trois Mystery Box VoidCases!",
    price = 1400,
    item_id = 181,
    amount = 3,
})

for k,v in pairs(zpn.config.Masks) do
	AddItem({
		type = "type_lua",
		name = v.name,
		desc = v.desc,
		model = v.mdl,
		model_angle = Angle(0,0,0),
		model_fov = 18,
		price = v.price,
		lua = function(ply)
			zpn.Mask.Equipt(ply,k, true)
		end,
		// permanent = true,
	})
end


/*
    //////////////////////
    //Shop Item Exambles//
    //////////////////////

    ASS https://www.gmodstore.com/market/view/advanced-accessory-the-most-advanced-accessory-system
    AddItem({
        type = "type_ass",
        class = 1, // UniqueID
        name = "Pumpkin Hat",
        desc = "A nice hat!",
        model = "models/props/pumpkin_z.mdl",
        price = 25,
        amount = 1,
        model_skin = 1,
        model_fov = 13,
        permanent = true,
    })


    SH Accessory HatID https://www.gmodstore.com/market/view/3781
    AddItem({
        type = "type_sh_acc",
        class = "pumpkinhat",
        name = "Pumpkin Hat",
        desc = "A nice hat!",
        model = "models/props/pumpkin_z.mdl",
        price = 25,
        amount = 1,
        model_skin = 1,
        model_fov = 13,
        permanent = true,
    })


    Pointshop01 Points https://github.com/adamdburton/pointshop
    AddItem({
        type = "type_pointshop01",
        name = "PS1 Points",
        desc = "Some Pointshop points!",
        icon = Material("materials/zerochain/zpn/ui/zpn_p01_icon.png", "smooth"),
        price = 10,
        amount = 5,
    })


    Pointshop02 StandardPoints https://github.com/Kamshak/Pointshop2
    AddItem({
        type = "type_pointshop02_standard",
        name = "PS2 StandardPoints",
        desc = "Some Pointshop2 points!",
        icon = Material("materials/zerochain/zpn/ui/zpn_p02_icon.png", "smooth"),
        price = 10,
        amount = 5,
    })

    Pointshop02 PremiumPoints https://github.com/Kamshak/Pointshop2
    AddItem({
        type = "type_pointshop02_premium",
        name = "PS2 PremiumPoints",
        desc = "Some Pointshop2 PremiumPoints!",
        icon = Material("materials/zerochain/zpn/ui/zpn_p02+_icon.png", "smooth"),
        price = 50,
        amount = 5,
    })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    BluesUnboxing3 https://www.gmodstore.com/market/view/5306
    AddItem({
        type = "type_bu3",
        class = "weaponid",
        name = "Butterflyknife",
        desc = "Cool Knife!",
        model = "models/props/butterflyknife.mdl",
        price = 150,
        amount = 1,
        model_skin = 1,
        model_fov = 13,
        permanent = true,
    })

    EasySkins https://www.gmodstore.com/market/view/easy-skins
    AddItem({
        type = "type_easyskins",
        skin_name = "Graffiti",
        name = "Graffiti",
        price = 25,
        amount = 1,
        ranks = {
            ["superadmin"] = true,
            ["VIP"] = true,
        },
    })


    mTokens https://www.gmodstore.com/market/view/6712
    AddItem({
        type = "type_mtokens",
        name = "mTokens",
        desc = "Some mTokens!",
        icon = Material("materials/zerochain/zpn/ui/zpn_p01_icon.png", "smooth"),
        price = 25,
        amount = 1,
    })

	ZerosPyrocrafter 2 - PyroCoins https://www.gmodstore.com/market/view/zero-s-pyrocrafter-2-firework-script
    AddItem({
        type = "type_zpc2_coin",
        name = "PyroCoins",
        desc = "Those coins can be used to unbox new effects!",
        icon = Material("materials/zerochain/zpc2/ui/zpc2_pyrocoin.png", "smooth"),
        price = 10,
        amount = 1,
    })

	Lua Examble
	AddItem({
		type = "type_lua",
		name = "Fire",
		desc = "Its just fire.",
		icon = Material("materials/zerochain/zerolib/ui/icon_hot.png", "smooth"),
		price = 1,
		lua = function(ply)
			ply:Ignite(3,1)
		end,
	})

	// Voidcase Examble
	// NOTE You dont need to specify the name, desc or icon / model, its gonna get that data from the Voidcase item config
	AddItem({
		type = "type_voidcase_item",
		price = 1,
		item_id = 1,
		amount = 3,
	})

    //////////////////////
    //////////////////////
*/
