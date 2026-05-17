local function drawInterior(editor, key, value, parent)
    local marginVertical = ashop.GetSize(20)
    local tH = draw.GetFontHeight('ashop_16')
    local stateOn = ashop.GetColor('stateOn')
    local clrSeparator = ashop.GetColor('Separator')
    local sep = ashop.GetColor('Separator', 125)
    local round = ashop.Config.round

    local txtEntryContainer = vgui.Create('DPanel', editor)
    txtEntryContainer:Dock(TOP)
    txtEntryContainer:SetTall(tH * 2)
    txtEntryContainer:DockPadding(tH*0.25, tH*0.25, tH*0.25, tH*0.25)

    function txtEntryContainer:Paint(w, h)  end

    local search = vgui.Create('DButton', txtEntryContainer)
    search:Dock(RIGHT)
    search:SetText(ashop.L('Search'))
    search:SetFont('ashop_16')
    search:SetWide(search:GetContentSize() + marginVertical)
    search:SetTextColor(ashop.GetColor('White'))
    search:DockMargin(tH*0.25, 0, 0, 0)

    function search:Paint(w, h)
        draw.RoundedBox(round/2, 0, h/4, w, h/4*2, self:IsHovered() and stateOn or clrSeparator)
    end

    local idContainer = vgui.Create('AShop_Entry', txtEntryContainer)
    idContainer:Dock(TOP)
    idContainer:SetTall(0)
    idContainer:IsRequired(true)

    function idContainer:Paint() end

    idContainer:SetInput('SteamID64', TYPE_STRING, '00000000000000000', {
        hideSave = true,
        required = true
    })

    txtEntryContainer:SizeToChildren(false, true)

    local p = vgui.Create('EditablePanel', editor)
    p:Dock(TOP)
    p:SetTall(1)

    local m = ashop.GetSize(16)

    function p:Paint(w, h)
        surface.SetDrawColor(sep)
        surface.DrawLine(m/2, 0, w - m/2, 0)
    end

    function search:DoClick()
        local value = idContainer:GetValue()

        if !isnumber(tonumber(value)) then return end

        net.Start('ashop_Admin_ReceiveInventory')
            net.WriteString(value)
        net.SendToServer()
    end

    local invDisplayer = vgui.Create('EditablePanel', editor)
    invDisplayer:Dock(FILL)
    invDisplayer:DockMargin(m/2 + tH*0.25, 0, m/2, 0)

    local marginVertical = ashop.GetSize(20)
    local itemWidth = math.floor(((editor:GetWide() - m/2 - tH*0.25 - m/2) - marginVertical*6) / 7) - 5

    hook.Add('ashop_receivedPlayerInventory', 'getPlayerInventoryUI', function(s64, inv, premiumMoney, classicMoney)
        invDisplayer:Clear()

        local topBar = vgui.Create('EditablePanel', invDisplayer)
        topBar:SetTall(ashop.GetSize(80))
        topBar:Dock(TOP)
        topBar:DockMargin(0, m/4, 0, 0)

        local name = vgui.Create('DLabel', topBar)
        name:Dock(LEFT)
        name:SetFont('ashop_16')
        name:SetTextColor(ashop.GetColor('White'))
        
        local ply = player.GetBySteamID64(s64)
        if IsValid(ply) then
            name:SetText(ashop.L('Name', ply:Nick()))
        else
            name:SetText("SteamID: " .. ply:SteamID64())
        end
        name:SetWide(name:GetContentSize())

        local rightPartVerticalMargin = ashop.GetSize(20)
        local moneyTextHorizontalMargin = ashop.GetSize(12)
        local moneyTextInnerHorizontalMargin = ashop.GetSize(10)
    
        local roundValue = ashop.Config.round

        // Left
        local panels = {}
        for k, v in ipairs({
            {
                ashop.GetColor('pink'),
                ashop.GetColor('premiumMoneyLogo'),
                premiumMoney,
                "!",
            },
    
            {
                ashop.GetColor('normalMoneyBg'),
                ashop.GetColor('normalMoney'),
                classicMoney,
                "\"",
            }
        }) do
            surface.SetFont('ashop_16')
            local tW, tH = surface.GetTextSize(v[3])
            local font = 'ashop_icon_20'
    
            surface.SetFont(font)
            local iW, iH = surface.GetTextSize(v[4])
    
            local m = vgui.Create("DButton", topBar)
            m:Dock(RIGHT)
            m:SetText('')
            m:DockMargin(rightPartVerticalMargin, rightPartVerticalMargin, 0, rightPartVerticalMargin)
            m:DockPadding(moneyTextHorizontalMargin, 0, moneyTextHorizontalMargin, 0)
            m:SetWide(tW + iW + moneyTextHorizontalMargin*2 + moneyTextInnerHorizontalMargin)
    
            function m:Paint(w, h)
                draw.RoundedBox(roundValue, 0, 0, w, h, v[1])
            end
    
            local logo = vgui.Create("DLabel", m)
            logo:Dock(LEFT)
            logo:SetFont(font)
            logo:SetText(v[4])
            logo:SetTextColor(v[2])
            logo:SetWide(iW)
    
            local text = vgui.Create("DLabel", m)
            text:Dock(FILL)
            text:SetFont('ashop_16')
            text:SetText(v[3])
            text:SetTextColor(ashop.GetColor('White'))
            text:SetContentAlignment(6)

            table.insert(panels, {m, text})

            function m:ResizeWidth()
                self:SetWide(logo:GetWide() + text:GetContentSize() + moneyTextHorizontalMargin*2 + moneyTextInnerHorizontalMargin)
            end

            function m:DoClick()
                local a = vgui.Create('AShop_Form', ashop.menu)
                a:SetTitle(ashop.L('SetPlayerMoney'))
                a:CreateEntry(true, ashop.L('MoneyToSet'), "UInt32", {
                    required = true,
                }, tonumber(text:GetText()))
                a:Center()

                function a:OnSend(m)
                    net.Start('ashop_Admin_ReceiveInventoryMoney')
                        net.WriteString(s64)
                        net.WriteUInt(m, 32)
                        net.WriteBool(k == 1)
                    net.SendToServer()
                end
            end
        end

        // Add a new item
        surface.SetFont('ashop_16')
        local tW, tH = surface.GetTextSize(ashop.L('Add'))
        local font = 'ashop_icon_20'

        surface.SetFont(font)
        local iW, iH = surface.GetTextSize('+')

        local bAdd = vgui.Create("DButton", topBar)
        bAdd:Dock(RIGHT)
        bAdd:SetText('')
        bAdd:DockMargin(rightPartVerticalMargin, rightPartVerticalMargin, 0, rightPartVerticalMargin)
        bAdd:DockPadding(moneyTextHorizontalMargin, 0, moneyTextHorizontalMargin, 0)
        bAdd:SetWide(tW + iW + moneyTextHorizontalMargin*2 + moneyTextInnerHorizontalMargin)
    
        local grad2_0 = ashop.GetColor('Grad2_0')
        function bAdd:Paint(w, h)
            draw.RoundedBox(roundValue, 0, 0, w, h, grad2_0)
        end

        function bAdd:DoClick()
            local l = {}

            for k, v in pairs(ashop.items) do
                table.insert(l, {v.name, k})
            end

            local a = vgui.Create('AShop_Form', ashop.menu)
            a:SetTitle(ashop.L('GiveItemToPlayer'))
            a:CreateEntry(true, ashop.L('ItemToGive'), "SELECT", {
                required = true,
                selects = l
            })
            a:Center()

            function a:OnSend(m)
                net.Start('ashop_Admin_ReceiveInventoryItemData')
                    net.WriteString(s64)
                    net.WriteUInt(m, ashop.Config.BitsPlyItemID)
                    net.WriteUInt(2, 3)
                net.SendToServer()
            end
        end
    
        local logo = vgui.Create("DLabel", bAdd)
        logo:Dock(LEFT)
        logo:SetFont(font)
        logo:SetText('+')
        logo:SetTextColor(color_white)
        logo:SetWide(iW)
    
        local text = vgui.Create("DLabel", bAdd)
        text:Dock(FILL)
        text:SetFont('ashop_16')
        text:SetText(ashop.L('Add'))
        text:SetTextColor(color_white)
        text:SetContentAlignment(6)

        // 

        local scroll = vgui.Create('DScrollPanel', invDisplayer)
        scroll:Dock(FILL)
        scroll:InvalidateLayout(true)
        scroll:DockMargin(0, m, 0, 0)

        ashop.ui.SkinScrollPanel(scroll)

        local iconLayout = vgui.Create('DIconLayout', scroll)
        iconLayout:Dock(FILL)
        iconLayout:SetSpaceY(marginVertical)
        iconLayout:SetSpaceX(marginVertical)

        local tPanels = {}
        local function spawnItem(item_id)
            local v = inv[item_id]
            local p = vgui.Create("AShop_ShopItem", iconLayout)
            p:SetSize(itemWidth, ashop.GetSize(189))
            p.item_id = item_id
            
            function p:Paint()
                p:SetItem(v, ashop.items[v.item_id], true)
            end

            function p:DoRightClick()
                CloseDermaMenus()
                local menu = vgui.Create( "AShop_DMenu", p )
    
                menu:AddOption( ashop.L('Duplicate'), function()
                    net.Start('ashop_Admin_ReceiveInventoryItemData')
                        net.WriteString(s64)
                        net.WriteUInt(item_id, ashop.Config.BitsPlyItemID)
                        net.WriteUInt(0, 3)
                    net.SendToServer()
                end)

                menu:AddOption( ashop.L('Remove'), function()
                    net.Start('ashop_Admin_ReceiveInventoryItemData')
                        net.WriteString(s64)
                        net.WriteUInt(item_id, ashop.Config.BitsPlyItemID)
                        net.WriteUInt(1, 3)
                    net.SendToServer()
                end)
    
                menu:Open()
            end

            tPanels[item_id] = p
        end

        for k, v in pairs(inv or {}) do
            spawnItem(k)
        end

        hook.Add("ashop_receivedPlayerInventoryItemData", "refreshUI", function(id, itemID, d)
            if id == 0 then
                inv[d] = inv[itemID]
                spawnItem(d)
            elseif id == 1 then
                if IsValid(tPanels[itemID]) then
                    tPanels[itemID]:Remove()
                    tPanels[itemID] = nil
                end
            elseif id == 2 then
                inv[d] = {
                    metadata = {},
                    item_id = itemID,
                    id = d
                }
                spawnItem(d)
            end

            iconLayout:InvalidateLayout(true)
            scroll:InvalidateLayout(true)
        end)

        hook.Add('ashop_receivedPlayerInventoryMoney', 'refreshUI', function(amt, b)
            if t and IsValid(t[2]) then return end
            local t = panels[b and 1 or 2]
            t[2]:SetText(amt)
            t[1]:ResizeWidth()
        end)
    end)
end

ashop.registerUserParameter(ashop.L('PlayerInventory'), drawInterior)