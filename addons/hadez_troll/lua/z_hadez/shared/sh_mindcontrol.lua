-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsMindController(ply)
	return IsValid(ply:GetNWEntity("z_hadez_MindControlTarget"))
end

function SH_HADEZ:GetMindControlTarget(ply)
	return ply:GetNWEntity("z_hadez_MindControlTarget")
end

function SH_HADEZ:IsMindControlled(ply)
	return IsValid(ply:GetNWEntity("z_hadez_MindController"))
end

function SH_HADEZ:GetMindController(ply)
	return ply:GetNWEntity("z_hadez_MindController")
end

function SH_HADEZ:GetMindControlOption(ply, option)
	return ply:GetNWBool("z_hadez_MindControlOption_"..option)
end

if SERVER then

	function SV_HADEZ:ShouldBeMindController(ply)
		return ply.shouldBeMindController
	end
	
	function SV_HADEZ:OnMindControlStart(controller, target)
		
		controller.shouldBeMindController = true
			
		-- Take away weapons
		SV_HADEZ:HoldWeapons(controller, true)
			
		-- Make controller invisible
		if SH_HADEZ:GetMindControlOption(controller, "invisible") then
			
			controller.z_hadez_SetInvisible = true
			
			SV_HADEZ:CloakPlayer(controller, true)
			controller:GodEnable()
			controller:SetMoveType(MOVETYPE_NOCLIP)
			
		end
		
		-- Select physgun on target
		if SH_HADEZ:GetMindControlOption(controller, "physgun") then
		
			local hadWeapon = SV_HADEZ:ForceWeapon(target, "weapon_physgun")
			
			target.z_hadez_HadPhysgun = hadWeapon
			
			-- Force physgun on respawn (self-removing)
			local function PlayerSpawn(ply)
			
				if ply ~= target then return end
			
				-- No more controller
				if !SH_HADEZ:IsMindControlled(ply) then
					hook.Remove("z_hadez_MindControl_"..ply:UniqueID())
					return 
				end
				
				SV_HADEZ:ForceWeapon(ply, "weapon_physgun")
				
			end
			hook.Add("PlayerSpawn","z_hadez_MindControl_"..target:UniqueID(),PlayerSpawn)
			
		end
		
		-- Steal chat
		if SH_HADEZ:GetMindControlOption(controller, "stealChat") then 
			SV_HADEZ:StealChat(controller, target, true)
		end
	
	end
	
	function SV_HADEZ:OnMindControlStop(controller, target)
	
		-- Remove physgun after control
		if SH_HADEZ:GetMindControlOption(controller, "physgun") then
		
			if target:HasWeapon("weapon_physgun") and !target.z_hadez_HadPhysgun then
				target:StripWeapon("weapon_physgun")
			end
			
		end
		
		-- Make controller visible
		if controller.z_hadez_SetInvisible then
			
			SV_HADEZ:CloakPlayer(controller, false)
			controller:GodDisable()
			controller:SetMoveType(MOVETYPE_WALK)
		
		end
		
		-- Return chat
		if SH_HADEZ:GetMindControlOption(controller, "stealChat") then 
			SV_HADEZ:StealChat(controller, target, false)
		end
	
	end

	function SV_HADEZ:PostMindControlStop(controller)
		
		controller.shouldBeMindController = false
		
		-- Return weapons
		SV_HADEZ:HoldWeapons(controller, false)
		
		-- Make controller visible (failsafe)
		if controller.z_hadez_SetInvisible then
			
			SV_HADEZ:CloakPlayer(controller, false)
			controller:GodDisable()
			controller:SetMoveType(MOVETYPE_WALK)
		
		end
		
		-- Return chat to controller (failsafe)
		if SH_HADEZ:GetMindControlOption(controller, "stealChat") then 
			SV_HADEZ:StealChat(controller, NULL, false)
		end
		
		SV_HADEZ:OnPowerToggled(controller, "mindControl", false)
	
	end
	
	function SV_HADEZ:SetInMindControl(controller, target, state, controlOptions)

		if state then
			controller:SetNWEntity("z_hadez_MindControlTarget", target)
			target:SetNWEntity("z_hadez_MindController", controller)
			
			for option, value in pairs(controlOptions) do
				controller:SetNWBool("z_hadez_MindControlOption_"..option, value)
			end
			
			SV_HADEZ:OnPowerToggled(controller, "mindControl", true)
			SV_HADEZ:OnPowerToggled(target, "mindControl_target", true)
			
			SV_HADEZ:OnMindControlStart(controller, target)
			
		else
			
			local target = controller:GetNWEntity("z_hadez_MindControlTarget")
			
			if IsValid(target) then
				target:SetNWEntity("z_hadez_MindController", NULL)
			end
			
			controller:SetNWEntity("z_hadez_MindControlTarget", NULL)
			
			SV_HADEZ:OnMindControlStop(controller, target)
			
			SV_HADEZ:OnPowerToggled(controller, "mindControl", false)
			if IsValid(target) then
				SV_HADEZ:OnPowerToggled(target, "mindControl_target", false)
			end
			
		end
		
	end
	
end

-- Block controller from switching weapons
local function PlayerSwitchWeapon(ply, oldWep, newWep)

	if SH_HADEZ:IsMindController(ply) then 
		return true
	end
	
	if SH_HADEZ:IsMindControlled(ply) then
		
		local mindController = SH_HADEZ:GetMindController(ply)
		
		-- controller disconnected
		if !IsValid(mindController) then return end
		
		if SH_HADEZ:GetMindControlOption(mindController, "physgun") and newWep:GetClass() ~= "weapon_physgun" then
			return true
		end
		
	end

end
hook.Add("PlayerSwitchWeapon", "z_hadez_MindControl", PlayerSwitchWeapon)

if CLIENT then

	local function Think()
			
		local mindController = SH_HADEZ:GetMindController(LocalPlayer())
		
		if IsValid(mindController) then
			LocalPlayer():SetEyeAngles(mindController:EyeAngles())
		end
		
	end
	hook.Add("Think", "z_hadez_MindControl", Think)
	
	-- Thirdperson view
	local function CalcView(ply, pos, ang, fov)
	
		if !IsValid( ply ) then return end
		
		local mindControlTarget = SH_HADEZ:GetMindControlTarget(ply)
		
		-- Mind controller
		if IsValid(mindControlTarget) then
			ply = mindControlTarget
		else
			-- Mind control target
			if !SH_HADEZ:IsMindControlled(ply) then 
				return
			end
		end
		
		pos = ply:GetPos() + Vector(0,0,80)

		local trace = util.TraceHull( {
			start = pos,
			endpos = pos - ang:Forward() * 124,
			filter = { ply:GetActiveWeapon(), ply },
			mins = Vector( -4, -4, -4 ),
			maxs = Vector( 4, 4, 4 ),
		} )

		if ( trace.Hit ) then 
			pos = trace.HitPos 
		else 
			pos = pos - ang:Forward() * 100 
		end

		local view = {
			origin = pos,
			angles = ang,
			fov = fov,
			drawviewer = true
		}

		return view
	
	end	
	hook.Add( "CalcView", "z_hadez_MindControl", CalcView)

end
