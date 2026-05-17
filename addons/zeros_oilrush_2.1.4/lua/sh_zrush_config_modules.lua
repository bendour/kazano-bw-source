zrush = zrush or {}
zrush.AbilityModules = {}
local function AddAbilityModule(data) return table.insert(zrush.AbilityModules, data) end

AddAbilityModule({
	name = "Speed Boost",
	type = "speed",
	amount = 0.8,
	desc = "Increases the Speed of the Machine a bit.",
	price = 750000000,
	ranks = {},
	jobs = {},
	color = Color(50, 255, 0)
})

AddAbilityModule({
	name = "Production Boost",
	type = "production",
	amount = 2,
	desc = "Increases the production amount of the machine a bit.",
	price = 750000000,
	ranks = {},
	jobs = {},
	color = Color(50, 255, 0)
})

AddAbilityModule({
	name = "AntiJam Boost",
	type = "antijam",
	amount = .8,
	desc = "Reduces the chance of jamming the machine a bit.",
	price = 750000000,
	ranks = {},
	jobs = {},
	color = Color(50, 255, 0)
})

AddAbilityModule({
	name = "Cooling Boost",
	type = "cooling",
	amount = .8,
	desc = "Reduces the chance of OverHeating the machine a bit.",
	price = 750000000,
	ranks = {},
	jobs = {},
	color = Color(50, 255, 0)
})

AddAbilityModule({
	name = "Extra Pipes",
	type = "pipes",
	amount = 20,
	desc = "Adds some extra space for Pipes in the Queue.",
	price = 750000000,
	ranks = {},
	jobs = {},
	color = Color(50, 255, 0)
})

AddAbilityModule({
	name = "Refining Boost",
	type = "refining",
	amount = .8,
	desc = "Increases the refined Fuel amount a bit.",
	price = 750000000,
	ranks = {},
	jobs = {},
	color = Color(50, 255, 0)
})

--------------------------------

local vips = {
	["VIP"] = true,
	["Premium"] = true,
	["TrialModerator"] = true,
	["Moderator"] = true,
	["SuperModerator"] = true,
	["admin"] = true,
	["superadmin"] = true,
}

AddAbilityModule({
	name = "Xtreme Speed Boost",
	type = "speed",
	amount = .9,
	desc = "Injects High Quallity Oil in the Machine which increases the Speed.",
	price = 1000000000,
	ranks = vips,
	jobs = {},
	color = Color(255, 0, 0)
})

AddAbilityModule({
	name = "Xtreme Production Boost",
	type = "production",
	amount = 2.5,
	desc = "Integrates a Intel CPU in the Machine which improves the Logistic",
	price = 1000000000,
	ranks = vips,
	jobs = {},
	color = Color(255, 0, 0)
})

AddAbilityModule({
	name = "Xtreme AntiJam Boost",
	type = "antijam",
	amount = .9,
	desc = "Reduces the chance of jamming the machine.",
	price = 1000000000,
	ranks = vips,
	jobs = {},
	color = Color(255, 0, 0)
})

AddAbilityModule({
	name = "Xtreme Cooling Boost",
	type = "cooling",
	amount = .9,
	desc = "Reduces the chance of OverHeating the machine.",
	price = 1000000000,
	ranks = vips,
	jobs = {},
	color = Color(255, 0, 0)
})

AddAbilityModule({
	name = "Xtreme Extra Pipes",
	type = "pipes",
	amount = 30,
	desc = "Adds much mor extra space for Pipes in the Queue.",
	price = 1000000000,
	ranks = vips,
	jobs = {},
	color = Color(255, 0, 0)
})

AddAbilityModule({
	name = "Xtreme Refining Boost",
	type = "refining",
	amount = .9,
	desc = "Increases the refined Fuel amount a lot.",
	price = 1000000000,
	ranks = vips,
	jobs = {},
	color = Color(255, 0, 0)
})
////////////////////////////////////////////
////////////////////////////////////////////