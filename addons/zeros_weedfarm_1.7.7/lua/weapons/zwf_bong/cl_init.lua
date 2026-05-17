include("shared.lua")
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true -- Do you want the SWEP to have a crosshair?
local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastWeed = -1
	self.LastWeedAmount = -1
	self.WeedLevel = -1
	self.WeedName = "nil"

end

function SWEP:DrawHUD()
	local weed = self:GetWeedID()

	if self.LastWeed ~= weed then
		self.LastWeed = weed


		if self.LastWeed ~= -1 then
			self.WeedLevel = self:GetWeed_Amount()
			self.WeedName = self:GetWeed_Name()
		end
	end

	local weed_amount = self:GetWeed_Amount()
	if self.LastWeedAmount ~= weed_amount then
		self.LastWeedAmount = weed_amount
	end


	if self.LastWeed ~= -1 then


		local bongData = zwf.config.Bongs.items[self.BongID]


		self.WeedLevel = self.WeedLevel - 2 * FrameTime()
		self.WeedLevel = math.Clamp(self.WeedLevel, self.LastWeedAmount, bongData.hold_amount)


		local width = (315 / bongData.hold_amount) * self.WeedLevel

		draw.RoundedBox(5, 800 * wMod, 1027 * hMod, 320 * wMod, 45 * hMod, zwf.default_colors["gray02"])
		draw.RoundedBox(5, 803 * wMod, 1029 * hMod, width * wMod, 41 * hMod, zwf.config.Plants[self.LastWeed].color)
		draw.SimpleText(self.WeedName, zwf.f.GetFont("zwf_wateringcan_font01"), 960 * wMod, 1065 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end
end

function SWEP:Think()
	zwf.f.LoopedSound(self, "zwf_bong_loop", self:GetIsSmoking())
end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:StopLoopedSound()
	self:StopSound("zwf_bong_loop")
	zwf.f.StopLoopedSound(self)
end

function SWEP:Holster()
	self:StopLoopedSound()
end

function SWEP:OnRemove()
	self:StopLoopedSound()
end
