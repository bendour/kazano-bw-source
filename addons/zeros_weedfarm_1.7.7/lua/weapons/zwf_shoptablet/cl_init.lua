include("shared.lua")
SWEP.PrintName = "Tablet" // The name of your SWEP
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true // Do you want the SWEP to have a crosshair?

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)

end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + 1)
end


function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end
