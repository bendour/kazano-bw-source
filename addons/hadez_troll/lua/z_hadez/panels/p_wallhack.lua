-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_wallhack","z_hadez/tabs/xray.vmt","wallhack")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)	
		return true, SH_HADEZ:HasWallhack(ply) and "(Wallhack)" or ""
	end, "wallhack")
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.49,10)
	togglePanel:SetSize(355,215)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:HasWallhack(LocalPlayer())
	end
	
	local toggleW, rightRowX = togglePanel:GetWide()/2-7.5, togglePanel:GetWide()/2+2
	
	-- Option Sliders
	local chamsToggle = CL_HADEZ:CreateTogglePanel(5, 5, toggleW, 30, "wallhackChams", togglePanel, CanChangeFunc)
	local wireframeToggle = CL_HADEZ:CreateTogglePanel(5, 40, toggleW, 30, "wallhackWireframe", togglePanel, CanChangeFunc)
	local hitboxesToggle = CL_HADEZ:CreateTogglePanel(5, 75, toggleW, 30, "wallhackHitboxes", togglePanel, CanChangeFunc)
	local bonesToggle = CL_HADEZ:CreateTogglePanel(5, 110, toggleW, 30, "wallhackBones", togglePanel, CanChangeFunc)
	local aimlinesToggle = CL_HADEZ:CreateTogglePanel(5, 145, toggleW, 30, "wallhackAimlines", togglePanel, CanChangeFunc)
	local showWeaponsToggle = CL_HADEZ:CreateTogglePanel(5, 180, toggleW, 30, "wallhackWeapons", togglePanel, CanChangeFunc)
	
	chamsToggle.OnChange = function(self, enabled) if enabled then wireframeToggle:SetEnabled(false) end end
	wireframeToggle.OnChange = function(self, enabled) if enabled then chamsToggle:SetEnabled(false) end end
	if chamsToggle:IsEnabled() then wireframeToggle:SetEnabled(false) end
	if wireframeToggle:IsEnabled() then chamsToggle:SetEnabled(false) end
	
	local nameToggle = CL_HADEZ:CreateTogglePanel(rightRowX, 5, toggleW, 30, "wallhackName", togglePanel, CanChangeFunc)
	local teamToggle = CL_HADEZ:CreateTogglePanel(rightRowX, 40, toggleW, 30, "wallhackTeam", togglePanel, CanChangeFunc)
	local healthToggle = CL_HADEZ:CreateTogglePanel(rightRowX, 75, toggleW, 30, "wallhackHealth", togglePanel, CanChangeFunc)
	local distanceToggle = CL_HADEZ:CreateTogglePanel(rightRowX, 110, toggleW, 30, "wallhackDistance", togglePanel, CanChangeFunc)
	local lineToggle = CL_HADEZ:CreateTogglePanel(rightRowX, 145, toggleW, 30, "wallhackLine", togglePanel, CanChangeFunc)
	local weaponInfoToggle = CL_HADEZ:CreateTogglePanel(rightRowX, 180, toggleW, 30, "wallhackWeaponInfo", togglePanel, CanChangeFunc)
	
	-- Control btn
	local wallhackBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.725, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("controlPlayer"), self)
	wallhackBtn.TextThink = function(self)
		self:SetText(SH_HADEZ:Translate("wallhackToggle"))	
	end
	
	wallhackBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_WallhackToggle")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			
			net.WriteBool(chamsToggle:IsEnabled())
			net.WriteBool(wireframeToggle:IsEnabled())
			net.WriteBool(hitboxesToggle:IsEnabled())
			net.WriteBool(bonesToggle:IsEnabled())
			net.WriteBool(aimlinesToggle:IsEnabled())
			net.WriteBool(showWeaponsToggle:IsEnabled())
			
			net.WriteBool(nameToggle:IsEnabled())
			net.WriteBool(teamToggle:IsEnabled())
			net.WriteBool(healthToggle:IsEnabled())
			net.WriteBool(distanceToggle:IsEnabled())
			net.WriteBool(lineToggle:IsEnabled())
			net.WriteBool(weaponInfoToggle:IsEnabled())
			
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_wallhack",PANEL,"DScrollPanel")