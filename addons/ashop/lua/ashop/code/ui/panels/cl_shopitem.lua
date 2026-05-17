
local PANEL = {}

function PANEL:Init()
	self:SetText('')
end

local itemBgClr = ashop.GetColor('ItemBg')
local itemBgClrR, itemBgClrG, itemBgClrB = ashop.GetColor('ItemBg'):Unpack()
local white = ashop.GetColor('White')

local grad = Material('akulla/gradient-d')
local circle = Material('akulla/circle.png', 'smooth')

ashop.RunningShopItemPanels = ashop.RunningShopItemPanels or {}

hook.Add('ashop_itemedit', 'refreshShopItems', function(item, itemTable)
	for k, v in pairs(ashop.RunningShopItemPanels) do
		if k.itemID == item then
			k:Refresh()
		end
	end
end)

hook.Add('ashop_refreshSettingsUI', 'refreshRarityShopItems', function(n, rarityID)
	if n == ashop.L('Rarity') then
		for k, v in pairs(ashop.RunningShopItemPanels) do
			if ashop.items[k.itemID] and ashop.items[k.itemID].rarity == rarityID then
				k:Refresh()
			end
		end
	end
end)

function PANEL:Refresh()
	self:SetItem(self.plyItem, self.itemID, self.drawPrice)
end

function PANEL:SetItem(plyItem, itemID, drawPrice)
	ashop.RunningShopItemPanels[self] = true
	self.outlinedItemBox = nil
	self:Clear()

	local item = isnumber(itemID) and ashop.items[itemID] or itemID
	local object_type = ashop.object_types[item.object_types]
	local lp = LocalPlayer()

	local rarity = ashop.rarity[item.rarity]

	local rarityStyle = ashop.itemShopEffects[rarity.style]
	local cR = ashop.rarity[item.rarity]

	// Unpacked
	local ModelDrawTable
	self.plyItem = plyItem
	self.itemID = itemID
	self.drawPrice = drawPrice

	function self:Paint(w, h)
		if !self.outlinedItemBox then
			self.outlinedItemBox, self.polyshape = ashop.ui.RoundedBoxOutlined(self.OutlineOverride or ashop.Config.round, 0, 0, w, h, itemBgClr, rarity.clr, 2, function()
				surface.SetMaterial(grad)
				surface.SetDrawColor(cR.r, cR.g, cR.b, 25)
				surface.DrawTexturedRect(0, h*0.6, w, h*0.4 )
			end)
		end

		if self.isEquipped then
			self.outlinedItemBoxInt = self.outlinedItemBoxInt or ashop.ui.RoundedBox(self.OutlineOverride or ashop.Config.round, 1, 1, w-2, h-2)
			self.outlinedItemBoxExt = self.outlinedItemBoxExt or ashop.ui.RoundedBox(self.OutlineOverride or ashop.Config.round, 0, 0, w, h)

			// Draw roundedbox is ugly
			surface.SetDrawColor(cR.r, cR.g, cR.b)
			draw.NoTexture()
			surface.DrawPoly(self.outlinedItemBoxExt)

			ashop.StartStencil()
				draw.NoTexture()
				surface.SetDrawColor(itemBgClrR, itemBgClrG, itemBgClrB)
				surface.DrawPoly(self.outlinedItemBoxInt)
		end

		// Create a stencil, anyway
		if (rarityStyle and rarityStyle.preDraw) or ModelDrawTable then
			if !self.isEquipped then
				ashop.StartStencil()
					draw.NoTexture()
					surface.SetDrawColor(itemBgClrR, itemBgClrG, itemBgClrB)
					surface.DrawPoly(self.polyshape)
			end

			ashop.ReplaceStencil(1)

			local b
			if rarityStyle then
				rarityStyle.preDraw(self, w, h, self.isEquipped, rarity.clr)
			end

			surface.SetDrawColor(cR.r, cR.g, cR.b, 20)
			surface.SetMaterial(circle)
			surface.DrawTexturedRect(w*0.1, h*0.1, w*0.8, w*0.8)

			if ModelDrawTable then
				for k, v in ipairs(ModelDrawTable) do
					v:PaintManual()
				end
			end

			if b then
				ashop.EndStencil()
				return
			end
		end

		self.outlinedItemBox(tobool(((rarityStyle and rarityStyle.preDraw) or ModelDrawTable) or self.isEquipped))
	end

	local price
	local font16 = ashop.GetFontHeight('ashop_16')
	self.price = {}
	if drawPrice then
		local isPromotionValid = item.promotion_start and item.promotion_end and item.promotion_amount and
			item.promotion_start < os.time() and os.time() - 20 < item.promotion_end and item.promotion_amount > 0

		local fontSize25 = ashop.GetFontHeight('ashop_icon_25')
		price = vgui.Create("EditablePanel", self)
		price:Dock(BOTTOM)
		price:SetTall(fontSize25*2)
		price:DockMargin(0, 0, 0, self:GetTall()*0.1 - fontSize25)
		price:SetMouseInputEnabled(false)
		price:SetZPos(4)

		local multiples = item.premium_price && item.price
		local usedWidth = 0
		local pnls = {}

		for a, b in ipairs({
			{"\"", item.price},
			{"!", item.premium_price},
		}) do
			if !b[2] then continue end
			local pnl = vgui.Create("EditablePanel", price)
			pnl:Dock(LEFT)

			local logo = vgui.Create("DLabel", pnl)
			logo:Dock(LEFT)
			logo:SetFont(a == 2 and 'ashop_icon_25' or 'ashop_icon_20')
			logo:SetTextColor(white)
			logo:SetText(b[1])
			logo:SetWide(logo:GetContentSize())
			logo:SetContentAlignment(8)

			local priceAfterRank = math.floor(b[2] * (100 - (ashop.rankpromo[lp:GetUserGroup()] or 0))/100)
			local priceText = vgui.Create("DLabel", pnl)
			priceText:Dock(LEFT)
			priceText:SetFont('ashop_16')
			priceText:SetTextColor(white)
			priceText:SetText(priceAfterRank )
			priceText:DockMargin(5, (fontSize25 - ashop.GetFontHeight(priceText:GetFont()))/2, 0, 0)
			priceText:SetWide(priceText:GetContentSize())
			priceText:SetContentAlignment(8)

			self.price[a] = priceAfterRank
			if isPromotionValid then
				local rarityClr50 = ColorAlpha(rarity.clr, 255*0.5)
				priceText:SetTextColor(rarityClr50)

				local pricePromo = math.floor(priceAfterRank * (1 - item.promotion_amount/100))

				self.price[a] = pricePromo
				function priceText:Paint(w, h)
					surface.SetDrawColor(cR)
					surface.DrawLine(0, font16/2, w, font16/2)

					draw.SimpleText(pricePromo, 'ashop_16', w/2, fontSize25, color_white, 1, 1)
				end
			end

			pnl:SetWide(logo:GetWide() + priceText:GetWide() + 5)
			usedWidth = usedWidth + pnl:GetWide()
			table.insert(pnls, pnl)
		end

        local space = math.floor((self:GetWide() - usedWidth) / (#pnls+1))

        for k, v in ipairs(pnls) do
            v:DockMargin(space, 0, 0, 0)
        end
	end

	local name = vgui.Create("DLabel", self)
	name:Dock(BOTTOM)
	name:SetText(item.name)
	name:SetFont("ashop_12_600")
	name:SetTextColor(white)
	name:SetContentAlignment(5)
	name:SetTall(select(2, name:GetContentSize()))
	name:DockMargin(0, 0, 0, price and 0 or self:GetTall()*0.1)
	name:SetMouseInputEnabled(false)
	name:SetZPos(5)

	local container = vgui.Create("EditablePanel", self)
	container:Dock(FILL)
	container:SetMouseInputEnabled(false)
	container:SetZPos(6)

	if item.picture_link then
		local mat
		function container:Paint(w, h)
			local m = isfunction(mat) and mat() or mat

			if m and !m:IsError() then
				local mW = math.min(w*0.6, h*0.6)
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(m)
				surface.DrawTexturedRect((w - mW)/2, h*0.2, mW, mW)
			end
		end
			
		local removeFunc = ashop.ui.setMaterialByLink(item.picture_link, {
			["$translucent"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1
		}, function(m)
			mat = m
		end, 'UnlitGeneric')

		if removeFunc then
			function container:OnRemove()
				removeFunc()
			end
		end
	elseif object_type.UI_FILL then
		_, ModelDrawTable = object_type.UI_FILL(plyItem, item, container, self, self:GetWide(),
			self:GetTall() - (price and price:GetTall() or 0) -
				name:GetTall() - self:GetTall()*0.1, rarityStyle and rarityStyle.noCircle )
		self.ModelDrawTable = ModelDrawTable
	end

	surface.SetFont('ashop_icon_20')
	local iW = surface.GetTextSize('(')
	local icons = vgui.Create('EditablePanel', self)
	local marginVertical = ashop.GetSize(16)
	icons:SetPos(self:GetWide() - iW - marginVertical / 2, marginVertical/2)
	icons:SetSize(iW, 0)
	icons:SetMouseInputEnabled(true)

	if item.group_restrained and ashop.groupranks[item.group_restrained] then
		local cantBuy = !ashop.groupranks[item.group_restrained].ranks[lp:GetUserGroup()]

		local h, s, v = ColorToHSV(rarity.clr)
		v = 0.75

		local cant = vgui.Create('DLabel', icons)
		cant:SetFont("ashop_icon_20")
		cant:SetText('(')
		cant:Dock(TOP)
		cant:SetTall(select(2, cant:GetContentSize()))
		cant:SetTextColor(cantBuy and HSVToColor(h, s, v) or rarity.clr)
		cant:SetMouseInputEnabled(true)

		if cantBuy then
			cant:SetTooltipPanelOverride("AShop_Tooltip")
			cant:SetTooltip(ashop.groupranks[item.group_restrained].desc or ashop.L('CantBuyRank'))
		end

		icons:SetTall(icons:GetTall() + cant:GetTall())
	end

	if item.expireTime then
		if plyItem then
			local h, s, v = ColorToHSV(rarity.clr)
			v = 0.75

			local time = vgui.Create('DLabel', icons)
			time:SetFont("ashop_icon_20")
			time:SetText('4')
			time:Dock(TOP)
			time:SetTall(select(2, time:GetContentSize()))
			time:SetTextColor(HSVToColor(h, s, v))
			time:SetMouseInputEnabled(true)
			time:SetTooltipPanelOverride("AShop_Tooltip")
			time:SetTooltip(ashop.L('ExpireItemIn', ashop.FormatDate(item.expireTime - (os.time() - plyItem.when), 99)))
			icons:SetTall(icons:GetTall() + time:GetTall())
		else
			local h, s, v = ColorToHSV(rarity.clr)
			s = 1
			v = 1

			local time = vgui.Create('DLabel', icons)
			time:SetFont("ashop_icon_20")
			time:SetText('2')
			time:Dock(TOP)
			time:SetTall(select(2, time:GetContentSize()))
			time:SetTextColor(HSVToColor(h, s, v))
			time:SetMouseInputEnabled(true)
			time:SetTooltipPanelOverride("AShop_Tooltip")
			time:SetTooltip(ashop.L('ExpireItem', ashop.FormatDate(item.expireTime, 99)))
			icons:SetTall(icons:GetTall() + time:GetTall())
		end
	end
end

function PANEL:OnRemove()
	for k, v in ipairs(self.ModelDrawTable or {}) do
		if IsValid(v) then
			v:Remove()
		end
	end

	if ashop.RunningShopItemPanels[self] then
		ashop.RunningShopItemPanels[self] = nil
	end
end

derma.DefineControl( "AShop_ShopItem", "Item drawer", PANEL, "DButton" )