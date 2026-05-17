function ashop.GetItemAttribute(plyItem, item, attr)
    if plyItem.metadata and plyItem.metadata[attr] then
        return plyItem.metadata[attr]
    end
    
    if item.metadata and item.metadata[attr] then
        return item.metadata[attr]
    end
end

/*
    if item.sub_types then
        local o = ashop.object_types[item.object_types]

        if o and o.sub_cat[item.sub_types] and o.sub_cat[item.sub_types].metadata then
            
    end
*/
function ashop.GetSubTypeAttributeByRawItem(item, attr)
    return ashop.object_types[item.object_types].sub_cat[item.sub_types].metadata[attr]
end

function ashop.GetSubTypeAttributeByPlayerItem(item, attr)
    return ashop.GetSubTypeAttributeByRawItem(ashop.items[item.item_id], attr)
end

function ashop.FindFirstRarity()
    return next(ashop.rarity)
end