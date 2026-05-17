AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

--[[-------------------------------------------------------------------------
Set values for the barrel + crate to communicate with
---------------------------------------------------------------------------]]
function ENT:Initialize()
	self:SetModel("models/freeman/codeine_cup.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	if lean_updated.cupdmg.val then
		self:SetHealth(lean_updated.cuphp.val)
	end
	self:Setliquid(false)
	self.i_used = false
	self.i_leancup = true
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
end

--[[-------------------------------------------------------------------------
Remove cup if allowed to via config
---------------------------------------------------------------------------]]
function ENT:OnTakeDamage(dmg)
	if lean_updated.cupdmg.val then
		self:SetHealth(self:Health() - dmg:GetDamage())
		if self:Health() <= 0 then
			self:Remove()
		end
	else
		return false
	end
end

--[[-------------------------------------------------------------------------
Lean effects
---------------------------------------------------------------------------]]
function ENT:Use(act,ply)
	if !IsValid(ply) then return end
	if lean_updated.allowleanuse.val && self:Getliquid() && !ply.onlean then
		ply:EmitSound("npc/barnacle/barnacle_gulp1.wav")
		self:SetBodygroup(1,0)
		self:Setliquid(false)
		ply:SetWalkSpeed(ply:GetWalkSpeed() + lean_updated.speedamount.val)
		ply:SetRunSpeed(ply:GetRunSpeed() + lean_updated.speedamount.val)
		ply.onlean = true
		net.Start("lean_sendeffects")
		net.WriteBool(ply.onlean)
		net.Send(ply)
		net.Start("lean_msg")
		net.WriteString("You drank some lean...")
		net.Send(ply)
		hook.Run("lean_drankLean", ply)
		timer.Create("lean_" .. ply:SteamID64(),lean_updated.speedtime.val,1, function()
			ply:SetWalkSpeed(ply:GetWalkSpeed() - lean_updated.speedamount.val)
			ply:SetRunSpeed(ply:GetRunSpeed() - lean_updated.speedamount.val)
			ply.onlean = false
			net.Start("lean_sendeffects")
			net.WriteBool(ply.onlean)
			net.Send(ply)
			net.Start("lean_msg")
			net.WriteString("Lean effects wore off")
			net.Send(ply)
		end)
	end
end

--[[-------------------------------------------------------------------------
Get rid of the cooldown if the player died
---------------------------------------------------------------------------]]
hook.Add("PlayerDeath", "lean_timerCheck", function(ply)
	if timer.Exists("lean_" .. ply:SteamID64()) then
		timer.Remove("lean_" .. ply:SteamID64())
		ply.onlean = false
		net.Start("lean_sendeffects")
		net.WriteBool(ply.onlean)
		net.Send(ply)
	end
end)