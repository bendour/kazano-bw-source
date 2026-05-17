local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('EntitiesClass')
OBJECT_TYPE.DefaultRender = "Consumables"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('Entities_1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('Entities_2'),
        type = TYPE_STRING,
    },
}

OBJECT_TYPE.UniqueIdentifier = "Entities"

ashop.RegisterObjectType(OBJECT_TYPE)