-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}

CL_HADEZ:AddMenuTab("p_hadez_blackout","z_hadez/tabs/crash.vmt","blackout")

function PANEL:Init(realInit)

	if !realInit then return end
	
	-- Player selection panel
	local playerSelectionPnl = CL_HADEZ:CreatePlayerSelectionPanel(self:GetWide()*0.05, 8, self:GetWide()*0.4, self:GetTall()*0.9, self, true, false, function(ply)
	
		if SH_HADEZ:IsBlackedout(ply) then
			return true, "(Blacked out)"
		end
		
		return true
		
	end)
	
	playerSelectionPnl.OnSelectedPlayersUpdate = function(self)
		selectedPlayers = self:GetSelectedPlayers()
	end
	selectedPlayers = playerSelectionPnl:SetSelectedPlayers(selectedPlayers)
	
	-- To any dev reading: The crash feature is not allowed on gmodstore, thus I have restricted its use to myself only. Feel free to remove the restriction though ;)
	local crashToggle
	if LocalPlayer():SteamID() == "STEAM_0:0:0" then
	
		local togglePanel = vgui.Create("DPanel",self)
		togglePanel:SetPos(self:GetWide()*0.53,10)
		togglePanel:SetSize(300,40)
		togglePanel.Paint = function(self, w, h)
			draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
		end
		
		local function CanChangeFunc()
			return true
		end
		
		-- Option sliders
		crashToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "Crash to desktop", togglePanel, CanChangeFunc)
	
	end
	
	-- Blackout btn
	local blackoutBtn = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, self:GetTall()*0.4, SH_HADEZ:Translate("blackoutPlayer"), self)
	
	blackoutBtn.DoClick = function()
	
		local selectedPlayers = playerSelectionPnl:GetSelectedPlayers()
	
		if #selectedPlayers == 0 then
			CL_HADEZ:CreateWarningMessage(SH_HADEZ:Translate("selectPlayer"))
			return
		end
		
		-- send msg to server
		net.Start("z_hadez_BlackoutPlayers")
			SH_HADEZ:NetWritePlayers(selectedPlayers)
			net.WriteBool(crashToggle and crashToggle:IsEnabled() or false)
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_blackout",PANEL,"DScrollPanel")