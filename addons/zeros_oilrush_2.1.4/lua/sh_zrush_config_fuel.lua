zrush = zrush or {}
zrush.FuelTypes = {}
local function AddFuel(data) return table.insert(zrush.FuelTypes, data) end

AddFuel({
	name = "Regular Petrol",
	color = Color(75, 225, 75),
	refineoutput = .95,
	price = 274e8,
	ranks = {},
})

AddFuel({
	name = "Premium Petrol",
	color = Color(225, 75, 75),
	refineoutput = .95,
	price = 300e8,
	ranks = {
		["VIP"] = true,
		["Premium"] = true,
		["TrialModerator"] = true,
		["Moderator"] = true,
		["SuperModerator"] = true,
		["Administrator"] = true,
		["admin"] = true,
		["superadmin"] = true,
	}
})