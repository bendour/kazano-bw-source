-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_weaponmod","z_hadez/tabs/weaponmod.vmt","weaponMod")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)	
		return true, SH_HADEZ:HasWeaponMod(ply) and "(Modded)" or ""
	end, "weaponMod")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,215)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:HasWeaponMod(LocalPlayer())
	end
	
	-- Option Sliders
	local infiniteClipToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "weaponModInfiniteClip", togglePanel, CanChangeFunc)
	local infiniteReserveToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "weaponModInfiniteReserve", togglePanel, CanChangeFunc)
	local rapidFireToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "weaponModRapidFire", togglePanel, CanChangeFunc)
	local rapidFireToolgunToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "weaponModRapidFireToolgun", togglePanel, CanChangeFunc)
	local noSpreadToggle = CL_HADEZ:CreateTogglePanel(5, 145, togglePanel:GetWide()-10, 30, "weaponModNoSpread", togglePanel, CanChangeFunc)
	local noRecoilToggle = CL_HADEZ:CreateTogglePanel(5, 180, togglePanel:GetWide()-10, 30, "weaponModNoRecoil", togglePanel, CanChangeFunc)
	
	-- Launch btn
	local weaponModBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("weaponMod"), self)
	
	weaponModBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()

		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end

		-- send msg to server
		net.Start("z_hadez_WeaponModPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(infiniteClipToggle:IsEnabled())
			net.WriteBool(infiniteReserveToggle:IsEnabled())
			net.WriteBool(rapidFireToggle:IsEnabled())
			net.WriteBool(rapidFireToolgunToggle:IsEnabled())
			net.WriteBool(noSpreadToggle:IsEnabled())
			net.WriteBool(noRecoilToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_weaponmod",PANEL,"DScrollPanel")