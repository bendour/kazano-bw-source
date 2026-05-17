hook.Add('ashop_equipStateChange', 'updateSQL', function(ply, state, newID, oldID, slot)
    if state == -1 then
        ashop.SQL.query('DELETE FROM ashop_equip WHERE item_id = ' .. oldID)
    elseif state == 1 then
        // Some SQL errors happens here, this is a temporary fix
        ashop.SQL.query('DELETE FROM ashop_equip WHERE item_id = ' .. newID .. ' AND slot_id = ' .. slot)
        //
        ashop.SQL.query('INSERT INTO ashop_equip(item_id, slot_id) VALUES(' .. newID .. ', ' .. slot ..')')
    else
        ashop.SQL.query('UPDATE ashop_equip SET item_id = ' .. newID .. ' WHERE item_id = ' .. oldID)
    end
end)

// TODO: Cache player value, if he didn't changed items
local function loopHook(ply, isModelPanel, funcName, ...)
    if !ply.ashop_data or !ply.ashop_data.items then return end
    
    for objectTypeID, subCatTable in pairs(ply.ashop_data.equipped or {}) do
        local o = ashop.object_types[objectTypeID]
        if !o[funcName] then continue end
    
        for subCatID, slots in pairs(subCatTable) do
            for slotID, plyItemID in pairs(slots) do
                local plyItem = ply.ashop_data.items[plyItemID]
                o[funcName](ply, plyItem, ashop.items[plyItem.item_id], isModelPanel, slotID, ...)
            end
        end
    end
end

hook.Add('PlayerSpawn', 'ashop_onPlayerSpawn', function(ply)
    // The point of this variable is to have a track of spawn
    // I want to have this counter, so I can give weapons/command one and only one time per spawn
    // A simple thing would be to have a boolean and on/off everytime, but, this can imply to loop all the
    // items of player, and rather than a >100 times loop, I can use this variable and check without any reset.
    ply.ashop_spawncounter = (ply.ashop_spawncounter or 0) + 1

    // Wait that the commandes reset kicks in
    timer.Simple(0, function()
        loopHook(ply, false, 'OnPlayerSpawn')
    end)
end)

hook.Add('PlayerDeath', 'ashop_onPlayerSpawn', function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        loopHook(attacker, false, 'OnKill', victim, inflictor)
        loopHook(victim, false, 'OnKilled', attacker, inflictor)
    end
end)

local PLAYER = FindMetaTable("Player")
ashop.detour = ashop.detour or {}

util.AddNetworkString('ashop_fireSetActiveWeapon')
if !ashop.detour.SetActiveWeapon then
    ashop.detour.SetActiveWeapon = PLAYER.SetActiveWeapon
    ashop.detour.SelectWeapon = PLAYER.SelectWeapon

    // See desc
    // https://wiki.facepunch.com/gmod/Player:SetActiveWeapon
    function PLAYER:SetActiveWeapon(wep)
        ashop.detour.SetActiveWeapon(self, wep)

        net.Start("ashop_fireSetActiveWeapon")
        net.Send(self)
    end

    function PLAYER:SelectWeapon(wep)
        ashop.detour.SelectWeapon(self, wep)

        net.Start("ashop_fireSetActiveWeapon")
        net.Send(self)
    end

    hook.Add("PlayerGiveSWEP", "ashop_fixGmodWeaponSwitch", function(ply, weapon)
        net.Start("ashop_fireSetActiveWeapon")
        net.Send(ply)
    end)
end

util.AddNetworkString('ashop_PlayerEquippedItem')
ashop.SafeNet('PlayerEquippedItem', function(ply)
    local item = net.ReadUInt(ashop.Config.BitsPlyItemID)

    local plyItem = ply.ashop_data.items[item]
    if !plyItem then return end

    local itemTable = ashop.items[plyItem.item_id]
    if !itemTable then return end

    local objectType = ashop.object_types[itemTable.object_types]

    local slotNum = itemTable.sub_types and objectType.sub_cat[itemTable.sub_types].slotSize or objectType.slotSize
    local slotRead = math.ceil(math.log(slotNum, 2))
    local equip = net.ReadBool() and net.ReadUInt(slotRead) or nil

    if equip and itemTable.group_restrained and ashop.groupranks[itemTable.group_restrained] and !ashop.groupranks[itemTable.group_restrained].ranks[ply:GetUserGroup()] then
        return
    end

    if objectType.SlotDefault then
        ply:AShop_ItemEquip(item, equip)
    else
        assert(objectType.OnUse, "Non-equipable item without OnUse function")

        if objectType.RestrictUse and objectType.RestrictUse(ply, itemTable, plyItem) then
            return
        end

        objectType.OnUse(ply, plyItem, itemTable)
        ashop.actions.DeletePlayerItem(ply, plyItem.id)
    end
end)