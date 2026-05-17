ashop.RegisterPremade("Pirate Hat", {
        requireWorkshop = "351194925",

        objectTypes = {
            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Hat"
            },
        },

        items = {
            {
                name = "Pirate Hat",
                rendering = 1,
                metadata = {
                    [1] = 'models/piratehat/piratehat.mdl',
                    [3] = Vector(5.03125, 0.0625, 0.21875),
                    [4] = Angle(180, -70.3125, -90.40625),
                },
            },
        }
    }
)