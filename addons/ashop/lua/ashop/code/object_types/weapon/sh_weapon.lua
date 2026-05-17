local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TempWeaponClass')
OBJECT_TYPE.UniqueIdentifier = "TempWeapons"
OBJECT_TYPE.DefaultRender = "Consumables"

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('TempWeapon_1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('TempWeapon_2'),
        type = "UInt16",
    },

    [3] = {
        name = ashop.L('TempWeapon_3'),
        type = "UInt16",
    },

    [4] = {
        name = ashop.L('TempWeapon_4'),
        type = TYPE_VECTOR,
        options = {
            maxVar = 180,
        }
    },
}

function OBJECT_TYPE.RestrictUse()
    if (TTT or TTT2) and GetRoundState and GetRoundState() != ROUND_PREP then
        return true
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)