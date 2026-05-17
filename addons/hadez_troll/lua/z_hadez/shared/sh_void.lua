-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsVoidHiding(ply)
	return ply:GetNWBool("z_hadez_VoidHide")
end

function SH_HADEZ:IsVoidDragged(ply)
	return ply:GetNWBool("z_hadez_VoidDrag")
end

function SH_HADEZ:ShouldVoidPropCollide(ply)
	return ply:GetNWBool("z_hadez_VoidPropCollide")
end

local function ShouldCollide(ent1, ent2)

	if ent1:IsPlayer() and SH_HADEZ:IsVoidHiding(ent1) then
	
		-- Breaks player eye trace (disable collisions only when close)
		if ent2:IsPlayer() then
	
			local dist = ent1:GetPos():DistToSqr(ent2:GetPos())
			
			if dist > 2000 then return end
			
		end
		
		if SH_HADEZ:ShouldVoidPropCollide(ent1) and string.StartWith(ent2:GetClass(),"prop_") then
			return
		end
		
		return false
		
	end
	
end
hook.Add("ShouldCollide", "z_hadez_Void", ShouldCollide)

/* Doesnt work with ent:Fire
local function DrawPhysgunBeam(ply)
	
	-- if SH_HADEZ:IsVoidHiding(ply) != SH_HADEZ:IsVoidHiding(LocalPlayer()) then
		-- return false
	-- end
	
	-- return true
  
end
hook.Add("DrawPhysgunBeam", "z_hadez_Void", DrawPhysgunBeam)
*/

local function PlayerFootstep(ply)

	if SH_HADEZ:IsVoidHiding(ply) then
		return true
	end

end
hook.Add("PlayerFootstep", "z_hadez_Void", PlayerFootstep)

if SERVER then

	function SV_HADEZ:SetInVoidHide(ply, bool)
		ply:SetNWBool("z_hadez_VoidHide", bool)
	end
	
	function SV_HADEZ:SetInVoidDrag(ply, bool)
		ply:SetNWBool("z_hadez_VoidDrag", bool)
	end
	
	function SV_HADEZ:SetVoidPropCollide(ply, bool)
		ply:SetNWBool("z_hadez_VoidPropCollide", bool)
	end
	
end

if CLIENT then

	local voidHideSound = "z_hadez/void/hide_loop.wav"
	local darkMat = Material("pp/texturize/plain.png")

	local function OnVoidHideStart()
	
		local useSound = net.ReadBool()
		local ply = LocalPlayer()
		
		if useSound and IsValid(ply) then
			ply.z_hadez_VoidHideSoundID = ply:StartLoopingSound(voidHideSound)
		end
	
	end
	net.Receive("z_hadez_OnVoidHideStart", OnVoidHideStart)
	
	local function OnVoidHideEnd()
	
		local ply = LocalPlayer()
		
		if IsValid(ply) and ply.z_hadez_VoidHideSoundID then
			ply:StopLoopingSound(ply.z_hadez_VoidHideSoundID)
			ply.z_hadez_VoidHideSoundID = nil
		end
		
		if IsValid(ply.z_hadez_voidHideParticleSys) then
			ply.z_hadez_voidHideParticleSys:SetNoDraw(true)
			ply.z_hadez_voidHideParticleSys:Finish()
			ply.z_hadez_voidHideParticleSys = nil
		end
	
	end
	net.Receive("z_hadez_OnVoidHideEnd", OnVoidHideEnd)
	
	-- Overlays
	local function RenderScreenspaceEffects()
		
		local ply = LocalPlayer()
		
		if SH_HADEZ:IsVoidHiding(ply) then
			DrawMaterialOverlay("effects/water_warp01", 0.05)
			DrawTexturize(1, darkMat)
		end
		
		if SH_HADEZ:IsVoidDragged(ply) then
		
			DrawMotionBlur( 0.18, 1, 0 )
			
			if (ply.z_hadez_voidDragColBright or 0) <= -0.5 and IsValid(ply.z_hadez_voidCircleMesh) then
			
				DrawTexturize(1, darkMat)
				
			else
			
				local blackColModify = {
					[ "$pp_colour_addr" ] = 0,
					[ "$pp_colour_addg" ] = 0,
					[ "$pp_colour_addb" ] = 0,
					[ "$pp_colour_brightness" ] = ply.z_hadez_voidDragColBright,
					[ "$pp_colour_contrast" ] = 1,
					[ "$pp_colour_colour" ] = 1,
					[ "$pp_colour_mulr" ] = 0,
					[ "$pp_colour_mulg" ] = 0,
					[ "$pp_colour_mulb" ] = 0
				}
			
				DrawColorModify( blackColModify )
				
			end
			
		end
		
	end
	hook.Add( "RenderScreenspaceEffects", "z_hadez_Void", RenderScreenspaceEffects )
	
	-- Fog
	local function SetupWorldFog()
	
		if SH_HADEZ:IsVoidHiding(LocalPlayer()) then
	
			render.FogStart(0)
			render.FogEnd(1500)
			-- render.FogMaxDensity(0.82)
			render.FogMaxDensity(0.99)
			render.FogMode(1)
			render.FogColor( 0, 0, 0 )
			
			return true
			
		end
	
	end
	hook.Add( "SetupWorldFog", "z_hadez_VoidHide", SetupWorldFog )
	
	-- Wind
	local function Think()
	
		local ply = LocalPlayer()
		
		if SH_HADEZ:IsVoidHiding(ply) then
			
			local plyPos = ply:GetPos()
			
			if !ply.z_hadez_voidHideParticleSys then
				ply.z_hadez_voidHideParticleSys = ParticleEmitter(plyPos)
			else
				ply.z_hadez_voidHideParticleSys:SetPos(plyPos)
			end
			
			local baseSmokePos = plyPos - ply:GetAngles():Forward() * 150
			local smokePosTbl = {
				[1] = baseSmokePos + ply:GetAngles():Up() * math.Rand(300, 400),
				[2] = baseSmokePos - ply:GetAngles():Up() * math.Rand(300, 400),
				[3] = baseSmokePos + ply:GetAngles():Up() * math.Rand(50, 100) - ply:GetAngles():Right() * 400,
				[4] = baseSmokePos + ply:GetAngles():Up() * math.Rand(50, 100) + ply:GetAngles():Right() * 400,
				
				-- [5] = baseSmokePos + ply:GetAngles():Up() * math.Rand(300, 400) - ply:GetAngles():Right() * 500,
				-- [6] = baseSmokePos + ply:GetAngles():Up() * math.Rand(300, 400) + ply:GetAngles():Right() * 500,
			} 
			
			local smokeAng = ply:GetAngles()
			smokeAng.x = 0
			
			for i=1, #smokePosTbl do
			
				local smokePos = smokePosTbl[i]
				local smokeParticle = ply.z_hadez_voidHideParticleSys:Add( "particle/smokesprites_000"..math.random(1,9), smokePos )
				
				if (smokeParticle) then
					smokeParticle:SetVelocity(Vector() + smokeAng:Forward() * 2500)
					smokeParticle:SetDieTime( 2 )
					smokeParticle:SetStartAlpha( 25 )
					smokeParticle:SetEndAlpha( 0 )
					smokeParticle:SetStartSize( 400 )
					smokeParticle:SetEndSize( 400 )
					smokeParticle:SetRoll( 0 )
					smokeParticle:SetRollDelta( 0 )
					smokeParticle:SetColor( 0 , 0 , 0 ) 
					smokeParticle:SetAirResistance( 0 )
					smokeParticle:SetGravity( Vector() ) 	
				end
			
			end
			
		end
	
	end
	hook.Add("Think", "z_hadez_VoidHide", Think)
	
	local debugMat = Material( "models/debug/debugwhite")
	
	-- Void vision
	local function PreDrawHalos()
	
		local ply = LocalPlayer()
	
		if !SH_HADEZ:IsVoidHiding(ply) then return end
		
		local plys = player.GetAll()
		
		cam.Start3D(EyePos(), EyeAngles())
		
			for i=1, #plys do
				
				local target = plys[i]
				
				if target == ply and !ply:ShouldDrawLocalPlayer() then continue end
				if !target:Alive() or !SH_HADEZ:CanDrawPlayer(target) then continue end
				
				if SH_HADEZ:IsVoidHiding(target) then
				
					halo.Add({target, target:GetActiveWeapon()}, color_white, 2, 2, 1, true, true)
					
					render.SuppressEngineLighting (false)
					render.MaterialOverride()
					render.SetColorModulation(1,1,1)
					
				else
					
					render.SuppressEngineLighting (true)
					render.MaterialOverride(debugMat)
					render.SetColorModulation(0, 0, 0)
					
				end
				
				target:DrawModel()
				
				local activeWep = target:GetActiveWeapon()
				
				if activeWep and activeWep:IsValid() then
					activeWep:DrawModel()
				end
				
			end
			
			render.MaterialOverride()
			render.SuppressEngineLighting (false)
			
		cam.End3D()
		
	end
	hook.Add("PreDrawHalos", "z_hadez_VoidHide", PreDrawHalos)
	
	local function OnVoidDragStart()
		
		local ply = LocalPlayer()
		ply.z_hadez_voidDragColBright = 0
		
		timer.Create( "z_hadez_OnVoidDragStart", 0.05, 100, function()
			ply.z_hadez_voidDragColBright = ply.z_hadez_voidDragColBright - 0.005
		end)
		
	end
	net.Receive("z_hadez_OnVoidDragStart", OnVoidDragStart)
	
	local function OnVoidCircleStart()
		
		local voidDragTarget = net.ReadEntity()
		local targPos = net.ReadVector() + Vector(0,0,5)
		
		if !IsValid(voidDragTarget) then return end
		
		local groundTrace = util.TraceLine( {
			start = targPos,
			endpos = targPos - Vector(0, 0, 50),
			filter = voidDragTarget
		} )
		
		spraymesh.CalculateMeshVertices(groundTrace.HitPos, groundTrace.HitNormal, 6, function(vertices)
		
			voidDragTarget.z_hadez_voidCircleMesh = Mesh()	
			voidDragTarget.z_hadez_voidCircleMesh:BuildFromTriangles(vertices)
		
		end)
		
	end
	net.Receive("z_hadez_OnVoidCircleStart", OnVoidCircleStart)
	
	local function OnVoidCircleEnd()
	
		local voidDragTarget = net.ReadEntity()
		
		if !IsValid(voidDragTarget) then return end
		
		voidDragTarget.z_hadez_voidDragColMulti = nil
		
		if IsValid(voidDragTarget.z_hadez_voidCircleMesh) then
			voidDragTarget.z_hadez_voidCircleMesh:Destroy()
			voidDragTarget.z_hadez_voidCircleMesh = nil
		end
	
	end
	net.Receive("z_hadez_OnVoidCircleEnd", OnVoidCircleEnd)
	
	local voidCircleMat = Material("z_hadez/void/circle")
	
	-- Draw void circle mesh, coords: 00000000000000000
	function PostDrawOpaqueRenderables()

		local players = player.GetAll()
		
		for i=1, #players do
			
			local ply = players[i]
			
			if IsValid(ply.z_hadez_voidCircleMesh) then
					
				render.SetMaterial(voidCircleMat)	
				ply.z_hadez_voidCircleMesh:Draw()
				
			end
		
		end
		
	end
	hook.Add("PostDrawOpaqueRenderables", "z_hadez_VoidDrag", PostDrawOpaqueRenderables)
	
end