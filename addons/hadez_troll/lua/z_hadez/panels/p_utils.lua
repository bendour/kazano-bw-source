-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local redGrungeBG = Material("z_hadez/raw/red_grunge_bg_faded.png")
local gradientCenter = surface.GetTextureID("gui/center_gradient.vmt")
local gradientUp = surface.GetTextureID("gui/gradient_up.vmt")
local selectAllIcon = "z_hadez/menu/select_all"
local selectAllBtnW = 32

function CL_HADEZ:CreatePlayerSelectionPanel(x, y, w, h, parent, canSelectMultiple, canTargetSelf, canClickFunc, permissionKey)

	local basePnl = vgui.Create("DPanel",parent)
	basePnl:SetPos(x,y)
	basePnl:SetSize(w,h)
	basePnl:SetPaintBackground(true)
	basePnl.Paint = function(self, w, h)
		-- BG Texture
		surface.SetDrawColor(color_white)
		surface.SetMaterial(redGrungeBG)
		surface.DrawTexturedRect( 0, 0, w, h )
		
		surface.SetDrawColor(Color(0,0,0,150))
		surface.DrawTexturedRect( 0, 0, w, h )
		
		-- Up gradient
		surface.SetDrawColor(color_black)
		surface.SetTexture(gradientUp)
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	
	basePnl.selectedPlayers = {}
	
	function basePnl:OnSelectedPlayersUpdate()
	
	end
	
	function basePnl:GetSelectedPlayers()
		return self.selectedPlayers
	end
	
	function basePnl:SetSelectedPlayers(selectedPlayers)
	
		local validPlayers = {}
	
		for i=1, #selectedPlayers do
			
			if IsValid(selectedPlayers[i]) then
				table.insert(validPlayers, selectedPlayers[i])
			end
			
		end
	
		self.selectedPlayers = validPlayers
		self:FillRows()
		
		return validPlayers
	end
	
	
	local nameSearch = vgui.Create("DTextEntry",basePnl)
	nameSearch:SetPos(4,0)
	nameSearch:SetSize(w-selectAllBtnW-16,30)
	nameSearch:SetFont("z_hadez_playerSearchBar")
	nameSearch:SetTextColor(color_white)
	nameSearch:SetPaintBackground(false)
	nameSearch:SetPlaceholderText(SH_HADEZ:Translate("search"))
	
	nameSearch.m_colCursor = color_white
	nameSearch.m_colPlaceholder = SH_HADEZ.VAR.COLOR.LIGHTGREY
	
	local oldPaint = nameSearch.Paint
	nameSearch.Paint = function(self, w, h)
		
		-- Center gradient
		surface.SetDrawColor(ColorAlpha(SH_HADEZ.VAR.COLOR.LIGHTGREY,150))
		surface.SetTexture(gradientCenter)
		surface.DrawTexturedRect( 0, h-1, w, 1 )
		
		-- Input box
		oldPaint(self,w,h)
		
	end
	
	nameSearch.OnChange = function(self)
		basePnl:FillRows()
	end
	
	if canSelectMultiple then
	
		local selectAllBtn = vgui.Create("DImageButton",basePnl)
		selectAllBtn:SetSize( selectAllBtnW, selectAllBtnW/2)
		selectAllBtn:SetPos( basePnl:GetWide()-selectAllBtnW-8, 8)
		selectAllBtn:SetImage( selectAllIcon )
		selectAllBtn:SetColor(SH_HADEZ.VAR.COLOR.LIGHTGREY)
		selectAllBtn.DoClick = function()
		
			local selectedPlayers = basePnl:GetSelectedPlayers()
			local shouldSelect = #selectedPlayers ~= #basePnl.plyButtons

			for i=1, #basePnl.plyButtons do
				
				local btn = basePnl.plyButtons[i]
				btn:DoClick(shouldSelect)
				
			end
			
		end
		
	end
	
	local playerScrollPnl = vgui.Create("DScrollPanel",basePnl)
	playerScrollPnl:SetPos(0,nameSearch:GetTall())
	playerScrollPnl:SetSize(w,h-nameSearch:GetTall())
	playerScrollPnl:SetPaintBackground(false)
	CL_HADEZ:SkinScrollPanel(playerScrollPnl)
	
	local lastPressedBtn
	
	function basePnl:FillRows()
	
		playerScrollPnl:Clear()
		basePnl.plyButtons = {}
		
		local filter = string.Trim( nameSearch:GetText():lower() )
		local plys = table.Copy(player.GetAll()) -- player.GetHumans()
		local canTargetAll = !SH_HADEZ:HasTargetAllRestriction(LocalPlayer(), permissionKey)
		
		table.sort( plys, function(a, b) return a:Nick():lower() < b:Nick():lower() end )
		
		local startY = 0
		for i=1, #plys do
		
			local ply = plys[i]
			
			if ply ~= LocalPlayer() and !canTargetAll then continue end
			if (!canTargetSelf and ply == LocalPlayer()) then continue end
			if SH_HADEZ:IsLSACBot(ply) then continue end
		
			-- Filter
			if #filter > 0 and string.find( ply:Nick():lower(), filter, 1, true ) == nil then
				continue
			end
			
			local plyName = string.sub(ply:Nick(),1,45)
			local plyBtn = vgui.Create("DButton",playerScrollPnl)
			plyBtn:SetPos(0,startY)
			plyBtn:SetSize(playerScrollPnl:GetWide(),25)
			plyBtn:SetText(plyName)
			plyBtn:SetFont("z_hadez_playerSearchName")
			plyBtn:SetTextColor(color_white)
			plyBtn:SetPaintBackground(false)
			plyBtn:SetContentAlignment(4)
			plyBtn:SetTextInset(8, 0)
			
			table.insert(basePnl.plyButtons, plyBtn)
			
			plyBtn.Think = function()
			
				if !IsValid(ply) then
					plyBtn:SetText(plyName.." (disconnected)")
					return
				end
				
				local canClick, canClickTxt = canClickFunc(ply)
				
				if canClickTxt and #canClickTxt > 0 then
					plyBtn:SetText(plyName.." "..canClickTxt)
				else
					plyBtn:SetText(plyName)
				end
				
			end
			
			local normalCol, hoverCol = ColorAlpha(color_black,100), ColorAlpha(SH_HADEZ.VAR.COLOR.LIGHTBLUE,100)
			plyBtn.Paint = function(self, w, h)
				draw.RoundedBox( 4, 4, 2, w-8, h-4, !self:IsHovered() and normalCol or hoverCol )
			end
			
			local selectedPlayers = basePnl:GetSelectedPlayers()
			plyBtn.DoClick = function(self, forcedSelect)
				
				if !IsValid(ply) or !canClickFunc(ply) then return end
			
				if !table.HasValue(selectedPlayers, ply) then
				
					if forcedSelect == false then return end
				
					-- Automatic unselect
					if !canSelectMultiple and #selectedPlayers > 0 and IsValid(lastPressedBtn) then 
						lastPressedBtn:DoClick()
					end
				
					plyBtn:SetTextColor(SH_HADEZ.VAR.COLOR.RED)
					table.insert(selectedPlayers, ply)
					basePnl:OnSelectedPlayersUpdate()
					lastPressedBtn = plyBtn
					
				else

					if forcedSelect == true then return end

					plyBtn:SetTextColor(color_white)
					table.RemoveByValue(selectedPlayers, ply)
					basePnl:OnSelectedPlayersUpdate()
					
				end
				
			end
			
			-- update color on btn recreation
			if table.HasValue(selectedPlayers,ply) then
				plyBtn:SetTextColor(SH_HADEZ.VAR.COLOR.RED)
				lastPressedBtn = plyBtn
			end
			
			startY = startY + plyBtn:GetTall()
		
		end
	
	end
	
	basePnl:FillRows()
	
	return basePnl

end

local sliderToggleBG = surface.GetTextureID("z_hadez/menu/slider_toggle_bg.vmt")
local devilCircle = surface.GetTextureID("z_hadez/menu/devil_circle.vmt")

function CL_HADEZ:CreateTogglePanel(x, y, w, h, preferenceKey, parent, canChangeFunc)
	
	local toggleW, toggleH  = 35, 40
	local sliderX = w-toggleW-8
	local circleSize, circleX = 22, sliderX
	local nextCircleAnimate = 0
	local sliderBGCol, circleCol =  SH_HADEZ.VAR.COLOR.GREY, SH_HADEZ.VAR.COLOR.DARKGREY
	canChangeFunc = canChangeFunc or function() return true end
	
	local basePnl = vgui.Create("DPanel", parent)
	basePnl:SetPos(x, y)
	basePnl:SetSize(w,h)
	basePnl:SetPaintBackground(false)
	basePnl.isEnabled = false
	
	local function CanChangeToggle()
		if SH_HADEZ:IsRestrictedForPly(LocalPlayer(), preferenceKey) then
		
			if basePnl.IsEnabled then
				basePnl:SetEnabled(false)
			end
		
			return false
		end
		
		return canChangeFunc()
	end
	
	function basePnl:OnChange(value)
		
	end
	
	function basePnl:SetEnabled(value)
		self.isEnabled = value
		
		CL_HADEZ:SetPreference(preferenceKey, value)
		
		self:OnChange(value)
	end
	
	function basePnl:IsEnabled()
		return self.isEnabled
	end
	
	basePnl.Think = function(self)
	
		if nextCircleAnimate < CurTime() then
			
			if self:IsEnabled() then
				circleX = math.Approach(circleX, sliderX+toggleW-circleSize, 3)
				sliderBGCol = LerpVector( 0.2, sliderBGCol:ToVector(), SH_HADEZ.VAR.COLOR.RED:ToVector() ):ToColor()
				circleCol = LerpVector( 0.2, circleCol:ToVector(), color_white:ToVector() ):ToColor()
			else
				circleX = math.Approach(circleX, sliderX, 3)
				sliderBGCol = LerpVector( 0.2, sliderBGCol:ToVector(), SH_HADEZ.VAR.COLOR.GREY:ToVector() ):ToColor()
				circleCol = LerpVector( 0.2, circleCol:ToVector(), SH_HADEZ.VAR.COLOR.DARKGREY:ToVector() ):ToColor()
			end
			
			nextCircleAnimate = CurTime() + 0.033
		end
	
	end
	basePnl.Paint = function(self, w, h)
		-- BG
		draw.RoundedBox( 8, 2, 2, w-4, h-4, SH_HADEZ.VAR.COLOR.LESSDARKY )
		
		-- Slider bg
		surface.SetDrawColor(ColorAlpha(sliderBGCol,150))
		surface.SetTexture(sliderToggleBG)
		surface.DrawTexturedRect( sliderX, h/2-toggleH/2, toggleW, toggleH )
		
		-- Slider circle 
		surface.SetDrawColor(circleCol)
		surface.SetTexture(devilCircle)
		surface.DrawTexturedRect( circleX, h/2-circleSize*0.525, circleSize, circleSize )
		
	end
	
	local titleLbl = vgui.Create("DLabel", basePnl)
	titleLbl:SetPos(8,0)
	titleLbl:SetText(SH_HADEZ:Translate(preferenceKey))
	titleLbl:SetFont("z_hadez_sliderText")
	titleLbl:SizeToContents()
	titleLbl:SetTall(h)
	titleLbl:SetColor(color_white)
	basePnl.titleLbl = titleLbl
	
	local slideBtn = vgui.Create("DButton",basePnl)
	slideBtn:SetPos(0,0)
	slideBtn:SetSize(w,h)
	slideBtn:SetText('')
	slideBtn:SetPaintBackground(false)
	basePnl.slideBtn = slideBtn
	
	slideBtn.Paint = function(self, w, h)
		if !CanChangeToggle() then
			self:SetCursor("arrow")
			draw.RoundedBox( 8, 2, 2, w-4, h-4, ColorAlpha(color_black,150) )
		else
			self:SetCursor("hand")
		end
	end
	
	slideBtn.DoClick = function()
		if !CanChangeToggle() then return end
		basePnl:SetEnabled(!basePnl:IsEnabled())
	end
	
	if CL_HADEZ:HasPreference(preferenceKey) then
	
		basePnl:SetEnabled(CL_HADEZ:GetPreference(preferenceKey))
		
		if basePnl:IsEnabled() then
			circleX = sliderX+toggleW-circleSize
			sliderBGCol = SH_HADEZ.VAR.COLOR.RED
			circleCol = color_white
		end
		
	else
		
		if preferenceKey ~= "_" then
		
			-- Enable all options by default
			basePnl:SetEnabled(true)
			
		end
		
	end
	
	return basePnl
	
end

function CL_HADEZ:CreateActionButton(x, y, txt, parent)

	local actionBtn = vgui.Create("DButton", parent)
	actionBtn:SetPos(x, y)
	actionBtn:SetSize(0, 40)
	actionBtn:SetText(txt)
	actionBtn:SetFont("z_hadez_menuTabTitle")
	actionBtn:SetTextColor(SH_HADEZ.VAR.COLOR.RED)
	
	function actionBtn:TextThink()
		-- overriding
	end
	
	actionBtn.Think = function(self)
		
		if self:IsHovered() then
			self:SetTextColor(SH_HADEZ.VAR.COLOR.LIGHTBLUE)
		else
			self:SetTextColor(SH_HADEZ.VAR.COLOR.RED)
		end
		
		self:TextThink()
		
		self:SizeToContentsX()
		self:SetWide(self:GetWide()+40)
		self:SetPos(x-self:GetWide()/2,y)
		
	end
	
	actionBtn.Paint = function(self, w, h)
		draw.RoundedBox( 6, 0, 0, w, h, SH_HADEZ.VAR.COLOR.DARKY)
	end
	
	return actionBtn

end

function CL_HADEZ:CreateComboBox(x, y, w, h, preferenceKey, options, parent, canChangeFunc)

	local comboBox = vgui.Create("DComboBox", parent)
	comboBox:SetPos( x, y )
	comboBox:SetSize( w, h )
	comboBox:SetTextColor(color_white)
	comboBox:SetFont("z_hadez_binderText")
	comboBox:SetValue(CL_HADEZ:GetPreference(preferenceKey) or "")
	comboBox:SetSortItems( false )
	canChangeFunc = canChangeFunc or function() return true end
	
	local __oldDoClick = comboBox.DoClick
	comboBox.DoClick = function(self)
		
		if !canChangeFunc() then return end
		
		__oldDoClick(self)
		
	end
	
	local disabledTextCol = Color(175,175,175)
	comboBox.Paint = function(self, w, h)
	
		draw.RoundedBox( 8, 2, 2, w-4, h-4, SH_HADEZ.VAR.COLOR.LESSDARKY )
		
		if !canChangeFunc() then
			self:SetCursor("arrow")
			draw.RoundedBox( 8, 2, 2, w-4, h-4, ColorAlpha(color_black,150) )
			self:SetTextColor(disabledTextCol)
		else
			self:SetCursor("hand")
			self:SetTextColor(color_white)
		end
		
	end
	
	comboBox.RefreshOptions = function(self)
		
		local selectedOption = comboBox:GetValue()
		comboBox:Clear()
		comboBox:SetValue(selectedOption)
		
		local restrictionValue = SH_HADEZ:IsRestrictedForPly(LocalPlayer(), preferenceKey)
		
		for i=1, #options do
		
			local option = options[i]
			
			if option ~= selectedOption then
				comboBox:AddChoice(option)
			end
			
			-- Option restrictions
			if option == restrictionValue then
				break
			end
			
		end
		
	end
	comboBox:RefreshOptions()
	
	comboBox.OnSelect = function( self, index, value, func )
		
		CL_HADEZ:SetPreference(preferenceKey, value)
		self:RefreshOptions()
		
	end
	
	function comboBox:SubChildFunc(subChild)
		-- overriding
	end
	
	local oldOpenMenu = comboBox.OpenMenu
	comboBox.OpenMenu = function( self, pControlOpener )
	
		-- create & open menu
		oldOpenMenu(self,pControlOpener)
		
		-- style menu
		if self.Menu ~= nil then
		
			-- restyle the background
			self.Menu.Paint = function(self, w, h)
				
				-- BG
				draw.RoundedBox( 0, 2, 2, w-4, h-4, SH_HADEZ.VAR.COLOR.LIGHTYDARK )
				
			end
			
			local basePanel = self.Menu:GetChildren()[1]
			local menuOptionPanels = self.Menu:GetChildren()
			
			for _, child in pairs(menuOptionPanels) do
			
				if child:GetClassName() == "Panel" then
				
					for _, subChild in pairs(child:GetChildren()) do
						
						local class = subChild:GetClassName()
						
						-- change the text color of the label
						if class == "Label" then
							subChild:SetFont("z_hadez_binderText")
							subChild:SetTextColor(color_white)	
							comboBox:SubChildFunc(subChild)
						end
						
					end
					
				end
				
			end
		end
	end

	return comboBox

end

local prevWarning

function CL_HADEZ:CreateWarningMessage(txt)

	if prevWarning and prevWarning:IsValid() then
		prevWarning:Remove()
	end

	local x, y = input.GetCursorPos()
	
	local warningLbl = vgui.Create("DLabel")
	warningLbl:SetText(txt)
	warningLbl:SetFont("z_hadez_warningMessage")
	warningLbl:SizeToContents()
	warningLbl:SetSize(warningLbl:GetWide()+16,warningLbl:GetTall()+6)
	warningLbl:SetColor(color_white)
	warningLbl:SetPos(x-warningLbl:GetWide()/2, y-warningLbl:GetTall()-20)
	warningLbl:SetContentAlignment(5)
	warningLbl:MakePopup()
	prevWarning = warningLbl
	
	warningLbl.Think = function(self)
		
		if !CL_HADEZ:MenuIsOpen() then
			self:Remove()
		end
	
		warningLbl:MoveToFront()
	end
	
	warningLbl.Paint = function(self, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, SH_HADEZ.VAR.COLOR.SUPERDARKORGANGE )
	end
	
	timer.Simple(1, function()
		if IsValid(warningLbl) then
			warningLbl:Remove()
		end
	end)
	



end

local darkRedGrunge = Material("z_hadez/raw/dark_red_grunge_bg_faded.png")

function CL_HADEZ:SkinPanel(pnl)

	pnl:SetPaintBackground(false)

	local oldPaint = pnl.Paint 
	pnl.Paint = function(self, w, h)
	
		-- BG Texture
		surface.SetDrawColor(color_white)
		surface.SetMaterial(darkRedGrunge)
		surface.DrawTexturedRect( 0, 0, w, h )
		
		oldPaint(self, w, h)
		
	end

end

function CL_HADEZ:SkinScrollPanel(scrollP)
	
	local sbar = scrollP:GetVBar()
	
	sbar:SetWide(3)
	sbar:SetHideButtons( true )
	
	function sbar:Paint( w, h )
	end
	
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 2, 0, 0, w, h, SH_HADEZ.VAR.COLOR.LIGHTGREY )
	end
	
	return sbar

end