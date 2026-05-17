zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.config = zwf.config or {}

zwf.config.Shop = {
    [1] = {
        title = zwf.language.Shop["category_Equipment"],
        items = {
            [1] = {
                // Name of the item
                name = zwf.language.Shop["item_generator_title"],

                 // Description
                desc = zwf.language.Shop["item_generator_desc"],

                // Price
                price = 38e12,

                // Class of the Entity
                class = "zwf_generator",

                // Display Model
                model = "models/zerochain/props_weedfarm/zwf_generator.mdl",

                // The Ranks that are allowed to buy this item. Leave empty to disable
                ranks = {
                },

                // The Jobs that are allowed to buy this item. Leave empty to disable
                jobs = {
                    //[TEAM_CITIZEN] = true,
                },

                // The player can only buy this amount at once
                max = 1,
            },
            [2] = {
                name = zwf.language.Shop["item_fuel_title"],
                desc = zwf.language.Shop["item_fuel_desc"],
                price = 10e12,
                class = "zwf_fuel",
                model = "models/zerochain/props_weedfarm/zwf_fuel.mdl",
				ranks = {},
                max = 3,
            },
            [3] = {
                lampid = 1,
                desc = zwf.language.Shop["item_lamp01_desc"],
                price = 38e12,
                class = "zwf_lamp",
                model = "models/zerochain/props_weedfarm/zwf_lamp01.mdl",
                ranks = {},
                max = 5,
            },
            [4] = {
                lampid = 2,
                desc = zwf.language.Shop["item_lamp02_desc"],
                price = 38e12,
                class = "zwf_lamp",
                model = "models/zerochain/props_weedfarm/zwf_lamp02.mdl",
                ranks = {},
                max = 5,
            },
            [5] = {
                name = zwf.language.Shop["item_ventilator_title"],
                desc = zwf.language.Shop["item_ventilator_desc"],
                price = 38e12,
                class = "zwf_ventilator",
                model = "models/zerochain/props_weedfarm/zwf_ventilator01.mdl",
                ranks = {},
                max = 5,
            },
            [6] = {
                name = zwf.language.Shop["item_outlet_title"],
                desc = zwf.language.Shop["item_outlet_desc"],
                price = 38e12,
                class = "zwf_outlet",
                model = "models/zerochain/props_weedfarm/zwf_outlets.mdl",
                ranks = {},
                max = 2,
            },
            [7] = {
                name = zwf.language.Shop["item_flowerpot01_title"],
                desc = zwf.language.Shop["item_flowerpot01_desc"],
                price = 38e12,
                class = "zwf_pot",
                model = "models/zerochain/props_weedfarm/zwf_pot01.mdl",
                ranks = {},
                max = 10,
            },
            [8] = {
                name = zwf.language.Shop["item_flowerpot02_title"],
                desc = zwf.language.Shop["item_flowerpot02_desc"],
                price = 38e12,
                class = "zwf_pot_hydro",
                model = "models/zerochain/props_weedfarm/zwf_pot02.mdl",
                ranks = {
                    ["VIP"] = true,
					["Premium"] = true,
                    ["TrialModerator"] = true,
                    ["Moderator"] = true,
                    ["SuperModerator"] = true,
                    ["Administrator"] = true,
                    ["admin"] = true,
                    ["superadmin"] = true,
                },
                max = 10,
            },
            [9] = {
                name = zwf.language.Shop["item_soil_title"],
                desc = zwf.language.Shop["item_soil_desc"],
                price = 10e12,
                class = "zwf_soil",
                model = "models/zerochain/props_weedfarm/zwf_soil.mdl",
                ranks = {},
                max = 10,
            },
            [10] = {
                name = zwf.language.Shop["item_watertank_title"],
                desc = zwf.language.Shop["item_watertank_desc"],
                price = 38e12,
                class = "zwf_watertank",
                model = "models/zerochain/props_weedfarm/zwf_watertank.mdl",
                ranks = {},
                max = 1,
            },
            [11] = {
                name = zwf.language.Shop["item_drystation_title"],
                desc = zwf.language.Shop["item_drystation_desc"],
                price = 38e12,
                class = "zwf_drystation",
                model = "models/zerochain/props_weedfarm/zwf_drystation.mdl",
                ranks = {},
                max = 1,
            },
            [12] = {
                name = zwf.language.Shop["item_packingtable_title"],
                desc = zwf.language.Shop["item_packingtable_desc"],
                price = 38e12,
                class = "zwf_packingstation",
                model = "models/zerochain/props_weedfarm/zwf_packingstation.mdl",
                ranks = {},
                max = 1,
            },
            [13] = {
                name = zwf.language.Shop["item_autopacker_title"],
                desc = zwf.language.Shop["item_autopacker_desc"],
                price = 38e12,
                class = "zwf_autopacker",
                model = "models/zerochain/props_weedfarm/zwf_autopacker.mdl",
                ranks = {
                    ["VIP"] = true,
					["Premium"] = true,
                    ["TrialModerator"] = true,
                    ["Moderator"] = true,
                    ["SuperModerator"] = true,
                    ["Administrator"] = true,
                    ["admin"] = true,
                    ["superadmin"] = true,
                },
                max = 1,
            },
            [14] = {
                name = zwf.language.Shop["item_seedlab_title"],
                desc = zwf.language.Shop["item_seedlab_desc"],
                price = 38e12,
                class = "zwf_splice_lab",
                model = "models/zerochain/props_weedfarm/zwf_seedlab.mdl",
                ranks = {
                    ["VIP"] = true,
					["Premium"] = true,
                    ["TrialModerator"] = true,
                    ["Moderator"] = true,
                    ["SuperModerator"] = true,
                    ["Administrator"] = true,
                    ["admin"] = true,
                    ["superadmin"] = true,
                },
                max = 1,
            },
            [15] = {
                name = zwf.language.Shop["item_seedbank_title"],
                desc = zwf.language.Shop["item_seedbank_desc"],
                price = 38e12,
                class = "zwf_seed_bank",
                model = "models/zerochain/props_weedfarm/zwf_seedbank.mdl",
                ranks = {
                    ["VIP"] = true,
					["Premium"] = true,
                    ["TrialModerator"] = true,
                    ["Moderator"] = true,
                    ["SuperModerator"] = true,
                    ["Administrator"] = true,
                    ["admin"] = true,
                    ["superadmin"] = true,
                },
                max = 1,
            },
            [16] = {
                name = zwf.language.Shop["item_palette_title"],
                desc = zwf.language.Shop["item_palette_desc"],
                price = 100000000000000,
                class = "zwf_palette",
                model = "models/props_junk/wood_pallet001a.mdl",
                ranks = {},
                max = 3,
            },
        }
    },

    [2] = {
        title = zwf.language.Shop["category_Seeds"],
        items = {
            [1] = {
                seedid = 1,
                desc = zwf.language.Shop["item_seed01_desc"],
                price = 38e12,
                class = "zwf_seed",
                ranks = {},
            },
            [2] = {
                seedid = 4,
                desc = zwf.language.Shop["item_seed04_desc"],
                price = 38e12,
                class = "zwf_seed",
                ranks = {
                    ["VIP"] = true,
					["Premium"] = true,
                    ["TrialModerator"] = true,
                    ["Moderator"] = true,
                    ["SuperModerator"] = true,
                    ["Administrator"] = true,
                    ["admin"] = true,
                    ["superadmin"] = true,
                },
            },
        }
    },

    [3] = {
        title = zwf.language.Shop["category_Nutritions"],
        items = {
            [1] = {
                nutid = 1,
                desc = zwf.language.Shop["item_nutrition01_desc"],
                price = 38e12,
                class = "zwf_nutrition",
                model = "models/zerochain/props_weedfarm/zwf_nutritionbottle.mdl",
                ranks = {},
            },

            [2] = {
                nutid = 5,
                desc = zwf.language.Shop["item_nutrition05_desc"],
                price = 38e12,
                class = "zwf_nutrition",
                model = "models/zerochain/props_weedfarm/zwf_nutritionbottle.mdl",
                ranks = {
                    ["VIP"] = true,
					["Premium"] = true,
                    ["TrialModerator"] = true,
                    ["Moderator"] = true,
                    ["SuperModerator"] = true,
                    ["Administrator"] = true,
                    ["admin"] = true,
                    ["superadmin"] = true,
                },
            },
        }
    },
}
