AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.Weight = 5

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastWeedHit = -1

	self.SmokeCount = 0
end

function SWEP:StopBongSound()
	self:SetIsSmoking(false)

	zwf.f.CreateNetEffect("zwf_joint_stop",self:GetOwner())
end


function SWEP:Holster(swep)

	// Stops the bong sound
	self:StopBongSound()

	// Removes the swep timers
	zwf.f.Timer_Remove("zwf_joint_smokeweed_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_joint_stopsmoking_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_joint_drawanim_" .. self:EntIndex() .. "_timer")

	self.SmokeCount = 0

	self:SendWeaponAnim(ACT_VM_HOLSTER)
	self:SetIsSmoking(false)

	self:SetIsBusy(false)

	// Stops Third person smoking animation
	zwf.f.PlayerSmokeAnim_Stop(self:GetOwner())

	if self:GetWeed_Amount() <= 0 then
		self:RemoveJoint()
	end

	return true
end

function SWEP:Deploy()

	self:GetOwner():SetAnimation(PLAYER_IDLE)

	self:EnableWeed()

	self:PlayDrawAnim()

	return true
end


// Make bong hit
function SWEP:PrimaryAttack()
	if self:GetIsBusy() then
		return false
	end

	if self:GetWeedID() ~= -1 then
		self:SetIsBusy(true)
		self:DoPrimaryAnims()
	else
		zwf.f.Notify(self:GetOwner(),zwf.language.General["bong_no_weed"], 1)
	end
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:DoPrimaryAnims()
	if not IsValid(self) then return end // Safety first!
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) // Play primary anim

	local timerID = "zwf_joint_smokeweed_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	// Creates the screeneffect
	zwf.f.Timer_Create(timerID,1,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) then
			self:GetOwner():EmitSound("zwf_igniter_lit")
			zwf.f.CreateNetEffect("zwf_joint_start",self:GetOwner())

			// Start Third person smoking animation
			zwf.f.PlayerSmokeAnim_Start(self:GetOwner())

			self:SmokeWeed()
		end
	end)
end

function SWEP:SmokeWeed()
	self:SetIsSmoking(true)


	// Inhale animation
	self:SendWeaponAnim(ACT_VM_THROW)

	zwf.f.CreateHighEffect(self:GetWeedID(),self:GetWeed_THC(),zwf.config.HighEffect.DefaultEffect_Duration,self:GetOwner())

	self:SetWeed_Amount(self:GetWeed_Amount() - zwf.config.Bongs.Use_Amount)

	self:GetOwner():GetViewModel():SetSkin(1)

	self:SetIsBurning(true)

	self.SmokeCount = self.SmokeCount + 1

	self.LastWeedHit = CurTime() + 0.5
end

function SWEP:StopSmoking()
	// Stops Third person smoking animation
	zwf.f.PlayerSmokeAnim_Stop(self:GetOwner())

	// Stops the bong sound
	self:StopBongSound()

	self:SetIsSmoking(false)

	// Finish animation
	self:SendWeaponAnim(ACT_VM_PULLPIN)

	local timerID = "zwf_joint_stopsmoking_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,2.6,1,function()
		zwf.f.Timer_Remove(timerID)
		if IsValid(self) then
			self:SmokeFinish()
		end
	end)

	self.LastWeedHit = CurTime() + 0.5
end

function SWEP:SmokeFinish()
	if self.SmokeCount > 0 then

		if self.SmokeCount > math.Round(zwf.config.DoobyTable.WeedPerJoint * 0.5) and math.random(1,2) == 1 then
			self:GetOwner():EmitSound("zwf_cough")
		end

		zwf.f.SmokeEffect(self:GetWeedID(),self.SmokeCount,self:GetOwner(),25)
		self.SmokeCount = 0
	end

	if self:GetWeed_Amount() <= 0 then
		self:RemoveJoint()
	else

		if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and string.sub( self:GetOwner():GetActiveWeapon():GetClass(), 1,8 ) then
			self:PlayIdleAnim()
		end
	end

	self:SetIsBusy(false)
end

function SWEP:Think()
	if self:GetIsSmoking() and self.LastWeedHit < CurTime() then

		if self:GetWeed_Amount() > 0 and IsValid(self:GetOwner()) and self:GetOwner():KeyDown(IN_ATTACK) then

			self:SmokeWeed()
		else
			self:StopSmoking()
		end
	end
end




// Collect weed
function SWEP:SecondaryAttack()
	if self:GetIsBusy() then return end

	self:SetNextSecondaryFire(CurTime() + 0.7)
end





function SWEP:Reload()

	if self:GetIsBusy() then return end

	self:RemoveJoint()
end


function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end // Safety first!

	self:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zwf_joint_drawanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.3,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and string.sub( self:GetOwner():GetActiveWeapon():GetClass(), 1,8 )  then

			self:PlayIdleAnim()
		end
	end)
end

function SWEP:PlayIdleAnim()
	if not IsValid(self) then return end // Safety first!

	if self:GetIsBurning() then

		// A idle animation with burn effect
		self:SendWeaponAnim(ACT_VM_HITLEFT)
	else

		// Player idle anim
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end



function SWEP:ShouldDropOnDie()
	return false
end



function SWEP:EnableWeed()

	local weedID = self:GetWeedID()
	if weedID ~= -1 then


		if self:GetIsBurning() then
			self:GetOwner():GetViewModel():SetSkin(1)
		else
			self:GetOwner():GetViewModel():SetSkin(0)
		end

	else
		self:RemoveJoint()
	end
end

function SWEP:RemoveJoint()
	self:SetIsSmoking(false)
	self:SetIsBurning(false)
	self:GetOwner():GetViewModel():SetSkin(0)

	self:GetOwner():StripWeapon("zwf_joint")
end
