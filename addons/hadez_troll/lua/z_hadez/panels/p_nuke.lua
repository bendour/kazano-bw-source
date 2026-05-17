-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_nuke","z_hadez/tabs/nuke.vmt","nukeLaunch")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, false, true, function(ply)
	
		if !ply:Alive() then
			return true, "(Dead)"
		end
		
		if SH_HADEZ:IsNukeActive() then
			return false, "(Nuke)"
		end
		
		return true
		
	end, "nukeLaunch")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,75)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:IsNukeActive()
	end
	
	-- Option Sliders
	local countDownToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "nukeCountdown", togglePanel, CanChangeFunc)
	local soundToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "nukeSound", togglePanel, CanChangeFunc)
	
	-- Launch btn
	local nukeBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("nukeLaunch"), self)
	
	nukeBtn.DoClick = function()
	
		if SH_HADEZ:IsNukeActive() then return end
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_NukeLaunch")
			net.WriteEntity(selectedPlayers[1])
			net.WriteBool(countDownToggle:IsEnabled())
			net.WriteBool(soundToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_nuke",PANEL,"DScrollPanel")