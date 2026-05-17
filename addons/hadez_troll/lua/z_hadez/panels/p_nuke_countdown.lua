-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()

local redGrungeBG = Material("z_hadez/raw/red_grunge_bg_faded.png")
local nukeIcon = "z_hadez/nuke/nuke"
local nukeStartSound = "z_hadez/nuke/start.wav"
local nukeAlertSound = "z_hadez/nuke/alarm.wav"

local countDownW, countDownH = 275,69
local animSpeed = 0.5
local useSound = true

local function NukeCountdown()

	useSound = net.ReadBool()

	if IsValid(CL_HADEZ.nukeCountdown) then
		CL_HADEZ.nukeCountdown:Remove()
	end

	CL_HADEZ.nukeCountdown = vgui.Create('p_hadez_nukeCountdown')
	
end 
net.Receive("z_hadez_NukeCountdown",NukeCountdown)
 
function PANEL:Init()
	
	local ply = LocalPlayer()
	
	self:ParentToHUD()
	self:SetSize(countDownW,countDownH)
	self:SetPos(0, -600)
	self:CenterHorizontal()
	self.Paint = function(self, w, h)
		-- BG
		draw.RoundedBox( 8, 0, 0, w, h, SH_HADEZ.VAR.COLOR.MOREDARKY)
	end
	
	-- Animate
	self:MoveTo( self:GetPos(), scrH*0.075, animSpeed)
	
	local nukeImg = vgui.Create("DImage", self)
	nukeImg:SetPos(5,0)
	nukeImg:SetSize( 64, 64 )
	nukeImg:SetImage(nukeIcon)
	nukeImg:SetImageColor(SH_HADEZ.VAR.COLOR.RED)
	nukeImg:CenterVertical()
	
	local textCenter = (self:GetWide()-nukeImg:GetWide())/2 + nukeImg:GetWide()
	
	local incomingLbl = vgui.Create("DLabel", self)
	incomingLbl:SetText(string.upper(SH_HADEZ:Translate("nukeIncoming")))
	incomingLbl:SetFont("z_hadez_nukeTitle")
	incomingLbl:SetColor(SH_HADEZ.VAR.COLOR.RED)
	incomingLbl:SizeToContents()
	incomingLbl:SetPos(textCenter-incomingLbl:GetWide()/2,self:GetTall()*0.2)
	
	local countDownLbl = vgui.Create("DLabel", self)
	countDownLbl:SetText("00:00:00")
	countDownLbl:SetFont("z_hadez_nukeCountdown")
	countDownLbl:SetColor(SH_HADEZ.VAR.COLOR.RED)
	countDownLbl:SizeToContents()
	countDownLbl:SetPos(textCenter-countDownLbl:GetWide()/2,self:GetTall()*0.6)
	
	local nukeDelay = SH_HADEZ:GetNukeDelay()
	local nukeDetonateTime = os.clock() + nukeDelay
	local playedSound = false
	local basePnl = self
	
	if useSound and nukeDelay > 27 or nukeDelay < 20 then 
		surface.PlaySound(nukeStartSound)
	end
	
	countDownLbl.Think = function(self)

		-- Time left
		local diff = nukeDetonateTime - os.clock()
		
		if diff > 0 then
		
			-- Nuke alarm ( sound length 27 secs )
			if useSound and !playedSound and diff < 25 and diff > 20 then 
				surface.PlaySound(nukeAlertSound)
				surface.PlaySound(nukeAlertSound)
				surface.PlaySound(nukeAlertSound)
				surface.PlaySound(nukeAlertSound)
				playedSound = true
			end
		
			local timeStr = SH_HADEZ:FormatTime(diff, "%M:%S:")

			self:SetText(timeStr)

		else
		
			-- Animate
			basePnl:MoveTo( basePnl:GetPos(), -600, animSpeed, 0, -1, function()
				basePnl:Remove()
			end)
			
		end
		
	end
	
end
vgui.Register('p_hadez_nukeCountdown',PANEL,'DPanel')

