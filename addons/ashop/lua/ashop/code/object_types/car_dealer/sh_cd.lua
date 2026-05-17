local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Cars"
OBJECT_TYPE.UniqueIdentifier = "Cars"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('CarDealer_1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('CarDealer_2'),
        type = TYPE_STRING
    }
}

OBJECT_TYPE.DefaultRender = "Consumables"

ashop.RegisterObjectType(OBJECT_TYPE)