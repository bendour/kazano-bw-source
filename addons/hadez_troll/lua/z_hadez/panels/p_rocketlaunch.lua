-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_rocketlaunch","z_hadez/tabs/rocket.vmt","rocketLaunch")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		if !ply:Alive() then
			return true, "(Dead)"
		end
		
		return true, SH_HADEZ:IsInRocketLaunch(ply) and "(Launching)" or ""
		
	end, "rocketLaunch")
	
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
		return true
	end
	
	-- Option Sliders
	local explodeToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "launchExplode", togglePanel, CanChangeFunc)
	local soundToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "launchSound", togglePanel, CanChangeFunc)
	
	-- Launch btn
	local launchBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("launchPlayer"), self)
	launchBtn.TextThink = function(self)
			
		if #selectedPlayers < 2 then
			self:SetText(SH_HADEZ:Translate("launchPlayer"))
		else
			self:SetText(SH_HADEZ:Translate("launchPlayers"))
		end
	
	end
	
	launchBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_RocketLaunchPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(explodeToggle:IsEnabled())
			net.WriteBool(soundToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_rocketlaunch",PANEL,"DScrollPanel")