/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.config = zpn.config or {}
zpn.config.Masks = {}
local function AddItem(data) return table.insert(zpn.config.Masks,data) end

AddItem({
    name = "Mask of Gael",

    desc = "Increases the amount of candy collected by 300%",
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

	// The model of the mask
	mdl = "models/zerochain/props_pumpkinnight/zpn_mask01.mdl",

	// How much more candy will the player collect while wearing this mask
	// 1 = 100% (NoChange)
	// 2 = 200% (Double)
	candy_mul = 3,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

	// How often can the mask protect the player against the ghost before it breaks?
	ghost_protect = 1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

	// How much more damage will the wearer inflict on his enemies (Pumpkins,Ghosts,Boss,Minions)
	// 1 = 100% (NoChange)
	// 2 = 200% (Double)
	//attack_mul = 1,

	// How much damage will be reflected back when the wearer is attacked by enemies (Ghosts,Boss,Minions)
	// NOTE Only applys to the the script enemies
	// 1 = 100% (No Damage to the wearer and 100% of the damage goes back to the inflictor)
	// 0.5 = 50% (Half)
	// reflect_mul = 0.5,

	// If set then monsters will ignore the wearer of the mask but he also cant inflict damage to them anymore
	// monster_friend = true,

	// How many candy points does the mask costs in the shop?
	price = 300,
})

AddItem({
    name = "Mask of Shay",
    desc = "The wearer cant hurt monsters but neither will they.",
	mdl = "models/zerochain/props_pumpkinnight/zpn_mask02.mdl",
	candy_mul = 1.25,
	monster_friend = true,
	price = 300,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

AddItem({
    name = "Mask of Ulik",
    desc = "Reflects 50% of the damage back to the monster.",
	mdl = "models/zerochain/props_pumpkinnight/zpn_mask03.mdl",
	candy_mul = 1.25,
	ghost_protect = 1,
	reflect_mul = 0.5,
	price = 300,
})

AddItem({
    name = "Mask of Ceallach",
    desc = "Increases damage inflicted to monsters by 200%",
	mdl = "models/zerochain/props_pumpkinnight/zpn_mask04.mdl",
	candy_mul = 1.25,
	ghost_protect = 1,
	attack_mul = 2,
	price = 300,
})
