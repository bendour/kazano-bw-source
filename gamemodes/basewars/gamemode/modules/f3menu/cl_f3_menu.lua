local devMode = false
local closeIcon = Material("basewars_materials/close.png", "smooth")

local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5

local PANEL = {}
function PANEL:Init()
    self.tabs = BaseWars:GetBaseWarsMenuTabs()
    local ply = LocalPlayer()
    self.localPlayer = ply

	if ply.F3SavedPanel and not self.tabs[ply.F3SavedPanel] then
		ply.F3SavedPanel = 1
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
    -- Maintenir le centrage parfait lors des redimensionnements
    self.Frame.OnSizeChanged = function(s, w, h)
        s:Center()
    end
    -- Fond translucide harmonisé + blur optionnel (identique F4)
    self.Frame.Paint = function(s,w,h)
        local bg = GetBaseWarsTheme("bws_background") or Color(10,10,12)
        BaseWars:DrawRoundedBox(12, 0, 0, w, h, ColorAlpha(bg, 75))
        if self.localPlayer:GetBaseWarsConfig("bluredBackground") then
            BaseWars:DrawBlur(s, 4)
        end
    end

    self.Frame.Topbar = self.Frame:Add("DPanel")
    self.Frame.Topbar:Dock(TOP)
    self.Frame.Topbar:SetTall(math.max(BaseWars.ScreenScale * 40, ScrH() * 0.06))
    self.Frame.Topbar.Paint = function(s,w,h)
        local titleCol = GetBaseWarsTheme("bws_titleBar") or Color(20,20,22)
        BaseWars:DrawRoundedBoxEx(12, 0, 0, w, h, ColorAlpha(titleCol, 80), true, true, false, false)
        draw.SimpleText("- Kazano Menu -", "BaseWars.26", w * .5, h * .5, GetBaseWarsTheme("bws_text") or color_white, 1, 1)
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
        local bgCol = GetBaseWarsTheme("bws_contentBackground") or Color(16,16,18)
        BaseWars:DrawRoundedBox(12, 0, 0, w, h, ColorAlpha(bgCol, 90))

        local accent = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("bws_text") or color_white
        surface.SetDrawColor(accent.r or 255, accent.g or 255, accent.b or 255, 30)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

        local marginLoc = BaseWars.ScreenScale * 8
        local avatarSize = BaseWars.ScreenScale * 56
        local textX = marginLoc + avatarSize + marginLoc
        local textColor = GetBaseWarsTheme("bws_text")
        local darkText = GetBaseWarsTheme("bws_darkText")

        local plyName = ply:Name()
        draw.SimpleText(plyName, "BaseWars.20", textX, marginLoc, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local moneyText = ply:GetLang("scoreboard_money"):format(BaseWars:FormatMoney(ply:GetMoney()))
        draw.SimpleText(moneyText, "BaseWars.18", textX, marginLoc + BaseWars.ScreenScale * 24, darkText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local levelText = ply:GetLang("scoreboard_level"):format(BaseWars:FormatNumber(ply:GetLevel()))
        draw.SimpleText(levelText, "BaseWars.18", textX, marginLoc + BaseWars.ScreenScale * 44, darkText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local playerAvatar = self.Frame.Sidebar.Player:Add("BaseWars.Avatar")
    playerAvatar:SetPos(BaseWars.ScreenScale * 8, BaseWars.ScreenScale * 8)
    playerAvatar:SetSize(BaseWars.ScreenScale * 56, BaseWars.ScreenScale * 56)
    playerAvatar:SetPlayer(ply, 256)

	self.Frame.Sidebar.Scroll = self.Frame.Sidebar:Add("DScrollPanel")
	self.Frame.Sidebar.Scroll:GetVBar():SetWide(0)
	self.Frame.Sidebar.Scroll:Dock(FILL)

    self.Frame.Sidebar.Close = self.Frame.Sidebar:Add("BaseWars.Button")
    self.Frame.Sidebar.Close:Dock(BOTTOM)
    self.Frame.Sidebar.Close:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Sidebar.Close.Draw = function(s,w,h)
        local textColor = GetBaseWarsTheme("bws_text")

        BaseWars:DrawMaterial(closeIcon, bigMargin * 1.5, bigMargin, h - bigMargin * 2, h - bigMargin * 2, textColor)
        draw.SimpleText(ply:GetLang("close"), "BaseWars.20", h * 1.1, h * .5, textColor, 0, 1)
    end
    self.Frame.Sidebar.Close:SetColor(GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"), true)
    self.Frame.Sidebar.Close:SetAccentColor(GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("gen_accent"))
    self.Frame.Sidebar.Close.LerpFunc = function(s)
        return s:IsHovered()
    end
    self.Frame.Sidebar.Close.DoClick = function(s)
        s:ButtonSound()
        BaseWars:CloseF3Menu()
    end

	self.CurrentPanel = ply.F3SavedPanel or 1
	for k, v in SortedPairsByMemberValue(self.tabs, "order") do
		local tabName = v.name[1] == "#" and ply:GetLang(string.sub(v.name, 2)) or v.name

        local NavButton = self.Frame.Sidebar.Scroll:Add("BaseWars.Button")
        NavButton:Dock(TOP)
        NavButton:DockMargin(bigMargin, margin * 1.25, bigMargin, 0)
        NavButton.Draw = function(s,w,h)
            local textColor = GetBaseWarsTheme("bws_text")

            BaseWars:DrawMaterial(v.icon, bigMargin * 1.5, bigMargin, h - bigMargin * 2, h - bigMargin * 2, textColor)
            draw.SimpleText(tabName, "BaseWars.20", h * 1.1, h * .5, textColor, 0, 1)
        end
        NavButton.LerpFunc = function(s)
            return s:IsHovered() or self.CurrentPanel == k
        end
        NavButton:SetColor(GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"), true)
        NavButton:SetAccentColor(GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("gen_accent"))
        NavButton.DoClick = function(s)
            if self.CurrentPanel == k and not devMode then return end
            if IsValid(self.Frame.Body.OldContentPanel) then return end

			s:ButtonSound()

			ply.F3SavedPanel = k
			self.CurrentPanel = k
			if v.panel then
				self:Build(v.panel, true)
			end
		end
		NavButton.Tick = function(s)
			if v.name == "bwm_faction" then
				s:SetAccentColor(ply:GetFactionColor())
			end

			if v.name == "bwm_prestige" and not BaseWars.Config.Prestige.Enable then
				s:Remove()
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

	if #self.tabs > 0 then
		self:Build(self.tabs[ply.F3SavedPanel or 1].panel)
	end

    BaseWars:EaseInBlurBackground(self, 3, .9)
end

function PANEL:OnKeyCodePressed(key)
	if input.LookupKeyBinding(key) == "gm_showspare1" then
		BaseWars:CloseF3Menu()
	end
end

function PANEL:Build(panelName, replacePanel)
	if not IsValid(self.Frame.Body) then return end
	if not panelName then return end

	local transisionDuration = devMode and 0 or .25

	if replacePanel then
		self.Frame.Body.OldContentPanel = self.Frame.Body.ContentPanel
		self.Frame.Body.OldContentPanel:AlphaTo(0, transisionDuration, 0, function()
			if IsValid(self.Frame.Body.OldContentPanel) then
				self.Frame.Body.OldContentPanel:Remove()
			end
		end)
	end

	self.Frame.Body.ContentPanel = self.Frame.Body:Add(panelName)
	self.Frame.Body.ContentPanel:SetAlpha(0)
	self.Frame.Body.ContentPanel:AlphaTo(255, transisionDuration, 0, function() end)
	self.Frame.Body.ContentPanel:Dock(FILL)
end

function PANEL:Think()
	self.accentColor = GetBaseWarsTheme("gen_accent")
end

function PANEL:Paint(w, h)
end

vgui.Register("BaseWars.F3Menu", PANEL, "DFrame")

-- Animations d’ouverture/fermeture (identiques F4)
function PANEL:AnimateOpen()
    if not IsValid(self.Frame) then return end
    self:SetAlpha(0)

    local toW, toH = ScrW() * .85, ScrH() * .85
    self.Frame:SetSize(ScrW() * .8, ScrH() * .8)
    self.Frame:Center()
    self.Frame:SizeTo(toW, toH, .22, 0, .2, function() if IsValid(self.Frame) then self.Frame:Center() end end)
    self:AlphaTo(255, .18, 0)
end

function PANEL:AnimateClose()
    if not IsValid(self.Frame) then self:Remove() return end
    local toW, toH = ScrW() * .82, ScrH() * .82
    self.Frame:SizeTo(toW, toH, .17, 0, .2, function() if IsValid(self.Frame) then self.Frame:Center() end end)
    self:AlphaTo(0, .17, 0, function()
        if IsValid(self) then self:Remove() end
    end)
end