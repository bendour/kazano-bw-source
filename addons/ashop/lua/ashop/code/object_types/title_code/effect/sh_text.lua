local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('EffectClass')
OBJECT_TYPE.DefaultRender = "Titles"
OBJECT_TYPE.UniqueIdentifier = "TitleEffect"

// Name, and extra data
OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('Style'),
        type = "UInt8",
        options = {
            required = true
        }
    },
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.NoChild = true
OBJECT_TYPE.BlockSlotEdit = true

ashop.RegisterObjectType(OBJECT_TYPE)