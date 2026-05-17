ashop.RegisterPremade("Naruto", {
        requireWorkshop = "114195906",

        objectTypes = {
            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Facemask"
            },

            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Hat"
            },
        },

        items = {
            {
                name = "Anbu Mask",
                rendering = 1,
                metadata = {
                    [1] = 'models/naruto/props/anbumask.mdl',
                    [3] = Vector(-2.0625, -3.71875, -0.21875),
                    [4] = Angle(180, -0.25, 90.40625),
                },
            },

            {
                name = "Oinin Mask",
                rendering = 1,
                metadata = {
                    [1] = 'models/naruto/props/oininmask.mdl',
                    [3] = Vector(-2.0625, -3.71875, -0.21875),
                    [4] = Angle(180, 89.84375, 89.84375),
                },
            },

            {
                name = "Hokage",
                rendering = 2,
                metadata = {
                    [1] = 'models/naruto/props/kagehat.mdl',
                    [3] = Vector(-2.21875, -1.90625, -0.0625),
                    [4] = Angle(180, 12.1875, 89.84375),
                    [11] = 0,
                },
            },

            {
                name = "Kazekage",
                rendering = 2,
                metadata = {
                    [1] = 'models/naruto/props/kagehat.mdl',
                    [3] = Vector(-2.21875, -1.90625, -0.0625),
                    [4] = Angle(180, 12.1875, 89.84375),
                    [11] = 1,
                },
            },

            {
                name = "Mizukage",
                rendering = 2,
                metadata = {
                    [1] = 'models/naruto/props/kagehat.mdl',
                    [3] = Vector(-2.21875, -1.90625, -0.0625),
                    [4] = Angle(180, 12.1875, 89.84375),
                    [11] = 2,
                },
            },

            {
                name = "Tsuchikage",
                rendering = 2,
                metadata = {
                    [1] = 'models/naruto/props/kagehat.mdl',
                    [3] = Vector(-2.21875, -1.90625, -0.0625),
                    [4] = Angle(180, 12.1875, 89.84375),
                    [11] = 3,
                },
            },

            {
                name = "Raikage",
                rendering = 2,
                metadata = {
                    [1] = 'models/naruto/props/kagehat.mdl',
                    [3] = Vector(-2.21875, -1.90625, -0.0625),
                    [4] = Angle(180, 12.1875, 89.84375),
                    [11] = 4,
                },
            },

            {
                name = "Ninja Headband",
                rendering = 2,
                metadata = {
                    [1] = 'models/naruto/props/headband.mdl',
                    [3] = Vector(3.375, 0.40625, -0.0625),
                    [4] = Angle(180, 103.4375, 90.40625),
                },
            },
        }
    }
)