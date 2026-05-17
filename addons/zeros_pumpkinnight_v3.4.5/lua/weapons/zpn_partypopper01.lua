/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

AddCSLuaFile()

include("sh_zpn_config_main.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

DEFINE_BASECLASS("zpn_partypopper")

SWEP.Base = "zpn_partypopper"
SWEP.PrintName = "Pumpkin Slayer" // The name of your SWEP
SWEP.Category = "Zeros PumpkinNight"
SWEP.ViewModelFOV = 90
SWEP.ViewModel = "models/zerochain/props_pumpkinnight/zpn_partypopper_vm.mdl"
SWEP.WorldModel = "models/zerochain/props_pumpkinnight/zpn_partypopper.mdl"
SWEP.AdminSpawnable = true
SWEP.Spawnable = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

SWEP.PartyPopperID = 2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("zerochain/zpn/vgui/zpn_swep_partypopper01")
    SWEP.BounceWeaponIcon = false
end
