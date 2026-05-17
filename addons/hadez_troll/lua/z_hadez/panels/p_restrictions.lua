-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()

local gradientDown = surface.GetTextureID("gui/gradient_down.vmt")

local settingsBtnIcon = "z_hadez/menu/settings"
local closeBtnIcon = "z_hadez/menu/skull"

local menuW, menuH = 300,200
local menuAnimSpeed = 0.2
local restrictionPanel

local function VGUIMousePressed(pnl, mouseCode)
	if IsValid(restrictionPanel) then
		if pnl:GetName() ~= "p_hadez_restrictions" and !pnl:HasParent(restrictionPanel) then
			restrictionPanel:Remove()
			restrictionPanel = nil
		end
	end
end
hook.Add("VGUIMousePressed", "z_hadez_Restrictions", VGUIMousePressed)

local function CreateRestrictionToggleButton(restrictionKey, yPos, parent)
	
	local restrictionToggle = CL_HADEZ:CreateTogglePanel(5, yPos, parent:GetWide()-10, 28, "_", parent)
	restrictionToggle.titleLbl:SetText(SH_HADEZ:Translate(restrictionKey))
	restrictionToggle.titleLbl:SetFont("z_hadez_playerSearchName")
	restrictionToggle.titleLbl:SizeToContentsX()
	restrictionToggle.slideBtn.isUpdatingData = false
	
	restrictionToggle.slideBtn.Think = function(self)
	
		if self.isUpdatingData then return end
		
		local restrictions = SH_HADEZ:GetRestrictions()
			
		if restrictions[parent.permissionID] and restrictions[parent.permissionID][parent.permissionKey] and restrictions[parent.permissionID][parent.permissionKey][restrictionKey] then
			restrictionToggle.isEnabled = false
		else
			restrictionToggle.isEnabled = true
		end
		
	end
	
	restrictionToggle.slideBtn.DoClick = function(self, blockNetUpdate)
		
		local restrictions = SH_HADEZ:GetRestrictions()
		self.isUpdatingData = true
		restrictionToggle.isEnabled = !restrictionToggle.isEnabled
		local isRestricted = !restrictionToggle.isEnabled
		
		restrictions[parent.permissionID] = restrictions[parent.permissionID] or {}
		restrictions[parent.permissionID][parent.permissionKey] = restrictions[parent.permissionID][parent.permissionKey] or {}
		restrictions[parent.permissionID][parent.permissionKey][restrictionKey] = isRestricted and true or nil
		
		net.Start("z_hadez_UpdateRestrictions")
			net.WriteString(parent.permissionID)
			net.WriteString(parent.permissionKey)
			net.WriteString(restrictionKey)
			net.WriteString(isRestricted and "1" or "0")
		net.SendToServer()
		
		timer.Simple(1, function()
			if IsValid(self) then
				self.isUpdatingData = false
			end
		end)
		
	end
	
	return restrictionToggle

end

local function CreateRestrictionComboBox(restrictionTbl, yPos, parent)

	local restrictionKey, restrictionValues = restrictionTbl.id, restrictionTbl.values
	local restrictionSelection = CL_HADEZ:CreateComboBox(5, yPos, parent:GetWide()-10, 28, "_", restrictionValues, parent)
	restrictionSelection.isUpdatingData = false
	
	restrictionSelection:SetValue(restrictionValues[#restrictionValues])
	restrictionSelection.Think = function(self)
	
		if self.isUpdatingData then return end
		
		local restrictions = SH_HADEZ:GetRestrictions()
			
		if restrictions[parent.permissionID] and restrictions[parent.permissionID][parent.permissionKey] and restrictions[parent.permissionID][parent.permissionKey][restrictionKey] then
			restrictionSelection:SetValue(restrictions[parent.permissionID][parent.permissionKey][restrictionKey])
		end
		
	end
	
	restrictionSelection.OnSelect = function( self, index, value, func )

		net.Start("z_hadez_UpdateRestrictions")
			net.WriteString(parent.permissionID)
			net.WriteString(parent.permissionKey)
			net.WriteString(restrictionKey)
			net.WriteString(value)
		net.SendToServer()
		
		self.isUpdatingData = true
		
		timer.Simple(1, function()
			if IsValid(self) then
				self.isUpdatingData = false
			end
		end)
		
		self:RefreshOptions()
		
	end

end

function PANEL:Init(realInit)

	if !realInit then return end
	local permName = SH_HADEZ:GetPermissionName(self.permissionKey)
	local permRestrictions = SH_HADEZ:GetPermRestrictions(self.permissionKey)
	
	if table.Count(permRestrictions) == 0 then 
		self:Remove()
		return 
	end
	
	if IsValid(restrictionPanel) then
		restrictionPanel:Remove()
		restrictionPanel = nil
	end
	
	restrictionPanel = self
	
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSize(menuW,menuH)
	self:Center()
	self.Paint = function(self, w, h) 
		-- BG
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.DARK)
		
		surface.SetFont("z_hadez_restrictionsTitle")
		surface.SetTextColor( 255, 255, 255 )
		surface.SetTextPos( 8, 8 )
		surface.DrawText(permName.." restrictions")
	end
	
	-- Animate alpha
	self:SetAlpha(0)
	self:AlphaTo(255, menuAnimSpeed)
	
	self:MoveToFront()
	self:MakePopup()
	
	local extraY = 28
	
	-- Power Restrictions
	for _, restriction in ipairs(permRestrictions) do
	
		if !istable(restriction) then
			CreateRestrictionToggleButton(restriction, 5+extraY, self)
		else
			CreateRestrictionComboBox(restriction, 5+extraY, self)
		end
		
		extraY = extraY + 33
	
	end
	
	self:SetTall(extraY+5)
	self:Center()
	
	-- Close btn
	local closeBtn = vgui.Create("DImageButton", self)
	closeBtn:SetPos( menuW-26, 4 )
	closeBtn:SetSize( 20, 20 )
	closeBtn:SetColor(ColorAlpha(SH_HADEZ.VAR.COLOR.RED,150))
	closeBtn:SetImage( closeBtnIcon )	
	closeBtn.DoClick = function()
		self:Close()
	end
	
end
vgui.Register("p_hadez_restrictions",PANEL,"DFrame")