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

	self:GetOwner():EmitSound("zwf_bong_end")
end

function SWEP:Holster(swep)

	// Removes the swep timers
	zwf.f.Timer_Remove("zwf_bong_smokeweed_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_bong_stopsmoking_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_bong_secondaryanim_" .. self:EntIndex() .. "_timer")
	zwf.f.Timer_Remove("zwf_bong_drawanim_" .. self:EntIndex() .. "_timer")

	if self:GetIsSmoking() == true then
		// Stops the bong sound
		self:StopBongSound()

		self.SmokeCount = 0

		self:SetIsSmoking(false)

		// Stops Third person smoking animation
		zwf.f.PlayerSmokeAnim_Stop(self:GetOwner())
	end

	self:SetIsBusy(false)

	self:SendWeaponAnim(ACT_VM_HOLSTER)

	self:ResetWeed()
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



	local timerID = "zwf_bong_smokeweed_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	// Creates the screeneffect
	zwf.f.Timer_Create(timerID,1,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) then
			self:GetOwner():EmitSound("zwf_igniter_lit")

			// Start Third person smoking animation
			zwf.f.PlayerSmokeAnim_Start(self:GetOwner())

			self:SmokeWeed()
		end
	end)
end

function SWEP:SmokeWeed()

	self:GetOwner():SetAnimation(PLAYER_START_AIMING)

	self:SetIsSmoking(true)

	// Inhale animation
	self:SendWeaponAnim(ACT_VM_THROW)

	zwf.f.CreateHighEffect(self:GetWeedID(),self:GetWeed_THC(),zwf.config.HighEffect.DefaultEffect_Duration,self:GetOwner())

	hook.Run("zwf_OnWeedSmoked",self:GetOwner(),self:GetWeedID(),self:GetWeed_THC())

	self:SetWeed_Amount(self:GetWeed_Amount() - zwf.config.Bongs.Use_Amount)

	self:GetOwner():GetViewModel():SetSkin(7)

	self:SetIsBurning(true)

	self.SmokeCount = self.SmokeCount + 1

	self.LastWeedHit = CurTime() + 0.5
end

function SWEP:StopSmoking()

	// Stops Third person smoking animation
	zwf.f.PlayerSmokeAnim_Stop(self:GetOwner())

	self:GetOwner():SetAnimation(PLAYER_LEAVE_AIMING)

	// Stops the bong sound
	self:StopBongSound()

	self:SetIsSmoking(false)

	// Finish animation
	self:SendWeaponAnim(ACT_VM_PULLPIN)

	local rest_weed = self:GetWeed_Amount()

	if rest_weed <= 0 then
		self:ResetWeed()
	end

	local timerID = "zwf_bong_stopsmoking_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	// Creates the screeneffect
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

		if self.SmokeCount > 5 and math.random(1,2) == 1 then
			self:GetOwner():EmitSound("zwf_cough")
		end


		zwf.f.SmokeEffect(self:GetWeedID(),self.SmokeCount,self:GetOwner(),self.BongID)
		self.SmokeCount = 0
	end

	if self:GetWeed_Amount() <= 0 then
		self:SetWeedID(-1)
		self:SetWeed_THC(-1)
		self:SetWeed_Amount(0)
		self:SetWeed_Name("NILL")
	end

	if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and string.sub( self:GetOwner():GetActiveWeapon():GetClass(), 1,8 ) then
		self:PlayIdleAnim()
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


	if self:GetWeedID() ~= -1 then return end

	local tr = self:GetOwner():GetEyeTrace()

	if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zwf_jar" and tr.Entity:GetWeedAmount() > 0 then

		self:SetIsBusy(true)

		self:DoSecondaryAnims()

		local bongData = zwf.config.Bongs.items[self.BongID]

		local jarAmount = tr.Entity:GetWeedAmount()
		local weedID = tr.Entity:GetPlantID()

		self:SetWeedID(weedID)
		self:SetWeed_THC(tr.Entity:GetTHC())
		self:SetWeed_Name(tr.Entity:GetWeedName())
		self:SetWeed_Amount(bongData.hold_amount)

		self:EnableWeed()

		if jarAmount > bongData.hold_amount then
			tr.Entity:SetWeedAmount(tr.Entity:GetWeedAmount() - bongData.hold_amount)
		else
			tr.Entity:Remove()
		end

		// Punch the player's view
		self:GetOwner():ViewPunch( Angle( -3, 0, 0 ) )

		self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	end


	self:SetNextSecondaryFire(CurTime() + 0.7)
end

function SWEP:DoSecondaryAnims()
	if not IsValid(self) then return end // Safety first!
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) // Play secondary anim

	local timerID = "zwf_bong_secondaryanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.7,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self) then
			self:SetIsBusy(false)
		end
		if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and string.sub( self:GetOwner():GetActiveWeapon():GetClass(), 1,8 ) then
			self:PlayIdleAnim()
		end
	end)
end



function SWEP:Reload()

	if self:GetIsBusy() then return end

	if self:GetWeedID() ~= -1 then

		self:ResetWeed()

		self:SetWeedID(-1)
		self:SetWeed_THC(-1)
		self:SetWeed_Name("NILL")
		self:SetWeed_Amount(0)
		self:SetIsBurning(false)
	end

	self:PlayIdleAnim()
end


function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end // Safety first!

	self:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zwf_bong_drawanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.3,1,function()
		zwf.f.Timer_Remove(timerID)

		if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and string.sub( self:GetOwner():GetActiveWeapon():GetClass(), 1,8 )  then

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
			self:GetOwner():GetViewModel():SetSkin(7)
		else
			self:GetOwner():GetViewModel():SetSkin( zwf.config.Plants[weedID].skin)
		end

		self:GetOwner():GetViewModel():SetBodygroup(0, 1)
	else
		self:ResetWeed()
	end
end

function SWEP:ResetWeed()

	self:SetIsBurning(false)
	self:GetOwner():GetViewModel():SetSkin(0)
	self:GetOwner():GetViewModel():SetBodygroup(0, 0)
end
