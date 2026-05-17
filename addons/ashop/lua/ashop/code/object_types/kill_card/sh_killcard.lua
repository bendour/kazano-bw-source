local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('KillCardClass')
OBJECT_TYPE.DefaultRender = "Accessories"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('KillCard_1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('KillCard_2'),
        type = TYPE_COLOR,
        options = {
            required = true
        }
    },
}

OBJECT_TYPE.UniqueIdentifier = "KillCards"
OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.NoChild = true
OBJECT_TYPE.BlockSlotEdit = true

ashop.RegisterObjectType(OBJECT_TYPE)