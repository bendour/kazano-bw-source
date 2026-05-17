local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('CarSkins')
OBJECT_TYPE.DefaultRender = "Accessories"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('CarSkin_1'),
        type = TYPE_STRING,
    },

    [2] = {
        name = ashop.L('CarSkin_2'),
        type = 'LIST',
        options = {
            listObjects = {
                {TYPE_STRING, "List of vehicle that can use this skin"},
            },
            required = true
        },
    }
}

OBJECT_TYPE.SlotDefault = 5
OBJECT_TYPE.UniqueIdentifier = "CarSkin"
OBJECT_TYPE.NoChild = true

ashop.RegisterObjectType(OBJECT_TYPE)