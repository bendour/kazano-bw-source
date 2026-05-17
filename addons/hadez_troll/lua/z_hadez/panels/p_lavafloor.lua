-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}
local volcanoTexID = surface.GetTextureID("z_hadez/lavafloor/volcano")
local volcanoEruptionTexID = surface.GetTextureID("z_hadez/lavafloor/volcano_eruption")

CL_HADEZ:AddMenuTab("p_hadez_lavafloor","z_hadez/tabs/lava.vmt","lavaFloor")

function PANEL:Init(realInit)

	if !realInit then return end
	
	local menuPnl = self.menuPnl
	menuPnl.bgTexture = volcanoTexID
	
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.05,self:GetTall()*0.1)
	togglePanel:SetSize(300,280)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	local function CanChangeFunc()
		return !SH_HADEZ:IsLavaFloorActive()
	end
	
	-- Option sliders
	local startLevelToggle = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "lavaFloorStartLevel", togglePanel, CanChangeFunc)
	local speedUpToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "lavaFloorSpeedUp", togglePanel, CanChangeFunc)
	local spectateToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "lavaFloorSpectate", togglePanel, CanChangeFunc)
	local ignitePropsToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "lavaFloorIgniteProps", togglePanel, CanChangeFunc)
	local doomsdayToggle = CL_HADEZ:CreateTogglePanel(5, 145, togglePanel:GetWide()-10, 30, "lavaFloorDoomsday", togglePanel, CanChangeFunc)
	local earthquakeToggle = CL_HADEZ:CreateTogglePanel(5, 180, togglePanel:GetWide()-10, 30, "lavaFloorEarthquake", togglePanel, CanChangeFunc)
	local soundToggle = CL_HADEZ:CreateTogglePanel(5, 215, togglePanel:GetWide()-10, 30, "lavaFloorSound", togglePanel, CanChangeFunc)
	
	-- Speed choice
	if !CL_HADEZ:HasPreference("lavaFloorSpeed") then
		CL_HADEZ:SetPreference("lavaFloorSpeed", "x1")
	end
	
	local speedSelection = CL_HADEZ:CreateComboBox(5, 250, togglePanel:GetWide()-10, 24, "lavaFloorSpeed", {"x1", "x2", "x3", "x4", "x5", "x10", "x25", "x50", "x100", "x250", "x500", "x1000"}, togglePanel, CanChangeFunc)
	
	-- Lava information
	local lavaInfoPnl = vgui.Create("DPanel",self)
	lavaInfoPnl:SetPos(self:GetWide()*0.53,self:GetTall()*0.3)
	lavaInfoPnl:SetSize(300,35)
	lavaInfoPnl.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
		draw.RoundedBox( 8, 6, 6, w-12, h-12, SH_HADEZ.VAR.COLOR.LESSDARKY )
	end
	
	local lavaSpeedLbl = vgui.Create("DLabel", lavaInfoPnl)
	lavaSpeedLbl:SetPos(12)
	lavaSpeedLbl:SetText(SH_HADEZ:Translate("lavaFloorLevelInfo"))
	lavaSpeedLbl:SetFont("z_hadez_sliderText")
	lavaSpeedLbl:SizeToContents()
	lavaSpeedLbl:SetTall(lavaInfoPnl:GetTall())
	lavaSpeedLbl:SetColor(color_white)
	
	local lavaSpeedValueLbl = vgui.Create("DLabel", lavaInfoPnl)
	lavaSpeedValueLbl:SetPos(12)
	lavaSpeedValueLbl:SetText("0%")
	lavaSpeedValueLbl:SetFont("z_hadez_sliderText")
	lavaSpeedValueLbl:SizeToContents()
	lavaSpeedValueLbl:SetTall(lavaInfoPnl:GetTall())
	lavaSpeedValueLbl:SetColor(color_white)
	lavaSpeedValueLbl.Think = function(self)
		
		local lavaLevel = 100-(math.Round(SH_HADEZ:GetLavaLevel()/SH_HADEZ:GetLavaMinLevel(), 4)*100)
		-- lavaLevel = math.Clamp(lavaLevel, 0, 100)
		lavaLevel = math.Clamp(lavaLevel, 0, 1000)
		lavaLevel = string.format("%.2f",lavaLevel)
		
		self:SetText(lavaLevel.."%")
		self:SizeToContentsX()
		self:SetPos(lavaInfoPnl:GetWide()-self:GetWide()-12)
		
	end
	
	-- Lava floor btn
	local lavaFloorBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, self:GetTall()*0.45, SH_HADEZ:Translate("lavaFloorRise"), self)
	lavaFloorBtn.TextThink = function(self)
		
		if !SH_HADEZ:IsLavaFloorActive() then
			self:SetText(SH_HADEZ:Translate("lavaFloorRise"))
			menuPnl.bgTexture = volcanoTexID
		else
			if !SH_HADEZ:IsLavaFloorRecalling() then
				self:SetText(SH_HADEZ:Translate("lavaFloorRecall"))
			else
				self:SetText(SH_HADEZ:Translate("lavaFloorForceStop"))
			end
			menuPnl.bgTexture = volcanoEruptionTexID
		end
	
	end
	
	lavaFloorBtn.DoClick = function()
	

		-- send msg to server
		net.Start("z_hadez_LavaFloor")
			net.WriteBool(startLevelToggle:IsEnabled())
			net.WriteBool(speedUpToggle:IsEnabled())
			net.WriteBool(spectateToggle:IsEnabled())
			net.WriteBool(ignitePropsToggle:IsEnabled())
			net.WriteBool(doomsdayToggle:IsEnabled())
			net.WriteBool(earthquakeToggle:IsEnabled())
			net.WriteBool(soundToggle:IsEnabled())
			net.WriteString(speedSelection:GetValue())
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_lavafloor",PANEL,"DScrollPanel")