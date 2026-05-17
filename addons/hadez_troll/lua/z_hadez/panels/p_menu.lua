-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()

local menuBG = Material("z_hadez/raw/bg_full.jpg")
local redFlame = surface.GetTextureID("z_hadez/menu/flame_red.vmt")
local gradientCenter = surface.GetTextureID("gui/center_gradient.vmt")
local gradientRight = surface.GetTextureID("gui/gradient.vmt")
local settingsBtnIcon = "z_hadez/menu/settings"
local closeBtnIcon = "z_hadez/menu/skull"
local returnBtnIcon = "z_hadez/menu/arrow_left"

local menuW, menuH, subMenuH = 750, 450, 400
local menuAnimSpeed = 0.2
local menuTitle = "HAD3Z"
local settingsTitle = "Permissions"

local flameH = 100
local flameW = flameH*0.54
local maxFlames = 25
local flameAnimSpeed = 0.5

local activeTab, activeTabPnl

function PANEL:Init()
	
	local returnBtn, settingsBtn
	local menuPnl = self
	
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSize(menuW,menuH)
	self:Center()
	self.bgTexture = nil
	self.Paint = function(self, w, h) 
		-- BG
		surface.SetDrawColor( color_white )
		
		if self.bgTexture then
			surface.SetTexture( self.bgTexture )
		else
			surface.SetMaterial( menuBG )
		end
		surface.DrawTexturedRect( 0, 0, w, h )
		
		CL_HADEZ:DrawBlur(self)
		
		if !activeTab then
			-- Title
			CL_HADEZ:DrawDoubleBlueTxt(menuTitle, "z_hadez_menuTitle", 50, 10, 2)
			CL_HADEZ:DrawDoubleBlueTxt("("..SH_HADEZ.VAR.VERSION..")", "z_hadez_menuVersion", 120, 10, 2)
		else
			CL_HADEZ:DrawDoubleBlueTxt(activeTab, "z_hadez_menuTitle", 50, 10, 2)
		end
		
		-- Left separator
		surface.SetDrawColor( SH_HADEZ.VAR.COLOR.LIGHTBLUE )
		surface.SetTexture( gradientRight )
		surface.DrawTexturedRect( 0, 40, 300, 2 )
		
		-- Right separator
		surface.SetDrawColor( SH_HADEZ.VAR.COLOR.RED )
		surface.DrawTexturedRectRotated( w-150, 41, 300, 2, 180 )
		
	end
	
	-- Animate alpha
	self:SetAlpha(0)
	self:AlphaTo(255, menuAnimSpeed)
	
	self:MoveToFront()
	self:MakePopup()
	
	-- Tab Content Panel
	local tabContentPnl = vgui.Create("DPanel",self)
	tabContentPnl:SetSize(menuW,menuH-40)
	tabContentPnl:SetPos(0,40)
	tabContentPnl:SetPaintBackground(false)
	
	-- Tab Panel (button container)
	local tabButtonPnl = vgui.Create("DScrollPanel",self)
	tabButtonPnl:SetSize(menuW-80,menuH-100)
	tabButtonPnl:SetPos(40,65)
	tabButtonPnl:SetPaintBackground(false)
	
	local sbar = CL_HADEZ:SkinScrollPanel(tabButtonPnl)
	function sbar:Paint( w, h )
		draw.RoundedBox( 2, 0, 0, w, h, SH_HADEZ.VAR.COLOR.LIGHTYDARK )
	end
	
	-- Flames
	local flamePnl = vgui.Create("DPanel",self)
	flamePnl:SetSize(menuW,100)
	flamePnl:SetZPos(10)
	flamePnl:SetMouseInputEnabled(false)
	
	local animatedFlameNext = 0
	local flamePos, flameLowPos, flameHighPos = 50, 50, 35
	local flameIsRising = true
	flamePnl.Think = function(self)
	
		flamePnl:SetPos(0,menuPnl:GetTall()-flamePnl:GetTall())
		
		if animatedFlameNext < CurTime() then
			
			if flameIsRising then
				flamePos = math.Approach( flamePos, flameHighPos, 0.25 )
				
				if flamePos == flameHighPos then
					flameIsRising = false
				end
				
			else
				flamePos = math.Approach( flamePos, flameLowPos, 0.25 )
				
				if flamePos == flameLowPos then
					flameIsRising = true
				end
			
			end
		
			animatedFlameNext = CurTime() + 0.033
		end
		
	end
	
	flamePnl.Paint = function(self, w, h)
		
		for i=1, maxFlames do
			surface.SetDrawColor(color_white)
			surface.SetTexture(redFlame)
			surface.DrawTexturedRect( -13 + 30*(i-1), flamePos, flameW, flameH )
		end
		
	end
	
	-- Settings btn
	settingsBtn = vgui.Create("DImageButton", self)
	settingsBtn:SetPos( 10, 8 )
	settingsBtn:SetSize( 25, 25 )
	settingsBtn:SetColor(SH_HADEZ.VAR.COLOR.LIGHTBLUE)
	settingsBtn:SetImage( settingsBtnIcon )	
	settingsBtn.DoClick = function(self)

		local openedTab = vgui.Create("p_hadez_settings",tabContentPnl)
		openedTab:SetPos(0,0)
		openedTab:SetSize(tabContentPnl:GetWide(),tabContentPnl:GetTall())
		openedTab:SetPaintBackground(false)
		openedTab:Init(true)
		
		activeTab = settingsTitle
		activeTabPnl = openedTab
		self:SetVisible(false)
		tabButtonPnl:SetVisible(false)
		returnBtn:SetVisible(true)

	end
	
	-- Close btn
	local closeBtn = vgui.Create("DImageButton", self)
	closeBtn:SetPos( menuW-33, 8 )
	closeBtn:SetSize( 25, 25 )
	closeBtn:SetColor(ColorAlpha(SH_HADEZ.VAR.COLOR.RED,150))
	closeBtn:SetImage( closeBtnIcon )	
	closeBtn.DoClick = function()
		CL_HADEZ:ToggleMenu(true)
	end
	
	-- Return btn
	returnBtn = vgui.Create("DImageButton", self)
	returnBtn:SetPos( 8, 5 )
	returnBtn:SetSize( 30, 30 )
	returnBtn:SetColor(SH_HADEZ.VAR.COLOR.LIGHTBLUE)
	returnBtn:SetImage( returnBtnIcon )
	returnBtn:SetVisible(false)
	returnBtn.DoClick = function(self)
		if IsValid(activeTabPnl) then
			menuPnl.bgTexture = nil
			activeTab = nil
			activeTabPnl:Remove()
			self:SetVisible(false)
			settingsBtn:SetVisible(true)
			tabButtonPnl:SetVisible(true)
			menuPnl:SetSize(menuW, menuH)
			tabContentPnl:SetSize(menuW,menuH-40)
		end
	end
	
	if activeTab == settingsTitle then
		settingsBtn:DoClick()
	end
	
	-- DEBUG
	-- for i=1, 20 do
		-- CL_HADEZ:AddMenuTab("p_hadez_rocketfly"..i,"z_hadez/tabs/rocket.vmt","Rocket Launch")
	-- end
	
	-- Tabs
	local startX, startY = 0,0
	
	for pName, tab in SortedPairsByMemberValue(CL_HADEZ:GetMenuTabs(),"title") do
		
		local tabPnl = vgui.Create("DPanel",tabButtonPnl)
		tabPnl:SetPos(25+(startX*210),0+(startY*50))
		tabPnl:SetSize(190,50)
		
		local hasAccess
		
		local hoverBarW, iconRotation, nextAnimate  = 0, 0, 0
		tabPnl.Think = function(self)
			
			hasAccess = SH_HADEZ:HasAccess(tab.permKey)
			
			if nextAnimate < CurTime() and hasAccess then
			
				if self:IsHovered() or self:IsChildHovered() then
					hoverBarW = math.Approach( hoverBarW, tabPnl:GetWide(), 40 )
					iconRotation = iconRotation + 2
				else
					hoverBarW = math.Approach( hoverBarW, 0, 40 )
					iconRotation = math.Approach( iconRotation, iconRotation - (iconRotation%360), 10 )
				end
				
				nextAnimate = CurTime() + 0.033
			end
			
		end
		tabPnl.Paint = function(self, w, h)
			-- BG
			draw.RoundedBox( 6, 0, 11, w, h-22, SH_HADEZ.VAR.COLOR.DARKY)
		
			-- Gradient
			surface.SetDrawColor(ColorAlpha(SH_HADEZ.VAR.COLOR.RED, 200))
			surface.SetTexture(gradientCenter)
			surface.DrawTexturedRect( w/2-hoverBarW/2, h-12, hoverBarW, 2 )
		end
		
		local imgTextureID = surface.GetTextureID(tab.icon)
		local imgSize = tabPnl:GetTall()*0.85
		local tabImg = vgui.Create("DImage",tabPnl)
		tabImg:SetPos(0,0)
		tabImg:SetSize(tabPnl:GetTall(),tabPnl:GetTall())
		tabImg:SetImageColor(SH_HADEZ.VAR.COLOR.ICONORANGE)
		
		local disIconCol = Color(150, 99, 27)
		
		tabImg.Paint = function(self, w, h)
		
			if hasAccess then
				surface.SetDrawColor(tabImg:GetImageColor())
			else
				surface.SetDrawColor(disIconCol)
			end
			
			surface.SetTexture(imgTextureID)
			surface.DrawTexturedRectRotated( w/2, h/2, imgSize, imgSize, iconRotation )
		end
		
		local tabLbl = vgui.Create("DLabel",tabPnl)
		tabLbl:SetPos(tabImg:GetWide()+5,0)
		tabLbl:SetSize(tabPnl:GetWide()-tabImg:GetWide()-5,tabPnl:GetTall())
		tabLbl:SetText(tab.title)
		tabLbl:SetFont("z_hadez_menuTabTitle")
		
		local tabBtn = vgui.Create("DButton",tabPnl)
		tabBtn:SetPos(0,0)
		tabBtn:SetSize(tabPnl:GetWide(),tabPnl:GetTall())
		tabBtn:SetText('')
		tabBtn:SetPaintBackground(false)
		
		tabBtn.Think = function(self)
		
			if !hasAccess then
				self:SetCursor("arrow")
				tabLbl:SetColor(SH_HADEZ.VAR.COLOR.LIGHTGREY)
				
			else
				self:SetCursor("hand")
				tabLbl:SetColor(color_white)
			end
		
		end
		
		tabBtn.DoClick = function(self, forced)
		
			if !hasAccess and !forced then return end
		
			menuPnl:SetSize(menuW, subMenuH)
			tabContentPnl:SetSize(menuW,subMenuH-40)
			
			local openedTab = vgui.Create(pName,tabContentPnl)
			openedTab:SetPos(0,0)
			openedTab:SetSize(tabContentPnl:GetWide(),tabContentPnl:GetTall())
			openedTab.menuPnl = menuPnl
			openedTab:SetPaintBackground(false)
			openedTab:Init(true)
			
			activeTab = tab.title
			activeTabPnl = openedTab
			settingsBtn:SetVisible(false)
			tabButtonPnl:SetVisible(false)
			returnBtn:SetVisible(true)
			
		end
		
		if activeTab == tab.title then
			tabBtn:DoClick(true)
		end
		
		startY = startY + 1
		
		if startY%7 == 0 then
			startY = 0
			startX = startX + 1			
		end
		
	
	end
	
end
vgui.Register("p_hadez_menu",PANEL,"DFrame")