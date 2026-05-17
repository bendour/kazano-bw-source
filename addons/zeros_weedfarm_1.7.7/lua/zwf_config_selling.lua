zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.config = zwf.config or {}

zwf.config.NPC = {
    // The model of the npc
    Model = "models/zerochain/props_weedfarm/zwf_npc.mdl",

    // Setting this to false will improve network performance but disables the npc reactions for the player
    Capabilities = true,


    // How will the player sell the Weed?
    SellMode = 2,
    // 1 = The Player needs to put the Weedblocks on the Palette Entity and sell it at the NPC
    // 2 = The Player can absorb the WeedBlocks and sell them at the NPC

    // Do we want to use the dynamic buy rate which changes the Price for weed over time for the NPC
    DynamicBuyRate = true,

    // The maximal buy rate in % (Set to 100 for now no price change)
    MaxBuyRate = 125,

    // The minimal buy rate in % (Set to 100 for now no price change)
    MinBuyRate = 80,

    // The interval at which the sell price changes in second ( Set to -1 to disable the refresh timer)
    RefreshRate = 600,

    // These Jobs can buy Bongs. (Leave empty to allowe everyone to buy bongs)
    Customers = {
        //[TEAM_CITIZEN] = true
    },
}

zwf.config.Bongs = {

    // How much weed gets used per bong hit
    Use_Amount = 1,

    items = {
        [1] = {
            w_class = "zwf_bong01",
            e_class = "zwf_bong01_ent",
            name = "Cherry Bowl",
            desc = "A little sweet bong.",
            hold_amount = 10,
            price = 500000000000000,
            model = "models/zerochain/props_weedfarm/zwf_bong01.mdl",
            ranks = {},
        },
        [2] = {
            w_class = "zwf_bong02",
            e_class = "zwf_bong02_ent",
            name = "Reggae Dream",
            desc = "A big reggae colored bong.",
            hold_amount = 15,
            price = 500000000000000,
            model = "models/zerochain/props_weedfarm/zwf_bong02.mdl",
            ranks = {},
        },
        [3] = {
            w_class = "zwf_bong03",
            e_class = "zwf_bong03_ent",
            name = "Dark Leaf",
            desc = "A small bong with weed leafs on it.",
            hold_amount = 20, // How much weed can the bong hold
            price = 500000000000000,
            model = "models/zerochain/props_weedfarm/zwf_bong03.mdl",
            ranks = {
                ["VIP"] = true,
                ["superadmin"] = true
            },
        },
    }
}

zwf.config.Police = {

    // Do we want the player to get wanted when he sells weed.
    WantedOnWeedSell = false,

    // The Wanted message we display
    WantedMessage = "Sold Weed!",

    // How long is the player wanted for it?
    WantedTime = 120,

    // These jobs can get extra money if they destroy weed reletated stuff and also get a Wanted notification once a player sells weed
    -- Jobs  = {
    --     [TEAM_POLICE] = true,
    -- },

    // How much money the police player gets for destroying weed reletated stuff
    Reward = {
        ["plant"] = 25,
        ["weedblock"] = 100,
        ["weedjunk"] = 25,
        ["weedjar"] = 25,
        ["palette"] = 100, // This value per weedblock on palette entity
    }
}

zwf.config.SnifferSWEP = {
    // Shows every harvest ready weed plant in this distance
    distance = 1000,

    // The duration of the sniff action in seconds per sniff
    duration = 3,

    // How often can the player sniff for illegal items in seconds
    interval = 1,

    // Here we add the entity classes which should be detected
    items = {
        ["zwf_pot"] = {
            // The icon we want to display
            icon = zwf.default_materials["illegal_indicator"],

            // The color of the icon
            color = Color(233, 48, 48),

            // Return true to display the icon
            check = function(ent)
                if ent:GetSeed() ~= 1 and ent:GetHarvestReady() then
                    return true
                else
                    return false
                end
            end
        },
        ["zwf_jar"] = {
            // The icon we want to display
            icon = zwf.default_materials["illegal_indicator"],

            // The color of the icon
            color = Color(233, 48, 48),

            // Return true to display the icon
            check = function(ent)
                if ent:GetPlantID() ~= 1 then
                    return true
                else
                    return false
                end
            end
        },
        ["zwf_pot_hydro"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetSeed() ~= 1 and ent:GetHarvestReady() then
                    return true
                else
                    return false
                end
            end
        },
        ["zwf_joint_ent"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                return true
            end
        },
        ["zwf_palette"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetBlockCount() > 0 then
                    return true
                else
                    return false
                end
            end
        },
        ["zwf_weedblock"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                return true
            end
        },
        ["zwf_weedstick"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                return true
            end
        },
        ["zmlab_collectcrate"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetMethAmount() > 0 then
                    return true
                else
                    return false
                end
            end
        },
        ["zmlab_meth"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetMethAmount() > 0 then
                    return true
                else
                    return false
                end
            end
        },
        ["zmlab_meth_baggy"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetMethAmount() > 0 then
                    return true
                else
                    return false
                end
            end
        },
        ["zmlab_palette"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetMethAmount() > 0 then
                    return true
                else
                    return false
                end
            end
        },
        ["zcm_firecracker"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                return true
            end
        },
        ["zcm_box"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetFireworkCount() > 0 then
                    return true
                else
                    return false
                end
            end
        },
        ["zyb_jar"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetMoonShine() > 0 then
                    return true
                else
                    return false
                end
            end
        },
        ["zyb_jarcrate"] = {
            icon = zwf.default_materials["illegal_indicator"],
            color = Color(233, 48, 48),
            check = function(ent)
                if ent:GetJarCount() > 0 then
                    return true
                else
                    return false
                end
            end
        }
    }
}
