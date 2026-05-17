zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.config = zwf.config or {}



zwf.config.Cable = {
    // The maximal distance between entities before the cable breaks.
    distance = 300,

    // How often should we try to Transfer Water/Power to connected entities.
    transfer_interval = 0.1, // seconds
}

zwf.config.WateringCan = {
    // How much water can it hold
    Capacity = 100,

    // How much water gets filled from the waterTank to the WateringCan per click
    Transfer_Amount = 5,
}

zwf.config.WaterTank = {
    // How much water can the tank hold.
    Capacity = 1000,

    // How much money does it cost to refill the waterTank per liter
    RefillCostPerUnit = 2,
}

zwf.config.Generator = {
    // How much fuel does it hold
    Fuel_Capacity = 200,

    // How much fuel does it use every 5 seconds
    Fuel_usage = 1,

    // If the generator is in idle mode because its power wont get used then we stop using fuel aswell
    Fuel_SpareBenefit = false,

    // Here we can tell the generator what entities can be used for fuel and what value inside the entities defines the amount
    Fuel_Ents = {
        ["zwf_fuel"] = function(ent)
            return ent.FuelAmount
        end,
        ["vc_pickup_fuel_diesel"] = function(ent)
            return ent.VC_Storage
        end,
        ["vc_pickup_fuel_petrol"] = function(ent)
            return ent.VC_Storage
        end,
    },


    // The max amount of tries the player could need to start the generator.
    Max_StartTrys = 4,

    // How often does it convert fuel to power in seconds
    Power_intarval = 1,

    // How much power does it produce per interval
    Power_production = 25,

    // How much power can the generator store
    Power_storage = 100,


    // Does the Generator gets broken over time and needs maintance?
    Maintance = true,

    // How many seconds of usage before the Generator needs to be repaired
    Maintance_time = 750,

    // The time before the generator explodes
    Maintance_countdown = 20
}

zwf.config.Outlet = {
    Power_storage = 10,
}

zwf.config.Lamps = {
    [1] = {
        name = "Sodium Lamp",

        model = "models/zerochain/props_weedfarm/zwf_lamp01.mdl",

        // How much energy it can store
        Power_storage = 10,

        // How much energy it uses
        Power_usage = 2,

        // How much heat it inflicts on the plant
        Heat = 3,

        // The color of the light
        light_color = Color(235,205,165,255),
    },
    [2] = {
        name = "LED Lamp",
        model = "models/zerochain/props_weedfarm/zwf_lamp02.mdl",
        Power_storage = 25,
        Power_usage = 4,
        Heat = 0,
        light_color = Color(231,128,218,255),
    },
}

zwf.config.Ventilator = {
    // Amount of power that can be stored
    Power_storage = 10,

    // How much energy it uses
    Power_usage = 2,

    // The Temp decrease
    Cooling = 7,
}



zwf.config.Seeds = {
    // The number of seeds a seedbox can hold.
    Count = 5,

    // How many seedbox entities can the player spawn
    ent_limt = 7,
}

zwf.config.SeedBank = {

    // How many seeds can be stored in the seedbank
    Limit = 25,
}

zwf.config.SeedLab = {

    // How long does it take to make a new seed
    SpliceTime = 100,
}



zwf.config.Flowerpot = {
    // How much water can the flowerpot hold
    Water_Capacity = 100,
}

zwf.config.Growing = {
    // The maximal THC Level a plant can produce
    max_thc = 50, // %

    // The shortest duration a plant can grow (This should not be smaller then the shortest growtime defined in zwf.config.Plants)
    min_duration = 20, // seconds

    // The maximal Weed Amount a plant can produce
    // *Note: This can be reached by increasing the YieldAmount via NutritionBoost, SeedLab Inheritance or if enabled after the Plant has fully grown in PostGrow
    max_amount = 800,


    // How long has the plant to be unhappy before it dies.
    kill_time = 60,

    PostGrow = {
        // Do we want the plants to keep growing after they finished their growcycle
        Enabled = true,

        // The interval at which we increase the weed amount in seconds
        increment_interval = 30,

        // How much weed gets added
        increment_amount = 10 //g
    }
}

zwf.config.Nutrition = {
    [1] = {
        name = "Hyper Viper", // Name of the nutrition mix
        skin = 1, // The skin for the model
        boost = {
            [1] = {
                b_type = 1, // The type of boost , 1 = Speed, 2 = WeedAmount, 3 = Plague Protection
                b_amount = 5 // Boostamount in % [1-100]
            },
        }
    },
    [2] = {
        name = "Haze of Light",
        skin = 0,
        boost = {
            [1] = {
                b_type = 1,
                b_amount = 15
            },
        }
    },


    [3] = {
        name = "Fat Harvest",
        skin = 2,
        boost = {
            [1] = {
                b_type = 2,
                b_amount = 5
            },
        }
    },
    [4] = {
        name = "MEGA Harvest",
        skin = 3,
        boost = {
            [1] = {
                b_type = 2,
                b_amount = 15
            },
        }
    },

    [5] = {
        name = "Rapid Rabbit Mix",
        skin = 4,
        boost = {
            [1] = {
                b_type = 1,
                b_amount = 3
            },
            [2] = {
                b_type = 2,
                b_amount = 3
            },
            [3] = {
                b_type = 3,
                b_amount = 50
            }
        }
    },
    [6] = {
        name = "Get Schwifty Mix",
        skin = 5,
        boost = {
            [1] = {
                b_type = 1,
                b_amount = 8
            },
            [2] = {
                b_type = 2,
                b_amount = 8
            },
            [3] = {
                b_type = 3,
                b_amount = 100 // 100% for this boost type means the plant will never get sick
            }
        }
    },
}

zwf.config.Plague = {
    // Do we want to enable the Plague System which infects plants overtime
    Enabled = true,

    // The interval at which we roll a dice if the plant should get infected
    infect_interval = 75, // in seconds

    // How high is the chance that the plant gets infected
    infect_chance = 30, // %

    // How long after the last infection till the plant can get infected again
    infect_cooldown = 30
}

zwf.config.Plants = {
    [1] = {
        // The name of the plant
        name = "O.G. Kush",

        // The model skin
        skin = 0,

        // The sell value per full weed block
        // *Note: A full weedblock is made out of 4 Full Jars of weed so if the weedblock got made out of 4 half jars of weed then this sell value will be half aswell
        sellvalue = 1535e12,

        // The default THC level in %
        thc_level = 10,

        // The screeneffect that should display when smoking the weed
        high_effect = 1,

        // The music that should play while high (This starts inside the sound folder so you dont need to write "sound" in front of your path)
        high_music = nil, // path/to/the/musicfile.wav // Examble: "music.wav"

        // The theme color for this weed
        color = Color(179,196,121,255),

        cut_effect = "zwf_cutting01",
        pack_effect = "zwf_packing01",
        death_effect = "zwf_death01",

        Grow = {
            // How long it takes to grow
            Duration = 200,

            // If set then the plants grow duration cant go any lower then this value. It pretty much overwrites zwf.config.Growing.min_duration for this specific plant
            //Min_Duration = 20,

            // This value defines the Difficulty for growing the plant, higher values mean its gonna use up faster Water
            Difficulty = 1, // [1 - 10]

            // How much weed can this plant produce if grown perfectly
            MaxYieldAmount = 250,
        },
    },
    [2] = {
        name = "Bubba Kush",
        skin = 2,
        sellvalue = 5000,
        thc_level = 12,
        high_effect = 2,
        high_music = nil,
        color = Color(126,220,208,255),
        cut_effect = "zwf_cutting01",
        pack_effect = "zwf_packing01",
        death_effect = "zwf_death01",
        Grow = {
            Duration = 225,
            Difficulty = 2,
            MaxYieldAmount = 150,
        },
    },
    [3] = {
        name = "Sour Diesel",
        skin = 3,
        sellvalue = 7500,
        thc_level = 14,
        high_effect = 3,
        high_music = nil,
        color = Color(220,216,169,255),
        cut_effect = "zwf_cutting03",
        pack_effect = "zwf_packing03",
        death_effect = "zwf_death03",
        Grow = {
            Duration = 250,
            Difficulty = 5,
            MaxYieldAmount = 125,
        },
    },
    [4] = {
        name = "AK-47",
        skin = 4,
        sellvalue = 160e13,
        thc_level = 16,
        high_effect = 4,
        high_music = nil,
        color = Color(190,214,174,255),
        cut_effect = "zwf_cutting01",
        pack_effect = "zwf_packing01",
        death_effect = "zwf_death01",
        Grow = {
            Duration = 300,
            Difficulty = 6,
            MaxYieldAmount = 125,
        },
    },
    [5] = {
        name = "Super Lemon Haze",
        skin = 5,
        sellvalue = 10000,
        thc_level = 20,
        high_effect = 5,
        high_music = nil,
        color = Color(240,222,118,255),
        cut_effect = "zwf_cutting03",
        pack_effect = "zwf_packing03",
        death_effect = "zwf_death03",
        Grow = {
            Duration = 400,
            Difficulty = 7,
            MaxYieldAmount = 100,
        },
    },
    [6] = {
        name = "Strawberry Cough",
        skin = 6,
        sellvalue = 12000,
        thc_level = 25,
        high_effect = 6,
        high_music = nil,
        color = Color(217,82,54,255),
        cut_effect = "zwf_cutting02",
        pack_effect = "zwf_packing02",
        death_effect = "zwf_death02",
        Grow = {
            Duration = 500,
            Difficulty = 8,
            MaxYieldAmount = 100,
        },
    },
    [7] = {
        name = "Dark Devil",
        skin = 1,
        sellvalue = 13000,
        thc_level = 30,
        high_effect = 7,
        high_music = nil,
        color = Color(233,120,184,255),
        cut_effect = "zwf_cutting02",
        pack_effect = "zwf_packing02",
        death_effect = "zwf_death02",
        Grow = {
            Duration = 600,
            Difficulty = 9,
            MaxYieldAmount = 100,
        },
    },
}
