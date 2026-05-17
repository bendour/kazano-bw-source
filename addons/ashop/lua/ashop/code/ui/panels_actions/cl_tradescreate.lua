--[[ashop.tradesList = ashop.tradesList or {}

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "ashop_removependingtrades", function( data )
	local ply = Player(data.userid)

    if IsValid(ply) then
        table.RemoveByValue(ashop.tradesList, ply)
    end
end )

local function drawInterior(editor, tradingPly, _, parent)
    ashop.ui.popAskbox(ashop.L('SendTradeInvitation', tradingPly:Nick()), ashop.L('NeedsToAcceptAfterward'), function()
        net.Start('ashop_trades')
            net.WriteUInt(0, 3)
            net.WriteEntity(tradingPly)
        net.SendToServer()

        ashop.DermaNotify(ashop.L('TradeSent', tradingPly:Nick()), NOTIFY_HINT, 5)
    end)
end

ashop.registerUserParameter(ashop.L('TradeCreate'), drawInterior, function()
    local o = {}
    local t = {}

    for k, v in ipairs(ashop.tradesList) do
        if !IsValid(v) then
            table.remove(ashop.tradesList, v)
            continue
        end

        t[v] = true
    end

    local lply = LocalPlayer()
    for k, v in ipairs(player.GetHumans()) do
        if t[v] or v == lply then continue end
        local name = v:Nick()
        table.insert(o, {name, v, v})
    end

    return o
end, interior)]]--