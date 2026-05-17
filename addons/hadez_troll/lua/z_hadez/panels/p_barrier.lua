-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_barrier","z_hadez/tabs/barrier.vmt","barrier")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
			
		return true, SH_HADEZ:HasBarrier(ply) and "(Barrier)" or ""
		
	end, "barrier")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,266)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:HasBarrier(LocalPlayer()) 
	end
	
	-- Set default values
	CL_HADEZ:GetPreference("barrierInverse", false)
	
	-- Option Sliders
	local barrierToggles = {}
	barrierToggles.invincibleToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 26, "barrierInvincible", togglePanel, CanChangeFunc)
	barrierToggles.killPlyToggle = CL_HADEZ:CreateTogglePanel(5, 34, togglePanel:GetWide()-10, 26, "barrierKillPly", togglePanel, CanChangeFunc)
	barrierToggles.killNpcToggle = CL_HADEZ:CreateTogglePanel(5, 63, togglePanel:GetWide()-10, 26, "barrierKillNpc", togglePanel, CanChangeFunc)
	barrierToggles.regenerateHealthToggle = CL_HADEZ:CreateTogglePanel(5, 92, togglePanel:GetWide()-10, 26, "barrierRegenerateHealth", togglePanel, CanChangeFunc)
	barrierToggles.regenerateArmorToggle = CL_HADEZ:CreateTogglePanel(5, 121, togglePanel:GetWide()-10, 26, "barrierRegenerateArmor", togglePanel, CanChangeFunc)
	barrierToggles.noDamageToggle = CL_HADEZ:CreateTogglePanel(5, 150, togglePanel:GetWide()-10, 26, "barrierNoDamage", togglePanel, CanChangeFunc)
	barrierToggles.inverseToggle = CL_HADEZ:CreateTogglePanel(5, 179, togglePanel:GetWide()-10, 26, "barrierInverse", togglePanel, CanChangeFunc)
	barrierToggles.soundToggle = CL_HADEZ:CreateTogglePanel(5, 208, togglePanel:GetWide()-10, 26, "barrierSound", togglePanel, CanChangeFunc)
	
	-- Font size adjustment
	for _, toggle in pairs(barrierToggles) do
		toggle.titleLbl:SetFont("z_hadez_sliderTextTiny")
	end
	
	-- Range choice
	if !CL_HADEZ:HasPreference("barrierRange") then
		CL_HADEZ:SetPreference("barrierRange", "5m")
	end
	
	local rangeSelection = CL_HADEZ:CreateComboBox(5, 237, togglePanel:GetWide()-10, 24, "barrierRange", {"3m", "5m", "10m", "20m", "30m", "40m", "50m", "100m", "250m", "1000m"}, togglePanel, CanChangeFunc)
	
	-- Launch btn
	local barrierBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+10, SH_HADEZ:Translate("barrierToggle"), self)
	
	barrierBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_BarrierPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(barrierToggles.invincibleToggle:IsEnabled())
			net.WriteBool(barrierToggles.killPlyToggle:IsEnabled())
			net.WriteBool(barrierToggles.killNpcToggle:IsEnabled())
			net.WriteBool(barrierToggles.regenerateHealthToggle:IsEnabled())
			net.WriteBool(barrierToggles.regenerateArmorToggle:IsEnabled())
			net.WriteBool(barrierToggles.noDamageToggle:IsEnabled())
			net.WriteBool(barrierToggles.inverseToggle:IsEnabled())
			net.WriteBool(barrierToggles.soundToggle:IsEnabled())
			net.WriteString(rangeSelection:GetValue())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_barrier",PANEL,"DScrollPanel")