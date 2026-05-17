//ashop.registerUserParameter
local normalColor = ashop.GetColor('Grad1_1')
local white = ashop.GetColor('White')
local sOn = ashop.GetColor('StateOn')
local w50 = ashop.GetColor('White25')

local function drawInterior(editor, key, value, parent)
    local buttonH = ashop.GetSize(50)
    local marginVertical = ashop.GetSize(20)

    local p = vgui.Create('EditablePanel', editor)
    p:SetSize(ashop.GetSize(350), buttonH*3 + marginVertical*2)

    local exchangeType = vgui.Create('EditablePanel', p)
    exchangeType:Dock(TOP)
    exchangeType:SetTall(buttonH)

    local lbl = vgui.Create('DLabel', exchangeType)
    lbl:Dock(FILL)
    lbl:SetFont('ashop_16')
    lbl:DockMargin(marginVertical/2, 0, 0, 0)
    lbl:SetTextColor(white)
    lbl:SetText(parent:GetText())

    local firstCurrency = value.currencyName
    local secondCurrency = value.toPremium and ashop.L('ACoinsPremium') or ashop.L('ACoinsClassic')

    if !value.toCoins then
        local temp = secondCurrency
        secondCurrency = firstCurrency
        firstCurrency = temp
    end
    
    function exchangeType:Paint(w, h)
        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, normalColor)
        DisableClipping(true)
        draw.SimpleText(ashop.L('ExchangeType'), "ashop_14", marginVertical/2, 0, w50, 0, 1)
        DisableClipping(false)
    end

    local amounts = vgui.Create('EditablePanel', p)
    amounts:Dock(TOP)
    amounts:SetTall(buttonH)
    amounts:DockMargin(0, marginVertical, 0, marginVertical)

    local tradeTo = vgui.Create('EditablePanel', amounts)
    tradeTo:Dock(RIGHT)
    tradeTo:SetTall(buttonH)
    tradeTo:SetWide(p:GetWide()/5*2)

    local tradeToAmount = vgui.Create('DLabel', tradeTo)
    tradeToAmount:Dock(FILL)
    tradeToAmount:SetFont('ashop_16')
    tradeToAmount:DockMargin(marginVertical/2, 0, 0, 0)
    tradeToAmount:SetTextColor(white)
    tradeToAmount:SetText(0)
    
    function tradeTo:Paint(w, h)
        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, normalColor)
        DisableClipping(true)
        draw.SimpleText(secondCurrency, "ashop_14", marginVertical/2, 0, w50, 0, 1)
        DisableClipping(false)
    end

    local tradeFrom = vgui.Create('EditablePanel', amounts)
    tradeFrom:Dock(LEFT)
    tradeFrom:SetTall(buttonH)
    tradeFrom:SetWide(p:GetWide()/5*2)

    local tradeFromAmount = vgui.Create('DTextEntry', tradeFrom)
    tradeFromAmount:Dock(FILL)
    tradeFromAmount:SetFont('ashop_16')
    tradeFromAmount:DockMargin(marginVertical/2, 0, 0, 0)
    tradeFromAmount:SetTextColor(white)
    tradeFromAmount:SetText(0)
    tradeFromAmount:SetNumeric(true)
    tradeFromAmount:SetPaintBackground(false)
    tradeFromAmount:SetDrawLanguageID(false)
    tradeFromAmount:SetDrawLanguageIDAtLeft(false)

    function tradeFromAmount:OnChange()
        local n = tonumber(tradeFromAmount:GetText())

        if n then
            tradeToAmount:SetText(n * value.convertRate)
        end
    end
    
    function tradeFrom:Paint(w, h)
        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, normalColor)
        DisableClipping(true)
        draw.SimpleText(firstCurrency, "ashop_14", marginVertical/2, 0, w50, 0, 1)
        DisableClipping(false)
    end

    local tradeIcon = vgui.Create('DLabel', amounts)
    tradeIcon:Dock(FILL)
    tradeIcon:SetFont('ashop_icon_20')
    tradeIcon:SetText('\'')
    tradeIcon:SetTextColor(white)
    tradeIcon:SetContentAlignment(5)

    local trade = vgui.Create('DButton', p)
    trade:Dock(TOP)
    trade:SetTall(buttonH)
    trade:SetFont('ashop_18')
    trade:SetTextColor(white)
    trade:SetText(ashop.L('Trade'))

    function trade:Paint(w, h)
        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, sOn)
    end

    local lp = LocalPlayer()
    function trade:DoClick()
        local amt = tonumber(tradeFromAmount:GetText())

        if !amt or amt <= 0 or amt > 2^32 or amt * value.convertRate > 2^32 then return end

        local currency = ashop.currencies.list[value.currencyName]

        if value.toCoins then
            if currency.getMoney(lp) < amt then
                ashop.DermaNotify(ashop.L('NotEnoughMoney'), NOTIFY_ERROR, 3)
                return
            end
        elseif !lp:ashopMoneyAfford(amt, isPremium) then
            ashop.DermaNotify(ashop.L('NotEnoughMoney'), NOTIFY_ERROR, 3)
            return
        end

        net.Start('ashop_ExecuteTrade')
            net.WriteUInt(key, 10)
            net.WriteUInt(amt, 32)
        net.SendToServer()
    end

    p:Center()
end

ashop.registerUserParameter(ashop.L('Currencies'), drawInterior, function()
    local o = {}

    for k, v in pairs(ashop.currencies.trades) do
        // Changer le nom
        local name
        local currencyName = v.currencyName

        if v.toCoins then
            name = currencyName .. " > " .. "Coins"
        else
            name = "Coins" .. " > " .. currencyName
        end

        table.insert(o, {name, k, v})
    end

    return o
end, interior)