-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_ammomod","z_hadez/tabs/ammomod.vmt","ammoMod")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)	
		return true, SH_HADEZ:HasAmmoMod(ply) and "(Modded)" or ""
	end, "ammoMod")
	
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
		return !SH_HADEZ:HasAmmoMod(LocalPlayer())
	end
	
	-- Default choices
	if !CL_HADEZ:HasPreference("ammoModEffect") then
		CL_HADEZ:SetPreference("ammoModEffect", SH_HADEZ:GetAmmoEffects()[1])
		CL_HADEZ:SetPreference("ammoModDamage", SH_HADEZ:GetDamageTypes()[1])
	end
	
	-- Options 
	local effectSelection = CL_HADEZ:CreateComboBox(5, 5, togglePanel:GetWide()-10, 30, "ammoModEffect", SH_HADEZ:GetAmmoEffects(), togglePanel, CanChangeFunc)
	local damageSelection = CL_HADEZ:CreateComboBox(5, 40, togglePanel:GetWide()-10, 30, "ammoModDamage", SH_HADEZ:GetDamageTypes(), togglePanel, CanChangeFunc)

	-- Ammo mod btn
	local weaponModBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("ammoMod"), self)
	
	weaponModBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()

		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end

		-- send msg to server
		net.Start("z_hadez_AmmoModPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteString(effectSelection:GetValue())
			net.WriteString(damageSelection:GetValue())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_ammomod",PANEL,"DScrollPanel")