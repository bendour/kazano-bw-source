/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.config = zpn.config or {}
zpn.config.Loot = {}
local function AddLoot(data) return table.insert(zpn.config.Loot,data) end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

	This special loot can be found in the presents underneath the christmas tree

*/

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

AddLoot({
	type = "type_health",
	dropchance = 25,
	notify = "You got 25 health!",
	amount = 25,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

AddLoot({
    type = "type_armor",
    dropchance = 25,
    notify = "You got 25 armor!",
    amount = 25,
})

AddLoot({
	type = "type_lua",
	dropchance = 5,
	lua = function(ply)
		local money = math.random(1, 10) * 1000
		zclib.Notify(ply, "You found " .. zclib.Money.Display(money, true) .. "!", 0)
		zclib.Money.Give(ply, money)
	end,
})




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////// DO NOT TOUCH ANYTHING BELLOW THIS LINE! THANK YOU (╯°□°）╯︵ ┻━┻ //////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Recalculates the final chance for all the items in the list
local function roundChance(what, precision) return math.floor(what * math.pow(10, precision) + 0.5) / math.pow(10, precision) end

local totalChance = 0
for k, v in pairs(zpn.config.Loot) do totalChance = totalChance + v.dropchance end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

for k, v in pairs(zpn.config.Loot) do
	local chance = roundChance((100 / totalChance) * v.dropchance, 2)
	v.dropchance = chance
end
