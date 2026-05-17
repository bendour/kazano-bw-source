-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}
local textInputText = ""

CL_HADEZ:AddMenuTab("p_hadez_hackytext","z_hadez/tabs/hackytext.vmt","hackyText")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
		return true, SH_HADEZ:HasHackyText(ply) and "(Showing)" or ""
	end)
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,0)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return true
	end
	
	-- Text input
	local inputPnl = vgui.Create("DPanel", togglePanel)
	inputPnl:SetPos(5,5)
	inputPnl:SetSize(togglePanel:GetWide()-10, 16*4)
	inputPnl.Paint = function(self, w, h)
		draw.RoundedBox( 8, 2, 2, w-4, h-4, SH_HADEZ.VAR.COLOR.LESSDARKY )
	end
	
	local textInput = vgui.Create("DTextEntry",inputPnl)
	textInput:SetPos(5,5)
	textInput:SetSize(inputPnl:GetWide()-10,inputPnl:GetTall()-10)
	textInput:SetFont("z_hadez_playerSearchBar")
	textInput:SetTextColor(color_white)
	textInput:SetTextInset(20,0)
	textInput:SetValue(textInputText)
	textInput:SetPaintBackground(false)
	textInput:SetPlaceholderText(SH_HADEZ:Translate("hackyTextInput"))
	textInput:SetMultiline(true)
	textInput.m_colCursor = color_white
	textInput.m_colPlaceholder = SH_HADEZ.VAR.COLOR.LIGHTGREY
	
	textInput.OnChange = function(self)
		textInputText = self:GetValue()		
	end
	
	local startY = inputPnl:GetBottomY()+5
	
	-- Default choices
	if !CL_HADEZ:HasPreference("hackyTextSize") then
		CL_HADEZ:SetPreference("hackyTextSize", SH_HADEZ:GetTextSizes()[1])
		CL_HADEZ:SetPreference("hackyTextFont", SH_HADEZ:GetTextFonts()[1])
		CL_HADEZ:SetPreference("hackyTextColor", SH_HADEZ:GetTextColors()[1])
	end

	-- Option Sliders
	local sizeSelection = CL_HADEZ:CreateComboBox(5, startY, togglePanel:GetWide()-10, 30, "hackyTextSize", SH_HADEZ:GetTextSizes(), togglePanel, CanChangeFunc)
	
	local fontSelection = CL_HADEZ:CreateComboBox(5, startY+35, togglePanel:GetWide()-10, 30, "hackyTextFont", SH_HADEZ:GetTextFonts(), togglePanel, CanChangeFunc)
	fontSelection:SetFont(SH_HADEZ:GetHackyTextFont(CL_HADEZ:GetPreference("hackyTextFont")))

	fontSelection.SubChildFunc = function(self, subChild)
		
		local font = subChild:GetText()
		
		if !font or #font == 0 then return end
		
		subChild:SetFont(SH_HADEZ:GetHackyTextFont(font))
		
	end

	local __oldOnSelect = fontSelection.OnSelect
	fontSelection.OnSelect = function(self, index, value, func)
		
		__oldOnSelect(self, index, value, func)
		
		self:SetFont(SH_HADEZ:GetHackyTextFont(value))
		
	end
	
	local colorSelection = CL_HADEZ:CreateComboBox(5, startY+70, togglePanel:GetWide()-10, 30, "hackyTextColor", SH_HADEZ:GetTextColors(), togglePanel, CanChangeFunc)
	
	togglePanel:SetTall(colorSelection:GetBottomY()+5)
	
	-- Launch btn
	local hackyTextBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("hackyText"), self)
	
	hackyTextBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		local text = textInputText
		
		if #text == 0 then
			text = SH_HADEZ:Translate("hackyTextInput")
		end
		
		-- send msg to server
		net.Start("z_hadez_HackyTextPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteString(text)
			net.WriteUInt(sizeSelection:GetValue(), 8)
			net.WriteString(fontSelection:GetValue())
			net.WriteString(colorSelection:GetValue())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_hackytext",PANEL,"DScrollPanel")