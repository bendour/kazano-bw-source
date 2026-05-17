util.AddNetworkString('ashop_trades')

ashop.trades = ashop.trades or {
    bucket = {},
    cooldown = {}
}

local bucket = ashop.trades.bucket
local cooldown = ashop.trades.cooldown

local tradeState = {
    WAITING_RESPONSE = 0,
    TRADING = 1,
    WAITING_OTHERPLY = 2
}

hook.Add("PlayerDisconnected", "ashop_removependingtrades", function(ply)
    for k, v in ipairs(ashop.trades) do
        if v.author == ply or v.target == ply2 then
            table.remove(ashop.trades, k)
        end
    end
end)

ashop.SafeNet('trades', function(ply)
    local id = net.ReadUInt(3)
    local ply2 = net.ReadEntity()

    if !IsValid(ply2) or !ply2:IsPlayer() or ply == ply2 then return end

    // Sort of hash function
    local bucketUID = (math.max(ply:UserID(), ply2:UserID())*10000) .. math.min(ply:UserID(), ply2:UserID())

    if id == 0 then
        if bucket[bucketUID] or !ply.ashop_data or !ply2.ashop_data then return end

        bucket[bucketUID] = {
            state = tradeState.WAITING_RESPONSE,
            author = ply,
            target = ply2
        }

        // Send a trade offer
        net.Start('ashop_trades')
            net.WriteUInt(0, 3)
            net.WriteEntity(ply)
        net.Send(ply2)
    elseif id == 1 then
        // Accept trade offer
        if !bucket[bucketUID] or bucket[bucketUID].target != ply then return end

        // Check if ply2 is already in a trade
        for k, v in pairs(bucket) do
            if v.state != tradeState.WAITING_RESPONSE and (v.author == ply2 or v.target == ply2) then
                // TODO: Send notify
                return
            end
        end

        net.Start('ashop_trades')
            net.WriteUInt(1, 3)
            net.WriteEntity(ply)
        net.Send(ply2)

        net.Start('ashop_trades')
            net.WriteUInt(1, 3)
            net.WriteEntity(ply2)
        net.Send(ply)

        bucket[bucketUID].state = tradeState.TRADING
    elseif id == 2 then
        if cooldown[ply] and cooldown[ply] > CurTime() + 10 then
            return
        end

        // Trade completed, check bucket
        local b = bucket[bucketUID]

        if !b or !b.startTradeTimer
            or b.startTradeTimer > CurTime()
            or !(b[ply] and b[ply2])
            or b.state == tradeState.WAITING_RESPONSE then return end

        local items = {
            {
                items = {},
            },

            {
                items = {},
            },
        }

        local order = b.target == ply
        local alreadySeen = {}

        for i = 1, net.ReadUInt(7) do
            local itemID = net.ReadUInt(ashop.Config.BitsPlyItemID)
            if alreadySeen[itemID] then return end

            items[order and 2 or 1].items[i] = itemID
            alreadySeen[itemID] = true
        end
        items[order and 2 or 1].premiumMoney = net.ReadUInt(32) or 0
        items[order and 2 or 1].money = net.ReadUInt(32) or 0

        for i = 1, net.ReadUInt(7) do
            local itemID = net.ReadUInt(ashop.Config.BitsPlyItemID)
            if alreadySeen[itemID] then return end

            items[order and 1 or 2].items[i] = itemID
            alreadySeen[itemID] = true
        end
        items[order and 1 or 2].premiumMoney = net.ReadUInt(32) or 0
        items[order and 1 or 2].money = net.ReadUInt(32) or 0

        if b.state == tradeState.WAITING_OTHERPLY then
            if (b.firstPlayerBucketBy and b.firstPlayerBucketBy == ply) then return end
            // Compare the items sent by the 2 players

            for i = 1, 2 do
                if #b.firstPlayerBucket[i].items != #items[i].items then return end
                for k, v in ipairs(b.firstPlayerBucket[i].items) do
                    if items[i].items[k] != v then return end
                    if !b[i == 1 and "author" or "target"].ashop_data.items[v] then return end
                end

                // Check Money
                if b.firstPlayerBucket[i].premiumMoney != items[i].premiumMoney then return end
                if b.firstPlayerBucket[i].money != items[i].money then return end
            end

            /*
                So far, we checked:
                    - Same money amount
                    - Same items
                    - Players still have the items
                Process the trade now
            */

            // Swap items owner
            for i = 1, 2 do
                local cleanAuthorItems, cleanAuthorRemove = {}, {}
                local losingPly = b[i == 1 and "author" or "target"]
                local winningPly = b[i != 1 and "author" or "target"]

                for k, v in ipairs(b.firstPlayerBucket[i].items) do
                    local plyItem = losingPly.ashop_data.items[v]

                    local i = table.insert(cleanAuthorItems, {
                        item_id = plyItem.item_id,
                        metadata = util.TableToJSON(plyItem.metadata),
                        price_buy = plyItem.price_buy,
                        premium_buy = plyItem.premium_buy
                    })

                    cleanAuthorRemove[i] = plyItem.id
                end

                if !table.IsEmpty(b.firstPlayerBucket[i].items) then
                    ashop.actions.BulkRemove(losingPly, cleanAuthorRemove)
                    ashop.actions.GiveBulk(winningPly, cleanAuthorItems)
                end
            end

            // Put player cooldown
            // Trading is a costly thing
            local c = CurTime()
            cooldown[ply] = c + 10
            cooldown[ply2] = c + 10
            bucket[bucketUID] = nil

            net.Start('ashop_trades')
                net.WriteUInt(2, 3)
                net.WriteEntity(ply)
            net.Send(ply2)

            net.Start('ashop_trades')
                net.WriteUInt(2, 3)
                net.WriteEntity(ply2)
            net.Send(ply)
        else
            b.firstPlayerBucket = items
            b.firstPlayerBucketBy = ply
            b.state = tradeState.WAITING_OTHERPLY
        end
    elseif id == 3 then
        if !bucket[bucketUID] then return end

        bucket[bucketUID] = nil
        net.Start('ashop_trades')
            net.WriteUInt(2, 3)
            net.WriteEntity(ply)
        net.Send(ply2)

        net.Start('ashop_trades')
            net.WriteUInt(2, 3)
            net.WriteEntity(ply2)
        net.Send(ply)
    elseif id == 4 then
        local b = bucket[bucketUID]
        if !b or b.state != tradeState.TRADING then return end
        local isAdd = net.ReadBool()
        local itemID = net.ReadUInt(ashop.Config.BitsPlyItemID)

        if !ply.ashop_data.items[itemID] or b[ply] then return end

        net.Start('ashop_trades')
            net.WriteUInt(3, 3)
            net.WriteBool(isAdd)
            net.WriteUInt(itemID, ashop.Config.BitsPlyItemID)
            net.WriteBool(true)
        net.Send(ply)

        local a, t = b.author, b.target
        local otherPly = ply == a and t or a
        net.Start('ashop_trades')
            net.WriteUInt(3, 3)
            net.WriteBool(isAdd)
            net.WriteUInt(itemID, ashop.Config.BitsPlyItemID)
            net.WriteBool(false)

            ashop.knownItems.plys[otherPly].plyitem = ashop.knownItems.plys[otherPly].plyitem or {}
            local knowTheItem = ashop.knownItems.plys[otherPly].plyitem[itemID]

            net.WriteBool(knowTheItem)
            if !knowTheItem then
                ashop.Network.W_PlyItem(ply.ashop_data.items[itemID])
                ashop.knownSetState(otherPly, 'plyitem', true, itemID)
            end
        net.Send(otherPly)
    elseif id == 5 then
        local b = bucket[bucketUID]
        if !b or b.state == tradeState.WAITING_RESPONSE then return end

        b[ply] = !b[ply]

        if b[ply] and b[ply2] then
            b.startTradeTimer = CurTime() + 4
        else
            b.startTradeTimer = nil
            b.firstPlayerBucket = nil
            b.state = tradeState.TRADING
            b.firstPlayerBucketBy = nil
        end

        net.Start('ashop_trades')
            net.WriteUInt(4, 3)
            net.WriteEntity(ply)
            net.WriteBool(b[ply])
            net.WriteBool(b[ply] and b[ply2])
        net.Send({ply, ply2})
    elseif id == 6 then
        local b = bucket[bucketUID]
        if !b or b.state != tradeState.TRADING or b[ply] then return end

        local amt = net.ReadUInt(32)
        local is_premium = net.ReadBool()

        if !ply:ashopMoneyAfford(amt, is_premium) then
            net.Start('ashop_trades')
                net.WriteUInt(5, 3)
                net.WriteEntity(ply)
                net.WriteUInt(ply:ashopMoneyGet(is_premium), 32)
                net.WriteBool(is_premium)
            net.Send({ply, ply2})
        else
            net.Start('ashop_trades')
                net.WriteUInt(5, 3)
                net.WriteEntity(ply)
                net.WriteUInt(amt, 32)
                net.WriteBool(is_premium)
            net.Send({ply, ply2})
        end
    end
end, 0.5)

//
ashop.SafeNet('Currency_Edit', function(ply)
    local act = net.ReadUInt(3)
    local id = net.ReadUInt(10)

    local value, sqlColumn, sqlValue, writeFunc

    if act == 0 then
        value = net.ReadString()

        assert(string.len(value) <= 24, "Name too long")
        sqlColumn = 'currencyName'
        writeFunc = net.WriteString
    elseif act == 1 then
        value = net.ReadBool()
        sqlColumn = 'toCoins'
        sqlValue = value and 1 or 0
        writeFunc = net.WriteBool
    elseif act == 2 then
        //value = net.ReadFloat()
        value = tonumber(net.ReadString())
        sqlColumn = 'convertRate'
        //writeFunc = net.WriteFloat
        writeFunc = net.WriteString
    elseif act == 3 then
        value = net.ReadBool()
        sqlColumn = 'toPremium'
        sqlValue = value and 1 or 0
        writeFunc = net.WriteBool
    end

    if sqlValue == nil then sqlValue = value end

    ashop.currencies.trades[id][sqlColumn] = value

    ashop.SQL.query("UPDATE ashop_currenciesTrades SET " .. sqlColumn .. " = " .. ashop.SQL.escape(sqlValue) .. " WHERE id = " .. id)
    net.Start('ashop_Currency_Edit')
        net.WriteUInt(id, 10)
        net.WriteUInt(act, 3)
        writeFunc(value)
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.Currency_Update, ply, ashop.currencies.trades[id].currencyName)
end, 0.5, true)