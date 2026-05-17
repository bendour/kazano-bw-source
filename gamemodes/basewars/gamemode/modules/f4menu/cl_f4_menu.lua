local icons = {
	close = Material("basewars_materials/close.png", "smooth"),
	copy = Material("basewars_materials/copy.png", "smooth"),
	favorite = Material("basewars_materials/f4/favorite.png", "smooth")
}
local cardH = BaseWars.ScreenScale * 85
local bigMargin = BaseWars.ScreenScale * 15
local margin = BaseWars.ScreenScale * 5

local PANEL = {}
function PANEL:Init()
	self.localPlayer = LocalPlayer()

	if self.localPlayer.F4SavedPanel then
		self.localPlayer.F4SavedPanel = math.Clamp(self.localPlayer.F4SavedPanel, 1, table.Count(BaseWars:GetShopList()))
	end

	self:SetSize(ScrW(), ScrH())
	self:Center()
	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable(false)
	self:ShowCloseButton(false)

	--[[-------------------------------------------------------------------
		FRAME
	---------------------------------------------------------------------]]

	self.Frame = self:Add("DPanel")
	self.Frame:SetSize(math.max(ScrW() * .75, BaseWars.ScreenScale * 600), math.max(ScrH() * .8, BaseWars.ScreenScale * 380))
	self.Frame:Center()
	-- Maintenir le centrage parfait lors des redimensionnements (animations)
	self.Frame.OnSizeChanged = function(s, w, h)
		s:Center()
	end
	-- Fond moderne translucide + blur
	self.Frame.Paint = function(s,w,h)
		local bg = GetBaseWarsTheme("bws_background") or Color(10,10,12)
		-- Coins arrondis uniformes avec rayon approprié et opacité renforcée
		BaseWars:DrawRoundedBox(12, 0, 0, w, h, ColorAlpha(bg, 75))
		if LocalPlayer():GetBaseWarsConfig("bluredBackground") then
			BaseWars:DrawBlur(s, 4)
		end
	end

	self.Frame.Topbar = self.Frame:Add("DPanel")
	self.Frame.Topbar:Dock(TOP)
	self.Frame.Topbar:SetTall(math.max(BaseWars.ScreenScale * 40, ScrH() * 0.06))
	self.Frame.Topbar.Paint = function(s,w,h)
		-- Barre supérieure avec coins arrondis uniformes et soulignement subtil
		local titleCol = GetBaseWarsTheme("bws_titleBar") or Color(20,20,22)
		BaseWars:DrawRoundedBoxEx(12, 0, 0, w, h, ColorAlpha(titleCol, 80), true, true, false, false)
		draw.SimpleText("- Kazano Shop -", "BaseWars.26", w * .5, h * .5, color_white, 1, 1)
		local underlineW = math.min(w * .25, BaseWars.ScreenScale * 220)
		local underlineH = 2
		local accent = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("bws_text") or color_white
		surface.SetDrawColor(accent.r or 200, accent.g or 60, accent.b or 70, 35)
		surface.DrawRect((w - underlineW) * .5, h - underlineH - 4, underlineW, underlineH)
	end

	--[[-------------------------------------------------------------------
		NAVIGATION
	---------------------------------------------------------------------]]

	self.Frame.Sidebar = self.Frame:Add("DPanel")
	self.Frame.Sidebar:Dock(LEFT)
	self.Frame.Sidebar:SetWide(math.min(math.max(BaseWars.ScreenScale * 220, ScrW() * 0.22), ScrW() * 0.28))
	self.Frame.Sidebar.Paint = function(s,w,h)
		local bg = GetBaseWarsTheme("bws_background") or Color(10,10,12)
		BaseWars:DrawRoundedBoxEx(12, 0, 0, w, h, ColorAlpha(bg, 75), false, false, true, false)
	end

    self.Frame.Sidebar.Player = self.Frame.Sidebar:Add("DPanel")
    self.Frame.Sidebar.Player:Dock(TOP)
    self.Frame.Sidebar.Player:SetTall(math.max(BaseWars.ScreenScale * 90, ScrH() * 0.08))
    self.Frame.Sidebar.Player.Paint = function(s,w,h)
        -- Conteneur sombre avec coins arrondis et léger contour
        local bgCol = GetBaseWarsTheme("bws_contentBackground") or Color(16,16,18)
        BaseWars:DrawRoundedBox(12, 0, 0, w, h, ColorAlpha(bgCol, 90))

        local accent = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("bws_text") or color_white
        surface.SetDrawColor(accent.r or 255, accent.g or 255, accent.b or 255, 30)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

        -- Mise en page texte
        local margin = BaseWars.ScreenScale * 8
        local avatarSize = BaseWars.ScreenScale * 56
        local textX = margin + avatarSize + margin
        local textColor = GetBaseWarsTheme("bws_text")
        local darkText = GetBaseWarsTheme("bws_darkText")

        -- Nom du joueur
        local plyName = self.localPlayer:Name()
        draw.SimpleText(plyName, "BaseWars.20", textX, margin, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        -- Argent du joueur (localisé)
        local moneyText = self.localPlayer:GetLang("scoreboard_money"):format(BaseWars:FormatMoney(self.localPlayer:GetMoney()))
        draw.SimpleText(moneyText, "BaseWars.18", textX, margin + BaseWars.ScreenScale * 24, darkText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        -- Niveau du joueur (localisé)
        local levelText = self.localPlayer:GetLang("scoreboard_level"):format(BaseWars:FormatNumber(self.localPlayer:GetLevel()))
        draw.SimpleText(levelText, "BaseWars.18", textX, margin + BaseWars.ScreenScale * 44, darkText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    -- Avatar du joueur à gauche dans le conteneur
    local playerAvatar = self.Frame.Sidebar.Player:Add("BaseWars.Avatar")
    playerAvatar:SetPos(BaseWars.ScreenScale * 8, BaseWars.ScreenScale * 8)
    playerAvatar:SetSize(BaseWars.ScreenScale * 56, BaseWars.ScreenScale * 56)
    playerAvatar:SetPlayer(self.localPlayer, 256)

	self.Frame.Sidebar.Scroll = self.Frame.Sidebar:Add("DScrollPanel")
	self.Frame.Sidebar.Scroll:GetVBar():SetWide(0)
	self.Frame.Sidebar.Scroll:Dock(FILL)

	self.Frame.Sidebar.Close = self.Frame.Sidebar:Add("OLD.BaseWars.Button")
	self.Frame.Sidebar.Close:Dock(BOTTOM)
	self.Frame.Sidebar.Close:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
	self.Frame.Sidebar.Close.__hoverProg = 0
	self.Frame.Sidebar.Close.Draw = function(s,w,h)
		local textColor = GetBaseWarsTheme("bws_text")

		BaseWars:DrawMaterial(icons["close"], bigMargin * 1.5, bigMargin, h - bigMargin * 2, h - bigMargin * 2, textColor)
		draw.SimpleText(self.localPlayer:GetLang("close"), "BaseWars.20", h * 1.1, h * .5, textColor, 0, 1)

		-- Survol subtil
		local a = math.floor(s.__hoverProg * 30)
		if a > 0 then
			draw.RoundedBox(8, 0, 0, w, h, Color(255,255,255,a))
		end

		-- Contour moderne
		local borderColor = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("bws_text") or color_white
		surface.SetDrawColor(borderColor.r or 255, borderColor.g or 255, borderColor.b or 255, math.floor(80 + 100 * s.__hoverProg))
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end
	self.Frame.Sidebar.Close.Think = function(s)
		s.__hoverProg = Lerp(FrameTime() * 10, s.__hoverProg, s:IsHovered() and 1 or 0)
	end
	self.Frame.Sidebar.Close.DoClick = function(s)
		s:ButtonSound()
		BaseWars:CloseF4Menu()
	end

	self.CurrentPanel = self.localPlayer.F4SavedPanel or 1
	for k, v in ipairs(BaseWars:GetShopList()) do
		if v.lockUntil and not v.lockUntil(self.localPlayer) then
			continue
		end

		local NavButton = self.Frame.Sidebar.Scroll:Add("OLD.BaseWars.Button")
		NavButton:Dock(TOP)
		NavButton:DockMargin(bigMargin, margin * 1.25, bigMargin, 0)
		NavButton:SetAccentColor(v.color)
		NavButton.__hoverProg = 0
		NavButton.Draw = function(s,w,h)
			local textColor = GetBaseWarsTheme("bws_text")

			BaseWars:DrawMaterial(v.icon, bigMargin * 1.5, bigMargin, h - bigMargin * 2, h - bigMargin * 2, textColor)
			draw.SimpleText(v.name, "BaseWars.20", h * 1.1, h * .5, textColor, 0, 1)
            -- Survol subtil + contour accentué
            local a = math.floor(s.__hoverProg * 30)
            if a > 0 then
                draw.RoundedBox(8, 0, 0, w, h, Color(255,255,255,a))
                local accent = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("bws_text") or color_white
                surface.SetDrawColor(accent.r or 255, accent.g or 60, accent.b or 70, 90)
                surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            end
		end
		NavButton.LerpFunc = function(s)
			return s:IsHovered() or self.CurrentPanel == k
		end
		NavButton.Think = function(s)
			s.__hoverProg = Lerp(FrameTime() * 10, s.__hoverProg, s:IsHovered() and 1 or 0)
		end
		NavButton.DoClick = function(s)
			if self.CurrentPanel == k then return end
			if IsValid(self.Frame.Body.OldContentPanel) then return end

			surface.PlaySound("bw_button.wav")

			self.localPlayer.F4SavedPanel = k
			self.CurrentPanel = k

			if k == 1 then
				self:BuildFavorites()
			else
				self:Build(v.subCategories, true)
			end
		end
	end

	--[[-------------------------------------------------------------------
		BODY
	---------------------------------------------------------------------]]

	self.Frame.Body = self.Frame:Add("DPanel")
	self.Frame.Body:Dock(FILL)
	self.Frame.Body:InvalidateParent(true)
	self.Frame.Body.Paint = function(s,w,h)
		local bg = GetBaseWarsTheme("bws_background") or Color(10,10,12)
		BaseWars:DrawRoundedBoxEx(12, 0, 0, w, h, ColorAlpha(bg, 75), false, false, false, true)
	end

	for k, v in ipairs(BaseWars:GetShopList()) do
		if self.CurrentPanel == 1 then
			self:BuildFavorites()

			break
		end

		if self.CurrentPanel == k then
			self:Build(v.subCategories)

			break
		end
	end

	BaseWars:EaseInBlurBackground(self, 3, .9)
end

-- Animations d’ouverture/fermeture du menu (DPanel/DFrame)
function PANEL:AnimateOpen()
    if not IsValid(self.Frame) then return end
    self:SetAlpha(0)

    -- Start slightly smaller, then scale up smoothly
    local toW, toH = ScrW() * .85, ScrH() * .85
    self.Frame:SetSize(ScrW() * .8, ScrH() * .8)
    self.Frame:Center()
    self.Frame:SizeTo(toW, toH, .22, 0, .2, function() if IsValid(self.Frame) then self.Frame:Center() end end)
    self:AlphaTo(255, .18, 0)
end

function PANEL:AnimateClose()
    if not IsValid(self.Frame) then self:Remove() return end
    -- Shrink and fade away
    local toW, toH = ScrW() * .82, ScrH() * .82
    self.Frame:SizeTo(toW, toH, .17, 0, .2, function() if IsValid(self.Frame) then self.Frame:Center() end end)
    self:AlphaTo(0, .17, 0, function()
        if IsValid(self) then self:Remove() end
    end)
end

function PANEL:OnKeyCodePressed(key)
	if input.LookupKeyBinding(key) == "gm_showspare2" then
		BaseWars:CloseF4Menu()
	end
end

function PANEL:BuildFavorites()
	if not IsValid(self.Frame.Body) then return end

	local transisionDuration = .25

	if IsValid(self.Frame.Body.ContentPanel) then
		self.Frame.Body.OldContentPanel = self.Frame.Body.ContentPanel
		self.Frame.Body.OldContentPanel:AlphaTo(0, transisionDuration, 0, function()
			if IsValid(self.Frame.Body.OldContentPanel) then
				self.Frame.Body.OldContentPanel:Remove()
			end
		end)
	end

	self.Frame.Body.ContentPanel = self.Frame.Body:Add("DScrollPanel")
	self.Frame.Body.ContentPanel:Dock(FILL)
	self.Frame.Body.ContentPanel:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
	self.Frame.Body.ContentPanel:SetAlpha(0)
	self.Frame.Body.ContentPanel:AlphaTo(255, transisionDuration, 0)
	self.Frame.Body.ContentPanel:GetVBar():SetWide(bigMargin)
	self.Frame.Body.ContentPanel:PaintScrollBar("bws")
	self.Frame.Body.ContentPanel.Paint = function(s,w,h)
		if #s:GetCanvas():GetChildren() == 0 then
			draw.SimpleText(self.localPlayer:GetLang("bws_nothingToBuy"), "BaseWars.30", w * .5, h * .5, GetBaseWarsTheme("bws_text"), 1, 1)
		end
	end

	local data = {}
	for k, v in ipairs(BaseWars:GetFavorites()) do
		local itemObject = BaseWars:GetBaseWarsEntity(v)
		if not itemObject then
			-- BaseWars:RemoveFavorite(v)

			continue
		end

		local subCategory = itemObject:GetSubCategory()
		if not data[subCategory] then
			data[subCategory] = {}
		end

		table.insert(data[subCategory], v)
	end

local bodyW = self.Frame.Body:GetWide()
local columns = (bodyW >= 900) and 3 or ((bodyW >= 500) and 2 or 1)
local cardW = (bodyW - bigMargin * 3 - margin * (columns - 1)) / columns

	for categoryName, categoryData in SortedPairs(data) do
		local first = categoryName[1]
		if tonumber(first) then
			categoryName = string.sub(categoryName, 2)
		end

		local category = self.Frame.Body.ContentPanel:Add("BaseWars.Cagory")
		category:Dock(TOP)
		category:SetName(categoryName)

		local Layout = vgui.Create("DIconLayout")
		Layout:DockMargin(0, margin, 0, 0)
		Layout:SetSpaceX(margin)
		Layout:SetSpaceY(margin)

		for _, entityID in ipairs(categoryData) do
			local itemObject = BaseWars:GetBaseWarsEntity(entityID)
			if not itemObject then continue end -- ???

			local canBuy, cantBuyReason = self.localPlayer:CanBuy(entityID)
			if self.localPlayer:GetBaseWarsConfig("hideNonBuyable") and not canBuy then continue end

			local item = Layout:Add("DButton")
			item:SetText("")
			item:SetSize(cardW, cardH)
		item.canBuy = canBuy
		item.cantBuyReason = cantBuyReason
		item.time = 0
		item.lerpColor = item.canBuy and GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bws_cantBuy")
		item.__hoverProg = 0
		item.Paint = function(s,w,h)
			s.lerpColor = BaseWars:LerpColor(FrameTime() * 15, s.lerpColor, item.canBuy and GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bws_cantBuy"))

			-- Fond minimaliste plus discret
			BaseWars:DrawRoundedBox(8, 0, 0, w, h, ColorAlpha(s.lerpColor, 60))

			-- Survol épuré: uniquement un fin contour accentué, sans voile blanc
			local accent = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("bws_text") or color_white
			local ba = math.floor(70 * s.__hoverProg)
			if ba > 0 then
				surface.SetDrawColor(accent.r or 255, accent.g or 60, accent.b or 70, ba)
				surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
			end
		end
		item.Think = function(s)
			s.__hoverProg = Lerp(FrameTime() * 10, s.__hoverProg, s:IsHovered() and 1 or 0)
		end
			item.DoClick = function(s)
				if self.localPlayer:GetBaseWarsConfig("showBuyPopup") then
					surface.PlaySound("bw_button.wav")
					local popup = vgui.Create("BaseWars.Popup.Shop")
					popup:SetEntityID(entityID)

					return
				end

				if s.canBuy then
					surface.PlaySound("bw_button.wav")
					RunConsoleCommand("basewarsbuy", entityID)

					if self.localPlayer:GetBaseWarsConfig("closeOnBuy") then
						BaseWars:CloseF4Menu()
					end

					return
				end

				BaseWars:Notify(s.cantBuyReason, NOTIFICATION_ERROR, 5)
			end
			item.Think = function(s)
				if CurTime() >= s.time then
					s.canBuy, s.cantBuyReason = self.localPlayer:CanBuy(entityID)
					s.time = CurTime() + .5

					if IsValid(item.Buttons.Favorite) then
						item.Buttons.Favorite:SetColor(s.lerpColor)
					end

					if IsValid(item.Buttons.Copy) then
						item.Buttons.Copy:SetColor(s.lerpColor)
					end
				end
			end

			item.Infos = item:Add("DPanel")
			item.Infos:SetMouseInputEnabled(false)
			item.Infos:Dock(FILL)
		item.Infos:DockMargin(margin * 1.5, margin * 1.5, margin * 1.5, margin * 1.5)
			item.Infos.Paint = function(s,w,h)
				draw.SimpleText(itemObject:GetName(), "BaseWars.20", w * .5, bigMargin, GetBaseWarsTheme("bws_text"), 1, 1)

				-- if not item.canBuy then
				-- 	draw.SimpleText(item.cantBuyReason, "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

				-- 	return
				-- end

				local bool, rank = itemObject:GetRankCheck()(self.localPlayer)
				if not bool then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantVIP"):format(rank), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if BaseWars.Config.Prestige.Enable and not self.localPlayer:HasPrestige(itemObject:GetPrestige()) then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantPrestige"):format(BaseWars:FormatNumber(itemObject:GetPrestige())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if not self.localPlayer:InRaid() and (string.find(itemObject:GetClass(), "bw_explosive") or string.find(itemObject:GetClass(), "bw_weapon_c4")) then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantRaid"), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if self.localPlayer:GetLevel() < itemObject:GetLevel() then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantLevel"):format(BaseWars:FormatNumber(itemObject:GetLevel())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if not self.localPlayer:CanAfford(itemObject:GetPrice()) then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantMoney"):format(BaseWars:FormatMoney(itemObject:GetPrice())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				draw.SimpleText(BaseWars:FormatMoney(itemObject:GetPrice()), "BaseWars.18", w * .5, BaseWars.ScreenScale * 30, GetBaseWarsTheme("bws_darkText"), 1, 1)
				draw.SimpleText(self.localPlayer:GetLang("bws_level"):format(BaseWars:FormatNumber(itemObject:GetLevel())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)
				draw.SimpleText(self.localPlayer:GetLang("bws_limit"):format(BaseWars:FormatNumber(itemObject:GetMax())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 60, GetBaseWarsTheme("bws_darkText"), 1, 1)
			end

			item.Model = item:Add("SpawnIcon")
			item.Model:Dock(LEFT)
			item.Model:DockMargin(bigMargin, bigMargin, 0, bigMargin)
			item.Model:SetWide(item:GetTall() - margin * 2)
			item.Model:SetMouseInputEnabled(false)
			item.Model:SetModel(itemObject:GetModel())

			item.Buttons = item:Add("DPanel")
			item.Buttons:Dock(RIGHT)
			item.Buttons:DockMargin(0, margin, margin, margin)
			item.Buttons:SetWide(cardH * .5 - margin)
			item.Buttons.Paint = nil

			item.Buttons.Favorite = item.Buttons:Add("BaseWars.Button")
			item.Buttons.Favorite:Dock(TOP)
			item.Buttons.Favorite:SetTall((cardH - margin * 3) * .5)
			item.Buttons.Favorite:SetColor(item.lerpColor, true)
			item.Buttons.Favorite.LerpFunc = function(s)
				return s:IsHovered() or BaseWars:IsFavorite(entityID)
			end
			item.Buttons.Favorite.Draw = function(s,w,h)
				BaseWars:DrawMaterial(icons["favorite"], w * .5, h * .5, h * .65, h * .65, color_white, 0)
			end
			item.Buttons.Favorite.DoClick = function(s)
				s:ButtonSound()

				BaseWars:RemoveFavorite(entityID)
				item:Remove()
			end

			item.Buttons.Copy = item.Buttons:Add("BaseWars.Button")
			item.Buttons.Copy:Dock(BOTTOM)
			item.Buttons.Copy:SetTall((cardH - margin * 3) * .5)
			item.Buttons.Copy:SetColor(item.lerpColor, true)
			item.Buttons.Copy.Draw = function(s,w,h)
				BaseWars:DrawMaterial(icons["copy"], w * .5, h * .5, h * .65, h * .65, color_white, 0)
			end
			item.Buttons.Copy.DoClick = function(s)
				s:ButtonSound()

				SetClipboardText("bind \"KEY\" \"basewarsbuy " .. entityID .. "\"")
				BaseWars:Notify("#bws_copyBind", NOTIFICATION_GENERIC, 5, itemObject:GetName())
			end
		end

        category:SetContents(Layout)
        Layout.__lastBodyW = 0
        Layout.Think = function(s)
            if s:ChildCount() <= 0 then
                category:Remove()
            end

            local bw = self.Frame.Body:GetWide()
            if bw ~= s.__lastBodyW then
                s.__lastBodyW = bw
                local cols = (bw >= 800) and 3 or ((bw >= 500) and 2 or 1)
                local newCardW = (bw - bigMargin * 3 - margin * (cols - 1)) / cols
                for _, child in ipairs(s:GetChildren()) do
                    if IsValid(child) then child:SetSize(newCardW, cardH) end
                end
                s:InvalidateLayout(true)
            end
        end

		if self.localPlayer:GetBaseWarsConfig("hideEmptyCategories") and #Layout:GetChildren() <= 0 then
			category:Remove()
		end
	end
end

function PANEL:Build(data, replacePanel)
	if not IsValid(self.Frame.Body) then return end
	if not data then return end

	local transisionDuration = .25

	if replacePanel then
		self.Frame.Body.OldContentPanel = self.Frame.Body.ContentPanel
		self.Frame.Body.OldContentPanel:AlphaTo(0, transisionDuration, 0, function()
			if IsValid(self.Frame.Body.OldContentPanel) then
				self.Frame.Body.OldContentPanel:Remove()
			end
		end)
	end

	self.Frame.Body.ContentPanel = self.Frame.Body:Add("DScrollPanel")
	self.Frame.Body.ContentPanel:Dock(FILL)
	self.Frame.Body.ContentPanel:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
	self.Frame.Body.ContentPanel:SetAlpha(0)
	self.Frame.Body.ContentPanel:AlphaTo(255, transisionDuration, 0)
	self.Frame.Body.ContentPanel:GetVBar():SetWide(bigMargin)
	self.Frame.Body.ContentPanel:PaintScrollBar("bws")
	self.Frame.Body.ContentPanel.Paint = function(s,w,h)
		if #s:GetCanvas():GetChildren() == 0 then
			draw.SimpleText(self.localPlayer:GetLang("bws_nothingToBuy"), "BaseWars.30", w * .5, h * .5, GetBaseWarsTheme("bws_text"), 1, 1)
		end
	end

local bodyW2 = self.Frame.Body:GetWide()
local columns2 = (bodyW2 >= 800) and 3 or ((bodyW2 >= 500) and 2 or 1)
local cardW = (bodyW2 - bigMargin * 3 - margin * (columns2 - 1)) / columns2

	for categoryName, categoryData in SortedPairs(data) do
		local first = categoryName[1]
		if tonumber(first) then
			categoryName = string.sub(categoryName, 2)
		end

		local category = self.Frame.Body.ContentPanel:Add("BaseWars.Cagory")
		category:Dock(TOP)
		category:SetName(categoryName)

		local Layout = vgui.Create("DIconLayout")
		Layout:DockMargin(0, margin, 0, 0)
		Layout:SetSpaceX(margin)
		Layout:SetSpaceY(margin)

		for _, entityID in ipairs(categoryData) do
			local itemObject = BaseWars:GetBaseWarsEntity(entityID)
			if not itemObject then continue end -- ???

			local canBuy, cantBuyReason = self.localPlayer:CanBuy(entityID)
			if self.localPlayer:GetBaseWarsConfig("hideNonBuyable") and not canBuy then continue end

			local item = Layout:Add("DButton")
			item:SetText("")
			item:SetSize(cardW, cardH)
			item.canBuy = canBuy
			item.cantBuyReason = cantBuyReason
			item.time = 0
			item.lerpColor = item.canBuy and GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bws_cantBuy")
			item.__hoverProg = 0
			item.Paint = function(s,w,h)
				s.lerpColor = BaseWars:LerpColor(FrameTime() * 15, s.lerpColor, item.canBuy and GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bws_cantBuy"))

				-- Animation de scale au survol
				local scale = 1 + s.__hoverProg * 0.05 -- Augmente de 5% au survol
				local scaledW, scaledH = w * scale, h * scale
				local offsetX, offsetY = (w - scaledW) / 2, (h - scaledH) / 2

				-- Fond avec animation de scale
				BaseWars:DrawRoundedBox(8, offsetX, offsetY, scaledW, scaledH, ColorAlpha(s.lerpColor, 80))

				-- Ombre portée au survol
				if s.__hoverProg > 0 then
					local shadowAlpha = math.floor(s.__hoverProg * 30)
					BaseWars:DrawRoundedBox(8, offsetX + 2, offsetY + 2, scaledW, scaledH, ColorAlpha(0, 0, 0, shadowAlpha))
				end
			end
			item.Think = function(s)
				s.__hoverProg = Lerp(FrameTime() * 10, s.__hoverProg, s:IsHovered() and 1 or 0)
			end
			item.DoClick = function(s)
				if self.localPlayer:GetBaseWarsConfig("showBuyPopup") then
					surface.PlaySound("bw_button.wav")
					local popup = vgui.Create("BaseWars.Popup.Shop")
					popup:SetEntityID(entityID)

					return
				end

				if s.canBuy then
					surface.PlaySound("bw_button.wav")
					RunConsoleCommand("basewarsbuy", entityID)

					if self.localPlayer:GetBaseWarsConfig("closeOnBuy") then
						BaseWars:CloseF4Menu()
					end

					return
				end

				BaseWars:Notify(s.cantBuyReason, NOTIFICATION_ERROR, 5)
			end
			item.Think = function(s)
				if CurTime() >= s.time then
					s.canBuy, s.cantBuyReason = self.localPlayer:CanBuy(entityID)
					s.time = CurTime() + .5

					if IsValid(item.Buttons.Favorite) then
						item.Buttons.Favorite:SetColor(s.lerpColor)
					end

					if IsValid(item.Buttons.Copy) then
						item.Buttons.Copy:SetColor(s.lerpColor)
					end
				end
			end

			item.Infos = item:Add("DPanel")
			item.Infos:SetMouseInputEnabled(false)
			item.Infos:Dock(FILL)
			item.Infos:DockMargin(margin * 1.5, margin * 1.5, margin * 1.5, margin * 1.5)
			item.Infos.Paint = function(s,w,h)
				draw.SimpleText(itemObject:GetName(), "BaseWars.20", w * .5, bigMargin, GetBaseWarsTheme("bws_text"), 1, 1)

				-- if not item.canBuy then
				-- 	draw.SimpleText(item.cantBuyReason, "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

				-- 	return
				-- end

				local bool, rank = itemObject:GetRankCheck()(self.localPlayer)
				if not bool then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantVIP"):format(rank), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if BaseWars.Config.Prestige.Enable and not self.localPlayer:HasPrestige(itemObject:GetPrestige()) then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantPrestige"):format(BaseWars:FormatNumber(itemObject:GetPrestige())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if not self.localPlayer:InRaid() and (string.find(itemObject:GetClass(), "bw_explosive") or string.find(itemObject:GetClass(), "bw_weapon_c4")) then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantRaid"), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if self.localPlayer:GetLevel() < itemObject:GetLevel() then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantLevel"):format(BaseWars:FormatNumber(itemObject:GetLevel())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				if not self.localPlayer:CanAfford(itemObject:GetPrice()) then
					draw.SimpleText(self.localPlayer:GetLang("bws_cantMoney"):format(BaseWars:FormatMoney(itemObject:GetPrice())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)

					return
				end

				draw.SimpleText(BaseWars:FormatMoney(itemObject:GetPrice()), "BaseWars.18", w * .5, BaseWars.ScreenScale * 30, GetBaseWarsTheme("bws_darkText"), 1, 1)
				draw.SimpleText(self.localPlayer:GetLang("bws_level"):format(BaseWars:FormatNumber(itemObject:GetLevel())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 45, GetBaseWarsTheme("bws_darkText"), 1, 1)
				draw.SimpleText(self.localPlayer:GetLang("bws_limit"):format(BaseWars:FormatNumber(itemObject:GetMax())), "BaseWars.18", w * .5, BaseWars.ScreenScale * 60, GetBaseWarsTheme("bws_darkText"), 1, 1)
			end

			item.Model = item:Add("SpawnIcon")
			item.Model:Dock(LEFT)
			item.Model:DockMargin(bigMargin, bigMargin, 0, bigMargin)
			item.Model:SetWide(item:GetTall() - margin * 2)
			item.Model:SetMouseInputEnabled(false)
			item.Model:SetModel(itemObject:GetModel())

			item.Buttons = item:Add("DPanel")
			item.Buttons:Dock(RIGHT)
			item.Buttons:DockMargin(0, margin, margin, margin)
			item.Buttons:SetWide(cardH * .5 - margin)
			item.Buttons.Paint = nil

			item.Buttons.Favorite = item.Buttons:Add("BaseWars.Button")
			item.Buttons.Favorite:Dock(TOP)
			item.Buttons.Favorite:SetTall((cardH - margin * 3) * .5)
			item.Buttons.Favorite:SetColor(item.lerpColor, true)
			item.Buttons.Favorite.LerpFunc = function(s)
				return s:IsHovered() or BaseWars:IsFavorite(entityID)
			end
			item.Buttons.Favorite.Draw = function(s,w,h)
				BaseWars:DrawMaterial(icons["favorite"], w * .5, h * .5, h * .65, h * .65, color_white, 0)
			end
			item.Buttons.Favorite.DoClick = function(s)
				s:ButtonSound()

				BaseWars[(BaseWars:IsFavorite(entityID) and "Remove" or "Add") .. "Favorite"](BaseWars, entityID)
			end

			item.Buttons.Copy = item.Buttons:Add("BaseWars.Button")
			item.Buttons.Copy:Dock(BOTTOM)
			item.Buttons.Copy:SetTall((cardH - margin * 3) * .5)
			item.Buttons.Copy:SetColor(item.lerpColor, true)
			item.Buttons.Copy.Draw = function(s,w,h)
				BaseWars:DrawMaterial(icons["copy"], w * .5, h * .5, h * .65, h * .65, color_white, 0)
			end
			item.Buttons.Copy.DoClick = function(s)
				s:ButtonSound()

				SetClipboardText("bind \"KEY\" \"basewarsbuy " .. entityID .. "\"")
				BaseWars:Notify("#bws_copyBind", NOTIFICATION_GENERIC, 5, itemObject:GetName())
			end
		end

		category:SetContents(Layout)
		Layout.__lastBodyW = 0
		Layout.Think = function(s)
			if s:ChildCount() <= 0 then
				category:Remove()
			end

            local bw = self.Frame.Body:GetWide()
            if bw ~= s.__lastBodyW then
                s.__lastBodyW = bw
                local cols = (bw >= 800) and 3 or ((bw >= 500) and 2 or 1)
                local newCardW = (bw - bigMargin * 3 - margin * (cols - 1)) / cols
                for _, child in ipairs(s:GetChildren()) do
                    if IsValid(child) then child:SetSize(newCardW, cardH) end
                end
                s:InvalidateLayout(true)
            end
		end

		if self.localPlayer:GetBaseWarsConfig("hideEmptyCategories") and #Layout:GetChildren() <= 0 then
			category:Remove()
		end
	end
end

function PANEL:Paint(w, h)
end

vgui.Register("BaseWars.F4Menu", PANEL, "DFrame")
