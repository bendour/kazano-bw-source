local PLAYER = FindMetaTable("Player")

function PLAYER:ashopGetID()
    assert(self.ashop_data, "Can't get player ID, there is no data")
    return self.ashop_data.id
end

function PLAYER:PS2_GetWallet()
    return self:ashopMoneyGet(false)
end

function PLAYER:PS2_CanAfford( itemClass )
    return self:ashopMoneyAfford( itemClass.price, false )
end

function PLAYER:PS2_HasItemEquipped( item )
    local equipped = self:AShop_SlotStateGet(item.object_types)

    for k, v in pairs(equipped or {}) do
        local plyItem = self.ashop_data.items[v]
        local item2 = ashop.items[plyItem.item_id]

        if item2.id == item.id then
            if CLIENT then
                return true
            else
                return k
            end
        end
    end

	return false
end

Pointshop2 = Pointshop2 or {}

function Pointshop2.GetItemClassByName( itemName )
    for k, v in pairs(ashop.items) do
        if v.name == itemName then
            return v
        end
    end
end

function ashop.GetGroupRestrictsAsSelect()
    local t = {}

    for k, v in pairs(ashop.groupranks) do
        table.insert(t, {v.name, k})
    end
    return t
end