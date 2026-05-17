local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('ColorClass')
OBJECT_TYPE.DefaultRender = "Titles"
OBJECT_TYPE.UniqueIdentifier = "TitleColor"

// Name, and extra data
OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('Color_1'),
        type = TYPE_COLOR,
    },

    [2] = {
        name = ashop.L('Color_2'),
        type = "UInt8"
    }
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.NoChild = true
OBJECT_TYPE.BlockSlotEdit = true

ashop.RegisterObjectType(OBJECT_TYPE)