AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
util.AddNetworkString("LeanMenu")

--[[-------------------------------------------------------------------------
Setting up model physics etc...
---------------------------------------------------------------------------]]
function ENT:Initialize()
	self:SetModel("models/freeman/codeine_barrel.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetAutomaticFrameAdvance(true)
	self:SetPlaybackRate(1)
	local sequence = self:LookupSequence("Open")
	self:ResetSequence(sequence)
	if lean_updated.barreldmg.val then
		self:SetHealth(lean_updated.barrelhp.val)
	end
	self:Setsprite_num(0)
	self:Setcodeine_num(0)
	self:Setranchers_num(0)
	self:Setice_num(0)
	self:Setholding(0)
	self:Setshook(0)
	self:Setextract(false)
	self:Setfull(false)
	self:Setmixing(false)
	self.uniqueid = "lean_" .. self:EntIndex()
end
function ENT:StartTouch(ent)
	if self:Getextract() && IsValid(ent) && ent.i_leancup && !ent:Getliquid() then
		ent:Setliquid(true)
		ent:SetBodygroup(1,1)
		ent:EmitSound("ambient/levels/canals/drip1.wav")
		self:Setholding(self:Getholding() - 1)
	end
end
function ENT:Think()
	if self:Getextract() && self:Getholding() <= 0 then
		self:Setextract(false)
		self:Setfull(false)
		self:Setmixing(false)
		self:SetBodygroup(1,0)
	end
	if self:Getsprite_num() == lean_updated.requiredsprite.val && self:Getcodeine_num() == lean_updated.requiredcodeine.val && self:Getranchers_num() == lean_updated.requiredranchers.val && self:Getice_num() == lean_updated.requiredice.val then
		self:Setfull(true)
		local sequence = self:LookupSequence("Close")
		self:ResetSequence(sequence)
		self:Setsprite_num(0)
		self:Setcodeine_num(0)
		self:Setranchers_num(0)
		self:Setice_num(0)
	end
	if lean_updated.manualshake.val then
		if self:Getfull() && !self:Getextract() then
			if self:GetVelocity():Length() > 1500 then
				self:Setshook(self:Getshook() + 1)
				if lean_updated.pingOnVel then
					self:EmitSound("npc/turret_floor/ping.wav")
				end
			end
			if self:Getshook() >= lean_updated.shakeamount.val then
				self:Setextract(true)
				self:Setshook(0)
				self:SetBodygroup(1,1)
				local anim = self:LookupSequence("Open")
				self:ResetSequence(anim)
				self:Setholding(lean_updated.extractamount.val)
			end
		end
	end
	self:NextThink(CurTime())
	return true
end

--[[-------------------------------------------------------------------------
Opening the menu when E is pressed
---------------------------------------------------------------------------]]
function ENT:Use(act,ply)
	if !self:Getfull() and !self:Getextract() then
		net.Start("LeanMenu")
		net.WriteEntity(self)
		net.Send(ply)
	elseif !lean_updated.manualshake.val && !self:Getmixing() then
		self:Setmixing(true)
		net.Start("lean_msg")
		net.WriteString("Beginning mixing process")
		net.Send(ply)
		timer.Create(self.uniqueid,lean_updated.mixingtime.val,1,function()
			net.Start("lean_msg")
			net.WriteString("Finished mixing")
			net.Send(ply)
			self:Setextract(true)
			self:SetBodygroup(1,1)
			local anim = self:LookupSequence("Open")
			self:ResetSequence(anim)
			self:Setholding(lean_updated.extractamount.val)
		end)
	end
end

--[[-------------------------------------------------------------------------
Removing barrel if the config lets us :)
---------------------------------------------------------------------------]]
function ENT:OnTakeDamage(dmg)
	if lean_updated.barreldmg.val then
		self:SetHealth(self:Health() - dmg:GetDamage())
		if self:Health() <= 0 then
			if timer.Exists(self.uniqueid) then
				timer.Remove(self.uniqueid)
			end
			self:Remove()
		end
	else
		return false
	end
end