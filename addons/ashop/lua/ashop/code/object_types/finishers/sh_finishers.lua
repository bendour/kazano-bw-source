local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('FinishersClass')
OBJECT_TYPE.DefaultRender = "Accessories"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('Finisher_0'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('Finisher_1'),
        type = TYPE_STRING,
    },

    [3] = {
        name = ashop.L('Finisher_2'),
        type = TYPE_BOOL,
    },

    [4] = {
        name = ashop.L('Finisher_3'),
        type = TYPE_VECTOR,
        options = {
            maxVar = 10
        }
    },

    [5] = {
        name = ashop.L('Finisher_4'),
        type = "UInt8",
    },

    [6] = {
        name = ashop.L('Finisher_5'),
        type = "UInt6",
    },

    [7] = {
        name = ashop.L('Finisher_6'),
        type = "FLOAT",
    },

    [8] = {
        name = ashop.L('Finisher_7'),
        type = TYPE_BOOL
    },

    [9] = {
        name = ashop.L('Finisher_8'),
        type = "FLOAT"
    }
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.UniqueIdentifier = "Finishers"

ashop.RegisterObjectType(OBJECT_TYPE)