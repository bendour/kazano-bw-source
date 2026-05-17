AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

--[[-------------------------------------------------------------------------
Setup values for the entity to make sure we can store lean inside
---------------------------------------------------------------------------]]
function ENT:Initialize()
	self:SetModel("models/freeman/codeine_crate.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetPos(self:GetPos()+Vector(0,0,50))
	if lean_updated.cratedmg.val then
		self:SetHealth(lean_updated.cratehp.val)
	end
	self:Setholding(0)
	self:Setfull(false)
end

--[[-------------------------------------------------------------------------
Checking if the entity that touched the crate was a lean bottle that
contains lean
---------------------------------------------------------------------------]]
function ENT:StartTouch(ent)
	if !self:Getfull() && IsValid(ent) && ent.i_leancup && !ent.i_used && ent:Getliquid() then
		ent.i_used = true
		ent:Remove()
		self:Setholding(self:Getholding() + 1)
		hook.Run("lean_incrate", unpack({self, self:Getholding()}))
	end
end
function ENT:Think()
	if self:Getholding() >= lean_updated.cratehold.val then
		self:Setfull(true)
	end
end

--[[-------------------------------------------------------------------------
If the config lets us press e on the crate, do so
---------------------------------------------------------------------------]]
function ENT:Use(ply)
	if lean_updated.usetosell.val && IsValid(ply) && self:Getholding() >= 1 then
		self:Remove()
		ply.lean = ply.lean + self:Getholding()
		net.Start("lean_msg")
		net.WriteString("You have picked up a box of lean. You are now carrying: " .. ply.lean)
		net.Send(ply)
	end
end

--[[-------------------------------------------------------------------------
Remove the crate if allowed to do so in the config
---------------------------------------------------------------------------]]
function ENT:OnTakeDamage(dmg)
	if lean_updated.cratedmg.val then
		self:SetHealth(self:Health() - dmg:GetDamage())
		if self:Health() <= 0 then
			self:Remove()
			if lean_updated.cratedropcups.val then
				if self:Getholding() > 0 then
					for i = 1, self:Getholding() do
						local ent = ents.Create("lean_cup")
						ent:SetPos(self:GetPos() + Vector(0,0,math.Rand(25,100)))
						ent:Spawn()
						ent:Setliquid(true)
						ent:SetBodygroup(1,1)
					end
				end
			end
		end
	else
		return false
	end
end