local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('ClothesClass')
OBJECT_TYPE.DefaultRender = "Accessories"

// Name, and extra data
OBJECT_TYPE.SubCategoriesParameters = {
    {ashop.L('Bone'), TYPE_STRING},
    {ashop.L('PictureLinkNotOverride'), TYPE_STRING},
}

OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = ashop.L('Clothes_1'),
        type = TYPE_STRING,
        options = {
            required = true
        }
    },

    [2] = {
        name = ashop.L('Pac3'),
        type = "UInt12",
    },

    [3] = {
        name = ashop.L('Pos'),
        type = TYPE_VECTOR,
        options = {
            maxVar = 55,
        }
    },

    [4] = {
        name = ashop.L('Ang'),
        type = TYPE_ANGLE,
        options = {
            maxVar = 180,
        }
    },

    [5] = {
        name = ashop.L('Clothes_5'),
        type = TYPE_ANGLE,
        options = {
            maxVar = 15,
        },
        userEditable = true
    },

    [6] = {
        name = ashop.L('Clothes_6'),
        type = TYPE_VECTOR,
        options = {
            maxVar = 5,
        },
        userEditable = true
    },

    [7] = {
        name = ashop.L('Scale'),
        type = TYPE_VECTOR,
        options = {
            maxVar = 3,
            minVar = 0.01

        },
        defaultValue = Vector(1, 1, 1)
    },

    [8] = {
        name = ashop.L('UserScale'),
        type = TYPE_VECTOR,

        userEditable = true,
        options = {
            maxVar = 0.25
        }
    },

    [9] = {
        name = ashop.L('Color'),
        type = TYPE_COLOR,
    },

    [10] = {
        name = ashop.L('Bonemergable'),
        type = TYPE_BOOL
    },

    [11] = {
        name = ashop.L('SkinID'),
        type = "UInt5"
    },

    [12] = {
        name = ashop.L('PreviewDistance'),
        type = "FLOAT",
    },

    [13] = {
        name = ashop.L('PreviewPos'),
        type = TYPE_VECTOR,
        options = {
            maxVar = 200,
        }
    },
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.UniqueIdentifier = "Wearables"

OBJECT_TYPE.DefaultSubCategories = {
    [ashop.L('ClothesDefaultHat')] = {"ValveBiped.Bip01_Head1", '5'},
    [ashop.L('ClothesDefaultBack')] = {"ValveBiped.Bip01_Spine2", '8'},
    [ashop.L('ClothesDefaultFacemask')] = {"ValveBiped.Bip01_Head1", '6'},
    [ashop.L('ClothesDefaultGlasses')] = {"ValveBiped.Bip01_Head1", '7'},
    [ashop.L('ClothesDefaultNeck')] = {"ValveBiped.Bip01_Neck1", '9'},
}

ashop.RegisterObjectType(OBJECT_TYPE)

// Compatibility
local PLAYER = FindMetaTable("Player")
local cacheUID

function PLAYER:ashop_equippedModel(mdl)
    if !cacheUID then
        cacheUID = ashop.GetObjectTypeIDByUID('Wearables')
    end

    if !self.ashop_data or !self.ashop_data.equipped or !self.ashop_data.equipped[cacheUID] then return false end

    local c = self.ashop_data.equipped[cacheUID]

    for _, slots in pairs(c or {}) do
        for slotID, plyItemID in pairs(slots) do
            local plyItem = self.ashop_data.items[plyItemID]

            local item = ashop.items[plyItem.item_id]
            if !item then continue end

            local model = ashop.GetItemAttribute(plyItem, item, 1)

            if model and model == mdl then
                return true
            end
        end
    end

    return false
end