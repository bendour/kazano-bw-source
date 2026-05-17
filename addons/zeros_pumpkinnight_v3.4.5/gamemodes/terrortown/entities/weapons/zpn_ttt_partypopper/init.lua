/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sh_zpn_config_main.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	self:Debug("Initialize")

	self:SetHoldType(self.HoldType)
	self:SetBusy(false)

	self.GotShot = false

	if self.PartyPopperID == 1 then
		self:SetSkin(0)
	elseif self.PartyPopperID == 2 then
		self:SetSkin(1)
	end
end

function SWEP:Holster(swep)
	self:Debug("Holster")

	// Removes the swep timers
	zclib.Timer.Remove("zpn_partypopper_drawanim_" .. self:EntIndex() .. "_timer")
	zclib.Timer.Remove("zpn_partypopper_shoot_" .. self:EntIndex() .. "_timer")

	if self.GotShot == true then
		zclib.Timer.Remove("zpn_partypopper_remove_" .. self:EntIndex() .. "_timer")
		self.Owner:StripWeapon(self:GetPopperClass())
	end


	self:SendWeaponAnim(ACT_VM_HOLSTER)

	if IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetBodygroup(2, 0)
	end

	self:SetBusy(false)

	return true
end

function SWEP:Deploy()
	self:Debug("Deploy")

	zclib.Timer.Remove("zpn_partypopper_drawanim_" .. self:EntIndex() .. "_timer")
	zclib.Timer.Remove("zpn_partypopper_shoot_" .. self:EntIndex() .. "_timer")

	self:SetBusy(true)

	self.GotShot = false

	self.Owner:SetAnimation(PLAYER_IDLE)

	self.Owner:GetViewModel():SetBodygroup(2, 0)

	if self.PartyPopperID == 1 then
		self.Owner:GetViewModel():SetSkin(0)
		self:SetSkin(0)
	elseif self.PartyPopperID == 2 then
		self.Owner:GetViewModel():SetSkin(1)
		self:SetSkin(1)
	end

	self:PlayDrawAnim()

	return true
end

function SWEP:Reload()
	self:Debug("Reload")
end


function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end // Safety first!
	self:Debug("PlayDrawAnim")

	self:SetBusy(true)

	self:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zpn_partypopper_drawanim_" .. self:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID,0.5,1,function()
		zclib.Timer.Remove(timerID)

		if IsValid(self) and IsValid(self.Owner) and IsValid(self.Owner:GetActiveWeapon()) and self.Owner:GetActiveWeapon():GetClass() == self:GetPopperClass()  then

			self:PlayIdleAnim()
		end
	end)
end

function SWEP:PlayIdleAnim()
	if not IsValid(self) then return end // Safety first!
	self:Debug("PlayIdleAnim")

	self:SendWeaponAnim(ACT_VM_IDLE)

	self:SetBusy(false)
end



function SWEP:PrimaryAttack()

	if self:GetBusy() then
		return false
	end
	self:Debug("PrimaryAttack")

	self:SetBusy(true)
	self:DoPrimaryAnims()
	self:SetNextPrimaryFire(CurTime() + 2)
	return true
end

function SWEP:DoPrimaryAnims()
	if not IsValid(self) then return end // Safety first!
	self:Debug("DoPrimaryAnims")

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) // Play primary anim
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.GotShot = true

	local timer01ID = "zpn_partypopper_shoot_" .. self:EntIndex() .. "_timer"
	zclib.Timer.Remove(timer01ID)

	zclib.Timer.Create(timer01ID,0.33,1,function()
		zclib.Timer.Remove(timer01ID)

		if IsValid(self) and IsValid(self.Owner) and IsValid(self.Owner:GetActiveWeapon()) and self.Owner:GetActiveWeapon():GetClass() == self:GetPopperClass()  then
			self:Shoot()
		end
	end)

	local timer02ID = "zpn_partypopper_remove_" .. self:EntIndex() .. "_timer"
	zclib.Timer.Remove(timer02ID)

	zclib.Timer.Create(timer02ID,2,1,function()
		zclib.Timer.Remove(timer02ID)

		if IsValid(self) and IsValid(self.Owner) then
			self:RemovePartypopper()
		end
	end)
end

function SWEP:Shoot()
	self:Debug("Shoot")

	local ang = self.Owner:EyeAngles()
	ang:RotateAroundAxis(self.Owner:EyeAngles():Right(),-90)

	local pos = self.Owner:EyePos() + ang:Forward() * 27 + ang:Up() * 35

	// Hide pumpkin
	self.Owner:GetViewModel():SetBodygroup(2, 1)
	self:SetBodygroup(2, 1)

	if self.PartyPopperID == 1 then
		// Create confetty
		zclib.NetEvent.Create("zpn_partypopper_normal", {self,pos,ang})

	elseif self.PartyPopperID == 2 then

		// Create confetty
		zclib.NetEvent.Create("zpn_partypopper_special", {self,pos,ang})

		local ent = ents.Create("zpn_ttt_partypopper_projectile")
		ent:SetPos(pos)
		ent:SetAngles(self.Owner:EyeAngles())
		ent.FlyDir = ent:GetAngles():Forward()
		ent.KillTime = 1
		ent:Spawn()
		ent:Activate()

		ent.Owner = self.Owner
	end
end

function SWEP:RemovePartypopper()
	self:Debug("RemovePartypopper")

	zclib.Timer.Remove("zpn_partypopper_drawanim_" .. self:EntIndex() .. "_timer")
	zclib.Timer.Remove("zpn_partypopper_shoot_" .. self:EntIndex() .. "_timer")
	zclib.Timer.Remove("zpn_partypopper_remove_" .. self:EntIndex() .. "_timer")
	self:SetBusy(false)
	self.Owner:StripWeapon(self:GetPopperClass())
end


function SWEP:ShouldDropOnDie()
	return false
end
