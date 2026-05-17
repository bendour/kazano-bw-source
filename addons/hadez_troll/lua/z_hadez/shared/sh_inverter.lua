-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsInverted(ply)
	return ply:GetNWBool("z_hadez_Inverter")
end

function SH_HADEZ:GetInverterOption(ply, option)
	return ply:GetNWBool("z_hadez_Inverter_"..option)
end

if SERVER then

	function SV_HADEZ:SetInverted(ply, bool)
		ply:SetNWBool("z_hadez_Inverter", bool)
	end
	
	function SV_HADEZ:SetInvertedOptions(ply, options)
	
		for name, value in pairs(options) do
			ply:SetNWBool("z_hadez_Inverter_"..name, value)
		end
		
	end
	
	util.AddNetworkString("z_hadez_SetInvertion")
	local function SetInvertion(len, ply)

		if !SH_HADEZ:HasAccess(ply, "inverter") then return end

		local targets = SH_HADEZ:NetReadPlayers()
		local inverterOptions = {
			move = net.ReadBool(),
			aim = net.ReadBool(),
			jump = net.ReadBool(),
			shoot = net.ReadBool(),
			screen = net.ReadBool()
		}
		
		for i=1, #targets do
		
			local target = targets[i]
			
			if !IsValid(target) then continue end
			
			local enabled = !SH_HADEZ:IsInverted(target)
			
			if enabled then
				SV_HADEZ:SetInvertedOptions(target, inverterOptions)
				SV_HADEZ:SetInverted(target, true)
			else
				SV_HADEZ:SetInverted(target, false)
			end
			
			SV_HADEZ:OnPowerToggled(target, "inverter", enabled)
			
		end
		
		SV_HADEZ:LogFeature("inverterLog", "inverter", ply, targets, function(ply)
			return SH_HADEZ:IsInverted(ply)
		end)

	end
	net.Receive("z_hadez_SetInvertion",SetInvertion)
	
end

if CLIENT then

	local function HasKey(bitflag, key)
		return bit.band(bitflag, key) == key
	end
	
	local function ReplaceKey(bitflag, oldKey, newKey)
	
		-- Remove old key
		btnBitflag = bit.band(bitflag, bit.bnot(oldKey))
		
		-- Add inverted key
		btnBitflag = bit.bor(bitflag, newKey)
		
		return btnBitflag
	
	end

	local function CreateMove(cmd)
	
		local ply = LocalPlayer()
	
		if !SH_HADEZ:IsInverted(ply) then return end
		
		if SH_HADEZ:GetInverterOption(ply, "move") then
			cmd:SetForwardMove(-cmd:GetForwardMove())
			cmd:SetSideMove(-cmd:GetSideMove())
		end
		
		local btnBitflag = cmd:GetButtons()
		
		if SH_HADEZ:GetInverterOption(ply, "jump") then
			if HasKey(btnBitflag, IN_DUCK) then
				cmd:SetButtons(ReplaceKey(btnBitflag, IN_DUCK, IN_JUMP))
				
			elseif HasKey(btnBitflag, IN_JUMP) then
				cmd:SetButtons(ReplaceKey(btnBitflag, IN_JUMP, IN_DUCK))
				cmd:RemoveKey(IN_JUMP)
			end
		end
		
		if SH_HADEZ:GetInverterOption(ply, "shoot") then
			if HasKey(btnBitflag, IN_ATTACK) then
				cmd:SetButtons(ReplaceKey(btnBitflag, IN_ATTACK, IN_ATTACK2))
				cmd:RemoveKey(IN_ATTACK)
			elseif HasKey(btnBitflag, IN_ATTACK2) then
				cmd:SetButtons(ReplaceKey(btnBitflag, IN_ATTACK2, IN_ATTACK))
				cmd:RemoveKey(IN_ATTACK2)
			end
		end

	end
	hook.Add("CreateMove", "z_hadez_Inverter", CreateMove)
	
	local function InputMouseApply(cmd, x, y, ang)
	
		local ply = LocalPlayer()
	
		if !SH_HADEZ:IsInverted(ply) then 
			
			-- Inverted screen effects are permanent until respawn
			if ply.__hadScreenInverted then
				ang.roll = 0
				cmd:SetViewAngles(ang)
				ply.__hadScreenInverted = false
			end
			
			return 
		end
		
		local hasInvertedScreen = SH_HADEZ:GetInverterOption(ply, "screen")
		local hasInvertedAim = SH_HADEZ:GetInverterOption(ply, "aim")
		
		if hasInvertedAim or hasInvertedScreen then
		
			if hasInvertedScreen then
				ply.__hadScreenInverted = true
				ang.roll = 180
			end
			
			-- Inverted screen already inverts controls (should be automatically fixed)
			if (hasInvertedAim and !hasInvertedScreen) or (hasInvertedScreen and !hasInvertedAim) then
				ang.pitch = ang.pitch - (y/50)
				ang.yaw = ang.yaw + (x/50)
				cmd:SetViewAngles(ang)
				return true
			else
				cmd:SetViewAngles(ang)
			end
		
		end
		
		/*
		if SH_HADEZ:GetInverterOption(ply, "screen") then
		
			
			ang.pitch = ang.pitch - (y/50)
			ang.yaw = ang.yaw + (x/50)
			
			-- Invert screen
			ang.roll = 180
			cmd:SetViewAngles( ang )
			
			-- return true
		end
		
		if SH_HADEZ:GetInverterOption(ply, "aim") and !hasInvertedScreen then
		
			ang.pitch = ang.pitch - (y/50)
			ang.yaw = ang.yaw + (x/50)
			cmd:SetViewAngles( ang )
			
			return true
		end
		*/
	
	end
	hook.Add( "InputMouseApply", "z_hadez_Inverter", InputMouseApply)

end