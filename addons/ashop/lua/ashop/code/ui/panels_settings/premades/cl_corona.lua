ashop.RegisterPremade("Chirurgical/Corona mask", {
        requireWorkshop = "2174343063",

        objectTypes = {
            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Facemask"
            }
        },

        items = {
            {
                name = "Corona Mask",
                rendering = 2,
                metadata = {
                    [1] = 'models/rebs/maske/maske.mdl',
                    [3] = Vector(0.40625, -5.03125, -0.0625),
                    [4] = Angle(0.25, -75, -90),
                    [11] = 1,
                },
            },

            {
                name = "Corona Mask 2",
                rendering = 2,
                metadata = {
                    [1] = 'models/rebs/maske/maske.mdl',
                    [3] = Vector(0.40625, -5.03125, -0.0625),
                    [4] = Angle(0.25, -75, -90),
                },
            },
        }
    }
)