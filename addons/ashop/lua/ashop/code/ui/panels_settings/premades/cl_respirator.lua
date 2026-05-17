ashop.RegisterPremade("Respirator", {
        requireWorkshop = "939706836",

        objectTypes = {
            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Facemask"
            },
        },

        items = {
            {
                name = "Respirator",
                rendering = 1,
                metadata = {
                    [1] = 'models/mgsv/gear/venom_respirator.mdl',
                    [3] = Vector(1.40625, -2.875, -0.21875),
                    [4] = Angle(180, 109.9375, 89.84375),
                    [10] = false,
                    [11] = 0,
                },
            },
        }
    }
)