local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
end

local i_maxPerRow = 6

function PANEL:RemoveOwned(itemTbl)
    for k, v in ipairs(self.owned:GetChildren()) do
        if v.plyItem.id == itemTbl.id then
            v:Remove()
            break
        end
    end
end

function PANEL:AddOwned(plyItemTable, itemID)
    local lp = LocalPlayer()
    local marginVertical = ashop.GetSize(20)
    local mIcons = ashop.GetSize(10)
    if self.buyableText:GetTall() == 0 then
        self.buyableText:SetTall(select(2, self.buyableText:GetContentSize()))
        self.buyableText:DockMargin(0, marginVertical, 0, marginVertical/2)
    end

    local itemTable = ashop.items[plyItemTable.item_id]
    assert(itemTable, "ItemTable is not valid: " .. plyItemTable.item_id)
    if !self:GetRenderTable().cat[itemTable.object_types] then return end
    local object_type = ashop.object_types[itemTable.object_types]

    local p = vgui.Create("AShop_ShopItem", self.owned)
    p:SetSize(self.itemWidth, ashop.GetSize(189) - ashop.GetFontHeight('ashop_icon_25'))
    p.RealSizeW = p:GetWide()
    p.RealSizeH = p:GetTall()
    p.RealParent = self.owned
    p.HoldItemObjectType = itemTable.object_types
    p.HoldItemSubObjectType = itemTable.sub_types or 0

    local displayer = self.displayer

    function p:Paint()
        self:SetItem(plyItemTable, plyItemTable.item_id, false)
    end

    p.DoClick = function()
        displayer:EquipItem(itemID)

        // Force refresh
        p.isEquipped = true
        self:RefreshEquipped(itemTable.object_types, itemTable.sub_types)
    end

    function p:IsEquippedCheck()
        local eq = displayer.Entity.ashop_data.equipped[itemTable.object_types]
        if !eq then return false end
        if !eq[itemTable.sub_types or 0] then return false end

        for key, v in pairs(eq[itemTable.sub_types or 0]) do
            if v == itemID then
                return true
            end
        end

        return false
    end

    p.isEquipped = p:IsEquippedCheck()

    local s = self

    local function equipIfNeeded(p)
        if !displayer.Entity.ashop_data or !displayer.Entity.ashop_data.equipped or
            !displayer.Entity.ashop_data.equipped[itemTable.object_types] or
            !displayer.Entity.ashop_data.equipped[itemTable.object_types][itemTable.sub_types or 0] then
            displayer:EquipItem(itemID)
        else
            local isEquipped = p:IsEquippedCheck()

            if !isEquipped then
                displayer:EquipItem(itemID)
            end

            p.isEquipped = true

            // Refresh painting
            s:RefreshEquipped(itemTable.object_types)
        end
    end

    p.DoRightClick = function()
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", p )

        if object_type.SlotDefault then
            local tbl, c = lp:AShop_SlotStateGet(itemTable.object_types, itemTable.sub_types)
            local isAlreadyEquipped, slot = false

            for k, v in pairs(tbl) do
                if v == itemID then
                    isAlreadyEquipped = true
                    slot = k
                    break
                end
            end

            if isAlreadyEquipped then
                menu:AddOption( ashop.L('Unequip'), function()
                    net.Start('ashop_PlayerEquippedItem')
                        net.WriteUInt(plyItemTable.id, ashop.Config.BitsPlyItemID)
                        net.WriteBool(true)
                        net.WriteUInt(slot, math.ceil(math.log(c, 2)))
                    net.SendToServer()

                    // Force refresh
                    p.isEquipped = false
                    ashop.EquipChange(displayer.Entity, itemID, slot, true)
                    s:RefreshEquipped(itemTable.object_types)
                end)
            else
                menu:AddOption( ashop.L('Equip'), function()
                    if itemTable.group_restrained and ashop.groupranks[itemTable.group_restrained] and !ashop.groupranks[itemTable.group_restrained].ranks[lp:GetUserGroup()] then
                        ashop.DermaNotify(ashop.L('WrongEquipRank'), NOTIFY_ERROR, 5)
                        return
                    end

                    local tbl2, count = displayer.Entity:AShop_SlotStateGet(itemTable.object_types, itemTable.sub_types)

                    if count <= 1 then
                        net.Start('ashop_PlayerEquippedItem')
                            net.WriteUInt(plyItemTable.id, ashop.Config.BitsPlyItemID)
                            net.WriteBool(false)
                        net.SendToServer()

                        local b = true
                        for k, v in pairs(tbl2) do
                            if v == itemID then
                                b = false
                                break
                            end
                        end
    
                        if b then
                            displayer:EquipItem(itemID)
                            p.isEquipped = true
                            s:RefreshEquipped(itemTable.object_types)
                        end

                        return
                    end

                    local w = math.min(count, i_maxPerRow)
                    local h = 1

                    if count > i_maxPerRow then
                        h = math.ceil(count / i_maxPerRow)
                    end

                    local clampedH = math.min(h, 4)

                    local selectSlot = vgui.Create('DPanel', ashop.menu)
                    selectSlot:SetSize(
                        w * p:GetWide() +
                        (mIcons * (w - 1)) + mIcons * 2,
                        
                        clampedH * p:GetTall() +
                        (mIcons * (clampedH - 1)) + mIcons * 2)
                    selectSlot:Center()

                    function selectSlot:Paint(w, h)
                        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, ashop.GetColor('Grad2_0'))
                    end

                    local scroll = vgui.Create('DScrollPanel', selectSlot)
                    scroll:Dock(FILL)
                    scroll:DockMargin(mIcons, mIcons, mIcons, mIcons)

                    ashop.menu:PushFocus(selectSlot)
                    local iconList = vgui.Create('DIconLayout', scroll)
                    iconList:Dock(FILL)
                    iconList:SetSpaceX(mIcons/2, mIcons/2, mIcons/2, mIcons/2)
                    iconList:SetSpaceY(mIcons/2, mIcons/2, mIcons/2, mIcons/2)

                    local b = false
                    local c1 = ashop.GetColor('Grad1_0')
                    local c11 = ashop.GetColor('Grad2_0')

                    for a = 0, h-1 do
                        for b = 0, w-1 do
                            if a * i_maxPerRow + b + 1 > count then
                                b = true
                                break
                            end

                            local button = vgui.Create('DButton', iconList)
                            button:SetTextColor(c11)
                            button:SetText(a * i_maxPerRow + b + 1)
                            button:SetSize(p:GetSize())
                            button:SetFont('ashop_60_600')

                            function button:Paint(w, h)
                                draw.RoundedBox(ashop.Config.round, 0, 0, w, h, c1)
                            end

                            function button:OnCursorEntered() self:SetTextColor(color_white) end
                            function button:OnCursorExited() self:SetTextColor(c11) end

                            if tbl2[a * i_maxPerRow + b + 1] then
                                local p = vgui.Create("AShop_ShopItem", button)
                                p:SetSize(button:GetSize())
                                p.RealSizeW = p:GetWide()
                                p.RealSizeH = p:GetTall()

                                function p:Paint()
                                    self:SetItem(displayer.Entity.ashop_data.items[tbl2[a * i_maxPerRow + b + 1]],
                                                displayer.Entity.ashop_data.items[tbl2[a * i_maxPerRow + b + 1]].item_id, false)
                                end

                                p:SetMouseInputEnabled(false)
                            end

                            function button:DoClick()
                                ashop.menu:PopFocus()
                                selectSlot:Remove()

                                net.Start('ashop_PlayerEquippedItem')
                                    net.WriteUInt(plyItemTable.id, ashop.Config.BitsPlyItemID)
                                    net.WriteBool(true)
                                    net.WriteUInt(a*i_maxPerRow + b + 1, math.ceil(math.log(count, 2)))
                                net.SendToServer()

                                displayer:EquipItem(itemID, a * i_maxPerRow + b + 1)
                                p.isEquipped = true
                                s:RefreshEquipped(itemTable.object_types)
                            end
                        end

                        if b then break end
                    end
                end)
            end
        elseif !object_type.HideOnUse then
            menu:AddOption( ashop.L('Use'), function()
                net.Start('ashop_PlayerEquippedItem')
                    net.WriteUInt(plyItemTable.id, ashop.Config.BitsPlyItemID)
                    net.WriteBool(false)
                net.SendToServer()
            end)
        end

        for itemParamID, itemParamTable in pairs(object_type.ItemParameters) do
            if !itemParamTable.userEditable then continue end

            menu:AddOption(itemParamTable.name, function()
                equipIfNeeded(p)
                displayer:CreateUserEntry(plyItemTable, itemParamTable, itemParamID)
            end)
        end

        for k, v in pairs(object_type.ExtraMenuOptions or {}) do
            menu:AddOption(k, function()
                v(plyItemTable, itemTable, displayer, p)
            end)
        end

        if ashop.Config.SellPrice and ashop.Config.SellPrice > 0 and ashop.Config.SellPrice <= 1 then
            menu:AddOption(ashop.L("SellThisItemFor", plyItemTable.price_buy * ashop.Config.SellPrice) .. " " .. ashop.L(plyItemTable.premium_buy and "ACoinsPremium" or "ACoinsClassic"), function()
                ashop.ui.popAskbox(ashop.L("AreYouSureToSellThis"), ashop.L('ThisItemCost', plyItemTable.price_buy), function()
                    net.Start('ashop_SellOwnItem')
                        net.WriteUInt(plyItemTable.id, ashop.Config.BitsPlyItemID)
                    net.SendToServer()
                end)
            end)
        end

        menu:Open()
    end

    local rarity = ashop.rarity[itemTable.rarity]
    local catFilter = itemTable.sub_types and ashop.object_types[itemTable.object_types].sub_cat[itemTable.sub_types].name or ashop.object_types[itemTable.object_types].Name
    self.filteredItems.cat[catFilter] = self.filteredItems.cat[catFilter] or {}
    table.insert(self.filteredItems.cat[catFilter], p)

    self.filteredItems.rarity[rarity.name] = self.filteredItems.rarity[rarity.name] or {}
    table.insert(self.filteredItems.rarity[rarity.name], p)

    table.insert(self.filteredItems.itemWithPanel, {p, itemTable})
end

function PANEL:RefreshEquipped(object_type, subType)
    for _, pnl in pairs({self.owned, self.buyableItems}) do
        for k, child in ipairs(pnl:GetChildren()) do
            // Same object_type, and was equipped at some point
            if child.HoldItemObjectType == object_type then
                child.isEquipped = child:IsEquippedCheck()
            end
        end
    end
end

function PANEL:GetRenderTable()
    return ashop.render[self.renderID]
end

// rarityFilter
// textFilter
// filterCategories
function PANEL:ApplyFilter()
    local marginVertical = ashop.GetSize(20)
    local filter = self.textFilter

    local toParent = {}
    for k, v in ipairs(self.filteredItems.itemWithPanel) do
        if !IsValid(v[1]) then continue end

        local item = v[2]
        local b = filter == "" or string.find(string.lower(v[2].name), filter)
        
        if b then
            local catFilter = item.sub_types and ashop.object_types[item.object_types].sub_cat[item.sub_types].name or ashop.object_types[item.object_types].Name
            b = table.IsEmpty(self.filterCategories) or self.filterCategories[catFilter]

            if b then
                b = table.IsEmpty(self.rarityFilter) or self.rarityFilter[ashop.rarity[item.rarity].name]

                if b and !table.IsEmpty(self.othersFilter) then
                    if self.othersFilter['onlypromo'] and !(item.promotion_start and item.promotion_end and item.promotion_amount and
                        item.promotion_start < os.time() and os.time() - 20 < item.promotion_end and item.promotion_amount > 0) then
                        b = false
                    end
                end
            end
        end

        // Reset the parent anyway, to have the last, same order
        v[1]:SetParent(nil)
        v[1]:SetTall(b and v[1].RealSizeH or 0)
        v[1]:SetWide(b and v[1].RealSizeW or 0)

        if b then
            table.insert(toParent, v)
        end
    end

    if self.sort then
        table.sort(toParent, self.sort)
    end

    for k, v in ipairs(toParent) do
        v[1]:SetParent(v[1].RealParent)
    end

    self.buyableItems:Layout()
    self.owned:Layout()
    self.buyableItems:InvalidateLayout(true)
    self.owned:InvalidateLayout(true)
    self.itemList:InvalidateLayout(true)

    self.buyableItems:SizeToContentsY()
    self.owned:SizeToContentsY()

    if self.buyableItems:GetTall() == 0 then
        self.buyableText:SetTall(0)
        self.buyableText:DockMargin(0, 0, 0, 0)
    elseif self.owned:GetTall() == 0 then
        self.buyableText:DockMargin(0, 0, 0, marginVertical/2)
    else
        self.buyableText:SetTall(select(2, self.buyableText:GetContentSize()))
        self.buyableText:DockMargin(0, marginVertical, 0, marginVertical/2)
    end
end

local stateOff = ashop.GetColor('StateOff')
local white = ashop.GetColor('White')

function PANEL:Fill(renderID)
    local horizontalMargin = ashop.GetSize(64)
    local sW = ashop.GetSize(1536) - ashop.GetSize(64)*2 - ashop.Config.round*2
    local marginVertical = ashop.GetSize(20)
    local ply = LocalPlayer()
    self.renderID = renderID
    self:Clear()

    // Filter Init
    local filter = vgui.Create("DScrollPanel", self)
    filter:Dock(LEFT)
    filter:SetWide(ashop.GetSize(155))
    filter:DockMargin(0, 0, horizontalMargin, 0)
    ashop.ui.SkinScrollPanel(filter)

    local vbar = filter:GetVBar()
    vbar:SetWide(0)
    function vbar.btnUp:Paint() end
    function vbar.btnDown:Paint() end
    function vbar:Paint(w, h) end

    function filter:Paint(w, h)
        if self:GetTall() >= self.pnlCanvas:GetTall() then return end

        local _, y = vbar.btnGrip:GetPos()
        local h = vbar.btnGrip:GetTall()

        DisableClipping(true)
        draw.RoundedBox(2, w+20, y, 2, h, stateOff)
        DisableClipping(false)
    end
    
    local filteredItems = {
        cat = {},
        rarity = {},
        priceMin = math.huge,
        priceMax = -math.huge,
        pricePremiumMin = math.huge,
        pricePremiumMax = -math.huge,

        itemWithPanel = {},
    }
    self.filteredItems = filteredItems

    // Displayer
    local displayer = vgui.Create( "AShop_DModelPanel", self )
    displayer:Dock(RIGHT)
    displayer:SetWide(ashop.GetSize(369))
    displayer:DockMargin(horizontalMargin, 0, 0, 0)
    displayer:SetLookAt( Vector( 0, 0, 0 ) )
    displayer:SetModel(ply:GetModel())
    displayer:EquipWeapon()
    displayer:DoClick()
    displayer:SetFOV( 45 )
    displayer.Entity:SetSequence("idle_passive")
    function displayer:LayoutEntity( ent ) end
    displayer:BoneFocus('ValveBiped.Bip01_Spine2')
    self.displayer = displayer

    local itemList = vgui.Create("DScrollPanel", self)
    itemList:Dock(FILL)
    ashop.ui.SkinScrollPanel(itemList, stateOff)
    self.itemList = itemList

    local owned = vgui.Create("DIconLayout", itemList)
    owned:Dock(TOP)
    owned:SetSpaceY(marginVertical)
    owned:SetSpaceX(marginVertical)
    self.owned = owned

    local buyableText = vgui.Create("DLabel", itemList)
    buyableText:Dock(TOP)
    buyableText:SetFont("ashop_18")
    buyableText:SetText(ashop.L('Buyable'))
    buyableText:SetTextColor(white)
    buyableText:SetTall(select(2, buyableText:GetContentSize()))
    buyableText:DockMargin(0, marginVertical, 0, marginVertical/2)
    self.buyableText = buyableText

    local buyable = vgui.Create("DIconLayout", itemList)
    buyable:Dock(TOP)
    buyable:SetSpaceY(marginVertical)
    buyable:SetSpaceX(marginVertical)
    self.buyableItems = buyable

    local itemListWidth = sW - displayer:GetWide() - horizontalMargin * 2 - filter:GetWide()
    self.itemWidth = math.floor((itemListWidth - marginVertical*4) / 5)

    for k, v in pairs((ply.ashop_data or {}).items or {}) do
        self:AddOwned(v, k)
    end
    owned:SizeToContentsY()

    hook.Add('Ashop_PlayerNewItem', 'RefreshUI', function(k, v)
        if IsValid(self) then
            self:AddOwned(v, k)
            self:ApplyFilter()
        end
    end)

    hook.Add('Ashop_PlayerRemoveItem', 'RefreshUI', function(k, v)
        if IsValid(self) then
            self:RemoveOwned(v, k)
            self:ApplyFilter()
        end
    end)

    for k, v in pairs(ashop.items) do
        if !self:GetRenderTable().cat[v.object_types] then continue end
        if !v.price and !v.premium_price then continue end

        // Derma
        local p = vgui.Create("AShop_ShopItem", buyable)
        p:SetSize(self.itemWidth, ashop.GetSize(189))

        function p:Paint()
            self:SetItem(nil, k, true)
        end

        p.RealSizeW = p:GetWide()
        p.RealSizeH = p:GetTall()
        p.RealParent = buyable
        p.HoldItemObjectType = v.object_types
        p.HoldItemSubObjectType = v.sub_types or 0

        // Filter
        local rarity = ashop.rarity[v.rarity]
        local catFilter = v.sub_types and ashop.object_types[v.object_types].sub_cat[v.sub_types].name or ashop.object_types[v.object_types].Name
        filteredItems.cat[catFilter] = filteredItems.cat[catFilter] or {}
        table.insert(filteredItems.cat[catFilter], p)

        filteredItems.rarity[rarity.name] = filteredItems.rarity[rarity.name] or {}
        table.insert(filteredItems.rarity[rarity.name], p)

        if v.premium_price then
            filteredItems.pricePremiumMax = math.max(filteredItems.pricePremiumMax, v.premium_price)
            filteredItems.pricePremiumMin = math.min(filteredItems.pricePremiumMin, v.premium_price)
        end

        if v.price then
            filteredItems.priceMax = math.max(filteredItems.priceMax, v.price)
            filteredItems.priceMin = math.min(filteredItems.priceMin, v.price)
        end

        table.insert(filteredItems.itemWithPanel, {p, v})

        function p:IsEquippedCheck()
            if !self.temporaryItemID then return end

            local data = IsValid(displayer.Entity) and displayer.Entity or ply
            if !data.ashop_data.equipped[v.object_types] or !data.ashop_data.equipped[v.object_types][v.sub_types or 0] then return false end

            for key, v in ipairs(data.ashop_data.equipped[v.object_types][v.sub_types or 0] or {}) do
                if data.ashop_data.items[v].item_id == k then
                    return true
                end
            end

            return false
        end

        p.DoClick = function()
            if !p.temporaryItemID then
                p.temporaryItemID = displayer:EquipItem(nil, nil, k)
            else
                displayer:EquipItem(p.temporaryItemID)
            end

            p.isEquipped = true
            self:RefreshEquipped(v.object_types, v.sub_types or 0)
        end

        p.DoRightClick = function()
            // ashop.ui.popAskbox(title, desc, onValid, onCancel)
            CloseDermaMenus()
            local menu = vgui.Create( "AShop_DMenu", p )

            if !v.group_restrained or !ashop.groupranks[v.group_restrained] or ashop.groupranks[v.group_restrained].ranks[ply:GetUserGroup()] then
                local mult = (1 - (ashop.rankpromo[ply:GetUserGroup()] or 0) / 100)
                if v.premium_price then
                    menu:AddOption(ashop.L('BuyWithPremiumMoney'), function()
                        if ply:ashopMoneyAfford(v.premium_price * mult, true) then
                            ashop.ui.popAskbox(ashop.L('BuyFormat', v.name), ashop.L('ThisItemCost', p.price[2]), function()
                                net.Start('ashop_buy')
                                    net.WriteUInt(k, ashop.Config.BitsItemID)
                                    net.WriteBool(true)
                                net.SendToServer()
                            end)
                        else
                            ashop.DermaNotify(ashop.L('YouCantAfford'), NOTIFY_ERROR, 5)
                        end
                    end)
                end
    
                if v.price then
                    menu:AddOption(ashop.L('BuyWithClassicMoney'), function()
                        if ply:ashopMoneyAfford(v.price * mult, false) then
                            ashop.ui.popAskbox(ashop.L('BuyFormat', v.name), ashop.L('ThisItemCost', p.price[1]), function()
                                net.Start('ashop_buy')
                                    net.WriteUInt(k, ashop.Config.BitsItemID)
                                    net.WriteBool(false)
                                net.SendToServer()
                            end)
                        else
                            ashop.DermaNotify(ashop.L('YouCantAfford'), NOTIFY_ERROR, 5)
                        end
                    end)
                end
    
                for k, extraOption in pairs(ashop.object_types[v.object_types].ExtraMenuOptions or {}) do
                    menu:AddOption(k, function()
                        extraOption(nil, v, displayer, p)
                    end)
                end
    
                menu:Open()
            end
        end


        p.isEquipped = false
    end

    if (#buyable:GetChildren()) == 0 then
        buyableText:SetTall(0)
        buyableText:DockMargin(0, 0, 0, 0)
    elseif (#owned:GetChildren()) == 0 then
        buyableText:DockMargin(0, 0, 0, marginVertical/2)
    else
        buyableText:SetTall(select(2, buyableText:GetContentSize()))
        buyableText:DockMargin(0, marginVertical, 0, marginVertical/2)
    end

    // Filter
    local filterTitle = vgui.Create("DLabel", filter)
    filterTitle:SetFont('ashop_24_600')
    filterTitle:SetTextColor(white)
    filterTitle:SetText(ashop.L('FilterBy'))
    filterTitle:Dock(TOP)
    filterTitle:SetTall(select(2, filterTitle:GetContentSize()))

    local filterName = vgui.Create("DLabel", filter)
    filterName:SetFont('ashop_14_600')
    filterName:SetTextColor(white)
    filterName:SetText(ashop.L('Name'))
    filterName:Dock(TOP)
    filterName:SetTall(select(2, filterName:GetContentSize()))
    filterName:DockMargin(0, marginVertical, 0, 0)

    local filterNameEntry = vgui.Create("AShop_DTextEntry", filter)
    filterNameEntry:Dock(TOP)
    filterNameEntry:SetFont('ashop_14')
    filterNameEntry:SetTextColor(white)
    filterNameEntry:GetPlaceholderText("Hi")
    filterNameEntry:DockMargin(0, marginVertical/4, 0, 0)
    filterNameEntry.boxcolor = stateOff
    self.textFilter = ""

    filterNameEntry.OnChange = function()
        self.textFilter = string.lower(filterNameEntry:GetText())
        self:ApplyFilter()
    end

    local filterCat = vgui.Create("DLabel", filter)
    filterCat:SetFont('ashop_14_600')
    filterCat:SetTextColor(white)
    filterCat:SetText(ashop.L('SubCategory'))
    filterCat:Dock(TOP)
    filterCat:SetTall(select(2, filterCat:GetContentSize()))
    filterCat:DockMargin(0, marginVertical, 0, 0)

    self.filterCategories = {}

    for k, v in pairs(filteredItems.cat) do
        local filterCatButton = vgui.Create("AShop_DCheckBoxLabel", filter)
        filterCatButton:SetFont('ashop_16')
        filterCatButton:SetTextColor(white)
        filterCatButton:SetText(k)
        filterCatButton:Dock(TOP)
        filterCatButton:SetTall(select(2, filterCatButton.Label:GetContentSize()))
        filterCatButton:DockMargin(0, marginVertical/4, 0, 0)

        filterCatButton.OnChange = function(_, v)
            self.filterCategories[k] = v and true or nil
            self:ApplyFilter()
        end
    end

    // Rarity
    local rarityCat = vgui.Create("DLabel", filter)
    rarityCat:SetFont('ashop_14_600')
    rarityCat:SetTextColor(white)
    rarityCat:SetText(ashop.L('Rarity'))
    rarityCat:Dock(TOP)
    rarityCat:SetTall(select(2, filterCat:GetContentSize()))
    rarityCat:DockMargin(0, marginVertical, 0, 0)

    self.rarityFilter = {}

    for k, v in pairs(filteredItems.rarity) do
        local rarityCatButton = vgui.Create("AShop_DCheckBoxLabel", filter)
        rarityCatButton:SetFont('ashop_16')
        rarityCatButton:SetTextColor(white)
        rarityCatButton:SetText(k)
        rarityCatButton:Dock(TOP)
        rarityCatButton:SetTall(select(2, rarityCatButton.Label:GetContentSize()))
        rarityCatButton:DockMargin(0, marginVertical/4, 0, 0)

        rarityCatButton.OnChange = function(_, v)
            self.rarityFilter[k] = v and true or nil
            self:ApplyFilter()
        end
    end

    // self.sort
    local orderBy = vgui.Create("DLabel", filter)
    orderBy:SetFont('ashop_14_600')
    orderBy:SetTextColor(white)
    orderBy:SetText(ashop.L('OrderBy'))
    orderBy:Dock(TOP)
    orderBy:SetTall(select(2, filterCat:GetContentSize()))
    orderBy:DockMargin(0, marginVertical, 0, 0)

    local orderBys = {}

    for k, v in ipairs({
        {
            'BestPrice',
            function(a, b)
                return (a[2].price or 0) > (b[2].price or 0)
            end,
        },

        {
            'LowestPrice',
            function(a, b)
                return (a[2].price or 0) < (b[2].price or 0)
            end,
        },
    }) do
        local c = vgui.Create("AShop_DCheckBoxLabel", filter)
        c:SetFont('ashop_16')
        c:SetTextColor(white)
        c:Dock(TOP)
        c:DockMargin(0, marginVertical/4, 0, 0)

        c:SetText(ashop.L(v[1]))
        c:SetTall(select(2, c.Label:GetContentSize()))

        c.OnChange = function(_, b)
            for k, v in ipairs(orderBys) do
                if v == c then continue end
                v.state = false
            end

            local goodFunc = v[2]

            self.sort = b and goodFunc or nil
            self:ApplyFilter()
        end

        table.insert(orderBys, c)
    end

    self.othersFilter = {}
    local othersFilter = vgui.Create("DLabel", filter)
    othersFilter:SetFont('ashop_14_600')
    othersFilter:SetTextColor(white)
    othersFilter:SetText(ashop.L('Others'))
    othersFilter:Dock(TOP)
    othersFilter:SetTall(select(2, filterCat:GetContentSize()))
    othersFilter:DockMargin(0, marginVertical, 0, 0)

    local onlyPromo = vgui.Create("AShop_DCheckBoxLabel", filter)
    onlyPromo:SetFont('ashop_16')
    onlyPromo:SetTextColor(white)
    onlyPromo:SetText(ashop.L('OnPromotion'))
    onlyPromo:Dock(TOP)
    onlyPromo:SetTall(select(2, onlyPromo.Label:GetContentSize()))
    onlyPromo:DockMargin(0, marginVertical/4, 0, 0)

    onlyPromo.OnChange = function(_, v)
        self.othersFilter['onlypromo'] = v and true or nil
        self:ApplyFilter()
    end
end

derma.DefineControl( "AShop_ShopDisplay", "", PANEL, "EditablePanel" )