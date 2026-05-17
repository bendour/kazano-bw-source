local function DrawInterior(editor, key, value, parent)
    local selects = {}

    for k, v in pairs(ashop.currencies.list) do
        table.insert(selects, {k, k})
    end

    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)

    local currencyType = vgui.Create('AShop_Entry', scroll)
    currencyType:Dock(TOP)
    currencyType:SetTall(0)
    currencyType:IsRequired(true)
    currencyType:SetInput(ashop.L('CurrencyType'), 'SELECT', value.currencyName, {selects = selects, required = true})
    currencyType.boxcolor = ashop.GetColor('Grad2_0')
    currencyType:AddSeparator()

    local toCoins = vgui.Create('AShop_Entry', scroll)
    toCoins:Dock(TOP)
    toCoins:SetTall(0)
    toCoins:IsRequired(true)
    toCoins:SetInput(ashop.L('OrderCurrencyCoins'), TYPE_BOOL, value.toCoins, {
        required = true
    })
    toCoins.boxcolor = ashop.GetColor('Grad2_0')
    toCoins:AddSeparator()

    local rate = vgui.Create('AShop_Entry', scroll)
    rate:Dock(TOP)
    rate:SetTall(0)
    rate:IsRequired(true)
    rate:SetInput(ashop.L('RatioCurrency'), "FLOAT", value.convertRate, {
        required = true
    })
    rate.boxcolor = ashop.GetColor('Grad2_0')
    rate:AddSeparator()

    local isPremium = vgui.Create('AShop_Entry', scroll)
    isPremium:Dock(TOP)
    isPremium:SetTall(0)
    isPremium:IsRequired(true)
    isPremium:SetInput(ashop.L('IsPremiumCoins'), TYPE_BOOL, value.toPremium, {
        required = true
    })
    isPremium.boxcolor = ashop.GetColor('Grad2_0')
    isPremium:AddSeparator()

    for k, v in ipairs({currencyType, toCoins, rate, isPremium}) do
        function v:OnSave(value)
            net.Start('ashop_Currency_Edit')
                net.WriteUInt(k-1, 3)
                net.WriteUInt(key, 10)

                if k == 3 then
                    // Not my fault
                    // For some reasons, gmod have issues with sending floats
                    net.WriteString(value)
                    //net.WriteFloat(value)
                elseif k == 1 then
                    net.WriteString(value)
                else
                    net.WriteBool(value)
                end
            net.SendToServer()
        end
    end
end

ashop.registerParameter(ashop.L('Currencies'), DrawInterior, function()
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
end, function()
    local selects = {}

    for k, v in pairs(ashop.currencies.list) do
        table.insert(selects, {k, k})
    end
    
    // Changer le nom
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateNewCurrencyType'))
    a:CreateEntry(true, ashop.L('CurrencyType'), 'SELECT', {selects = selects})
    a:CreateEntry(true, ashop.L('OrderCurrencyCoins'), TYPE_BOOL)
    a:CreateEntry(true, ashop.L('RatioCurrency'), "FLOAT")
    a:CreateEntry(true, ashop.L('IsPremiumCoins'), TYPE_BOOL)

    function a:OnSend(currencyName, toCoins, rate, premium_coins)
        net.Start('ashop_Currency_New')
            net.WriteString(currencyName)
            net.WriteBool(toCoins)
            //net.WriteFloat(rate or 1)
            net.WriteString(rate or 1)
            net.WriteBool(premium_coins)
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget)
    function but:DoRightClick()
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )
        menu:AddOption(ashop.L('Remove'), function()
            ashop.ui.popAskbox(ashop.L('SureToDeleteTrade'), "", function()
                net.Start('ashop_Currency_Delete')
                    net.WriteUInt(objectTarget.id, 8)
                net.SendToServer()
            end)
        end)

        menu:Open()
    end
end)