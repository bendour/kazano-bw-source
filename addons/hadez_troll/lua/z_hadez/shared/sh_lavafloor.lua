-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/*
	Big thanks to Bullseye who created the floor is lava gamemode! 
	Ref: https://steamcommunity.com/sharedfiles/filedetails/?id=1099454290
*/

function SH_HADEZ:IsLavaFloorActive()
	return GetGlobalBool("z_hadez_LavaFloor")
end

function SH_HADEZ:SetLavaFloor(bool)
	SetGlobalBool("z_hadez_LavaFloor", bool)
end

function SH_HADEZ:IsLavaFloorRecalling()
	return GetGlobalBool("z_hadez_LavaFloor_Recalling")
end

function SH_HADEZ:SetLavaFloorRecalling(bool)
	SetGlobalBool("z_hadez_LavaFloor_Recalling", bool)
end

function SH_HADEZ:GetLavaLevel()
	return GetGlobalFloat("z_hadez_LavaLevel", SH_HADEZ:GetLavaMinLevel())
end

function SH_HADEZ:GetLavaMinLevel()
	return game.GetWorld():GetModelRenderBounds().z
end

function SH_HADEZ:GetLavaMaxLevel()
	local _, maxBounds = game.GetWorld():GetModelRenderBounds()
	return maxBounds.z
end

function SH_HADEZ:SetLavaLevel(float)
	SetGlobalFloat("z_hadez_LavaLevel", float)
end

function SH_HADEZ:GetLavaFloorOption(option)
	return GetGlobalBool("z_hadez_LavaLevel_"..option)
end

function SH_HADEZ:GetLavaFloorSpectateTarget(ply)
	return ply:GetNWEntity("z_hadez_LavaFloor_Spectate")
end

function SH_HADEZ:SetLavaFloorSpectateTarget(ply, target)
	ply:SetNWEntity("z_hadez_LavaFloor_Spectate", target)
end

function SH_HADEZ:GetLavaStartOffset()
	-- Gives 15 seconds before it reaches the lowest player pos
	return 15*tonumber(SH_HADEZ:GetLavaFloorOption("speed"))
end

if SERVER then

	function SV_HADEZ:SetLavaFloorOptions(options)
	
		for name, value in pairs(options) do
			SetGlobalBool("z_hadez_LavaLevel_"..name, value)
		end
		
	end

	local spectateI = 1

	function SV_HADEZ:GetLavaFloorSpectateTarget()
		
		local plys = player.GetAll()
		
		for i=1, #plys do
			
			local randomI = ((spectateI+i) % #plys) + 1
			local ply = plys[randomI]
			
			if !ply.__killedByLava then
				spectateI = spectateI + 1
				return ply
			end
		
		end
		
	end

end

local function InitPostEntity()

	if SERVER then
		local skyCam = ents.FindByClass("sky_camera")[1]

		if skyCam then
			SetGlobalVector("z_hadez_LavaCamPos", skyCam:GetPos())
		end
	end
	
	if CLIENT then
		
		local min, max = Entity(0):GetModelRenderBounds()
		min.z, min.z = 0, 0
		CL_HADEZ.lavaFloor.mapScale = min:Distance(max) * 2
		
		CL_HADEZ.lavaFloor.clipTbl = {
			[1] = {Vector(1, 0, 0), -math.abs(min.x)},
			[2] = {Vector(-1, 0, 0), -math.abs(max.x)},
			[3] = {Vector(0, 1, 0), -math.abs(min.y)},
			[4] = {Vector(0, -1, 0), -math.abs(max.y)}
		}
	
	end

end
hook.Add("InitPostEntity", "z_hadez_LavaFloor", InitPostEntity)

if CLIENT then

	CL_HADEZ.lavaFloor = CL_HADEZ.lavaFloor or {}
	local lerpLavaChange = 0
	local lavaScale = 100
	local lavaSoundPath = "z_hadez/lavafloor/lava.mp3"
	
	local function SetupSkyboxFog(scale)
		CL_HADEZ.lavaFloor.skyboxScale = 1/scale
		hook.Remove("SetupSkyboxFog", "z_hadez_LavaFloor")
	end
	hook.Add("SetupSkyboxFog", "z_hadez_LavaFloor" ,SetupSkyboxFog)

	local function TextureClip(clipTbl, renderPlaneFunc)
	
		if !system.IsWindows() then
			return renderPlaneFunc()
		end
		
		render.EnableClipping(true)
			for i=1, #clipTbl do
				render.PushCustomClipPlane( clipTbl[i][1], clipTbl[i][2])
			end
			renderPlaneFunc()
			for i=1, #clipTbl do
				render.PopCustomClipPlane()
			end
		render.EnableClipping(false)
	
	end
	
	local lavaTexID = surface.GetTextureID( "z_hadez/lavafloor/lava.vmt" )
	
	-- Drawing lava
	local function PostDrawTranslucentRenderables(shoulDrawDepth, shouldDrawSkybox)
	
		if !SH_HADEZ:IsLavaFloorActive() then return end
	
		if !CL_HADEZ.lavaFloor.mapScale or !CL_HADEZ.lavaFloor.clipTbl then return end
			
		local isRecalling = SH_HADEZ:IsLavaFloorRecalling()
		local lavaLevel = SH_HADEZ:GetLavaLevel()
		-- local lavaSpeed = !isRecalling and SH_HADEZ:GetLavaFloorOption("speed") or 55
		local lavaSpeed = !isRecalling and SH_HADEZ:GetLavaFloorOption("realSpeed") or 55
		
		if math.abs(lerpLavaChange-lavaLevel) > (lavaSpeed+1) then
			lerpLavaChange = lavaLevel
		else
			lerpLavaChange = math.Approach( lerpLavaChange, lavaLevel, RealFrameTime() * lavaSpeed )
		end
	
		local mapScale = CL_HADEZ.lavaFloor.mapScale
		local lavaLevelVector = Vector(0,0,lerpLavaChange)
		local camAng = Angle(0, 0, 0)
		
		TextureClip(CL_HADEZ.lavaFloor.clipTbl, function()
			local x = 200 + math.abs((math.sin(CurTime()) * 35))
			surface.SetDrawColor(x, x, x)
			surface.SetTexture(lavaTexID)

			if !shouldDrawSkybox then
				
				-- Draw texture when player under lava
				if EyePos().z <= lavaLevelVector.z then
				
					cam.Start3D2D(lavaLevelVector, camAng + Angle( 180, 0, 0 ), 1)					
						surface.DrawTexturedRectUV(-mapScale / 2, -mapScale / 2, mapScale, mapScale, lavaScale, lavaScale, mapScale / 5000, mapScale / 5000)
					cam.End3D2D()
				
				else
				
					cam.Start3D2D(lavaLevelVector, camAng, 1)
						surface.DrawTexturedRectUV(-mapScale / 2, -mapScale / 2, mapScale, mapScale, lavaScale, lavaScale, mapScale / 5000, mapScale / 5000)
					cam.End3D2D()				
					
				end
			end
			
		end)

		-- Draw texture in skybox
		if shouldDrawSkybox and CL_HADEZ.lavaFloor.skyboxScale then
			
			local skyboxScale = CL_HADEZ.lavaFloor.skyboxScale
			
			cam.Start3D2D(GetGlobalVector("z_hadez_LavaCamPos") + (lavaLevelVector / skyboxScale), camAng, 1)
				surface.DrawTexturedRectUV(-mapScale / 2, -mapScale / 2, mapScale, mapScale, lavaScale*skyboxScale, lavaScale*skyboxScale, mapScale / 5000 * skyboxScale, mapScale / 5000 * skyboxScale)
			cam.End3D2D()
			
		end
	
	end
	hook.Add("PostDrawTranslucentRenderables", "z_hadez_LavaFloor", PostDrawTranslucentRenderables)
	
	-- Overlays
	local doomsdayEffect = {
		[ "$pp_colour_addr" ] 		= 0.05,
		[ "$pp_colour_addg" ] 		= 0,
		[ "$pp_colour_addb" ] 		= 0,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] 	= 0.1,
		[ "$pp_colour_colour" ] 	= 0,
		[ "$pp_colour_mulr" ] 		= 10,
		[ "$pp_colour_mulg" ] 		= 0,
		[ "$pp_colour_mulb" ] 		= 10
	}
	
	local lavaColorEffect = {
		[ "$pp_colour_addr" ] 		= 0,
		[ "$pp_colour_addg" ] 		= 0,
		[ "$pp_colour_addb" ] 		= 0,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] 	= 0.1,
		[ "$pp_colour_colour" ] 	= 0,
		[ "$pp_colour_mulr" ] 		= 100,
		[ "$pp_colour_mulg" ] 		= 0,
		[ "$pp_colour_mulb" ] 		= 0
	}
	
	local function RenderScreenspaceEffects()
		
		if !SH_HADEZ:IsLavaFloorActive() then return end
		
		if SH_HADEZ:GetLavaFloorOption("doomsDay") then
			DrawColorModify(doomsdayEffect)
		end
		
		if EyePos().z <= SH_HADEZ:GetLavaLevel() then
			DrawMaterialOverlay("effects/water_warp01", 0.5)
			DrawColorModify(lavaColorEffect)
		end
		
	end
	hook.Add( "RenderScreenspaceEffects", "z_hadez_LavaFloor", RenderScreenspaceEffects )
	
	-- Thirdperson view
	local function CalcView(ply, pos, ang, fov)
		
		if !SH_HADEZ:IsLavaFloorActive() or !IsValid( ply ) then return end
		
		local spectateTarget = SH_HADEZ:GetLavaFloorSpectateTarget(ply)
		
		if !IsValid(spectateTarget) then return end
		-- if IsValid(spectateTarget) then return end
		
		pos = spectateTarget:GetPos() + Vector(0,0,80)

		local trace = util.TraceHull( {
			start = pos,
			endpos = pos - ang:Forward() * 124,
			filter = { spectateTarget:GetActiveWeapon(), spectateTarget },
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
	hook.Add("CalcView", "z_hadez_LavaFloor", CalcView)
	
	-- Lava sound
	local function PlayLavaSound()
		
		CL_HADEZ.lavaFloor.lavaSound = CreateSound(game.GetWorld(), lavaSoundPath, filter)
		CL_HADEZ.lavaFloor.lavaSound:SetSoundLevel(0)
		CL_HADEZ.lavaFloor.lavaSound:Play()
		
	end
	net.Receive("z_hadez_PlayLavaSound", PlayLavaSound)
	
	local function StopLavaSound()
		
		if CL_HADEZ.lavaFloor.lavaSound and CL_HADEZ.lavaFloor.lavaSound.FadeOut ~= nil then
			if CL_HADEZ.lavaFloor.lavaSound:IsPlaying() then
				CL_HADEZ.lavaFloor.lavaSound:FadeOut(1)
			end
		end
		
	end
	net.Receive("z_hadez_StopLavaSound", StopLavaSound)
	
	local function Think()
		
		if !SH_HADEZ:IsLavaFloorActive() then return end
		
		if CL_HADEZ.lavaFloor.lavaSound and CL_HADEZ.lavaFloor.lavaSound.ChangeVolume ~= nil then
			
			local plyPos = LocalPlayer():GetPos()
			local zDiff = math.abs(plyPos.z - SH_HADEZ:GetLavaLevel())
			local newVolume = 1 - math.Clamp(zDiff/1000, 0, 1)
			
			CL_HADEZ.lavaFloor.lavaSound:ChangeVolume(newVolume, 0.1)
			
		end
	
	end
	hook.Add("Think", "z_hadez_LavaFloor", Think)

end