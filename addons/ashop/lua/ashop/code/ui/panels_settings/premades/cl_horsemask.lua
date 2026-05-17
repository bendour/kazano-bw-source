ashop.RegisterPremade("Horse Mask", {
        requireWorkshop = "166177187",

        objectTypes = {
            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Facemask"
            },
        },

        items = {
            {
                name = "Brown White Horse",
                rendering = 1,
                metadata = {
                    [1] = 'models/horsie/horsiemask.mdl',
                    [3] = Vector(3.21875, -3.375, -0.0625),
                    [4] = Angle(89.84375, 119.71875, 89.84375),
                },
            },

            {
                name = "Black Horse",
                rendering = 1,
                metadata = {
                    [1] = 'models/horsie/horsiemask.mdl',
                    [3] = Vector(3.21875, -3.375, -0.0625),
                    [4] = Angle(89.84375, 119.71875, 89.84375),
                    [11] = 1,
                },
            },

            {
                name = "Brown Horse",
                rendering = 1,
                metadata = {
                    [1] = 'models/horsie/horsiemask.mdl',
                    [3] = Vector(3.21875, -3.375, -0.0625),
                    [4] = Angle(89.84375, 119.71875, 89.84375),
                    [11] = 2,
                },
            },
        }
    }
)