-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_ravebreak","z_hadez/tabs/ravebreak.vmt","ravebreak")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		return true, SH_HADEZ:IsRaving(ply)  and "(Raving)" or ""
		
	end, "ravebreak")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,104)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return true
	end
	
	-- Option Sliders
	local danceToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "ravebreakDance", togglePanel, CanChangeFunc)
	local colorizeToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "ravebreakColorize", togglePanel, CanChangeFunc)
		
	-- Song choice
	if !CL_HADEZ:HasPreference("ravebreakSong") then
		CL_HADEZ:SetPreference("ravebreakSong", SH_HADEZ:GetRavebreakSongs()[1])
	end
	
	local songSelection = CL_HADEZ:CreateComboBox(5, 75, togglePanel:GetWide()-10, 24, "ravebreakSong", SH_HADEZ:GetRavebreakSongs(), togglePanel, CanChangeFunc)
	
	-- Ravebreak btn
	local ravebreakBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("ravebreak"), self)
	
	ravebreakBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_RavebreakPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteString(songSelection:GetValue())
			net.WriteBool(danceToggle:IsEnabled())
			net.WriteBool(colorizeToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_ravebreak",PANEL,"DScrollPanel")