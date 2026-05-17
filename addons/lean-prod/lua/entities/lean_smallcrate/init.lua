AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
resource.AddSingleFile("materials/lean_prod/lean.png")

-- Initialize the entity ( Prepare values for later use )
function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box001a.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
    if lean_updated.smalldmg.val then
        self:SetHealth(lean_updated.smallhp.val)
    end
    self:Setholding(0)
    self:Setfull(false)
end

-- Touch related things ( Adding cups etc )
function ENT:StartTouch(ent)
	if !self:Getfull() && IsValid(ent) && ent.i_leancup && !ent.i_used && ent:Getliquid() then
		ent.i_used = true
		ent:Remove()
		self:Setholding(self:Getholding() + 1)
		hook.Run("lean_incrate", unpack({self, self:Getholding()}))
	end
end
function ENT:Think()
	if self:Getholding() >= lean_updated.smallhold.val then
		self:Setfull(true)
	end
end

-- Integrate pressing E
function ENT:Use(ply)
	if lean_updated.usetosell.val && IsValid(ply) && self:Getholding() >= 1 then
    if ply != self:CPPIGetOwner() then
		BaseWars:Notify(ply, "#notYours", NOTIFICATION_ERROR, 5)
		return
	end
		self:Remove()
		ply.lean = ply.lean + self:Getholding()
		net.Start("lean_msg")
		net.WriteString("You have picked up a box of lean. You are now carrying: " .. ply.lean)
		net.Send(ply)
	end
end

-- Damage control if enabled
function ENT:OnTakeDamage(dmg)
	if lean_updated.smalldmg.val then
		self:SetHealth(self:Health() - dmg:GetDamage())
		if self:Health() <= 0 then
			self:Remove()
			if lean_updated.smalldrop.val then
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