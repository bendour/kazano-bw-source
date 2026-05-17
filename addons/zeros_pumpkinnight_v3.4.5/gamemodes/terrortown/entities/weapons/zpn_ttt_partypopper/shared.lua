/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("sh_zpn_config_main.lua")

SWEP.PrintName = "Partypopper" // The name of your SWEP
SWEP.Category = "Zeros PumpkinNight"
SWEP.Author = "JL" // Your name
SWEP.Instructions = "Hold LMB: Fire" // How do people use your SWEP?
SWEP.Contact = "https://www.gmodstore.com/users/ZeroChain" // How people should contact you if they find bugs, errors, etc
SWEP.Purpose = "Awesome way to celebrate Halloween" // What is the purpose of the SWEP?
SWEP.IconLetter	= "V"

SWEP.AutomaticFrameAdvance = true

SWEP.AdminSpawnable = false // Is the SWEP spawnable for admins?
SWEP.Spawnable = true // Can everybody spawn this SWEP? - If you want only admins to spawn it, keep this false and admin spawnable true.

SWEP.ViewModelFOV = 120 // How much of the weapon do you see?
SWEP.UseHands = true
SWEP.ViewModel = "models/zerochain/props_pumpkinnight/zpn_partypopper_vm.mdl"
SWEP.WorldModel = "models/zerochain/props_pumpkinnight/zpn_partypopper.mdl"


SWEP.AutoSwitchTo = true // When someone picks up the SWEP, should it automatically change to your SWEP?
SWEP.AutoSwitchFrom = false // Should the weapon change to the a different SWEP if another SWEP is picked up?
SWEP.Slot = 2 // Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6)
SWEP.SlotPos = 1 // Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.HoldType = "crossbow" // How is the SWEP held? (Pistol SMG Grenade Melee)
SWEP.FiresUnderwater = false // Does your SWEP fire under water?
SWEP.Weight = 5 // Set the weight of your SWEP.
SWEP.DrawCrosshair = true // Do you want the SWEP to have a crosshair?

SWEP.DrawAmmo = false // Does the ammo show up when you are using it? True / False

-- always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 1

// What weapon is this
SWEP.PartyPopperID = 2


--[[TTT config values]]--

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "none"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true




if CLIENT then
	SWEP.Icon = "vgui/entities/zpn_partypopper01"
end


function SWEP:Debug(action_name)
    zclib.Debug(self:GetClass() .. ":" .. action_name)
end

function SWEP:GetPopperClass()
    if self.PartyPopperID == 1 then
        return "zpn_partypopper"
    elseif self.PartyPopperID == 2 then
        return "zpn_ttt_partypopper"
    end
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Busy")
    if SERVER then
        self:SetBusy(false)
    end
end
