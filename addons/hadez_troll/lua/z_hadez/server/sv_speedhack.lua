-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_SpeedHackPlayers")
local function SpeedHackPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "speedHack") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local speedHackOptions = {
		run = net.ReadBool(),
		walk = net.ReadBool(),
		jumpHigh = net.ReadBool(),
		jumpInfinite = net.ReadBool(),
		noFallDMG = net.ReadBool(),
		time = net.ReadBool()
	}
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		local enabled = !SH_HADEZ:HasSpeedHack(target)
		
		if enabled then
			target.z_hadez_SpeedHackOptions = speedHackOptions
			SV_HADEZ:StartSpeedHack(target, speedHackOptions)
		else
			SV_HADEZ:StopSpeedHack(target)
		end
		
		SV_HADEZ:OnPowerToggled(target, "speedHack", enabled)
		
	end
	
	SV_HADEZ:LogFeature("speedHackLog", "speedHack", ply, targets, function(ply)
		return SH_HADEZ:HasSpeedHack(ply)
	end)
	
end
net.Receive("z_hadez_SpeedHackPlayers", SpeedHackPlayers)

function SV_HADEZ:StartSpeedHack(ply, options)

	SV_HADEZ:SetSpeedHack(ply, true)
	
	if !ply.z_hadez_SpeedHackDefault then
		ply.z_hadez_SpeedHackDefault = {
			run = ply:GetRunSpeed(),
			walk = ply:GetWalkSpeed(),
			jump = ply:GetJumpPower()
		}
	end

	if options.run then
		ply:SetRunSpeed(ply.z_hadez_SpeedHackDefault.run * 25)
	end
	
	if options.walk then
		ply:SetWalkSpeed(ply.z_hadez_SpeedHackDefault.walk * 15)
	end
	
	if options.jumpHigh then
		ply:SetJumpPower(ply.z_hadez_SpeedHackDefault.jump * 5)
	end
	
	if options.time then
		ply:SetLaggedMovementValue(5)
	end

end

function SV_HADEZ:StopSpeedHack(ply)

	local options = ply.z_hadez_SpeedHackOptions

	SV_HADEZ:SetSpeedHack(ply, false)
	
	if options.run then
		ply:SetRunSpeed(ply.z_hadez_SpeedHackDefault.run)
	end
	
	if options.walk then
		ply:SetWalkSpeed(ply.z_hadez_SpeedHackDefault.walk)
	end
	
	if options.jumpHigh then
		ply:SetJumpPower(ply.z_hadez_SpeedHackDefault.jump)
	end
	
	if options.time then
		ply:SetLaggedMovementValue(1)
	end

end

local function PlayerPostThink(ply)
	
	local curTime = CurTime()
	
	if (ply.nextCheck or 0) > curTime then return end
	ply.nextCheck = curTime + 1
	
	if !SH_HADEZ:HasSpeedHack(ply) or !ply.z_hadez_SpeedHackDefault then return end
	
	local options = ply.z_hadez_SpeedHackOptions
	local default = ply.z_hadez_SpeedHackDefault
	
	-- Enforce speedhack if speed ever resets
	if options.run and ply:GetRunSpeed() == default.run then
		SV_HADEZ:StartSpeedHack(ply, options)
		return
	end
	
	if options.walk and ply:GetWalkSpeed() == default.walk then
		SV_HADEZ:StartSpeedHack(ply, options)
		return
	end
	
	if options.jumpHigh and ply:GetJumpPower() == default.jump then
		SV_HADEZ:StartSpeedHack(ply, options)
		return
	end
	
	if options.time and ply:GetLaggedMovementValue() == 1 then
		SV_HADEZ:StartSpeedHack(ply, options)
	end

end
hook.Add("PlayerPostThink", "z_hadez_SpeedHack", PlayerPostThink)

local function GetFallDamage(ply, speed)

	if SH_HADEZ:HasSpeedHack(ply) and ply.z_hadez_SpeedHackOptions and ply.z_hadez_SpeedHackOptions.noFallDMG then
		return 0
	end
	
end
SH_HADEZ:PrioritizedAddHook("GetFallDamage", "z_hadez_SpeedHack", GetFallDamage)