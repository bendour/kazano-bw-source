-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local selectedPlayers = {}
local skeleton = Material("z_hadez/raw/skeleton.png")

CL_HADEZ:AddMenuTab("p_hadez_aimbot","z_hadez/tabs/headshot.vmt","aimbot")

local skeletonButtons = {
	{ pos = { x = 150, y = 4}, bone = "ValveBiped.Bip01_Head1" },
	{ pos = { x = 150, y = 44}, bone = "ValveBiped.Bip01_Neck1" },
	{ pos = { x = 150, y = 72}, bone = "ValveBiped.Bip01_Spine2" },
	{ pos = { x = 150, y = 102}, bone = "ValveBiped.Bip01_Spine1" },
	{ pos = { x = 150, y = 135}, bone = "ValveBiped.Bip01_Pelvis" },
	
	{ pos = { x = 200, y = 59}, bone = "ValveBiped.Bip01_R_UpperArm" },
	{ pos = { x = 244, y = 60}, bone = "ValveBiped.Bip01_R_Forearm" },
	{ pos = { x = 277, y = 60}, bone = "ValveBiped.Bip01_R_Hand" },
	
	{ pos = { x = 100, y = 59}, bone = "ValveBiped.Bip01_L_UpperArm" },
	{ pos = { x = 56, y = 60}, bone = "ValveBiped.Bip01_L_Forearm" },
	{ pos = { x = 23, y = 60}, bone = "ValveBiped.Bip01_L_Hand" },
	
	{ pos = { x = 169, y = 190}, bone = "ValveBiped.Bip01_R_Thigh" },
	{ pos = { x = 166, y = 255}, bone = "ValveBiped.Bip01_R_Calf" },
	{ pos = { x = 166, y = 292}, bone = "ValveBiped.Bip01_R_Foot" },
	{ pos = { x = 171, y = 310}, bone = "ValveBiped.Bip01_R_Toe0" },
	
	{ pos = { x = 131, y = 190}, bone = "ValveBiped.Bip01_L_Thigh" },
	{ pos = { x = 134, y = 255}, bone = "ValveBiped.Bip01_L_Calf" },
	{ pos = { x = 134, y = 292}, bone = "ValveBiped.Bip01_L_Foot" },
	{ pos = { x = 129, y = 310}, bone = "ValveBiped.Bip01_L_Toe0" }
}

function PANEL:Init(realInit)

	if !realInit then return end
	
	local function CanChangeFunc()
		return !SH_HADEZ:HasAimbot(LocalPlayer())
	end
	
	-- Skeleton
	local skeletonPanel = vgui.Create("DPanel",self)
	skeletonPanel:SetPos(self:GetWide()*0.05,8)
	skeletonPanel:SetSize(300,self:GetTall()*0.9)
	skeletonPanel.Paint = function(self, w, h)
		surface.SetDrawColor( color_white )
		surface.SetMaterial( skeleton )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	
	if !CL_HADEZ:HasPreference("aimbotBone") then
		CL_HADEZ:SetPreference("aimbotBone", "ValveBiped.Bip01_Head1")
	end
	
	for i=1, #skeletonButtons do
	
		local pos, bone = skeletonButtons[i].pos, skeletonButtons[i].bone
	
		local skeletonBtn = vgui.Create("DButton", skeletonPanel)
		skeletonBtn:SetSize(12,12)
		skeletonBtn:SetPos(pos.x-5, pos.y)
		skeletonBtn:SetText("")
		
		local bgColor = SH_HADEZ.VAR.COLOR.LIGHTBLUE
		skeletonBtn.Think = function()

			local bonePreference = CL_HADEZ:GetPreference("aimbotBone")
			
			if bonePreference then
				bgColor = bonePreference == bone and SH_HADEZ.VAR.COLOR.RED or SH_HADEZ.VAR.COLOR.LIGHTBLUE
			end

		end
		skeletonBtn.Paint = function(self, w, h)
			draw.RoundedBox( 8, 0, 0, w, h, bgColor)
			
			if !CanChangeFunc() then
				self:SetCursor("arrow")
				draw.RoundedBox( 8, 0, 0, w, h, ColorAlpha(color_black,150) )
			else
				self:SetCursor("hand")
			end
		end
		skeletonBtn.DoClick = function(self) 
			if !CanChangeFunc() then return end
			CL_HADEZ:SetPreference("aimbotBone", bone)
		end

	end
	
	-- Option panel
	local togglePanel = vgui.Create("DPanel",self)
	togglePanel:SetPos(self:GetWide()*0.53,10)
	togglePanel:SetSize(300,215)
	togglePanel.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	-- Option Sliders
	local crosshairSortToggle  = CL_HADEZ:CreateTogglePanel(5, 5, togglePanel:GetWide()-10, 30, "aimbotCrosshairSort", togglePanel, CanChangeFunc)
	local visibleOnlyToggle = CL_HADEZ:CreateTogglePanel(5, 40, togglePanel:GetWide()-10, 30, "aimbotVisibleOnly", togglePanel, CanChangeFunc)
	local neverMissToggle = CL_HADEZ:CreateTogglePanel(5, 75, togglePanel:GetWide()-10, 30, "aimbotNeverMiss", togglePanel, CanChangeFunc)
	local magicToggle = CL_HADEZ:CreateTogglePanel(5, 110, togglePanel:GetWide()-10, 30, "aimbotMagicBullets", togglePanel, CanChangeFunc)
	local pauzeOnDeathToggle = CL_HADEZ:CreateTogglePanel(5, 145, togglePanel:GetWide()-10, 30, "aimbotPauseOnDeath", togglePanel, CanChangeFunc)
	local alwaysActiveToggle  = CL_HADEZ:CreateTogglePanel(5, 180, togglePanel:GetWide()-10, 30, "aimbotAlwaysActive", togglePanel, CanChangeFunc)

	alwaysActiveToggle.OnChange = function(self, value)
	
		togglePanel:SizeTo(togglePanel:GetWide(), value and 215 or 242, 0.25)
		
	end
	
	if !CL_HADEZ:GetPreference("aimbotAlwaysActive") then
		togglePanel:SetTall(242)
	end

	-- Aim key binder
	local aimKeyBinder = vgui.Create( "DBinder", togglePanel )
	aimKeyBinder:SetSize( togglePanel:GetWide()-10, 22 )
	aimKeyBinder:SetPos( 5, 215 )
	aimKeyBinder:SetFont("z_hadez_binderText")
	aimKeyBinder:SetTextColor(color_white)
	
	local __oldThink = aimKeyBinder.Think
	aimKeyBinder.Think = function(self)
		
		__oldThink(self)
	
		local canChange = CanChangeFunc()
		aimKeyBinder:SetEnabled(canChange)
		aimKeyBinder:SetTextColor(canChange and color_white or SH_HADEZ.VAR.COLOR.GREY)
		
	end
	
	aimKeyBinder.Paint = function(self, w, h)
		draw.RoundedBox( 8, 2, 2, w-4, h-4, SH_HADEZ.VAR.COLOR.LESSDARKY)
		
		if !self:IsEnabled() then
			draw.RoundedBox( 8, 2, 2, w-4, h-4, ColorAlpha(color_black,150) )
		end
	end
	
	aimKeyBinder.OnChange = function(self, num)
		CL_HADEZ:SetPreference("aimbotAimKey", num)
	end
	
	if CL_HADEZ:HasPreference("aimbotAimKey") then
		aimKeyBinder:SetValue(CL_HADEZ:GetPreference("aimbotAimKey"))
	end

	-- Launch btn
	local aimbotBtn  = CL_HADEZ:CreateActionButton(self:GetWide()*0.73, togglePanel:GetBottomY()+20, SH_HADEZ:Translate("launchPlayer"), self)
	aimbotBtn.TextThink = function(self)
			
		if !SH_HADEZ:HasAimbot(LocalPlayer()) then
			self:SetText(SH_HADEZ:Translate("aimbotEnable"))
		else
			self:SetText(SH_HADEZ:Translate("aimbotDisable"))
		end
	
	end
	aimbotBtn.DoClick = function()
	
		-- send msg to server
		net.Start("z_hadez_AimbotToggle")
			net.WriteBool(crosshairSortToggle:IsEnabled())
			net.WriteBool(visibleOnlyToggle:IsEnabled())
			net.WriteBool(neverMissToggle:IsEnabled())
			net.WriteBool(magicToggle:IsEnabled())
			net.WriteBool(pauzeOnDeathToggle:IsEnabled())
			net.WriteBool(alwaysActiveToggle:IsEnabled())
			net.WriteFloat(aimKeyBinder:GetValue())
			net.WriteString(CL_HADEZ:GetPreference("aimbotBone"))
		net.SendToServer()
		
	end
	
end
vgui.Register("p_hadez_aimbot",PANEL,"DScrollPanel")