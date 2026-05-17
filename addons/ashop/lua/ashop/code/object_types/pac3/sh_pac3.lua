local OBJECT_TYPE = {}

OBJECT_TYPE.Name = 'Effets'
OBJECT_TYPE.DefaultRender = "Accessories"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = "Simple particles or Pac3 (Checked)",
        type = TYPE_BOOL,
    },

    [2] = {
        name = ashop.L('Pac3') .. " ID",
        type = "UInt12",
    },

    [3] = {
        name = "Particle file name",
        type = TYPE_STRING,
    },

    [4] = {
        name = "Particle name",
        type = TYPE_STRING,
    },

    [5] = {
        name = "Bone name ( Will use a entity )",
        type = TYPE_STRING,
    },

    [6] = {
        name = "Offset, if using bone",
        type = TYPE_VECTOR,
        options = {
            maxVar = 5,
        },
    },

    [7] = {
        name = "PAttach ( Useful if you don't use a bone )",
        type = "UInt4",
    },

    [8] = {
        name = "Angle, if using bone",
        type = TYPE_ANGLE,
        options = {
            maxVar = 180,
        }
    }
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.UniqueIdentifier = "Pac3"

ashop.RegisterObjectType(OBJECT_TYPE)