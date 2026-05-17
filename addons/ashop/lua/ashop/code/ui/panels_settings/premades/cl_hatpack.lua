ashop.RegisterPremade("Random Hat Pack", {
        requireWorkshop = "358462651",

        objectTypes = {
            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Facemask"
            },
        },

        items = {
            {
                name = "Skimask",
                rendering = 1,
                metadata = {
                    [1] = 'models/hats/skimask.mdl',
                    [3] = Vector(5.03125, 0.0625, 0.21875),
                    [4] = Angle(180, -70.3125, -90.40625),
                },
            },

            {
                name = "Cig",
                rendering = 1,
                metadata = {
                    [1] = 'models/hats/cig/cig.mdl',
                    [3] = Vector(0.21875, -5.71875, -0.90625),
                    [4] = Angle(-150.125, -122.4375, -19.25),
                },
            },

            {
                name = "Cigar",
                rendering = 1,
                metadata = {
                    [1] = 'models/hats/cigar/cigar.mdl',
                    [3] = Vector(0.0625, -6.03125, -0.71875),
                    [4] = Angle(-142.53125, -122.4375, -19.25),
                },
            },

            {
                name = "Bandana",
                rendering = 1,
                metadata = {
                    [1] = 'models/hats/bandana/bandana.mdl',
                    [3] = Vector(-15, -3.5625, -0.0625),
                    [4] = Angle(0.25, -79.53125, -89.84375),
                },
            },
        }
    }
)