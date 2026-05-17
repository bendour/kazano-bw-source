AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastReload = 1
end

function SWEP:SecondaryAttack()

	net.Start("zwf_Shop_Open_net")
	net.Send(self:GetOwner())


	self:SetNextSecondaryFire(CurTime() + 1)
end


function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:Reload()
	if CurTime() < self.LastReload then return end
	self.LastReload = CurTime() + 0.5

	zwf.f.SellItem(self:GetOwner())
end

function SWEP:Equip()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:GetOwner():SetAnimation(PLAYER_IDLE)
end

function SWEP:Deploy()
	self:GetOwner():SetAnimation(PLAYER_IDLE)

	self:PlayDrawAnim()

	return true
end

function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end // Safety first!

	self:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zwf_tablet_drawanim_" .. self:EntIndex() .. "_timer"
	zwf.f.Timer_Remove(timerID)

	zwf.f.Timer_Create(timerID,0.66,1,function()
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
	zwf.f.Timer_Remove("zwf_tablet_drawanim_" .. self:EntIndex() .. "_timer")
	return true
end




function SWEP:ShouldDropOnDie()
	return false
end
