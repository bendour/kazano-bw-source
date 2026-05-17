--[[ashop.tradesList = ashop.tradesList or {}

local p, tradingWith, twoAreReady, tradeDelay
local r = ashop.Config.round
local c1R, c1G, c1B = ashop.GetColor('Grad1_0'):Unpack()
local c2R, c2G, c2B = ashop.GetColor('Grad1_1'):Unpack()
local grad = Material('akulla/gradient-d')
local clrBox = ashop.GetColor('Grad1_1')
local greenClr = ashop.GetColor('Good')
local stateOff = ashop.GetColor('StateOff')

local function applyFunctions(part, scroll, layout, boxWidth, boxHeight, rowCount, columnCount, callback)
    local emptyPanels = {}
    local panelByID = {}

    local function clearEmpty(add)
        // Clear
        local childs = layout:ChildCount()
        for k, v in ipairs(emptyPanels) do
            v:Remove()
            childs = childs - 1
        end
        emptyPanels = {}


        // Now, add
        local fillScreen = childs < (rowCount * columnCount)

        local count = (fillScreen and (rowCount * columnCount - childs) or rowCount - (childs % rowCount))

        for i = 1, count do
            local p = vgui.Create('EditablePanel', layout)
            p:SetSize(boxWidth, boxHeight)

            function p:Paint(w, h)
                draw.RoundedBox(r, 0, 0, w, h, clrBox)
            end

            table.insert(emptyPanels, p)
        end

        layout:InvalidateLayout(childs == (rowCount * columnCount + 1))
        scroll:InvalidateLayout(false)
    end

    function part:PanelIDExists(id)
        return panelByID[id]
    end

    function part:AddItem(plyItem, notClear)
        local p = vgui.Create("AShop_ShopItem", layout)
        p:SetSize(boxWidth, boxHeight)

        function p:Paint()
            p:SetItem(plyItem, plyItem.item_id)
        end

        panelByID[plyItem.id] = p

        function p:DoClick()
            callback(plyItem.id)
        end

        if !notClear then
            clearEmpty()
        end
    end

    function part:RemoveItem(item_id)
        if IsValid(panelByID[item_id]) then
            panelByID[item_id]:Remove()
            panelByID[item_id] = nil
        end

        local p = vgui.Create('EditablePanel', layout)
        p:SetSize(boxWidth, boxHeight)
        function p:Paint(w, h) draw.RoundedBox(r, 0, 0, w, h, clrBox) end
        table.insert(emptyPanels, p)
    end

    return clearEmpty
end

net.Receive('ashop_trades', function()
    local uid = net.ReadUInt(3)

    if uid == 0 then
        local e = net.ReadEntity()
        if !IsValid(e) then return end
        table.insert(ashop.tradesList, e)
    elseif uid == 1 then
        if IsValid(p) then
            p:Remove()
            tradingWith = nil
            twoAreReady = nil 
            tradeDelay = nil
        end
        // Open the menu
        local boxHeight = ashop.GetSize(140)
        local boxWidth = ashop.GetSize(120)
        local sideMargin = ashop.GetSize(64)
        local numOfItems = 8
        local pnlsMargin = ashop.GetSize(5)
        local rightPartVerticalMargin = ashop.GetSize(20)
        local numOfItemsBottomH = 2
        local numOfItemsTopH = 3
        local numofItemsH = numOfItemsBottomH + numOfItemsTopH
        local fontHeight = ashop.GetFontHeight('ashop_20_600')
        local lp = LocalPlayer()

        tradingWith = net.ReadEntity()

        p = vgui.Create('EditablePanel')
        p:SetSize(boxWidth * (numOfItems + 1) + pnlsMargin * (numOfItems) + sideMargin*2, boxHeight*numofItemsH + sideMargin*2.75 + pnlsMargin*numofItemsH + fontHeight*4)
        p:MakePopup()
        p:Center()
        p:DockPadding(sideMargin, sideMargin, sideMargin, sideMargin)

        function p:OnRemove()
            net.Start('ashop_trades')
                net.WriteUInt(3, 3)
                net.WriteEntity(tradingWith)
            net.SendToServer()
        end

        function p:Paint(w, h)
            self.boxPoly = self.boxPoly or ashop.ui.RoundedBox(r, 0, 0, w, h)

            ashop.StartStencil()
                draw.NoTexture()
                surface.SetDrawColor(c1R, c1G, c1B)
                surface.DrawPoly(self.boxPoly)
            ashop.ReplaceStencil(1)
                surface.SetDrawColor(c2R, c2G, c2B)
                surface.SetMaterial(grad)
                surface.DrawTexturedRect(0, 0, w, h)
            ashop.EndStencil()
        end

        local topPart = vgui.Create('EditablePanel', p)
        topPart:Dock(TOP)
        topPart:SetTall(boxHeight*numOfItemsTopH + pnlsMargin*numOfItemsTopH + fontHeight*4 + sideMargin*0.25)
        topPart:DockMargin(0, 0, 0, sideMargin/2)

        for i = 1, 2 do
            local part = vgui.Create('EditablePanel', topPart)
            part:Dock(i == 1 and LEFT or RIGHT)
            part:SetWide(boxWidth * numOfItems/2 + 5*(numOfItems/2-1))

            local headerPart = vgui.Create('EditablePanel', part)
            headerPart:Dock(TOP)
            headerPart:SetTall(fontHeight*1.5)
            headerPart:DockMargin(0, 0, 0, fontHeight*0.5)

            local plyName = vgui.Create('DLabel', headerPart)
            plyName:Dock(LEFT)
            plyName:SetText(i == 1 and lp:Nick() or tradingWith:Nick())
            plyName:SetFont("ashop_20_600")
            plyName:SetTextColor(color_white)

            local headerSpaceLeft = part:GetWide() - pnlsMargin
            if i == 2 then
                local close = vgui.Create('DButton', headerPart)
                close:Dock(RIGHT)
                close:SetText(ashop.L('CloseMenu'))
                close:SetFont("ashop_18")
                close:SetTextColor(color_white)
                close:DockMargin(pnlsMargin, 0, 0, 0)
                close:SetWide(close:GetContentSize() + ashop.GetSize(20))

                function close:Paint(w, h)
                    draw.RoundedBox(4, 0, 0, w, h, clrBox)
                end

                function close:DoClick()
                    p:Remove()
                end
            end

            local isReady = vgui.Create('DButton', headerPart)
            isReady:Dock(RIGHT)
            isReady:SetFont("ashop_18")
            isReady:SetText(ashop.L('Ready'))
            isReady:SetTextColor(color_white)
            isReady:SetWide(isReady:GetContentSize() + ashop.GetSize(20))
            isReady:DockMargin(pnlsMargin, 0, 0, 0)

            function isReady:DoClick()
                if i == 2 then return end

                net.Start("ashop_trades")
                    net.WriteUInt(5, 3)
                    net.WriteEntity(tradingWith)
                net.SendToServer()
            end

            function isReady:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, clrBox)
            end

            // Money Part
            local moneyContainer = vgui.Create('EditablePanel', part)
            moneyContainer:Dock(TOP)
            moneyContainer:SetTall(fontHeight*1.5)
            moneyContainer:DockMargin(0, 0, 0, fontHeight*0.5)

            for j=1, 2 do
                local premiumMoneyContainer = vgui.Create('DPanel', moneyContainer)
                premiumMoneyContainer:Dock(j==1 and RIGHT or LEFT)
                premiumMoneyContainer:SetWide(headerSpaceLeft/2)
                premiumMoneyContainer:DockPadding(rightPartVerticalMargin/2, 0, rightPartVerticalMargin/2, 0)

                surface.SetFont('ashop_18')
                local tW = surface.GetTextSize(2^32)

                surface.SetFont('ashop_icon_20')
                tW = tW + surface.GetTextSize("!")

                local premiumMoneyLogo = vgui.Create('DLabel', premiumMoneyContainer)
                premiumMoneyLogo:Dock(LEFT)
                premiumMoneyLogo:SetFont('ashop_icon_20')
                premiumMoneyLogo:SetText(j == 1 and "!" or "\"")
                premiumMoneyLogo:SetTextColor(ashop.GetColor('White25'))
                premiumMoneyLogo:SetWide(premiumMoneyLogo:GetContentSize())

                local premiumMoneyInput = vgui.Create('DTextEntry', premiumMoneyContainer)
                premiumMoneyInput:SetText('0')
                premiumMoneyInput:SetFont('ashop_18')
                premiumMoneyInput:SetTextColor(color_white)
                premiumMoneyInput:SetNumeric(true)
                premiumMoneyInput:DockMargin(rightPartVerticalMargin/2, 0, 0, 0)
                premiumMoneyInput:SetDrawLanguageID(false)
                premiumMoneyInput:SetDrawLanguageIDAtLeft(false)
                premiumMoneyInput:Dock(FILL)
                premiumMoneyInput:SetEditable(i == 1)
                premiumMoneyInput:SetCursorColor(color_white)

                function premiumMoneyContainer:Paint(w, h)
                    draw.RoundedBox(8, 0, 0, w, h, premiumMoneyInput:HasFocus() and stateOff or clrBox)
                end

                function premiumMoneyInput:Paint(w, h)
                    local panel = self

                    -- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
                    if ( panel.GetPlaceholderText && panel.GetPlaceholderColor && panel:GetPlaceholderText() && panel:GetPlaceholderText():Trim() != "" && panel:GetPlaceholderColor() && ( !panel:GetText() || panel:GetText() == "" ) ) then
                        local oldText = panel:GetText()
                        
                        local str = panel:GetPlaceholderText()
                        if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
                        str = language.GetPhrase( str )
                        
                        panel:SetText( str )
                        panel:DrawTextEntryText( panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
                        panel:SetText( oldText )
                        
                        return
                    end
                    
                    panel:DrawTextEntryText( panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
                    return false
                end

                function premiumMoneyInput:OnEnter(val)
                    val = isnumber(tonumber(val)) and tonumber(val) or 0

                    net.Start("ashop_trades")
                        net.WriteUInt(6, 3)
                        net.WriteEntity(tradingWith)
                        // Add it to the trade
                        net.WriteUInt(val, 32)
                        net.WriteBool(j == 2)
                    net.SendToServer()
                end

                function premiumMoneyInput:OnLoseFocus(val)
                    self:OnEnter(self:GetText())
                end

                part[(j == 1 and "regular" or "premium") .. "money"] = premiumMoneyInput
            end
            //

            p[(i == 1 and "left" or "right") .. "part"] = part
            part.readyButton = isReady

            local partItem = vgui.Create('DScrollPanel', part)
            partItem:Dock(FILL)
            ashop.ui.SkinScrollPanel(partItem)

            local vbar = partItem:GetVBar()
            vbar:SetWide(0)
            function vbar.btnUp:Paint() end
            function vbar.btnDown:Paint() end
            function vbar:Paint(w, h) end

            function partItem:Paint(w, h)
                if partItem:GetTall() >= partItem.pnlCanvas:GetTall() then return end

                local _, y = vbar.btnGrip:GetPos()
                local h = vbar.btnGrip:GetTall()

                DisableClipping(true)
                draw.RoundedBox(2, w, y, 2, h, stateOff)
                DisableClipping(false)
            end
    
            local partItemLayout = vgui.Create('DIconLayout', partItem)
            partItemLayout:Dock(FILL)
            partItemLayout:SetSpaceX(pnlsMargin)
            partItemLayout:SetSpaceY(pnlsMargin)
            part.layout = partItemLayout

            applyFunctions(part, partItem, partItemLayout, boxWidth, boxHeight, numOfItems/2, numOfItemsTopH, function(plyItem)
                if i == 2 then return end
                net.Start("ashop_trades")
                    net.WriteUInt(4, 3)
                    net.WriteEntity(tradingWith)
                    // Add it to the trade
                    net.WriteBool(false)
                    net.WriteUInt(plyItem, ashop.Config.BitsPlyItemID)
                net.SendToServer()
            end)()
        end

        local middlePart = vgui.Create('DLabel', topPart)
        middlePart:Dock(FILL)
        middlePart:SetFont('ashop_icon_25')
        middlePart:SetText('\'')
        middlePart:SetContentAlignment(5)
        middlePart:SetTextColor(color_white)

        local ourItems = vgui.Create('DScrollPanel', p)
        ourItems:Dock(FILL)
        ashop.ui.SkinScrollPanel(ourItems)
        ourItems:GetVBar():SetWide(4)
        p.middlePart = ourItems

        local ourItemsLayout = vgui.Create('DIconLayout', ourItems)
        ourItemsLayout:Dock(FILL)
        ourItemsLayout:SetSpaceX(pnlsMargin)
        ourItemsLayout:SetSpaceY(pnlsMargin)

        local clearEmpty = applyFunctions(p, ourItems, ourItemsLayout, boxWidth-1, boxHeight, numOfItems+1, numOfItemsBottomH, function(plyItem)
            net.Start("ashop_trades")
                net.WriteUInt(4, 3)
                net.WriteEntity(tradingWith)
                // Add it to the trade
                net.WriteBool(true)
                net.WriteUInt(plyItem, ashop.Config.BitsPlyItemID)
            net.SendToServer()
        end)

        for k, v in pairs(lp.ashop_data.items) do
            p:AddItem(v, true)
        end

        clearEmpty()
    elseif uid == 2 then
        local e = net.ReadEntity()
        table.RemoveByValue(ashop.tradesList, e)

        if tradingWith == e then
            p:Remove()
        end

        p = nil
        tradingWith = nil
        twoAreReady = nil
    elseif uid == 3 then
        local isAdd = net.ReadBool()
        local itemID = net.ReadUInt(ashop.Config.BitsPlyItemID)
        local ourSide = net.ReadBool()

        if !ourSide and !net.ReadBool() then
            tradingWith.ashop_data = tradingWith.ashop_data or {}
            tradingWith.ashop_data.items = tradingWith.ashop_data.items or {}

            local plyItem = ashop.Network.R_PlyItem()

            tradingWith.ashop_data.items[plyItem.id] = plyItem
        end

        local playerPart = p[(ourSide and "left" or "right") .. "part"]
        local plyChanging = (ourSide and LocalPlayer() or tradingWith)

        if isAdd then
            if !playerPart:PanelIDExists(id) then
                p:RemoveItem(itemID)
                playerPart:AddItem(plyChanging.ashop_data.items[itemID])
            end
        else
            playerPart:RemoveItem(itemID)
            p:AddItem(plyChanging.ashop_data.items[itemID])
        end
    elseif uid == 4 then
        if !IsValid(tradingWith) then return end
        local ent = net.ReadEntity()
        local b = net.ReadBool()
        local ourSide = LocalPlayer() == ent
        local playerPart = p[(ourSide and "left" or "right") .. "part"]
        twoAreReady = net.ReadBool()
        tradeDelay = CurTime()

        if ourSide then
            playerPart.premiummoney:SetEditable(!b)
            playerPart.regularmoney:SetEditable(!b)
        end

        if b then
            playerPart.readyButton:SetTextColor(color_black)
            function playerPart.readyButton:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, greenClr)
            end

            local c2alt = Color(c2R -30, c2G-30, c2B-30, 220)

            if ourSide then
                function p.middlePart:PaintOver(w, h)
                    draw.RoundedBox(4, 0, 0, w, h, c2alt)
                    local cur2 = CurTime()

                    for i = -h + ((cur2/2)%1) * h / 2, w + h, h / 2 do
                        draw.NoTexture()
                        surface.SetDrawColor( c1R, c1G, c1B )
                        surface.DrawTexturedRectRotated( i, h / 2, h / 4, h * 2, 40 )
                    end

                    if twoAreReady then
                        draw.SimpleText(math.max(math.ceil(5 - (cur2 - tradeDelay)), 0), "ashop_60_600", w/2, h/2, color_white, 1, 1)
                    else
                        local _, tY = draw.SimpleText("-", "ashop_icon_50", w/2, h/2, color_white, 1, 1)
                        draw.SimpleText(ashop.L('TradeReady'), "ashop_20_600", w/2, h/2 + tY, color_white, 1, 1)
                    end
                end
            end

            if twoAreReady then
                timer.Create('ashop_startTradeTimer', 5, 1, function()
                    //
                    net.Start('ashop_trades')
                        net.WriteUInt(2, 3)
                        net.WriteEntity(tradingWith)

                        for k, v in ipairs({p.leftpart, p.rightpart}) do
                            local t = {}
                            for _, itemPanel in ipairs(v.layout:GetChildren()) do
                                if !itemPanel.plyItem then break end
                                table.insert(t, itemPanel.plyItem.id)
                            end

                            net.WriteUInt(#t, 7)

                            for k, v in ipairs(t) do
                                net.WriteUInt(v, ashop.Config.BitsPlyItemID)
                            end

                            net.WriteUInt(tonumber(v.premiummoney:GetText()) or 0, 32)
                            net.WriteUInt(tonumber(v.regularmoney:GetText()) or 0, 32)
                        end
                    net.SendToServer()
                end)
            else
                timer.Remove('ashop_startTradeTimer')
            end
        else
            playerPart.readyButton:SetTextColor(color_white)

            function playerPart.readyButton:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, clrBox)
            end

            if ourSide then
                function p.middlePart:PaintOver() end
            end
            timer.Remove('ashop_startTradeTimer')
        end
    elseif uid == 5 then
        local ent = net.ReadEntity()
        local ourSide = LocalPlayer() == ent
        local playerPart = p[(ourSide and "left" or "right") .. "part"]

        local amt = net.ReadUInt(32)
        local premium = net.ReadBool()

        playerPart[(premium and "premium" or "regular") .. "money"]:SetText(amt)
    end
end)

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "ashop_removependingtrades", function( data )
	local ply = Player(data.userid)

    if IsValid(ply) then
        table.RemoveByValue(ashop.tradesList, ply)
    end

    if (IsValid(ply) and ply == tradingWith) or (tradingWith and !IsValid(tradingWith)) then
        p:Remove()
    end
end )

local function drawInterior(editor, tradingPly, _, parent)
    ashop.menu:Remove()

    net.Start('ashop_trades')
        net.WriteUInt(1, 3)
        net.WriteEntity(tradingPly)
        net.WriteBool(true)
    net.SendToServer()
end

ashop.registerUserParameter(ashop.L('TradeOffers'), drawInterior, function()
    local o = {}

    for k, v in ipairs(ashop.tradesList) do
        if !IsValid(v) then
            table.remove(ashop.tradesList, v)
            continue
        end

        local name = v:Nick()
        table.insert(o, {name, v, v})
    end

    return o
end, interior)]]--