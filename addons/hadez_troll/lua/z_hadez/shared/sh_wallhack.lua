-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasWallhack(ply)
	return ply:GetNWBool("z_hadez_Wallhack")
end

function SH_HADEZ:GetWallhackOption(ply, option)
	return ply:GetNWBool("z_hadez_WallhackOption_"..option)
end

if SERVER then

	util.AddNetworkString("z_hadez_WallhackToggle")
	local function WallhackToggle(len, ply)

		if !SH_HADEZ:HasAccess(ply, "wallhack") then return end
		
		local targets = SH_HADEZ:NetReadPlayers()
		local wallhackOptions = {
			chams = net.ReadBool(),
			wireframe = net.ReadBool(),
			hitboxes = net.ReadBool(),
			bones = net.ReadBool(),
			aimlines = net.ReadBool(),
			showWeapons = net.ReadBool(),
			name = net.ReadBool(),
			team = net.ReadBool(),
			health = net.ReadBool(),
			distance = net.ReadBool(),
			line = net.ReadBool(),
			weaponInfo = net.ReadBool()
		}
		
		for i=1, #targets do
		
			local target = targets[i]
			
			local enabled = !SH_HADEZ:HasWallhack(target)
			
			target.z_hadez_wallhackOptions = wallhackOptions
			
			SV_HADEZ:SetWallhack(target, enabled)
			SV_HADEZ:OnPowerToggled(target, "wallhack", enabled)
			
			if enabled then
				SV_HADEZ:SetWallhackOptions(target, wallhackOptions)
			end
		
		end
		
		SV_HADEZ:LogFeature("wallhackLog", "wallhack", ply, targets, function(ply)
			return SH_HADEZ:HasWallhack(ply)
		end)

	end
	net.Receive("z_hadez_WallhackToggle", WallhackToggle)

	function SV_HADEZ:SetWallhack(ply, bool)
		ply:SetNWBool("z_hadez_Wallhack", bool)
	end
	
	function SV_HADEZ:SetWallhackOptions(ply, options)
	
		for name, enabled in pairs(options) do
			ply:SetNWBool("z_hadez_WallhackOption_"..name, enabled)
		end
		
	end
	
end

if CLIENT then

	local debugMat = Material( "models/debug/debugwhite")
	local wireframeMat = Material( "models/wireframe" )
	local sphereMat = Material( "editor/wireframe" )
	local weaponCol = SH_HADEZ.VAR.COLOR.FUCHSIA
	local weaponChamsVector = Vector(weaponCol.r/1, weaponCol.g/1, weaponCol.b/1)
	local scrW, scrH = ScrW(), ScrH()

	local function Wallhack3DContext(ply, target)
	
		local teamCol = team.GetColor(target:Team())
		local canDrawTarget = SH_HADEZ:CanDrawPlayer(target)
	
		render.SuppressEngineLighting(true)
		
		-- Chams & wireframe
		if canDrawTarget then
			if SH_HADEZ:GetWallhackOption(ply, "chams") then
				render.MaterialOverride(debugMat)
				render.SetColorModulation(teamCol.r/1, teamCol.g/1, teamCol.b/1)
				target:DrawModel()
			elseif SH_HADEZ:GetWallhackOption(ply, "wireframe") then
				render.MaterialOverride(wireframeMat)
				render.SetColorModulation(teamCol.r/1, teamCol.g/1, teamCol.b/1)
				target:DrawModel()
			end
		end
		
		-- Hitboxes & bones
		local showHitboxes, showBones = SH_HADEZ:GetWallhackOption(ply, "hitboxes"), SH_HADEZ:GetWallhackOption(ply, "bones")
		
		if showHitboxes or showBones then 
		
			local numHitBoxGroups = target:GetHitBoxGroupCount()
			
			for hitboxGroup=0, numHitBoxGroups-1 do
			
				local numHitBoxes = target:GetHitBoxCount( hitboxGroup )
			 
				for hitbox=0, numHitBoxes do 

					local mins, maxs = target:GetHitBoxBounds( hitbox, hitboxGroup )
					local bone = target:GetHitBoxBone( hitbox, hitboxGroup )

					if bone == nil then continue end

					local bonePos,boneAng = target:GetBonePosition(bone)

					render.SetMaterial( sphereMat )
					
					if showHitboxes then
						render.DrawBox( bonePos, boneAng, mins, maxs, teamCol, false)
					end

					-- skip the head bone
					if showBones and bone ~= 6 then
						render.DrawBox( bonePos, boneAng, mins-Vector(0,mins.y-0.01,mins.z), maxs-Vector(0,maxs.y-0.02,maxs.z), color_white, false)
					end
				end
			end
		end
		
		-- Weapons
		if SH_HADEZ:GetWallhackOption(ply, "showWeapons") then
		
			local activeWep = target:GetActiveWeapon()
			
			if activeWep and activeWep:IsValid() then
			
				local weaponOverride
			
				if SH_HADEZ:GetWallhackOption(ply, "wireframe") then
					weaponOverride = wireframeMat
				else
					weaponOverride = debugMat
				end
				
				render.MaterialOverride(weaponOverride)
				render.SetColorModulation(weaponChamsVector.x, weaponChamsVector.y, weaponChamsVector.z)
				activeWep:DrawModel()
			
			end
			
		end
		
		-- Aimlines
		if SH_HADEZ:GetWallhackOption(ply, "aimlines") then 
			
			local eyeTrace = target:GetEyeTrace()
			local eyePos = eyeTrace.StartPos + target:GetAimVector()*8 + Vector(0,0,1)
			
			render.DrawLine(eyePos, eyeTrace.HitPos, teamCol, true)
			
		end
		
		render.MaterialOverride()
		render.SuppressEngineLighting(false)
	
	end
	
	local function DrawWallhackTxt(x, y, txt, col, font)
		draw.SimpleTextOutlined(txt, font, x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
	end
	
	local function Wallhack2DContext(ply, target)
	
		local targTeam = target:Team()
		local teamCol = team.GetColor(targTeam)
		local targPos = target:GetPos()
		local lowPos = targPos:ToScreen()
		local highPos = (targPos + Vector(0, 0, 75)):ToScreen()
		
		-- Health & armor
		if SH_HADEZ:GetWallhackOption(ply, "health") then
			
			local h = lowPos.y - highPos.y
			local w = h/2
			
			-- Health
			local health, maxHealth = target:Health(), target:GetMaxHealth()
			local healthBarBGH = h*0.84
			local healthBarH = math.min(healthBarBGH*(health/maxHealth), healthBarBGH)
			local greenCol = SH_HADEZ.VAR.COLOR.GREEN
			local missingHealth = maxHealth - health
			local healthBarColor = Color(greenCol.r+(missingHealth*3), greenCol.g-missingHealth, greenCol.b)
			
			surface.SetDrawColor(ColorAlpha(color_black,150))
			surface.DrawRect( lowPos.x-w/2, lowPos.y-healthBarBGH, 3, healthBarBGH )
			
			surface.SetDrawColor(healthBarColor)
			surface.DrawRect( lowPos.x-w/2, lowPos.y-healthBarH, 3, healthBarH )
			
			-- Armor
			local armor, maxArmor = target:Armor(), target:GetMaxArmor()
			
			if armor > 0 then
			
				local armorBarBGW = w*0.95
				local armorBarH = math.min(armorBarBGW*(armor/maxArmor), armorBarBGW)
				
				surface.SetDrawColor(ColorAlpha(color_black,150))
				surface.DrawRect(lowPos.x-w*0.45, lowPos.y, armorBarBGW, 3)
				
				surface.SetDrawColor(SH_HADEZ.VAR.COLOR.LIGHTBLUE)
				surface.DrawRect(lowPos.x-w*0.45, lowPos.y, armorBarH, 3)
				
			end
		
		end
		
		local showTeam = SH_HADEZ:GetWallhackOption(ply, "team")
		
		-- Name
		if SH_HADEZ:GetWallhackOption(ply, "name") then 
		
			DrawWallhackTxt(lowPos.x, !showTeam and highPos.y or highPos.y-scrH*0.0135, target:Nick(), color_white, "z_hadez_wallhackName")
		
		end
		
		-- Team
		if showTeam then
			
			local teamName =  team.GetName(targTeam)
			
			DrawWallhackTxt(lowPos.x, highPos.y, teamName, teamCol, "z_hadez_wallhackTeam")
			
		end
		
		-- Weapon info
		if SH_HADEZ:GetWallhackOption(ply, "weaponInfo") then 
		
			local activeWep = target:GetActiveWeapon()
			
			if activeWep and activeWep:IsValid() then
				DrawWallhackTxt(lowPos.x, lowPos.y+scrH*0.0135, string.upper(activeWep:GetPrintName() or "Invalid"), SH_HADEZ.VAR.COLOR.ORANGERED, "z_hadez_wallhackTeam")
			end
		
		end
		
		-- Distance
		if SH_HADEZ:GetWallhackOption(ply, "distance") then
		
			local dist = math.Round(ply:GetPos():Distance(targPos)/100).."m"
		
			DrawWallhackTxt(lowPos.x, lowPos.y+scrH*0.028, dist, SH_HADEZ.VAR.COLOR.YELLOW, "z_hadez_wallhackTeam")
			
		end
		
		-- Line to
		if SH_HADEZ:GetWallhackOption(ply, "line") then
			surface.SetDrawColor( teamCol )
			surface.DrawLine( scrW/2, scrH, lowPos.x, math.Clamp(lowPos.y,0,scrH) )
		end
	
	end

	local function HUDPaint()
	
		local ply = LocalPlayer()
	
		if !SH_HADEZ:HasWallhack(ply) then return end
		
		local plys = player.GetAll()
		
		cam.Start3D(EyePos(), EyeAngles())
		
			for i=1, #plys do
				
				local target = plys[i]

				if ply == target or !target:Alive() or SH_HADEZ:IsLSACBot(target) then continue end
		
				Wallhack3DContext(ply, target)
				
			end
			
		cam.End3D()
		
		for i=1, #plys do
			
			local target = plys[i]

			if ply == target or !target:Alive() or SH_HADEZ:IsLSACBot(target) then continue end
	
			Wallhack2DContext(ply, target)
			
		end
	
	end
	hook.Add("HUDPaint", "z_hadez_Wallhack", HUDPaint)

end