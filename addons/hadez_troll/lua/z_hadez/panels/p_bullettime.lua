-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_bullettime","z_hadez/tabs/bullettime.vmt","bulletTime")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		return true, SH_HADEZ:HasBulletTime(ply)  and "(B-Time)" or ""
		
	end, "bulletTime")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,145)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:HasBulletTime(LocalPlayer())
	end
	
	-- Option Sliders
	local invincibleToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "bulletInvincible", togglePanel, CanChangeFunc)
	local returnDamageToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "bulletTimeReturn", togglePanel, CanChangeFunc)
	local dodgeBulletsToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "bulletTimeDodge", togglePanel, CanChangeFunc)
	local slowmoToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "bulletTimeSlowmo", togglePanel, CanChangeFunc)
	
	-- Ravebreak btn
	local weaponBreakBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("bulletTime"), self)
	
	weaponBreakBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_BulletTimePlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(invincibleToggle:IsEnabled())
			net.WriteBool(returnDamageToggle:IsEnabled())
			net.WriteBool(dodgeBulletsToggle:IsEnabled())
			net.WriteBool(slowmoToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_bullettime",PANEL,"DScrollPanel")