local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Commandes"
OBJECT_TYPE.DefaultRender = "Consumables"
OBJECT_TYPE.UniqueIdentifier = "Commandes"

// Name, and extra data
OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('Commandes_1'),
        type = TYPE_STRING,
    },

    [2] = {
        name = ashop.L('Commandes_2'),
        type = 'SELECT',
        options = {
            selects = {
                {ashop.L('Commandes_2_0'), 1},
                {ashop.L('Commandes_2_1'), 2},
                {ashop.L('Commandes_2_2'), 3}
            },

            outputType = 'UInt8',
            required = true
        },
    },

    [3] = {
        name = ashop.L('Commandes_3'),
        type = TYPE_STRING
    }
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.UniqueIdentifier = "Commandes"

ashop.RegisterObjectType(OBJECT_TYPE)