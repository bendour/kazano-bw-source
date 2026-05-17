-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

local redGrungeBG = Material("z_hadez/raw/red_grunge_bg_faded.png")
local gradientCenter = surface.GetTextureID("gui/center_gradient.vmt")
local gradientUp = surface.GetTextureID("gui/gradient_up.vmt")
local selectedRowID, selectedPermissionID, selectedPlayerName
local settingsPanel

function PANEL:Init(realInit)

	if !realInit then return end
	settingsPanel = self
	
	// Players-teams-ranks
	local playerTeamRankPnl = vgui.Create("DPanel",self)
	playerTeamRankPnl:SetPos(self:GetWide()*0.05,8)
	playerTeamRankPnl:SetSize(self:GetWide()*0.4,self:GetTall()*0.92)
	playerTeamRankPnl:SetPaintBackground(true)
	playerTeamRankPnl.Paint = function(self, w, h)
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
	
	local idSearch = vgui.Create("DTextEntry",playerTeamRankPnl)
	idSearch:SetPos(4,0)
	idSearch:SetSize(playerTeamRankPnl:GetWide()-8,30)
	idSearch:SetFont("z_hadez_playerSearchBar")
	idSearch:SetTextColor(color_white)
	idSearch:SetPaintBackground(false)
	idSearch:SetPlaceholderText(SH_HADEZ:Translate("search"))
	
	idSearch.m_colCursor = color_white
	idSearch.m_colPlaceholder = SH_HADEZ.VAR.COLOR.LIGHTGREY
	
	local oldPaint = idSearch.Paint
	idSearch.Paint = function(self, w, h)
		
		-- Center gradient
		surface.SetDrawColor(ColorAlpha(SH_HADEZ.VAR.COLOR.LIGHTGREY,150))
		surface.SetTexture(gradientCenter)
		surface.DrawTexturedRect( 0, h-1, w, 1 )
		
		-- Input box
		oldPaint(self,w,h)
		
	end
	
	idSearch.OnChange = function(self)
		playerTeamRankPnl:FillRows()
	end
	
	local playerScrollPnl = vgui.Create("DScrollPanel",playerTeamRankPnl)
	playerScrollPnl:SetPos(0,idSearch:GetTall())
	playerScrollPnl:SetSize(playerTeamRankPnl:GetWide(),playerTeamRankPnl:GetTall()-idSearch:GetTall())
	playerScrollPnl:SetPaintBackground(false)
	CL_HADEZ:SkinScrollPanel(playerScrollPnl)
	
	local playersAndGroups = SH_HADEZ:GetPlayersAndGroups()
	local normalCol, hoverCol = ColorAlpha(color_black,100), ColorAlpha(SH_HADEZ.VAR.COLOR.LIGHTBLUE,100)
	local lastPressedBtn
	
	table.sort( playersAndGroups, function(a, b)
		
		local aId, aName, aIsSteamID = a[1], a[2], SH_HADEZ:IsSteamID(a[1])
		local bId, bName, bIsSteamID = b[1], b[2], SH_HADEZ:IsSteamID(b[1])
		
		if aIsSteamID and !bIsSteamID then
			return false
		end
	
		if aId == bId or (aIsSteamID and bIsSteamID) then
			return aName:lower() < bName:lower()
		else		
			return tostring(aId) < tostring(bId)
		end
		
	end )
	
	function playerTeamRankPnl:FillRows()
	
		playerScrollPnl:Clear()
		playerTeamRankPnl.plyButtons = {}
		
		local filter = string.Trim( idSearch:GetText():lower() )
		
		local startY = 0
		for i=1, #playersAndGroups do
		
			local id, name = playersAndGroups[i][1], playersAndGroups[i][2]
			local rowID = tostring(id)..name
			
			-- Filter
			if #filter > 0 and string.find( (isstring(id) and id:lower() or id), filter, 1, true ) == nil and string.find( name:lower(), filter, 1, true ) == nil then
				continue
			end
			
			local rowBtn
			local rowPnl = vgui.Create("DPanel", playerScrollPnl)
			rowPnl:SetPos(0,startY)
			rowPnl:SetSize(playerScrollPnl:GetWide(),25)
			rowPnl.Paint = function(self, w, h)
				draw.RoundedBox( 4, 4, 2, w-8, h-4, !rowBtn:IsHovered() and normalCol or hoverCol )
			end
			
			startY = startY + rowPnl:GetTall()
			
			local idLbl = vgui.Create("DLabel", rowPnl)
			idLbl:SetPos(0,0)
			idLbl:SetTextInset(8, 0)
			idLbl:SetSize(rowPnl:GetWide()/2-8, rowPnl:GetTall())
			idLbl:SetText(id)
			idLbl:SetFont("z_hadez_playerID")
			
			local nameLbl = vgui.Create("DLabel", rowPnl)
			nameLbl:SetPos(rowPnl:GetWide()*0.35,0)
			nameLbl:SetTextInset(8, 0)
			nameLbl:SetSize(rowPnl:GetWide()*0.65, rowPnl:GetTall())
			nameLbl:SetText(name)
			nameLbl:SetColor(color_white)
			nameLbl:SetFont("z_hadez_playerSearchName")
			
			rowBtn = vgui.Create("DButton",rowPnl)
			rowBtn:Dock( FILL )
			rowBtn:SetText("")
			rowBtn:SetPaintBackground(false)
			rowBtn.DoClick = function(self, forcedSelect)
				
				if forcedSelect == false then
					idLbl:SetTextColor(color_white)
					nameLbl:SetTextColor(color_white)
					return
				end
				
				if selectedRowID ~= rowID or forcedSelect == true then
				
					-- Automatic unselect
					if IsValid(lastPressedBtn) then 
						lastPressedBtn:DoClick(false)
					end
					
					idLbl:SetTextColor(SH_HADEZ.VAR.COLOR.RED)
					nameLbl:SetTextColor(SH_HADEZ.VAR.COLOR.RED)
					
					selectedRowID = rowID
					lastPressedBtn = self
					
					if SH_HADEZ:IsSteamID(id) then
						selectedPermissionID = id
						selectedPlayerName = name
					else
						selectedPermissionID = name
						selectedPlayerName = ""
					end
					
				end
				
			end
			
			if selectedRowID == rowID then
				rowBtn:DoClick(true)
				playerScrollPnl:ScrollToChild(rowPnl)
			end
		
		end
	
	end
	
	playerTeamRankPnl:FillRows()
	
	// Permissions
	local permissionPnl = vgui.Create("DPanel",self)
	permissionPnl:SetPos(self:GetWide()*0.49,10)
	permissionPnl:SetSize(355,self:GetTall()*0.92)
	permissionPnl.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local togglePnl = vgui.Create("DScrollPanel",permissionPnl)
	togglePnl:SetPos(2,7)
	togglePnl:SetSize(permissionPnl:GetWide()-4,permissionPnl:GetTall()-40)
	togglePnl.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end

	local sbar = CL_HADEZ:SkinScrollPanel(togglePnl)
	sbar:SetWide(2)
	
	local function CanChangeFunc()
		return selectedRowID and LocalPlayer():IsSuperAdmin()
	end
	
	local function OpenRestrictions(permID, permKey)
		local restrictionFrame = vgui.Create("p_hadez_restrictions")
		restrictionFrame.permissionKey = permKey
		restrictionFrame.permissionID = permID
		restrictionFrame:Init(true)
	end
	
	local permissionInfo = SH_HADEZ:GetPermissionInfo()
	local permToggles = {}
	local toggleW, rightRowX = togglePnl:GetWide()/2-7.5, togglePnl:GetWide()/2+2
	local i, yPos = 0, 0
	
	for key, name in SortedPairsByValue(permissionInfo, false) do
	
		i = i + 1
		
		local xPos = i%2 == 0 and rightRowX or 4
		
		if i%2 ~= 0 and i > 1 then
			yPos = yPos + 28 + 4
		end

		local permToggle = CL_HADEZ:CreateTogglePanel(xPos, yPos, toggleW, 28, "_", togglePnl, CanChangeFunc)
		permToggle.titleLbl:SetText(name)
		permToggle.titleLbl:SetFont("z_hadez_playerSearchName")
		permToggle.titleLbl:SizeToContentsX()
		permToggle.slideBtn.isUpdatingData = false
		permToggle.permissionKey = key
		permToggle.slideBtn.Think = function(self)
			
			if self.isUpdatingData then return end
			
			local permissions = SH_HADEZ:GetPermissions()
			
			if selectedPermissionID then
				permToggle.isEnabled = permissions[selectedPermissionID] and permissions[selectedPermissionID][key]
			end
			
		end
		
		permToggle.slideBtn.DoClick = function(self, blockNetUpdate)
		
			if !CanChangeFunc() then return end
			
			local permissions = SH_HADEZ:GetPermissions()
			self.isUpdatingData = true
			permToggle.isEnabled = !permToggle.isEnabled
			
			permissions[selectedPermissionID] = permissions[selectedPermissionID] or {}
			
			if permToggle.isEnabled then
				
				-- Dont wait for server
				permissions[selectedPermissionID][key] = true
				
				if !blockNetUpdate then
					net.Start("z_hadez_AddPermission")
				end
			
			else
			
				-- Dont wait for server
				permissions[selectedPermissionID][key] = nil
			
				if !blockNetUpdate then
					net.Start("z_hadez_RemovePermission")
				end
			
			end
			
			if !blockNetUpdate then
				net.WriteString(selectedPermissionID)
				net.WriteString(key)
				net.WriteString(selectedPlayerName)
				net.SendToServer()
			end
			
			timer.Simple(1, function()
				
				if IsValid(self) then
					self.isUpdatingData = false
				end
				
			end)
			
			-- open permission restrictions
			if !blockNetUpdate and permToggle.isEnabled then
				OpenRestrictions(selectedPermissionID, key)		
			end
			
		end
		
		permToggle.slideBtn.DoRightClick = function(self)
			if !CanChangeFunc() then return end
			OpenRestrictions(selectedPermissionID, key)
		end
		
		permToggles[i] = permToggle
		
	end
	
	local toggleButton = vgui.Create("DButton", permissionPnl)
	toggleButton:SetSize(permissionPnl:GetWide()-16, 22)
	toggleButton:SetPos(8, permissionPnl:GetTall()-28)
	toggleButton:SetFont("z_hadez_playerSearchName")
	toggleButton:SetText(SH_HADEZ:Translate("toggle"):upper())
	toggleButton:SetColor(SH_HADEZ.VAR.COLOR.RED)
	toggleButton.Paint = function(self, w, h)
	
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.LIGHTYDARK )
	
		if !CanChangeFunc() then
			self:SetCursor("arrow")
			draw.RoundedBox( 8, 0, 0, w, h, ColorAlpha(color_black,200) )
		else
			self:SetCursor("hand")
		end
		
	end
	toggleButton.DoClick = function(self)
	
		for i=1, #permToggles do
		
			local permToggle = permToggles[i]
			permToggle.slideBtn:DoClick(true)
		
		end
		
		
		net.Start("z_hadez_ToggledPermissions")
			net.WriteString(selectedPermissionID)
			net.WriteString(selectedPlayerName)
			
			for i=1, #permToggles do
				local permToggle = permToggles[i]
				
				net.WriteString(permToggle.permissionKey)
				net.WriteBool(permToggle.isEnabled)
			end
		net.SendToServer()
	
	end
	
end
vgui.Register("p_hadez_settings",PANEL,"DScrollPanel")