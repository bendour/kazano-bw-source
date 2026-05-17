ashop.object_types = ashop.object_types or {}
local nameToID = {}
local numLeft

local function endRegister(t, sqlID)
    sqlID = sqlID and tonumber(sqlID) or nil
    t.sqlID = sqlID

    assert(isnumber(sqlID), "Missing a SqlID while registering")
    assert(!ashop.object_types[t.sqlID] or ashop.object_types[t.sqlID].Name != t.Name, 
        "Object mismatch, this shouldn't happens on a FRESH start, make a gmodstore ticket. IF this is after a lua refresh, this is not a big issue, you can ignore that")

    ashop.object_types[t.sqlID] = t
    numLeft = numLeft - 1

    // We have every SQL object_types IDs
    if numLeft > 0 then return end
    ashop.refreshAShopIDTable()
    
    local c = 10
    local function onEnd()
        c = c - 1

        if c <= 0 then
            // LET'S GO, WE HAVE EVERYTHING !
            // TODO: Verify that all datas are up-to-date with subparams etc ?

            // Fill categories with their values
            for k, v in pairs(ashop.object_types) do
                assert(ashop.render[v.renderIDBy], 'No render for a category')

                ashop.render[v.renderIDBy].cat = ashop.render[v.renderIDBy].cat or {}
                ashop.render[v.renderIDBy].cat[k] = true
            end
            hook.Run("ashop_load", ashop.LoadState.EverythingLoaded)
        end
    end

    // Fetch every sub_category, put them with their parent
    ashop.SQL.query('SELECT * FROM ashop_sub_types', function(d)
        for _, sub_type in pairs(d or {}) do
            sub_type.object_typeid = tonumber(sub_type.object_typeid)
            local oID = sub_type.object_typeid
            sub_type.id = tonumber(sub_type.id)
            sub_type.slotSize = tonumber(sub_type.slotSize)
            assert(ashop.object_types[oID], "Missing object_type while loading his sub_type: " .. oID)
    
            local t = ashop.object_types[oID]
            t.sub_cat = t.sub_cat or {}
    
            sub_type.metadata = util.JSONToTable(sub_type.metadata)
            t.sub_cat[sub_type.id] = sub_type
        end

        print('[AShop] Loaded sub_types')
        onEnd()
    end)

    // Load items now
    ashop.SQL.query('SELECT * FROM ashop_render', function(d)
        local a = {}

        for k, v in ipairs(d) do
            v.r = tonumber(v.r)
            v.g = tonumber(v.g)
            v.b = tonumber(v.b)
            v.style = tonumber(v.style)
            v.id = tonumber(v.id)
            a[v.id] = v
        end
        
        ashop.render = a
        assert('[AShop] Ashop_render SQL schema is empty')
        onEnd()
    end)

    // Load groupsranks
    ashop.SQL.query('SELECT * FROM ashop_groupranks', function(d)
        local a = {}

        for k, v in ipairs(d or {}) do
            v.ranks = util.JSONToTable(v.ranks)
            v.id = tonumber(v.id)
            v.freePerTime = tonumber(v.freePerTime)
            v.premiumPerTime = tonumber(v.premiumPerTime)

            if v.desc == "NULL" then
                v.desc = nil
            end

            if v.messageOnFail == "NULL" then
                v.messageOnFail = nil
            end

            a[v.id] = v
        end
        
        ashop.groupranks = a
        print('[AShop] Loaded ' .. table.Count(a) .. " group ranks")
        onEnd()
    end)

    // Load groupsranks
    ashop.SQL.query('SELECT * FROM ashop_rankpromotions', function(d)
        local a = {}

        for k, v in ipairs(d or {}) do
            a[v.rank] = tonumber(v.promo)
        end
        
        ashop.rankpromo = a
        print('[AShop] Loaded ' .. table.Count(a) .. " group promotions")
        onEnd()
    end)

    ashop.SQL.query('SELECT * FROM ashop_items', function(d)
        local a = {}

        for k, v in ipairs(d or {}) do
            // sqlite :))
            v.expireTime = tonumber(v.expireTime)
            v.id = tonumber(v.id)
            v.rarity = tonumber(v.rarity)
            v.promotion_amount = tonumber(v.promotion_amount)
            v.promotion_start = tonumber(v.promotion_start)
            v.promotion_end = tonumber(v.promotion_end)
            v.premium_price = tonumber(v.premium_price)
            v.price = tonumber(v.price)
            v.sub_types = tonumber(v.sub_types)
            v.object_types = tonumber(v.object_types)
            v.group_restrained = tonumber(v.group_restrained)

            if !ashop.object_types[v.object_types] then
                PrintTable(ashop.object_types)
                PrintTable(v)
                error("[AShop] Issue with this item: " .. v.id .. ", the object_type does not exist: ", v.object_types)
            end

            if v.picture_link and v.picture_link == "NULL" then
                v.picture_link = nil
            end

            if v.metadata and v.metadata != "NULL" then
                local cM = v.metadata
                v.metadata = util.JSONToTable(v.metadata)

                if !v.metadata then
                    error("Issue with metadatas on this item: " .. v.id)
                end

                // Not my fault: https://wiki.facepunch.com/gmod/util.JSONToTable
                local ip = ashop.object_types[v.object_types].ItemParameters

                for i, j in pairs(v.metadata) do
                    if !ip[i] then
                        v.metadata[i] = nil
                    elseif ip[i].type == TYPE_COLOR then
                        v.metadata[i] = Color(j.r, j.g, j.b)
                    end
                end
            end

            a[v.id] = v
        end
        
        ashop.items = a
        print('[AShop] Loaded ' .. table.Count(ashop.items) .. " items")
        onEnd()
    end)

    ashop.SQL.query('SELECT * FROM ashop_rarity', function(d)
        ashop.rarity = {}
        for k, v in ipairs(d) do
            v.id = tonumber(v.id)
            v.r = tonumber(v.r)
            v.g = tonumber(v.g)
            v.b = tonumber(v.b)
            v.style = tonumber(v.style)
            v.notif_unbox = tobool(tonumber(v.notif_unbox))
            v.notif_unboxsound = v.notif_unboxsound != "NULL" and v.notif_unboxsound or nil
    
            ashop.rarity[tonumber(v.id)] = v
        end

        print('[AShop] Loaded ' .. table.Count(ashop.rarity) .. " rarity")
        onEnd()
    end)

    timer.Simple(0, function()
        ashop.SQL.query('SELECT * FROM ashop_pac3', function(d)
            if !pac then
                print("[AShop] Trying to load pac3 things without pac3, will not load pac3")
                onEnd()
                return
            end
    
            ashop.pac3 = {}
            for k, v in ipairs(d or {}) do
                v.id = tonumber(v.id)
    
                ashop.pac3[v.id] = {
                    name = v.name,
                    outfit = v.outfit,
                    model_attach = tobool(tonumber(v.model_attach))
                }
            end
            onEnd()
        end)
    end)

    ashop.SQL.query('SELECT * FROM ashop_weaponmaterials', function(d)
        local a = {}

        for k, v in ipairs(d or {}) do
            a[v.weaponname] = {vm = util.JSONToTable(v.vm) or {}, wm = util.JSONToTable(v.wm) or {}}
        end
        
        ashop.weaponmaterials = a
        print('[AShop] Loaded ' .. table.Count(ashop.weaponmaterials) .. " weapon materials")
        onEnd()
    end)

    ashop.SQL.query('SELECT * FROM ashop_carmaterials', function(d)
        local a = {}

        for k, v in ipairs(d or {}) do
            a[v.car] = util.JSONToTable(v.data) or {}
        end
        
        ashop.carmaterials = a
        print('[AShop] Loaded ' .. table.Count(ashop.carmaterials) .. " cars materials")
        onEnd()
    end)

    ashop.SQL.query('SELECT * FROM ashop_currenciesTrades', function(d)
        local a = {}

        for k, v in ipairs(d or {}) do
            v.convertRate = tonumber(v.convertRate)
            v.toCoins = tonumber(v.toCoins)
            v.toPremium = tonumber(v.toPremium)
            v.id = tonumber(v.id)

            v.toCoins = v.toCoins == 1
            v.toPremium = v.toPremium == 1
            a[v.id] = v
        end
        
        ashop.currencies.trades = a
        print('[AShop] Loaded ' .. table.Count(ashop.currencies.trades) .. " currency trades")
        onEnd()
    end)
end


local function createObjectType(v)
    ashop.SQL.query('INSERT INTO ashop_object_types(name, stringID, slotSize, renderBy) VALUES(' .. ashop.SQL.escape(v.Name) .. ', \'' .. v.UniqueIdentifier .. '\',' .. (v.SlotDefault or 0) .. ', ' .. nameToID[v.DefaultRender] .. ')', function(_, qO)
        local sqlID = qO:lastInsert()
        if v.DefaultSubCategories then
            // Forgive me for my sins
            // We use a query and not a transaction
            // On query, we can get the last_insert_id, but not on mysqloo's transaction
            // This is so bad

            local mySins = {}
            for k, v2 in pairs(v.DefaultSubCategories) do
                local strippedJson = util.TableToJSON(v2)
                table.insert(mySins, "(" .. ashop.SQL.escape(k) .. ", '" .. strippedJson .. "', " .. sqlID .. "," .. (v.SlotDefault or 0) .. ")")
            end

            local theSin = "INSERT INTO ashop_sub_types(name, metadata, object_typeid, slotSize) VALUES" .. table.concat(mySins, ",")

            ashop.SQL.query(theSin, function()
                endRegister(v, sqlID)
            end)
        else
            endRegister(v, sqlID)
        end
    end)
end

local function fetchRender(renderData)
    ashop.render = {}

    for k, v in ipairs(renderData or {}) do
        v.id = tonumber(v.id)
        nameToID[v.name] = v.id
        ashop.render[v.id] = v
    end

    local waitingCreationOfRender = {}

    // For every type, get his UID in database, or create it
    numLeft = #ashop.GetUnloadedTypes()
    for k, v in ipairs(ashop.GetUnloadedTypes()) do
        ashop.SQL.query('SELECT id, renderBy, slotSize, name FROM ashop_object_types WHERE stringID = "' .. v.UniqueIdentifier .. '"', function(d)
            v.loop_index = k
            if !d then
                // The object_type does not exist, but the render exist
                if nameToID[v.DefaultRender] then
                    v.renderIDBy = nameToID[v.DefaultRender]
                    v.slotSize = v.SlotDefault or 0
                    createObjectType(v)
                else
                    // Render is waiting SQL insert, make the object_type wait
                    if waitingCreationOfRender[v.DefaultRender] then
                        if istable(waitingCreationOfRender[v.DefaultRender]) then
                            table.insert(waitingCreationOfRender[v.DefaultRender], v)
                        else
                            v.renderIDBy = nameToID[v.DefaultRender]
                            v.slotSize = v.SlotDefault or 0
                            createObjectType(v)
                        end
                    else
                        // Create render
                        assert(v.DefaultRender, "[AShop] Can't continue execution, a object_type is missing DefaultRender: " .. v.UniqueIdentifier)
                        waitingCreationOfRender[v.DefaultRender] = {v}

                        ashop.SQL.query("INSERT INTO ashop_render(name) VALUES('" .. v.DefaultRender .. "')", function(_, qO)
                            ashop.render[qO:lastInsert()] = {
                                name = v.DefaultRender,
                                id = qO:lastInsert()
                            }

                            nameToID[v.DefaultRender] = qO:lastInsert()

                            // Load waiting things
                            for k, v in ipairs(waitingCreationOfRender[v.DefaultRender]) do
                                v.renderIDBy = qO:lastInsert()
                                v.slotSize = v.SlotDefault or 0
                                createObjectType(v)
                            end

                            waitingCreationOfRender[v.DefaultRender] = true
                        end)
                    end
                end
            else
                d[1].id = tonumber(d[1].id)
                v.renderIDBy = tonumber(d[1].renderBy)
                v.slotSize = tonumber(d[1].slotSize)
                endRegister(v, d[1].id)
            end
        end)
    end
end

hook.Add("ashop_load", "LoadObjectTypes", function(load_state)
    if load_state != ashop.LoadState.CreatedSQLTables then return end
    lock = true

    ashop.SQL.query('SELECT * FROM ashop_render', fetchRender)
end)