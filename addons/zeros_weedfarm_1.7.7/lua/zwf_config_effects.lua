zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.config = zwf.config or {}

zwf.config.HighEffect = {

    // How long is the player high when smoking 1 hit of weed
    //*Note The effect duration can increase when smoking large amount of weed. The Effect intensity is defined by the THC amount of the weed.
    DefaultEffect_Duration = 2,

    // The maximal duration a effect can has in seconds.
    MaxDuration = 60,

    Effects = {
        [1] = {
            // The display materials
            mat = "zerochain/zwf/effect/zwf_high_effect01",

            // The refract material
            warp_mat = "zerochain/zwf/effect/zwf_high_effect01_warp",

            // The Bloom Color
            bloom = {0.729, 0.462, 0.125},

            // The DrawColorModify data
            colormodify = {

                ["pp_colour_addr"] = 0.729,
                ["pp_colour_addg"] = 0.462,
                ["pp_colour_addb"] = 0.125,

                ["pp_colour_brightness"] = -0.3,
                ["pp_colour_contrast"] = 1,
                ["pp_colour_colour"] = 1,

                ["pp_colour_mulr"] = 0,
                ["pp_colour_mulg"] = 0,
                ["pp_colour_mulb"] = 0
            }
        },

        [2] = {

            mat = "zerochain/zwf/effect/zwf_high_effect02",
            warp_mat = "zerochain/zwf/effect/zwf_high_effect02_warp",
            bloom = {0.901,  0, 0.231},
            colormodify = {

                ["pp_colour_addr"] = 0.901,
                ["pp_colour_addg"] = 0,
                ["pp_colour_addb"] = 0.231,
                ["pp_colour_brightness"] = -0.2,
                ["pp_colour_contrast"] = 1,
                ["pp_colour_colour"] = 0.8,
                ["pp_colour_mulr"] = 0,
                ["pp_colour_mulg"] = 0,
                ["pp_colour_mulb"] = 0
            }
        },
        [3] = {

            mat = "zerochain/zwf/effect/zwf_high_effect03",
            warp_mat = "zerochain/zwf/effect/zwf_high_effect03_warp",
            bloom = {0.376,  0.466, 0.074},
            colormodify = {

                ["pp_colour_addr"] = 0.376,
                ["pp_colour_addg"] = 0.466,
                ["pp_colour_addb"] = 0.074,
                ["pp_colour_brightness"] = -0.3,
                ["pp_colour_contrast"] = 1,
                ["pp_colour_colour"] = 0.5,
                ["pp_colour_mulr"] = 0,
                ["pp_colour_mulg"] = 0,
                ["pp_colour_mulb"] = 0
            }
        },
        [4] = {

            mat = "zerochain/zwf/effect/zwf_high_effect04",
            warp_mat = "zerochain/zwf/effect/zwf_high_effect04_warp",
            bloom = {0.752,  0.101, 1},
            colormodify = {

                ["pp_colour_addr"] = 0.752,
                ["pp_colour_addg"] = 0.101,
                ["pp_colour_addb"] = 1,
                ["pp_colour_brightness"] = -0.6,
                ["pp_colour_contrast"] = 1,
                ["pp_colour_colour"] = 0.5,
                ["pp_colour_mulr"] = 0,
                ["pp_colour_mulg"] = 0,
                ["pp_colour_mulb"] = 0
            }
        },
        [5] = {

            mat = "zerochain/zwf/effect/zwf_high_effect05",
            warp_mat = "zerochain/zwf/effect/zwf_high_effect05_warp",
            bloom = {0.349,  0.501, 0},
            colormodify = {

                ["pp_colour_addr"] = 0.349,
                ["pp_colour_addg"] = 0.501,
                ["pp_colour_addb"] = 0,
                ["pp_colour_brightness"] = -0.5,
                ["pp_colour_contrast"] = 1,
                ["pp_colour_colour"] = 0.2,
                ["pp_colour_mulr"] = 0,
                ["pp_colour_mulg"] = 0,
                ["pp_colour_mulb"] = 0
            }
        },
        [6] = {

            mat = "zerochain/zwf/effect/zwf_high_effect06",
            warp_mat = "zerochain/zwf/effect/zwf_high_effect06_warp",
            bloom = {0.729,  0.125, 0.211},
            colormodify = {

                ["pp_colour_addr"] = 0.729,
                ["pp_colour_addg"] = 0.125,
                ["pp_colour_addb"] = 0.211,
                ["pp_colour_brightness"] = -0.5,
                ["pp_colour_contrast"] = 1,
                ["pp_colour_colour"] = 0.2,
                ["pp_colour_mulr"] = 0,
                ["pp_colour_mulg"] = 0,
                ["pp_colour_mulb"] = 0
            }
        },
        [7] = {

            mat = "zerochain/zwf/effect/zwf_high_effect07",
            warp_mat = "zerochain/zwf/effect/zwf_high_effect07_warp",
            bloom = {0.560,  0.050, 0.788},
            colormodify = {

                ["pp_colour_addr"] = 0.560,
                ["pp_colour_addg"] = 0.050,
                ["pp_colour_addb"] = 0.788,
                ["pp_colour_brightness"] = -0.5,
                ["pp_colour_contrast"] = 1,
                ["pp_colour_colour"] = 0.2,
                ["pp_colour_mulr"] = 0,
                ["pp_colour_mulg"] = 0,
                ["pp_colour_mulb"] = 0
            }
        },
    }
}
