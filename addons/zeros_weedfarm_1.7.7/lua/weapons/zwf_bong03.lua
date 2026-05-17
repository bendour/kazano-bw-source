AddCSLuaFile()
DEFINE_BASECLASS("zwf_bong")

SWEP.Base = "zwf_bong"
SWEP.PrintName = "Dark Leaf"
SWEP.Category = "Zeros GrowOP"
SWEP.ViewModelFOV = 90
SWEP.ViewModel = "models/zerochain/props_weedfarm/zwf_bong03_vm.mdl"
SWEP.WorldModel = "models/zerochain/props_weedfarm/zwf_bong03_vm.mdl"
SWEP.AdminSpawnable = true
SWEP.Spawnable = true

SWEP.BongID = 3

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("zerochain/zwf/vgui/zwf_swep_bong03")
end

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 1, "WeedID")
    self:NetworkVar("String", 0, "Weed_Name")
    self:NetworkVar("Int", 2, "Weed_THC")
    self:NetworkVar("Int", 3, "Weed_Amount")
    self:NetworkVar("Bool", 0, "IsBusy")
    self:NetworkVar("Bool", 1, "IsSmoking")
    self:NetworkVar("Bool", 2, "IsBurning")

    if (SERVER) then
        self:SetWeedID(-1)
        self:SetWeed_THC(-1)
        self:SetIsBusy(false)
        self:SetWeed_Name("NILL")
        self:SetWeed_Amount(0)
        self:SetIsSmoking(false)

        self:SetIsBurning(false)
    end
end
