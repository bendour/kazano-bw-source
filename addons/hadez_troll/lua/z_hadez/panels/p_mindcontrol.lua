-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_mindcontrol","z_hadez/tabs/pentagram_eye.vmt","mindControl")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, false, false, function(ply)
		local isMindControlled = SH_HADEZ:IsMindControlled(ply)
		return !isMindControlled, isMindControlled and "(Controlled)" or ""
	end)
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,110)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:IsMindController(LocalPlayer())
	end
	
	-- Option Sliders
	local invisibleToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "invisibleOnControl", togglePanel, CanChangeFunc)
	local physgunToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "forcePhysgunOnControl", togglePanel, CanChangeFunc)
	local stealChatToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "stealChatOnControl", togglePanel, CanChangeFunc)
	
	local realSelf = self
	
	-- Control btn
	local controlBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("controlPlayer"), self)
	controlBtn.TextThink = function(self)
			
		if !SH_HADEZ:IsMindController(LocalPlayer()) then
			self:SetText(SH_HADEZ:Translate("controlPlayer"))
		else
			self:SetText(SH_HADEZ:Translate("stopControl"))
		end
			
	end
	
	controlBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
		local isMindControlling = SH_HADEZ:IsMindController(LocalPlayer())
	
		if !isMindControlling and #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_SetMindControlState")
			net.WriteEntity(selectedPlayers[1])
			net.WriteBool(!isMindControlling)
			net.WriteBool(invisibleToggle:IsEnabled())
			net.WriteBool(physgunToggle:IsEnabled())
			net.WriteBool(stealChatToggle:IsEnabled())
		net.SendToServer()
		
	end
	
	
	
end
vgui.Register("p_hadez_mindcontrol",PANEL,"DScrollPanel")