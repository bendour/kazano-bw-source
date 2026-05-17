-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_inverter","z_hadez/tabs/inverter.vmt","inverter")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		return true, SH_HADEZ:IsInverted(ply) and "(Inverted)" or ""
		
	end, "inverter")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,180)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:IsInverted(LocalPlayer())
	end
	
	-- Option Sliders
	local moveToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "invertMove", togglePanel, CanChangeFunc)
	local aimToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "invertAim", togglePanel, CanChangeFunc)
	local jumpToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "invertJump", togglePanel, CanChangeFunc)
	local shootToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "invertShoot", togglePanel, CanChangeFunc)
	local screenToggle = CL_HADEZ:CreateTogglePanel(5, 145, togglePanel:GetWide()-10, 30, "invertScreen", togglePanel, CanChangeFunc)
	
	-- Ravebreak btn
	local inverterBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("invert"), self)
	
	inverterBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_SetInvertion")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(moveToggle:IsEnabled())
			net.WriteBool(aimToggle:IsEnabled())
			net.WriteBool(jumpToggle:IsEnabled())
			net.WriteBool(shootToggle:IsEnabled())
			net.WriteBool(screenToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_inverter",PANEL,"DScrollPanel")