ashop.object_types = ashop.object_types or {}
local lock = false

local unloaded_types = {}
local nameToIndex = {}

function ashop.RegisterObjectType(t)
    assert(t and t.Name, "Trying to load a object_type without name")
    assert(t and t.UniqueIdentifier, "Trying to load a object_type without UniqueIdentifier: " .. t.Name)

    if lock then
        for k, v in pairs(ashop.object_types) do
            if v.UniqueIdentifier == t.UniqueIdentifier then
                print('[AShop] Merging the object_type ' .. t.UniqueIdentifier .. ' with the existing one.')
                table.Merge(ashop.object_types[k], t)

                if SERVER then
                    print("[AShop] Refresh object_type " .. t.UniqueIdentifier .. ", this only refresh functions.")
                end
                return
            end
        end

        error("Trying to register a object_type after loading")
    end

    t = hook.Run("ashop_preRegisterObjectType", t) or t

    if nameToIndex[t.UniqueIdentifier] then
        table.Merge(unloaded_types[nameToIndex[t.UniqueIdentifier]], t)
    else
        local index = table.insert(unloaded_types, t)
        nameToIndex[t.UniqueIdentifier] = index
    end
end

function ashop.GetUnloadedTypes()
    return unloaded_types
end

local uidToID = {}
function ashop.GetObjectTypeIDByUID(uid, noerror)
    local o = ashop.object_types[uidToID[uid]]

    if !noerror then
        assert(o, "This UID have no matching object_type")
    end
    return uidToID[uid], o
end

function ashop.refreshAShopIDTable()
    for k, v in pairs(ashop.object_types or {}) do
        uidToID[v.UniqueIdentifier] = k
    end
end
ashop.refreshAShopIDTable()

function ashop.VerifyInput(v, type, options)
    local isInt = string.find(type, "UInt")

    if options and options.required then
        if (isInt or type == "FLOAT") and (v == "" or !v) then
            return false, ashop.L('Input_MissingValue')
        end

        if type == TYPE_STRING and (v == "" or !v) then
            return false, ashop.L('Input_MissingValue')
        end

        if type == "ITEMID" and (v == "" or !v or !tonumber(v) or !ashop.items[tonumber(v)]) then
            return false, ashop.L('Input_NotExistingItem')
        end

        if type == "SELECT" and v == nil then
            return false, ashop.L('Input_MissingValue')
        end
    end

    if options and options.maxLength and (v and string.len(v) or 0) > options.maxLength then
        return false, ashop.L('TooLongText', options.maxLength)
    end

    if options and options.minLength and (v and string.len(v) or 0) < options.minLength then
        return false, ashop.L('Input_TooShortText', options.minLength)
    end

    if v and isInt then
        local n = tonumber(string.sub(type, 5))
        local limit = 2^n - 1

        if v < 0 then
            return false, ashop.L('Input_MoreThan0')
        end

        if v > limit then
            return false, ashop.L('Input_LessThanX', limit)
        end
    end

    if options and options.maxNumber and options.maxNumber < tonumber(v) then
        return false, ashop.L('Input_LessThanX', options.maxNumber)
    end

    if options and options.minNumber and options.minNumber < tonumber(v) then
        return false, ashop.L('Input_MoreThanX', options.minNumber)
    end

    if type == "ITEMID" and v != "" and (!tonumber(v) or !ashop.items[tonumber(v)]) then
        return false, ashop.L('Input_NotExistingItem')
    end

    if type == "LIST" and istable(v) then
        for i, j in ipairs(v) do
            // Not ipairs, since some values could be nil
            for kIndex, kValue in pairs(j) do
                local err, res = ashop.VerifyInput(kValue,
                    options.listObjects[kIndex][1], options.listObjects[kIndex][4])

                if err == false then
                    return err, res
                end
            end
        end
    end

    return true
end