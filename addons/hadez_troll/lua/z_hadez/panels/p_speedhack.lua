-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_speedhack","z_hadez/tabs/speedhack.vmt","speedHack")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)

		return true, SH_HADEZ:HasSpeedHack(ply) and "(Speed)" or ""
		
	end, "speedHack")
	
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
		return !SH_HADEZ:HasSpeedHack(LocalPlayer())
	end
	
	if !CL_HADEZ:HasPreference("speedHackTime") then
		CL_HADEZ:SetPreference("speedHackTime", false)
	end
	
	-- Option sliders
	local runToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "speedHackRun", togglePanel, CanChangeFunc)
	local walkToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "speedHackWalk", togglePanel, CanChangeFunc)
	local jumpHighToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "speedHackJumpHigh", togglePanel, CanChangeFunc)
	local jumpInfiniteToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "speedHackJumpInfinite", togglePanel, CanChangeFunc)
	local noFallDMGToggle = CL_HADEZ:CreateTogglePanel(5, 145, togglePanel:GetWide()-10, 30, "speedHackNoFallDMG", togglePanel, CanChangeFunc)
	local timeToggle = CL_HADEZ:CreateTogglePanel(5, 180, togglePanel:GetWide()-10, 30, "speedHackTime", togglePanel, CanChangeFunc)
	
	-- Speed hack btn
	local speedHackBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("speedHack"), self)
	
	speedHackBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_SpeedHackPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(runToggle:IsEnabled())
			net.WriteBool(walkToggle:IsEnabled())
			net.WriteBool(jumpHighToggle:IsEnabled())
			net.WriteBool(jumpInfiniteToggle:IsEnabled())
			net.WriteBool(noFallDMGToggle:IsEnabled())
			net.WriteBool(timeToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_speedhack",PANEL,"DScrollPanel")