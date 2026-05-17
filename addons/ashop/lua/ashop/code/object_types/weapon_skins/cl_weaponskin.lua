local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('WeaponSkinClass')
OBJECT_TYPE.UniqueIdentifier = "WeaponSkins"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, ignoreThat, fullSize)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local c = fullSize and math.max(w, h) or math.max(w, h) * 0.4

    // What an hack...
    local vmt = file.Read("materials/" .. item.metadata[1] .. ".vmt", 'GAME')
    local t = {
        ["$basetexture"] = item.metadata[1]
    }

    if vmt and string.find(vmt, 'AnimatedTexture') then
        t['Proxies'] = {
            ["AnimatedTexture"] = {
                ["animatedTextureVar"] = "$basetexture",
                ["animatedTextureFrameNumVar"] = "$frame",
                ["animatedTextureFrameRate"] = 30
            }
        }
    elseif vmt and string.find(vmt, 'TextureScroll') then
        t['Proxies'] = {
            ["TextureScroll"] = {
                ["texturescrollvar"] = "$baseTextureTransform",
                ["texturescrollrate"] = 0.1,
                ["texturescrollangle"] = 130
            }
        }
    end

    local mat = CreateMaterial('ashop_weptex_' .. item.metadata[1], "UnLitGeneric", t)

    local SpawnI = vgui.Create( "DPanel" , circleParent ) -- SpawnIcon
    SpawnI:SetSize(c, c)
    SpawnI:Center()
    
    local r1
    function SpawnI:Paint(w, h)
        if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, 0, 0, w, h)
        end

        ashop.StartStencil()
            surface.SetDrawColor(1, 1, 1, 1)
            draw.NoTexture()
            surface.DrawPoly(r1)
        ashop.ReplaceStencil(1)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, w, h)
        ashop.EndStencil()
    end
end

function OBJECT_TYPE.OnPostPlayerDraw(ply, _, _, inModelPanel)
    if inModelPanel and !IsValid(inModelPanel.WeaponModel) then return end
    ashop.WeaponSkinApply(ply, inModelPanel and inModelPanel.WeaponModel or ply:GetActiveWeapon())
end

function OBJECT_TYPE.OnViewModelChanged(ply, plyItem, item, _, _, vm, wep)
    if !wep or !IsValid(vm) or !IsValid(wep) then return end

    // What a painful weapon pack
    if wep.IsFAS2Weapon then
        for i = 1, #wep.W_Wep:GetMaterials() do
            wep.W_Wep:SetSubMaterial(i-1, nil)
        end

        for i = 1, #wep.Wep:GetMaterials() do
            wep.Wep:SetSubMaterial(i-1, nil)
        end
    elseif wep.ArcCWWeapon then
        if IsValid(wep.CW_VM) then
            for i = 1, #wep.CW_VM:GetMaterials() do
                wep.CW_VM:SetSubMaterial(i-1, nil)
            end
        end
    elseif wep.IsTFAWeapon then
        wep.MaterialCached_W = nil
        wep.MaterialCached_V = nil

        for i = 1, #vm:GetMaterials() do
            vm:SetSubMaterial(i-1, nil)
        end

        for i = 1, #wep:GetMaterials() do
            wep:SetSubMaterial(i-1, nil)
        end
        wep.MaterialCached = false
    else
        for i = 1, #vm:GetMaterials() do
            vm:SetSubMaterial(i-1, nil)
        end
    end

    if !item then return end

    local skinWep = ply.ashop_skinwep
    local skinTable = ashop.weaponmaterials[wep:GetClass()]
	local skinPath = item.metadata[1]

    if !skinTable or !skinPath or !skinWep then return end

	if wep.IsFAS2Weapon then
        // Fas2, duh !
        if IsValid(wep.W_Wep) then
            for matID in pairs(skinTable.wm) do
                wep.W_Wep:SetSubMaterial(matID, skinPath)
            end
        end
    
        if IsValid(wep.Wep) then
            for matID in pairs(skinTable.vm) do
                wep.Wep:SetSubMaterial(matID, skinPath)
            end
        end

        // https://github.com/Facepunch/garrysmod-issues/issues/2473
        timer.Create('ashop_FixGmodSwitchWeapon', 0.5, 0, function()
            if ply:GetActiveWeapon() != wep then
                ashop.OnViewModelChanged(ply:GetViewModel(), ply:GetActiveWeapon())
                timer.Remove('ashop_FixGmodSwitchWeapon')
            end
        end)
    elseif wep.ArcCWWeapon then
        if IsValid(wep.CW_VM) then
            for matID in pairs(skinTable.vm) do
                wep.CW_VM:SetSubMaterial(matID, skinPath)
            end
        end
    elseif wep.IsTFAWeapon then
        for k, v in ipairs({
            {wep.MaterialTable_V, skinTable.vm, wep.vRenderOrder, wep.VElements},
            {wep.MaterialTable_W, skinTable.wm, wep.wRenderOrder, wep.WElements},
        }) do
            for index = 0, #v[3] do
                if !v[2][index] then continue end
                v[1][index+1] = skinPath
                local obj = (k == 1 and vm or wep)
                obj:SetSubMaterial(index, skinPath)
            end

            local tfadetect = ashop.Config.aggressiveTFASkinDetection
            if tfadetect and tfadetect[wep:GetClass()] then            
                for k, v in pairs(v[4]) do
                    if !v.model or !v.bone or v.bone == "" or !(v.active or v.active == nil) then continue end
                    v.material = skinPath
                end
            end
        end

        wep:ClearStatCache()
    else
        for matID in pairs(skinTable.vm) do
            vm:SetSubMaterial(matID, skinPath)
        end
    end
end

function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    ply.ashop_skinwep = plyItem.id

    if !ply:IsPlayer() then
        ashop.WeaponSkinApply(ply, ply.Weapon)
    else
        local wep = ply:GetActiveWeapon()
        local vm = ply:GetViewModel()
        OBJECT_TYPE.OnViewModelChanged(ply, plyItem, item, nil, nil, vm, wep)
    end
end

function OBJECT_TYPE.OnLocalRemove(ply, plyItem, item)
    OBJECT_TYPE.OnRemove(ply, plyItem, item)
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    ply.ashop_skinwep = nil

    if !ply:IsPlayer() then
        ashop.WeaponSkinApply(ply, ply.Weapon)
    else
        local wep = ply:GetActiveWeapon()
        local vm = ply:GetViewModel()
        OBJECT_TYPE.OnViewModelChanged(ply, plyItem, item, nil, nil, vm, wep)
        ashop.WeaponSkinApply(ply, wep)
    end
end

// All players
function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if !ply:IsPlayer() then
        ashop.WeaponSkinApply(ply, ply.Weapon)
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)