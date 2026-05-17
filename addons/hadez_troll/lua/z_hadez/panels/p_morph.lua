-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}
local modelInputText = ""

CL_HADEZ:AddMenuTab("p_hadez_morph","z_hadez/tabs/morph.vmt","morph")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		return true, SH_HADEZ:IsMorphed(ply) and "(Morphed)" or ""
		
	end, "morph")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,110)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return true
	end
	
	-- Model choice
	if !CL_HADEZ:HasPreference("morphModel") then
		CL_HADEZ:SetPreference("morphModel", SH_HADEZ:GetMorphModelNames()[1])
	end
	
	-- Options
	local moveToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "morphMove", togglePanel, CanChangeFunc)
	local modelSelection = CL_HADEZ:CreateComboBox(5, 40, togglePanel:GetWide()-10, 30, "morphModel", SH_HADEZ:GetMorphModelNames(), togglePanel, CanChangeFunc)
	
	local inputPnl = vgui.Create("DPanel", togglePanel)
	inputPnl:SetPos(5,75)
	inputPnl:SetSize(togglePanel:GetWide()-10, 30)
	inputPnl.Paint = function(self, w, h)
		draw.RoundedBox( 8, 2, 2, w-4, h-4, SH_HADEZ.VAR.COLOR.LESSDARKY )
	end
	
	local modelInput = vgui.Create("DTextEntry",inputPnl)
	modelInput:SetPos(5,5)
	modelInput:SetSize(inputPnl:GetWide()-10,inputPnl:GetTall()-10)
	modelInput:SetFont("z_hadez_playerSearchBar")
	modelInput:SetTextColor(color_white)
	modelInput:SetTextInset(20,0)
	modelInput:SetValue(modelInputText)
	modelInput:SetPaintBackground(false)
	modelInput:SetPlaceholderText(SH_HADEZ:Translate("morphModelInput"))
	modelInput.m_colCursor = color_white
	modelInput.m_colPlaceholder = SH_HADEZ.VAR.COLOR.LIGHTGREY
	
	modelInput.Think = function(self) 
	
		if util.IsValidModel(modelInputText) then
			modelInput.HasValidModel = true
			modelInput:SetTextColor(SH_HADEZ.VAR.COLOR.GREEN)
		else
			modelInput.HasValidModel = false
			modelInput:SetTextColor(SH_HADEZ.VAR.COLOR.RED)
		end
	
	end
	
	modelInput.OnChange = function(self)
	
		modelInputText = self:GetValue()
		
		net.Start("z_hadez_MorphValidateModel")
			net.WriteString(modelInputText)
		net.SendToServer()
		
	end
	
	-- Morph btn
	local morphBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("morphPlayer"), self)
	morphBtn.TextThink = function(self)

		if #selectedPlayers < 2 then
			self:SetText(SH_HADEZ:Translate("morphPlayer"))
		else
			self:SetText(SH_HADEZ:Translate("morphPlayers"))
		end

	end
	
	morphBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		local morphTranslation = modelSelection:GetValue()
		local morphModel = SH_HADEZ:GetMorphModelFromTranslation(morphTranslation)
		
		if modelInput.HasValidModel then
			morphModel = modelInput:GetValue()
		end
		
		-- send msg to server
		net.Start("z_hadez_MorphPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(moveToggle:IsEnabled())
			net.WriteString(morphModel)
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_morph",PANEL,"DScrollPanel")