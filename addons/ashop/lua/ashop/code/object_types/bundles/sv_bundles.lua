local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('Bundles')
OBJECT_TYPE.UniqueIdentifier = "Bundles"

function OBJECT_TYPE.OnUse(ply, plyItem, item)
    assert(item.metadata and item.metadata[1], "Missing a list for the items to give, concerning this bundle: " .. item.name)

    // Complete verification BEFORE trying to give
    for k, v in pairs(item.metadata[1]) do
        assert(ashop.items[v[1]], "Item in the bundle '" .. item.name .. "' is not available anymore, abort bundle use")
    end

    // Everything is fine ? Great
    for k, v in pairs(item.metadata[1]) do
        ashop.actions.Give(ply, v[1], nil, 0, false)
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)