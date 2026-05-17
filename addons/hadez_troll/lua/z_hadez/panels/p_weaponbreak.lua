-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_weaponbreak","z_hadez/tabs/nodamage.vmt","weaponBreak")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		return true, SH_HADEZ:IsInWeaponBreak(ply)  and "(Broken)" or ""
		
	end, "weaponBreak")
	
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
		return !SH_HADEZ:IsInWeaponBreak(LocalPlayer())
	end
	
	-- Set default values
	CL_HADEZ:GetPreference("weaponBreakNoClipAmmo", false)
	CL_HADEZ:GetPreference("weaponBreakNoReserveAmmo", false)
	
	-- Option Sliders
	local suicideToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "weaponBreakSuicide", togglePanel, CanChangeFunc)
	local missBulletsToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "weaponBreakMiss", togglePanel, CanChangeFunc)
	local noClipAmmoToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "weaponBreakNoClipAmmo", togglePanel, CanChangeFunc)
	local noReserveAmmoToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "weaponBreakNoReserveAmmo", togglePanel, CanChangeFunc)
	
	-- Ravebreak btn
	local weaponBreakBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("weaponBreak"), self)
	
	weaponBreakBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_WeaponBreakPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(suicideToggle:IsEnabled())
			net.WriteBool(missBulletsToggle:IsEnabled())
			net.WriteBool(noClipAmmoToggle:IsEnabled())
			net.WriteBool(noReserveAmmoToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_weaponbreak",PANEL,"DScrollPanel")