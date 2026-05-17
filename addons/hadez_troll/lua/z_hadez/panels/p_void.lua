-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_void","z_hadez/tabs/void.vmt","void")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, true, function(ply)
	
		if SH_HADEZ:IsVoidHiding(ply) then
			return true, "(Hiding)"
		end
	
		if SH_HADEZ:IsVoidDragged(ply) then
			return true, "(Dragging)"
		end
	
		if !ply:Alive() then
			return true, "(Dead)"
		end
		
		return true
		
	end, "void")
	
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
		return true
	end
	
	-- Option Sliders
	local hideToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "voidHideOption", togglePanel, CanChangeFunc)
	local dragToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "voidDragOption", togglePanel, CanChangeFunc)
	local propCollideToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "voidPropCollide", togglePanel, CanChangeFunc)
	local soundToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "voidSound", togglePanel, CanChangeFunc)
	
	hideToggle.OnChange = function(self, enabled) 
		if enabled then 
			dragToggle:SetEnabled(false) 
		elseif !dragToggle:IsEnabled() and !enabled then 
			dragToggle:SetEnabled(true) 
		end 
	end
	
	dragToggle.OnChange = function(self, enabled) 
		if enabled then 
			hideToggle:SetEnabled(false) 
		elseif !hideToggle:IsEnabled() and !enabled then 
			hideToggle:SetEnabled(true) 
		end 
	end
	
	if hideToggle:IsEnabled() then dragToggle:SetEnabled(false) end
	if dragToggle:IsEnabled() then hideToggle:SetEnabled(false) end
	
	-- Void btn
	local voidBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("voidHide"), self)
	voidBtn.TextThink = function(self)
			
		if hideToggle:IsEnabled() then
			self:SetText(SH_HADEZ:Translate("voidHide"))
		else
			self:SetText(SH_HADEZ:Translate("voidDrag"))
		end
	
	end
	
	voidBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_VoidPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(hideToggle:IsEnabled())
			net.WriteBool(propCollideToggle:IsEnabled())
			net.WriteBool(soundToggle:IsEnabled())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_void",PANEL,"DScrollPanel")