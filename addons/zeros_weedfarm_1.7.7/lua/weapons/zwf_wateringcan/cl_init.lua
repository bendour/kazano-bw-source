include("shared.lua")

SWEP.PrintName = "Watering Can" // The name of your SWEP
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true // Do you want the SWEP to have a crosshair?

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastWater = -1
	self.IsWatering = false
end

function SWEP:DrawHUD()
	local water = self:GetWater()


	draw.RoundedBox(5, 800 * wMod, 1027 * hMod, 320 * wMod, 45 * hMod, zwf.default_colors["gray02"])


	//Water Bar
	if water > 0 then

		local newWaterLvl = (315 / zwf.config.WateringCan.Capacity) * water
		newWaterLvl = math.Clamp(newWaterLvl,0,315)
		if self.LastWater ~= newWaterLvl then
			self.LastWater = self.LastWater + 100 * FrameTime()
			self.LastWater = math.Clamp(self.LastWater, 0, newWaterLvl)
		end

		draw.RoundedBox(5, 803 * wMod, 1029 * hMod, self.LastWater * wMod, 41 * hMod, zwf.default_colors["water"])
	end

	draw.SimpleText(zwf.language.General["Water"] .. ": " .. water .. zwf.config.UoL, zwf.f.GetFont("zwf_wateringcan_font01"), 960 * wMod, 1065 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

function SWEP:Think()
	local isWatering = self:GetIsWatering()

	if isWatering ~= self.IsWatering then
		if self.IsWatering then
			if isWatering == false and self.LoopingSoundID ~= nil then
				self:StopWaterSound()
			end
		else
			self.LoopingSoundID = self:StartLoopingSound("zwf_watering_loop")
		end

		self.IsWatering = isWatering
	end
end

function SWEP:StopWaterSound()
	if self.LoopingSoundID ~= nil then
		self:StopLoopingSound(self.LoopingSoundID)
		self.LoopingSoundID = nil
	end
end



function SWEP:OnRemove()
	self:StopWaterSound()
end

function SWEP:Holster(swep)

	self:StopWaterSound()
end

function SWEP:Deploy()

	self:StopWaterSound()
end



function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + 1)
end
