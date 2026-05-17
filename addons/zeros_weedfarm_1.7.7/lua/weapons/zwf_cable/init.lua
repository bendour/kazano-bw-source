AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end


// Build Entity
function SWEP:PrimaryAttack()

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) // Play primary anim

	zwf.f.CableSWEP_Primary(self)

	local timerID = "zwf_cable_primaryanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.66,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self:GetOwner()) then
			self:PlayIdleAnim()
		end
	end)

	self:SetNextPrimaryFire(CurTime() + 0.25)
end

// Deconstruct Entity
function SWEP:SecondaryAttack()

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) // Play primary anim

	zwf.f.CableSWEP_Secondary(self)

	local timerID = "zwf_cable_secondaryanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.66,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self:GetOwner()) then
			self:PlayIdleAnim()
		end
	end)


	self:SetNextSecondaryFire(CurTime() + 0.25)
end



function SWEP:Reload()
end

function SWEP:Deploy()

	self:GetOwner():SetAnimation(PLAYER_IDLE)

	self:PlayDrawAnim()

	return true
end

function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end // Safety first!

	self:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zwf_cable_drawanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.64,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self:GetOwner()) then
			self:PlayIdleAnim()
		end
	end)
end

function SWEP:PlayIdleAnim()
	if not IsValid(self) then return end // Safety first!
	self:SendWeaponAnim(ACT_VM_IDLE) // Player idle anim
end

function SWEP:Holster(swep)

	self:SendWeaponAnim(ACT_VM_HOLSTER)
	zwf.f.Timer_Remove("zwf_cable_primaryanim_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_cable_drawanim_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_cable_secondaryanim_" .. self:EntIndex() .. "_timer")

	return true
end

function SWEP:ShouldDropOnDie()
	return false
end
