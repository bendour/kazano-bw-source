AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.Weight = 5

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastWaterHit = -1
end



function SWEP:PrimaryAttack()

	if self:GetIsBusy() == false and self:GetWater() > 0 then
		//self:WaterPlant()
		self:SetIsBusy(true)
		self:DoPrimaryAnims()
	end
	self:SetNextPrimaryFire(CurTime() + 1)
end



function SWEP:DoPrimaryAnims()
	if not IsValid(self) then return end // Safety first!
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) // Play primary anim

	local timerID = "zwf_wateringcan_primaryanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,1,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self:GetOwner()) then
			if self:GetOwner():KeyDown(IN_ATTACK) and self:GetWater() > 0 then
				self:SetIsWatering(true)
				self:WaterPlant()
			else
				self:StopWatering()
			end
		end
	end)
end

function SWEP:WaterPlant()

	// water animation
	self:SendWeaponAnim(ACT_VM_THROW)

	if self:GetWater() < 0 then return end

	local tr = self:GetOwner():GetEyeTrace()
	local trEnt = tr.Entity
	if tr.Hit and IsValid(trEnt) then
		local pot

		if string.sub( trEnt:GetClass(), 1, 7 )  == "zwf_pot" then
			pot = trEnt
		elseif trEnt:GetClass() == "zwf_plant" and IsValid(trEnt:GetParent()) and string.sub( trEnt:GetParent():GetClass(), 1, 7 )  == "zwf_pot" then
			pot = trEnt:GetParent()
		end

		if IsValid(pot) and zwf.f.Flowerpot_CanWaterPlant(pot) then
			zwf.f.Flowerpot_Watering(pot, zwf.config.WateringCan.Transfer_Amount)

		end
	end

	self:SetWater(self:GetWater() - zwf.config.WateringCan.Transfer_Amount)

	self.LastWaterHit = CurTime() + 0.5
end

function SWEP:StopWatering()

	self:SetIsWatering(false)

	// Finish animation
	self:SendWeaponAnim(ACT_VM_PULLPIN)

	local timerID = "zwf_wateringcan_stopwaterting_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.8,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) then
			if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and  self:GetOwner():GetActiveWeapon():GetClass() == "zwf_wateringcan" then
				self:PlayIdleAnim()
			end

			self:SetIsBusy(false)
		end
	end)

	self.LastWaterHit = CurTime() + 0.5
end

function SWEP:Think()
	if self:GetIsWatering() == true and self.LastWaterHit < CurTime() then

		if self:GetWater() > 0 and IsValid(self:GetOwner()) and self:GetOwner():KeyDown(IN_ATTACK) then

			self:WaterPlant()
		else
			self:StopWatering()
		end
	end
end






function SWEP:SecondaryAttack()

	zwf.f.SWEP_GetWater(self)

	self:SetNextSecondaryFire(CurTime() + 0.2)
end


function SWEP:Reload()
end

function SWEP:Deploy()

	self:GetOwner():SetAnimation(PLAYER_IDLE)
	self:SetIsWatering(false)
	self:SetIsBusy(false)
	self:PlayDrawAnim()
	return true
end

function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end // Safety first!

	self:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim


	local timerID = "zwf_wateringcan_drawanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.64,1,function()
		zwf.f.Timer_Remove(timerID)
		if IsValid(self) then
			self:PlayIdleAnim()
		end
	end)
end



function SWEP:PlayIdleAnim()
	if not IsValid(self) then return end // Safety first!
	self:SendWeaponAnim(ACT_VM_IDLE) // Player idle anim
end


function SWEP:Holster(swep)
	self:SetIsBusy(false)
	self:SetIsWatering(false)
	self:SendWeaponAnim(ACT_VM_HOLSTER)

	zwf.f.Timer_Remove("zwf_wateringcan_stopwaterting_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_wateringcan_drawanim_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_wateringcan_primaryanim_" .. self:EntIndex() .. "_timer")

	return true
end




function SWEP:ShouldDropOnDie()
	return false
end
