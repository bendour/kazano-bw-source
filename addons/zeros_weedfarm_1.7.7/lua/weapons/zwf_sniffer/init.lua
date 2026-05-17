AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.Weight = 5

function SWEP:PrimaryAttack()
	zwf.f.SnifferSWEP_Primary(self:GetOwner())
	self:SetNextPrimaryFire(CurTime() + zwf.config.SnifferSWEP.interval)
	self:SetNextSecondaryFire(CurTime() + zwf.config.SnifferSWEP.interval)
end

function SWEP:SecondaryAttack()
	zwf.f.SnifferSWEP_Primary(self:GetOwner())
	self:SetNextPrimaryFire(CurTime() + zwf.config.SnifferSWEP.interval)
	self:SetNextSecondaryFire(CurTime() + zwf.config.SnifferSWEP.interval)
end

function SWEP:Reload()
end

function SWEP:Deploy()
	self:GetOwner():SetAnimation(PLAYER_IDLE)
	return true
end




function SWEP:ShouldDropOnDie()
	return false
end
