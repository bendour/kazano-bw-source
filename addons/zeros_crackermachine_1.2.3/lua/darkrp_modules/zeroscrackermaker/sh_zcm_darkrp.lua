
TEAM_ZCM_FIREWORKMAKER = DarkRP.createJob("Illegal Firework Maker", {
    color = Color(225, 75, 75, 255),
    model = {"models/player/group03/male_04.mdl"},
    description = [[You are making illegal Firework!]],
    weapons = {},
    command = "zcm_illegalfireworkmaker",
    max = 2,
    salary = 0,
    admin = 0,
    vote = false,
    category = "Citizens",
    hasLicense = false
})

DarkRP.createCategory{
    name = "Illegal Firework Maker",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 107, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 104
}

DarkRP.createEntity("Firework Maker", {
    ent = "zcm_crackermachine",
    model = "models/zerochain/props_crackermaker/zcm_base.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzcm_crackermachine",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Illegal Firework Maker"
})

DarkRP.createEntity("BlackPowder", {
    ent = "zcm_blackpowder",
    model = "models/zerochain/props_crackermaker/zcm_blackpowder.mdl",
    price = 1000,
    max = 3,
    cmd = "buyzcm_blackpowder",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Illegal Firework Maker"
})

DarkRP.createEntity("Paper", {
    ent = "zcm_paperroll",
    model = "models/zerochain/props_crackermaker/zcm_paper.mdl",
    price = 1000,
    max = 3,
    cmd = "buyzcm_paperroll",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Illegal Firework Maker"
})

DarkRP.createEntity("Box", {
    ent = "zcm_box",
    model = "models/zerochain/props_crackermaker/zcm_box.mdl",
    price = 100,
    max = 3,
    cmd = "buyzcm_box",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Illegal Firework Maker"
})

DarkRP.createEntity("Pallet", {
    ent = "zcm_palette",
    model = "models/props_junk/wood_pallet001a.mdl",
    price = 100,
    max = 2,
    cmd = "buyzcm_palette",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Illegal Firework Maker"
})
