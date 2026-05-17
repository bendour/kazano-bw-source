-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_chatsteal","z_hadez/tabs/chatsteal.vmt","chatSteal")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, false, false, function(ply)
	
		if SH_HADEZ:IsMindControlled(ply) then
			return false, "(Controlled)"
		end
		
		if SH_HADEZ:HasChatStolen(ply) then
			return false, "(Stolen)"
		end
		
		if SH_HADEZ:IsChatStealing(ply) then
			return false, "(Stealing)"
		end
		
		return !SH_HADEZ:IsChatStealing(LocalPlayer())
		
	end)
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,40)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:IsChatStealing(LocalPlayer())
	end
	
	-- Option Sliders
	local canChatToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "chatStealMute", togglePanel, CanChangeFunc)
	
	-- Steal btn
	local stealBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("stealChat"), self)
	stealBtn.TextThink = function(self)
			
		if SH_HADEZ:IsChatStealing(LocalPlayer()) then
			self:SetText(SH_HADEZ:Translate("returnChat"))
		else
			self:SetText(SH_HADEZ:Translate("stealChat"))
		end
	
	end

	stealBtn.DoClick = function()
	
		if SH_HADEZ:IsMindController(LocalPlayer()) then return end
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
		local isChatStealing = SH_HADEZ:IsChatStealing(LocalPlayer())
	
		if !isChatStealing and #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		local target = selectedPlayers[1]
		
		if SH_HADEZ:IsMindControlled(target) or SH_HADEZ:IsChatStealing(target) then
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_ChatSteal")
			net.WriteEntity(selectedPlayers[1])
			net.WriteBool(canChatToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_chatsteal",PANEL,"DScrollPanel")