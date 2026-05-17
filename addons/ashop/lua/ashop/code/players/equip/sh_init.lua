local ENTITY = FindMetaTable("Entity")

// Get if the slot have items on it
// We return a table since admin can make multiples slot for the same item subcategory/category
// -1: Empty
function ENTITY:AShop_SlotStateGet(object_type, sub_type)
    if !self.ashop_data then
        return
    end

    assert(ashop.object_types[object_type], "Invalid object_types")

    self.ashop_data.equipped = self.ashop_data.equipped or {}
    local s = self.ashop_data.equipped[object_type] or {}

    local index, count
    local o = ashop.object_types[object_type]
    
    if sub_type then
        assert(o.sub_cat and o.sub_cat[sub_type], "Sub_type specified, but doesn't exist")
        index = sub_type
        count = (o.sub_cat[sub_type].slotSize or o.SlotDefault)
    else
        assert(!(o.sub_cat and !table.IsEmpty(o.sub_cat)), "Sub_type not specified, but there is sub-categories")
        index = 0
        count = o.slotSize or o.SlotDefault
    end

    local tbl = {}
    local state = s[index] or {}
    for i = 1, count do
        tbl[i] = state[i]
    end

    return tbl, count
end

function ENTITY:AShop_ItemEquip(plyItemID, specifiedSlot, onlyRemove)
    assert(self.ashop_data, "No ashop_data")
    local a = self.ashop_data.items[plyItemID]

    if !a then
        return "Player doesn't own this item"
    end
    
    local item = ashop.items[tonumber(a.item_id)]
    if !item then return end
    if !ashop.object_types[item.object_types].SlotDefault then return end

    local slots, slotCount = self:AShop_SlotStateGet(item.object_types, item.sub_types)
    local is_remove, removeID = false

    if specifiedSlot and specifiedSlot > slotCount then
        specifiedSlot = nil
    end

    for i=1, slotCount do
        if !slots[i] and specifiedSlot == nil then
            specifiedSlot = i
        end

        if slots[i] == plyItemID then
            is_remove = true
            removeID = i
            specifiedSlot = i
            break
        end
    end

    if onlyRemove and !is_remove then return end

    if !specifiedSlot then
        specifiedSlot = 1
    end

    self.ashop_data.equipped = self.ashop_data.equipped or {}
    self.ashop_data.equipped[item.object_types] = self.ashop_data.equipped[item.object_types] or {}
    self.ashop_data.equipped[item.object_types][item.sub_types or 0] = self.ashop_data.equipped[item.object_types][item.sub_types or 0] or {}
    local t = self.ashop_data.equipped[item.object_types][item.sub_types or 0]
    local object_type = ashop.object_types[item.object_types]

    if SERVER then
        ashop.sendDataToIgnorants({[item.id] = item}, 'items')
        ashop.sendDataToIgnorants({[plyItemID] = a}, 'plyitem', self)

        local playersReady = {}

        for k, v in ipairs(player.GetHumans()) do
            if v.ashop_ready then
                table.insert(playersReady, v)
            end
        end

        net.Start('ashop_PlayerEquippedItem')
            net.WriteEntity(self)
            net.WriteUInt(plyItemID, ashop.Config.BitsPlyItemID)
            net.WriteUInt(specifiedSlot, math.ceil(math.log(slotCount, 2)))
            net.WriteBool(is_remove)
        net.Send(playersReady)
    end

    if is_remove then
        // Remove object
        hook.Run('ashop_unequip', self, slot, item, self.ashop_data.items[t[specifiedSlot]], specifiedSlot)
        if object_type.OnRemove then
            object_type.OnRemove(self, self.ashop_data.items[t[specifiedSlot]], item)
        end

        hook.Run('ashop_equipStateChange', self, -1, nil, t[specifiedSlot])
        t[specifiedSlot] = nil
    else
        if t[specifiedSlot] then
            swap = true
            local oldplyItem = self.ashop_data.items[t[specifiedSlot]]
            local olditem = ashop.items[oldplyItem.item_id]

            if object_type.OnRemove then
                object_type.OnRemove(self, self.ashop_data.items[t[specifiedSlot]], item)
                hook.Run('ashop_unequip', self, slot, olditem, oldplyItem, specifiedSlot)
            end

            hook.Run('ashop_equipStateChange', self, 0, plyItemID, t[specifiedSlot])
        else
            hook.Run('ashop_equipStateChange', self, 1, plyItemID, nil, specifiedSlot)
        end

        t[specifiedSlot] = plyItemID

        hook.Run('ashop_equip', self, slot, item, a, specifiedSlot)

        if CLIENT and self == LocalPlayer() then
            if object_type.OnLocalEquip then
                object_type.OnLocalEquip(self, a, item)
            end
        else
            if object_type.OnEquip then
                object_type.OnEquip(self, a, item)
            end
        end
    end
end


gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "ashop_unequipItemsOnDC", function( data )
    local id = data.userid			// Same as Player:UserID()
    local ply = Player(id)
    if !IsValid(ply) or !ply.ashop_data then return end

    for object_typeID, v in pairs(ply.ashop_data.equipped) do
        local objType = ashop.object_types[object_typeID]
        for sub_type, j in pairs(v) do
            for slot, plyItemID in pairs(j) do
                if objType.OnRemove then
                    local plyItem = ply.ashop_data.items[plyItemID]
                    objType.OnRemove(ply, plyItem, ashop.items[plyItem.item_id])
                end
            end
        end
    end
end )