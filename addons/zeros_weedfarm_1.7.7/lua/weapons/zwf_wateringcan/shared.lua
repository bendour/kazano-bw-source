SWEP.PrintName = "Watering Can" // The name of your SWEP
SWEP.Author = "JL" // Your name
SWEP.Instructions = "LMB - Pour Water | RMB - Collect Water" // How do people use your SWEP?
SWEP.Contact = "https://www.gmodstore.com/users/ZeroChain" // How people should contact you if they find bugs, errors, etc
SWEP.Purpose = "Used for watering plants." // What is the purpose of the SWEP?
SWEP.AdminSpawnable = true // Is the SWEP spawnable for admins?
SWEP.Spawnable = true // Can everybody spawn this SWEP? - If you want only admins to spawn it, keep this false and admin spawnable true.
SWEP.ViewModelFOV = 100 // How much of the weapon do you see?

SWEP.ViewModel = "models/zerochain/props_weedfarm/zwf_wateringcan_vm.mdl"
SWEP.WorldModel =  "models/zerochain/props_weedfarm/zwf_wateringcan_vm.mdl"


if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("zerochain/zwf/vgui/zwf_swep_wateringcan")
end


SWEP.AutoSwitchTo = true // When someone picks up the SWEP, should it automatically change to your SWEP?
SWEP.AutoSwitchFrom = false // Should the weapon change to the a different SWEP if another SWEP is picked up?
SWEP.Slot = 3 // Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6)
SWEP.SlotPos = 5 // Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.HoldType = "slam" // How is the SWEP held? (Pistol SMG Grenade Melee)
SWEP.FiresUnderwater = false // Does your SWEP fire under water?
SWEP.Weight = 5 // Set the weight of your SWEP.
SWEP.DrawCrosshair = true // Do you want the SWEP to have a crosshair?
SWEP.Category = "Zeros GrowOP"
SWEP.DrawAmmo = false // Does the ammo show up when you are using it? True / False
SWEP.base = "weapon_base" //What your weapon is based on.

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 1

SWEP.UseHands = true

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Water")
	self:NetworkVar("Bool", 0, "IsBusy")
	self:NetworkVar("Bool", 1, "IsWatering")

	if (SERVER) then
		self:SetWater(zwf.config.WateringCan.Capacity)
		self:SetIsBusy(false)
		self:SetIsWatering(false)
	end
end
