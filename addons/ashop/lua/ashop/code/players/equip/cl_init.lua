function ashop.EquipChange(e, plyItemID, slot, is_remove)
    e:AShop_ItemEquip(plyItemID, slot, is_remove)
end

function ashop.UnequipAll(e)
    if !e or !e.ashop_data or !e.ashop_data.equipped then return end

    // UnequipAll is called every SetModel
    // UnequippAll will call PlayerModel Unequip
    // That will call SetModel
    // = infinite loop
    local good, objectTypeID, objectType = pcall(ashop.GetObjectTypeIDByUID, 'PlayerModel')
    for object_typeID, v in pairs(e.ashop_data.equipped) do
        if object_typeID == objectTypeID then continue end
        for sub_type, j in pairs(v) do
            for slot, plyItemID in pairs(j) do
                ashop.EquipChange(e, plyItemID, slot, true)
            end
        end
    end
end

hook.Add('ashop_unequip', 'ashop_callobjecttype', function(e, slot, item, plyItem)
    local object_type = ashop.object_types[item.object_types]
    assert(object_type, "Object_type does not exist")

    if e == LocalPlayer() and object_type.OnLocalRemove then
        if object_type.OnLocalRemove then
            object_type.OnLocalRemove(e, plyItem, item)
        end
    else
        if object_type.OnRemove then
            object_type.OnRemove(e, plyItem, item)
        end
    end
end)

// TODO: Cache player value, if he didn't changed items
local function loopHook(ply, isModelPanel, funcName, ...)
    if !ply.ashop_data or !ply.ashop_data.items then return end
    
    local fired = false
    for objectTypeID, subCatTable in pairs(ply.ashop_data.equipped or {}) do
        local o = ashop.object_types[objectTypeID]
        if !o[funcName] then continue end
    
        for subCatID, slots in pairs(subCatTable) do
            for slotID, plyItemID in pairs(slots) do
                local plyItem = ply.ashop_data.items[plyItemID]
                o[funcName](ply, plyItem, ashop.items[plyItem.item_id], isModelPanel, slotID, ...)
                fired = true
            end
        end
    end

    return fired
end

function ashop.OnViewModelChanged(vm, wep)
    local fired = loopHook(LocalPlayer(), false, 'OnViewModelChanged', vm, wep)

    if !fired then
        // Fallback for skins, reset it.
        local b = ashop.GetObjectTypeIDByUID('WeaponSkins', true)
        if !b then return end

        ashop.object_types[b].OnViewModelChanged(LocalPlayer(), nil, nil, nil, nil, vm, wep)
        ashop.WeaponSkinApply(LocalPlayer(), wep)
    end
end

net.Receive('ashop_fireSetActiveWeapon', function()
    timer.Simple(0.8, function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        local wep = ply:GetActiveWeapon()
    
        if !IsValid(wep) then return end
        ashop.OnViewModelChanged(ply:GetViewModel(wep:ViewModelIndex()), ply:GetActiveWeapon())
    end)
end)

function ashop.PostPlayerDraw(ply, flags, isModelPanel)
    loopHook(ply, isModelPanel, 'OnPostPlayerDraw', flags)
end

hook.Add("PostPlayerDraw", "ashop_draw", ashop.PostPlayerDraw)
hook.Add("OnViewModelChanged", "ashop_draw", function(vm)
    timer.Simple(0.25, function()
        local wep = LocalPlayer():GetActiveWeapon()
        ashop.OnViewModelChanged(vm, wep)
    end)
end)

hook.Add("PostDrawTranslucentRenderables", "ashop_draw", function()
    local p = LocalPlayer()
    if !p:ShouldDrawLocalPlayer() then
        loopHook(p, false, 'OnLocalFPDraw')
    end
end)