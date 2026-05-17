zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.config = zwf.config or {}

zwf.config.Harvest = {
    // Defines how often the player has to press E on the plant in order to harvest it
    // This value scales according to plant weed amount
    Count = 100, // 1 Cut per 100g of weed

    // The min amount of times the player needs to press E on the plant
    Min = 3,

    // The max amount
    Max = 25,
}

zwf.config.DryStation = {
    // How many % of weight are getting lost when drying
    Loss = 15,

    // How long does it take to dry weed
    Duration = 60,

    // How long does it take to harvest the weedstick from the DryStation
    Harvest_Time = 1,
}

zwf.config.Jar = {
    Capacity = 200, // How much weed can a jar hold
}

zwf.config.PackingStation = {
    // How many times needs the player interact with the packing station before the weedblock is done
    // Needs to be bigger then 7
    PackingCount = 12,
}

zwf.config.Palette = {
    // How many weedblocks can fit on one palette
    limit = 63,
}

zwf.config.DoobyTable = {
    // How much weed can be stored on the table
    Capacity = 30,

    // How much weed gets used per joint
    WeedPerJoint = 10,
}

zwf.config.Cooking = {
    // How much weed can a muffin hold?
    // *Note: This will define the max duration of the high effect after the player its the muffin.
    // Formel: (Muffin.WeedAmount / zwf.config.Bongs.Use_Amount) * zwf.config.HighEffect.DefaultEffect_Duration = Effect Duration
    weed_capacity = 30, // This weed amount will produce a high effect which has a length of 60 seconds

    // How long does the dough need to be mixed
    mix_duration = 30,

    // How long does the dough need to be baked
    bake_duration = 30,

    // Should we give the player energy instead of health?
    UseHungermod = false,

    edibles = {
        [1] = {
            name = "Muffin",

            // How much health does the player gets when eaten
            health = 5,

            // How much health can he gets at max when eating this?
            healthcap = 100,

            // The bodygroup used in the oven (Dont change it)
            oven_bg = 1,

            // The Model for the ingredient which needs to be added to the mixer
            backmix_model = "models/zerochain/props_weedfarm/zwf_backmix_muffin.mdl",

            // Model of the edible
            edible_model = "models/zerochain/props_weedfarm/zwf_muffin.mdl",
        },
        [2] = {
            name = "Brownie",
            health = 10,
            healthcap = 100,
            oven_bg = 2,
            backmix_model = "models/zerochain/props_weedfarm/zwf_backmix_brownie.mdl",
            edible_model = "models/zerochain/props_weedfarm/zwf_brownie.mdl",
        },
    }
}
