local OBJECT_TYPE = {}

ashop.DefaultWeaponsHL2 = {
    ["weapon_357"] = {
        "models/weapons/w_357.mdl",
        "models/weapons/c_357.mdl",
    },
    ["weapon_pistol"] = {
        "models/weapons/w_pistol.mdl",
        "models/weapons/c_pistol.mdl",
    },
    ["weapon_bugbait"] = {
        "models/weapons/w_bugbait.mdl",
        "models/weapons/c_bugbait.mdl",
    },
    ["weapon_crossbow"] = {
        "models/weapons/w_crossbow.mdl",
        "models/weapons/c_crossbow.mdl",
    },
    ["weapon_crowbar"] = {
        "models/weapons/w_crowbar.mdl",
        "models/weapons/c_crowbar.mdl",
    },
    ["weapon_physcannon"] = {
        "models/weapons/w_Physics.mdl",
        "models/weapons/c_physcannon.mdl",
    },
    ["weapon_ar2"] = {
        "models/weapons/w_irifle.mdl",
        "models/weapons/c_irifle.mdl",
    },
    ["weapon_rpg"] = {
        "models/weapons/w_rocket_launcher.mdl",
        "models/weapons/c_rpg.mdl",
    },
    ["weapon_shotgun"] = {
        "models/weapons/w_shotgun.mdl",
        "models/weapons/c_shotgun.mdl",
    },
    ["weapon_smg1"] = {
        "models/weapons/w_smg1.mdl",
        "models/weapons/c_smg1.mdl",
    },
    ["weapon_stunstick"] = {
        "models/weapons/w_stunbaton.mdl",
        "models/weapons/c_stunstick.mdl",
    }
}

function ashop.WeaponSkinApply(ply, wep)
    if !wep or !IsValid(wep) then return end

	local skinWep = ply.ashop_skinwep
    if skinWep == wep.ashop_weaponskin then return end
    local c = wep.ashop_WepClass or wep:GetClass()
	wep.ashop_weaponskin = skinWep

    for i = 1, table.Count(wep:GetMaterials()) do
        wep:SetSubMaterial(i-1, nil)
    end

    if !skinWep then return end
    
    local skinTable = ashop.weaponmaterials[c]
    if !skinTable then return end
    local plyItem = ply.ashop_data.items[ply.ashop_skinwep]
	local skinPath = ashop.GetItemAttribute(plyItem, ashop.items[plyItem.item_id], 1)
    
    if !skinPath then return end

	if wep.IsFAS2Weapon then
        if CLIENT then
            if IsValid(wep.W_Wep) then
                for i = 1, table.Count(wep.W_Wep:GetMaterials()) do
                    wep.W_Wep:SetSubMaterial(i-1, nil)
                end
    
                for matID, _ in pairs(skinTable.wm) do
                    wep.W_Wep:SetSubMaterial(matID, (v != 0 and skinPath or nil))
                end
            end
    
            if IsValid(wep.Wep) then
                for i = 1, table.Count(wep.Wep:GetMaterials()) do
                    wep.Wep:SetSubMaterial(i-1, nil)
                end
    
                for matID, _ in pairs(skinTable.vm) do
                    wep.Wep:SetSubMaterial(matID, (v != 0 and skinPath or nil))
                end
            end
        end
    elseif wep.ArcCWWeapon and !wep.DrawTraditionalWorldModel then
        if IsValid(wep.WMEnt) then
            for i = 1, table.Count(wep.WMEnt:GetMaterials()) do
                wep.WMEnt:SetSubMaterial(i, nil)
            end

            for matID, _ in pairs(skinTable.wm) do
                wep.WMEnt:SetSubMaterial(matID, skinPath)
            end
        end
    else
        for matID, _ in pairs(skinTable.wm) do
            wep:SetSubMaterial(matID, skinPath)
        end
    end
end

OBJECT_TYPE.Name = ashop.L('WeaponSkinClass')
OBJECT_TYPE.DefaultRender = "Weapons"

// Name, and extra data
OBJECT_TYPE.ItemParameters = {
    [1] = {
        name = "Skin Dir",
        type = TYPE_STRING,
        options = {
            required = true
        }
    },
}

OBJECT_TYPE.SlotDefault = 1
OBJECT_TYPE.NoChild = true
OBJECT_TYPE.BlockSlotEdit = true
OBJECT_TYPE.UniqueIdentifier = "WeaponSkins"

ashop.RegisterObjectType(OBJECT_TYPE)