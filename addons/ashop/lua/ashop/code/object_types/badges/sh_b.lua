local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Badges"
OBJECT_TYPE.UniqueIdentifier = "Badges"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('KillCard_1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('Description'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },
}

OBJECT_TYPE.DefaultRender = "Accessories"
OBJECT_TYPE.SlotDefault = 10

ashop.RegisterObjectType(OBJECT_TYPE)