local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('PetClass')
OBJECT_TYPE.DefaultRender = "Accessories"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('PlayerModel1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('Skin'),
        type = "UInt8",
    },

    [3] = {
        name = ashop.L('Finisher_3') .. " Y",
        type = "UInt6",
    },

    [4] = {
        name = ashop.L('Pet_4'),
        type = 'LIST',
        options = {
            listObjects = {
                {TYPE_STRING, ashop.L('Pet_Alt')},
                {"FLOAT", ashop.L('Pet_Alt2')},
            },
            required = true
        },
    },

    [5] = {
        name = ashop.L('Pet_5'),
        type = 'LIST',
        options = {
            listObjects = {
                {TYPE_STRING, ashop.L('Pet_Alt')},
                {"FLOAT", ashop.L('Pet_Alt2')},
            },
            required = true
        },
    },

    [6] = {
        name = ashop.L('Pet_6'),
        type = 'LIST',
        options = {
            listObjects = {
                {TYPE_STRING, ashop.L('Pet_Alt')},
                {"FLOAT", ashop.L('Pet_Alt2')},
            },
        },
    },

    [7] = {
        name = ashop.L('Pet_7'),
        type = 'LIST',
        options = {
            listObjects = {
                {TYPE_STRING, ashop.L('Pet_Alt')},
                {"FLOAT", ashop.L('Pet_Alt2')},
            },
        },
    },

    [8] = {
        name = ashop.L('Pet_8'),
        type = TYPE_STRING,
        userEditable = true,
    },

    [9] = {
        name = ashop.L('Scale'),
        type = "FLOAT",
    }
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.UniqueIdentifier = "Pets"

ashop.RegisterObjectType(OBJECT_TYPE)