AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Init()
	-- No energy system in this BaseWars version
end

function ENT:Think()
	self:ThinkFuncBypass()

	local rng = math.random(0, 10)
	if self:BadlyDamaged() and rng == 0 then
		self:Spark()
		return
	end

	self:ThinkFunc()
end

function ENT:ThinkFunc()
end

function ENT:ThinkFuncBypass()
end