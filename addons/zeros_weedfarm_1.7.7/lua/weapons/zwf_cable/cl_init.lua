include("shared.lua")

SWEP.PrintName = "Cable" // The name of your SWEP
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true // Do you want the SWEP to have a crosshair?

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end


local WaterEnts = {"zwf_watertank","zwf_pot_hydro"}
local WaterUser = {"zwf_pot_hydro"}

local EnergyEnts = {"zwf_generator","zwf_lamp","zwf_ventilator","zwf_outlet"}
local EnergyUser = {"zwf_lamp","zwf_ventilator","zwf_outlet"}

function SWEP:DrawHUD()
	local generator = self:GetSelectedEntity()
	if not IsValid(generator) then return end


	local tr = util.TraceLine( {
		start = LocalPlayer():EyePos(),
		endpos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 1000,
		filter = function( ent )
			if ( ent:GetClass() == "zwf_plant" or ent == LocalPlayer() ) then
				return false
			else
				return true
			end
		end
	} )

	local color = zwf.default_colors["black02"]
	local endPoint = Vector(0,0,0)
	local startPoint = Vector(0,0,0)

	if generator:GetClass() == "zwf_generator" then
		color = zwf.default_colors["white01"]
		startPoint = generator:LocalToWorld(Vector(-9, 19, 16))
	elseif generator:GetClass() == "zwf_lamp" then
		color = zwf.default_colors["white01"]
		startPoint = generator:GetAttachment(2).Pos
	elseif generator:GetClass() == "zwf_ventilator" then
		color = zwf.default_colors["white01"]
		startPoint = generator:LocalToWorld(Vector(0,-3,25))
	elseif generator:GetClass() == "zwf_outlet" then
		color = zwf.default_colors["white01"]
		startPoint = generator:GetPos()


	elseif generator:GetClass() == "zwf_watertank" then
		color = zwf.default_colors["water"]
		startPoint = generator:LocalToWorld(Vector(0, 34, 17))
	elseif generator:GetClass() == "zwf_pot_hydro" then
		color = zwf.default_colors["water"]
		startPoint = generator:LocalToWorld(Vector(-13, 0, 12.5))
	end

	if tr.Hit then

		if IsValid(tr.Entity) then


			if table.HasValue(EnergyEnts,generator:GetClass()) and table.HasValue(EnergyUser,tr.Entity:GetClass()) then
				// Generator is for Power

				endPoint = self:GetEndPos(generator,tr.Entity,tr)

			elseif table.HasValue(WaterEnts,generator:GetClass())  and table.HasValue(WaterUser,tr.Entity:GetClass()) then
				// Generator is for Water

				endPoint = self:GetEndPos(generator,tr.Entity,tr)

			else
				endPoint = tr.HitPos
			end

		else
			endPoint = tr.HitPos
		end

		cam.Start3D()
			render.DrawLine(startPoint, endPoint, color, false)
		cam.End3D()
	end
end

function SWEP:GetEndPos(generator,trEnt,tr)
	local endPoint

	if generator == trEnt then

		endPoint = tr.HitPos

	elseif table.HasValue(EnergyUser, trEnt:GetClass()) and not IsValid(tr.Entity:GetPowerSource()) then

		if trEnt:GetClass() == "zwf_lamp" then

			endPoint = trEnt:GetAttachment(1).Pos

		elseif trEnt:GetClass() == "zwf_ventilator" then

			endPoint = trEnt:LocalToWorld(Vector(0,-3,25))

		elseif trEnt:GetClass() == "zwf_outlet" then

			endPoint = trEnt:GetAttachment(4).Pos

		else
			endPoint = tr.HitPos
		end

	elseif table.HasValue(WaterUser, trEnt:GetClass()) and not IsValid(tr.Entity:GetWaterSource()) then

		if trEnt:GetClass() == "zwf_pot_hydro"  then

			endPoint = trEnt:LocalToWorld(Vector(13, 0, 12.5))
		else
			endPoint = tr.HitPos
		end

	else
		endPoint = tr.HitPos
	end

	return endPoint
end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + 1)
end
