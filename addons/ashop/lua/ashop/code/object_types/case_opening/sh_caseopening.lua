local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Case Opening"
OBJECT_TYPE.DefaultRender = "Consumables"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = "Model",
        type = 'SELECT',
        options = {
            selects = {
                {"Weapon case Crate", 'models/akulla/case/weapon-case.mdl'},
                {"Sci-Fi Crate", 'models/akulla/case/sci-fi.mdl'},
                {"Military Crate", 'models/akulla/case/military.mdl'}
            },

            outputType = TYPE_STRING,
            required = true,
        },
    },

    [2] = {
        name = "List of objects",
        type = 'LIST',
        options = {
            listObjects = {
                {"ITEMID", 'Item'},
                {"FLOAT", 'Drop rate'}
            },
            required = true
        },
    },

    [3] = {
        name = "Description",
        type = TYPE_STRING,
        options = {
            required = true,
            lineMultiplySize = 3
        }
    },

    [4] = {
        name = "Picture logo",
        type = TYPE_STRING
    },

    [5] = {
        name = "Color",
        type = TYPE_COLOR
    },

    [6] = {
        name = "Color 2",
        type = TYPE_COLOR
    },

    [7] = {
        name = "Picture override for first color",
        type = TYPE_STRING
    },

    [8] = {
        name = "Picture override for second color",
        type = TYPE_STRING
    },
}

OBJECT_TYPE.UniqueIdentifier = "CaseOpening"

ashop.RegisterObjectType(OBJECT_TYPE)