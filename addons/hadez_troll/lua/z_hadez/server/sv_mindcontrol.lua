-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_SetMindControlState")
local function SetMindControlState(len, ply)

	if !SH_HADEZ:HasAccess(ply, "mindControl") then return end

	local target = net.ReadEntity()
	local state = net.ReadBool()
	
	local controlOptions = {
		invisible = net.ReadBool(),
		physgun = net.ReadBool(),
		stealChat = net.ReadBool()
	}

	-- Target disconnected
	if state and !IsValid(target) then return end
	
	SV_HADEZ:SetInMindControl(ply, target, state, controlOptions)
	
	SV_HADEZ:LogFeature("mindControlLog", "mindControl", ply, target, function(ply)
		return SH_HADEZ:IsMindControlled(ply)
	end)

end
net.Receive("z_hadez_SetMindControlState",SetMindControlState)

local movementHistory = {}

local function StartCommand(ply, cmd)

	-- Notify on stop
	if SV_HADEZ:ShouldBeMindController(ply) and !SH_HADEZ:IsMindController(ply) then
		SV_HADEZ:PostMindControlStop(ply)
	end
	
	-- Start recording movement
	if SH_HADEZ:IsMindController(ply) then
	
		if !movementHistory[ply] then
			movementHistory[ply] = {}
		end
		
		local controllerCmd = {
			btns = cmd:GetButtons(),
			moveForward = cmd:GetForwardMove(),
			moveSide = cmd:GetSideMove(),
			moveUp = cmd:GetUpMove(),
			viewAngles = cmd:GetViewAngles()
		}
		
		table.insert(movementHistory[ply],controllerCmd)
		
		if #movementHistory[ply] >= 10 then
			table.remove(movementHistory[ply],10)
		end
		
		cmd:ClearMovement()
		cmd:ClearButtons()
		
	end
	
	-- Start using recorded movement
	if SH_HADEZ:IsMindControlled(ply) then
		
		local mindController = SH_HADEZ:GetMindController(ply)
		
		-- Controller disconnected
		if !IsValid(mindController) then return end
		
		cmd:ClearMovement()
		cmd:ClearButtons()
		
		if movementHistory[mindController] and #movementHistory[mindController] > 0 then
			
			local controllerCmd = movementHistory[mindController][1]
			
			cmd:SetButtons( controllerCmd.btns )
			cmd:SetForwardMove( controllerCmd.moveForward )
			cmd:SetSideMove( controllerCmd.moveSide )
			cmd:SetUpMove( controllerCmd.moveUp )
			cmd:SetViewAngles( controllerCmd.viewAngles )
			
			table.remove(movementHistory[mindController],1)
			
		end
			
	end
	
end
hook.Add("StartCommand", "z_hadez_MindControl", StartCommand)

local function SetupPlayerVisibility(ply, viewEnt)

	if SH_HADEZ:IsMindController(ply) then
	
		local target = SH_HADEZ:GetMindControlTarget(ply)
		
		if IsValid(target) then
			AddOriginToPVS(target:GetPos()) -- Controller can render target
		end
		
	end

	if SH_HADEZ:IsMindControlled(ply) then
	
		local mindController = SH_HADEZ:GetMindController(ply)
		
		if IsValid(mindController) then
			AddOriginToPVS(mindController:GetPos()) -- Target can get controller angles
		end
		
	end

end
hook.Add("SetupPlayerVisibility", "z_hadez_MindControl", SetupPlayerVisibility)

-- Block suicide when controlled
local function CanPlayerSuicide(ply)

	if SH_HADEZ:IsMindControlled(ply) then
		return false
	end
	
end
hook.Add("CanPlayerSuicide", "z_hadez_MindControl", CanPlayerSuicide)