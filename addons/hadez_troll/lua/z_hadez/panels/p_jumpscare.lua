-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_jumpscare","z_hadez/tabs/jumpscare.vmt","jumpscare")

local function CreateLabeledCombobox(x, y, w, h, preferenceKey, options, parent, canChangeFunc)
	
	local lbl = vgui.Create("DLabel", parent)
	lbl:SetPos(x+2, y+1)
	lbl:SetFont("z_hadez_playerSearchBar")
	lbl:SetColor(SH_HADEZ.VAR.COLOR.RED)
	lbl:SetText(SH_HADEZ:Translate(preferenceKey))
	lbl:SetContentAlignment(4)
	lbl:SizeToContentsX()
	
	local newComboW = w - lbl:GetWide() - 7
	local newComboX = x + lbl:GetWide() + 7
	
	local comboBox = CL_HADEZ:CreateComboBox(newComboX, y, newComboW, h, preferenceKey, options, parent, canChangeFunc)
	comboBox.extraLbl = lbl
	
	return comboBox

end

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		return true, SH_HADEZ:IsJumpscared(ply) and "(Jumpscared)" or ""
		
	end, "jumpscare")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,250)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:IsJumpscared(LocalPlayer())
	end
	
	local instantSoundEffects, longSoundEffects = SH_HADEZ:GetJumpscareSounds()
	
	-- Set default values
	CL_HADEZ:GetPreference("jumpscareMode", SH_HADEZ:GetJumpscareModes()[1])
	CL_HADEZ:GetPreference("jumpscareInstantSound", instantSoundEffects[1])
	CL_HADEZ:GetPreference("jumpscareLongSound", longSoundEffects[1])
	CL_HADEZ:GetPreference("jumpscareLongSoundExtra", instantSoundEffects[1])
	CL_HADEZ:GetPreference("jumpscareVisual", SH_HADEZ:GetJumpscareVisuals()[1])
	
	local selectionButtons = {}
	
	local function CreateInstantJumpscareOptions()
		selectionButtons.modeSelection = CreateLabeledCombobox(5, 5, togglePanel:GetWide()-10, 24, "jumpscareMode", SH_HADEZ:GetJumpscareModes(), togglePanel, CanChangeFunc)
		selectionButtons.soundSelection = CreateLabeledCombobox(5, 34, togglePanel:GetWide()-10, 24, "jumpscareInstantSound", instantSoundEffects, togglePanel, CanChangeFunc)
		selectionButtons.visualSelection = CreateLabeledCombobox(5, 63, togglePanel:GetWide()-10, 24, "jumpscareVisual", SH_HADEZ:GetJumpscareVisuals(), togglePanel, CanChangeFunc)
		togglePanel:SetTall(226)
	end
	
	local function CreateSlowJumpscareOptions()
		selectionButtons.modeSelection = CreateLabeledCombobox(5, 5, togglePanel:GetWide()-10, 24, "jumpscareMode", SH_HADEZ:GetJumpscareModes(), togglePanel, CanChangeFunc)
		selectionButtons.soundSelection = CreateLabeledCombobox(5, 34, togglePanel:GetWide()-10, 24, "jumpscareLongSound", longSoundEffects, togglePanel, CanChangeFunc)
		selectionButtons.extraSoundSelection = CreateLabeledCombobox(5, 63, togglePanel:GetWide()-10, 24, "jumpscareLongSoundExtra", instantSoundEffects, togglePanel, CanChangeFunc)
		selectionButtons.visualSelection = CreateLabeledCombobox(5, 92, togglePanel:GetWide()-10, 24, "jumpscareVisual", SH_HADEZ:GetJumpscareVisuals(), togglePanel, CanChangeFunc)
		togglePanel:SetTall(250)
	end 
	
	-- Preview image
	local previewW, previewH = 180, 120
	local visualPreviewImg = vgui.Create("DImage", togglePanel)
	visualPreviewImg:SetSize(previewW, previewH)
	visualPreviewImg:SetImage("z_hadez/jumpscare/"..CL_HADEZ:GetPreference("jumpscareVisual"))
	
	local function CreateOptionButtons(mode)
	
		for _, button in pairs(selectionButtons) do
			if button.extraLbl ~= nil then
				button.extraLbl:Remove()
			end
			button:Remove()
		end
		
		if mode == "instant" then
			CreateInstantJumpscareOptions()
		else
			CreateSlowJumpscareOptions()
		end
		
		-- Reposition preview
		visualPreviewImg:SetPos(togglePanel:GetWide()/2-previewW/2, togglePanel:GetBottomY()-previewH-18)
		
		-- Recreate buttons when mode changes
		local __oldSelect = selectionButtons.modeSelection.OnSelect
		selectionButtons.modeSelection.OnSelect = function(self, index, value, func)
		
			__oldSelect(self, index, value, func)
			
			CreateOptionButtons(value)
			
		end
		
		-- Change preview image when choice changes
		local __oldSelect = selectionButtons.visualSelection.OnSelect
		selectionButtons.visualSelection.OnSelect = function(self, index, value, func)
		
			__oldSelect(self, index, value, func)
			visualPreviewImg:SetImage("z_hadez/jumpscare/"..value)
			
		end
		
	end
	CreateOptionButtons(CL_HADEZ:GetPreference("jumpscareMode"))
	
	-- Jumpscare
	local jumpscareBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, 280, SH_HADEZ:Translate("jumpscare"), self)
	
	jumpscareBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_JumpscarePlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteString(selectionButtons.modeSelection:GetValue())
			net.WriteString(selectionButtons.soundSelection:GetValue())
			net.WriteString(IsValid(selectionButtons.extraSoundSelection) and selectionButtons.extraSoundSelection:GetValue() or "")
			net.WriteString(selectionButtons.visualSelection:GetValue())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_jumpscare",PANEL,"DScrollPanel")