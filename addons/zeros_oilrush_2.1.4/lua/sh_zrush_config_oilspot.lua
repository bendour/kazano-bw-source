zrush = zrush or {}
zrush.Holes = {}
local function AddOilSource(data) return table.insert(zrush.Holes, data) end

AddOilSource({
    chance = 50,
    depth = 20,
    burnchance = 50,
    oil_amount = math.Round(math.random(700, 1000)),
    gas_amount = math.Round(math.random(500, 1500)),
    chaos_chance = 5
})

AddOilSource({
    chance = 30,
    depth = 30,
    burnchance = 50,
    oil_amount = math.Round(math.random(600, 2000)),
    gas_amount = math.Round(math.random(500, 1500)),
    chaos_chance = 10
})

AddOilSource({
    chance = 20,
    depth = 40,
    burnchance = 75,
    oil_amount = math.Round(math.random(1500, 4000)),
    gas_amount = math.Round(math.random(2000, 5000)),
    chaos_chance = 20
})

AddOilSource({
    chance = 5,
    depth = 60,
    burnchance = 90,
    oil_amount = math.Round(math.random(5000, 10000)),
    gas_amount = math.Round(math.random(5000, 8000)),
    chaos_chance = 35
})