local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TrailsClass')
OBJECT_TYPE.DefaultRender = "Accessories"

// Name, and extra data
OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('Trails_1'),
        type = TYPE_BOOL,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('Trails_2'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [3] = {
        name = ashop.L('Trails_3'),
        type = TYPE_BOOL,
        options = {
            required = true
        }
    },

    [4] = {
        name = ashop.L('Trails_4'),
        type = TYPE_STRING,
    },

    [5] = {
        name = ashop.L('Trails_5'),
        type = TYPE_VECTOR,
        options = {
            maxVar = 2
        }
    },

    [6] = {
        name = ashop.L('Trails_6'),
        type = TYPE_STRING,
    },

    [7] = {
        name = ashop.L('Trails_7'),
        type = TYPE_COLOR,
    },

    [8] = {
        name = ashop.L('Trails_8'),
        type = TYPE_BOOL,
    },

    [9] = {
        name = ashop.L('Trails_9'),
        type = "UInt8",
    },

    [10] = {
        name = ashop.L('Trails_10'),
        type = "UInt8",
    },

    [11] = {
        name = ashop.L('Trails_11'),
        type = "UInt4",
    },
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.UniqueIdentifier = "Trails"

ashop.RegisterObjectType(OBJECT_TYPE)