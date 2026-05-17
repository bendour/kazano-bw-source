local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('Bundles')
OBJECT_TYPE.DefaultRender = "Consumables"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('ListOfObjects'),
        type = 'LIST',
        options = {
            listObjects = {
                {"ITEMID", 'Item'},
                {"UInt8", 'Amount'},
            },
            required = true
        },
    },
}

OBJECT_TYPE.UniqueIdentifier = "Bundles"

ashop.RegisterObjectType(OBJECT_TYPE)