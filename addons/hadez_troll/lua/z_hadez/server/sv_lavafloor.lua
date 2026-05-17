-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

SV_HADEZ.lavaFloor = SV_HADEZ.lavaFloor or {}
local eruptionSoundPath = "z_hadez/lavafloor/volcano_eruption.mp3"
local earthquakeDelays = {0, 9, 25, 55}
local lavaIsSpeedingUp, lavaSpeedOverwrite = false, -1

util.AddNetworkString("z_hadez_LavaFloor")
util.AddNetworkString("z_hadez_PlayLavaSound")
util.AddNetworkString("z_hadez_StopLavaSound")
local function LavaFloor(len, ply)

	if !SH_HADEZ:HasAccess(ply, "lavaFloor") then return end
	
	local lavaFloorOptions = {
		startLevel = net.ReadBool(),
		speedUp = net.ReadBool(),
		spectate = net.ReadBool(),
		igniteProps = net.ReadBool(),
		doomsday = net.ReadBool(),
		earthquake = net.ReadBool(),
		sound = net.ReadBool(),
		speed = net.ReadString()
	}
	
	lavaFloorOptions.speed = string.Split(lavaFloorOptions.speed, 'x')[2]
	
	if SH_HADEZ:IsLavaFloorActive() then
		SV_HADEZ:OnLavaFloorRecall(lavaFloorOptions)
	else
		SV_HADEZ:SetLavaFloorOptions(lavaFloorOptions)
		SV_HADEZ:OnLavaFloorRise(lavaFloorOptions)
	end
	
	SV_HADEZ:LogFeature("lavaFloorLog", "lavaFloor", ply, ply, function(ply)
	
		if !SH_HADEZ:IsLavaFloorRecalling() and !SH_HADEZ:IsLavaFloorActive() then
			return nil
		end
	
		return !SH_HADEZ:IsLavaFloorRecalling()
	end)

end
net.Receive("z_hadez_LavaFloor",LavaFloor)

function SV_HADEZ:OnLavaFloorRise(lavaFloorOptions)

	SH_HADEZ:IsLavaFloorRecalling(false)
	SH_HADEZ:SetLavaFloor(true)
	
	
	-- Set Starting level
	if lavaFloorOptions.startLevel then
		
		local lowestPly, lowestZ = SH_HADEZ:GetLowestPlayer()
		SH_HADEZ:SetLavaLevel(lowestZ-SH_HADEZ:GetLavaStartOffset())
		
	else
		SH_HADEZ:SetLavaLevel(SH_HADEZ:GetLavaMinLevel())
	end
	
	-- Earthquake
	if lavaFloorOptions.earthquake then
	
		local radius = math.Max(game.GetWorld():GetModelRenderBounds().x, game.GetWorld():GetModelRenderBounds().y)
		
		for i=1, #earthquakeDelays do
			local delay = earthquakeDelays[i]
			timer.Create("z_hadez_LavaFloorEarthquakeTimer"..i, delay, 1, function()
				util.ScreenShake(Vector(0,0,0), 10, 10, 10, radius)
			end)
		end	
		
	end
	
	-- Play sound
	if lavaFloorOptions.sound then
			
		local filter = RecipientFilter()
		filter:AddAllPlayers()

		SV_HADEZ.lavaFloor.eruptionSound = CreateSound(game.GetWorld(), eruptionSoundPath, filter)
		SV_HADEZ.lavaFloor.eruptionSound:SetSoundLevel(0)
		SV_HADEZ.lavaFloor.eruptionSound:Play()
		
		net.Start("z_hadez_PlayLavaSound")
		net.Broadcast()
		
	end
	
end

function SV_HADEZ:OnLavaFloorRecall()

	-- On double press instant reset
	if SH_HADEZ:IsLavaFloorRecalling() then
		SV_HADEZ:OnLavaFloorStop()
		return
	end

	SH_HADEZ:SetLavaFloorRecalling(true)
	
end

function SV_HADEZ:OnLavaFloorStop()

	SH_HADEZ:SetLavaFloor(false)
	SH_HADEZ:SetLavaFloorRecalling(false)
	SH_HADEZ:SetLavaLevel(SH_HADEZ:GetLavaMinLevel())

	-- Restore player movement
	local plyTbl = player.GetAll()
	for i=1, #plyTbl do
		
		local ply = plyTbl[i]
		ply:SetLaggedMovementValue(1)
		ply:SetGravity(1)
		ply.__killedByLava = false
		SH_HADEZ:SetLavaFloorSpectateTarget(ply, NULL)
		ply:GodDisable()
		SV_HADEZ:CloakPlayer(ply, false)
		
	end
	
	-- Stop earthquakes
	if SH_HADEZ:GetLavaFloorOption("earthquake") then
	
		for i=1, #earthquakeDelays do
			timer.Stop("z_hadez_LavaFloorEarthquakeTimer"..i)
		end
		
	end
	
	-- Stop sound
	if SV_HADEZ.lavaFloor.eruptionSound and SV_HADEZ.lavaFloor.eruptionSound.FadeOut ~= nil then
	
		if SV_HADEZ.lavaFloor.eruptionSound:IsPlaying() then
			SV_HADEZ.lavaFloor.eruptionSound:FadeOut(1)
		end
		
		net.Start("z_hadez_StopLavaSound")
		net.Broadcast()
		
	end
	
	-- Stop speedup
	if SH_HADEZ:GetLavaFloorOption("speedUp") then
		lavaIsSpeedingUp = false
		lavaSpeedOverwrite = -1
		timer.Stop("z_hadez_SpeedUpTimer")
	end
	
end

local function FindLowestPlayerNotKilledByLava()
	
	local toCheckPlayers = table.Copy(player.GetAll())
	
	table.sort(toCheckPlayers, function(ply1, ply2)
	
		if ply1.__killedByLava == ply2.__killedByLava then
			local ply1Pos = ply1:GetPos()
			local ply2Pos = ply2:GetPos()
			
			return ply1Pos.z < ply2Pos.z
		else
			return ply2.__killedByLava and not ply1.__killedByLava
		end
	
		return a[2] > b[2] 
	end)
	
	local lowestPlayer = toCheckPlayers[1]
	
	-- All players have been killed by lava
	if lowestPlayer.__killedByLava then return end
	
	return lowestPlayer
	
end

local nextThink = 0
local function Think()

	if !SH_HADEZ:IsLavaFloorActive() then return end
	
	local lavaSpeed = SH_HADEZ:GetLavaFloorOption("speed")
	
	if SH_HADEZ:IsLavaFloorRecalling() then
		
		SH_HADEZ:SetLavaLevel(SH_HADEZ:GetLavaLevel()-5)
		
		if SH_HADEZ:GetLavaLevel() <= SH_HADEZ:GetLavaMinLevel() then
			SV_HADEZ:OnLavaFloorStop()
			return
		end
	
	elseif nextThink < CurTime() then
	
		-- Speedup lava when no players closeby (cause waiting sucks)
		if SH_HADEZ:GetLavaFloorOption("speedUp") and !lavaIsSpeedingUp then
			
			-- Find closest player
			local lowestAlivePly = FindLowestPlayerNotKilledByLava()
			
			if IsValid(lowestAlivePly) then 
				
				local zPos = lowestAlivePly:GetPos().z
				
				-- If it takes more then 1 minute to reach the lowest alive player
				if zPos-(lavaSpeed*60) > SH_HADEZ:GetLavaLevel() then
					
					-- Catch up in 30 seconds and give 10 seconds after that for the target to move
					local zDiff = (zPos-(lavaSpeed*10))-SH_HADEZ:GetLavaLevel()
					lavaIsSpeedingUp = true
					lavaSpeedOverwrite = zDiff/30
					
					timer.Create("z_hadez_SpeedUpTimer", 40, 1, function()
						lavaSpeedOverwrite = -1
						lavaIsSpeedingUp = false
					end)
				end
			end
		end
		
		local realLavaSpeed = lavaSpeedOverwrite > 0 and lavaSpeedOverwrite or lavaSpeed
		
		SV_HADEZ:SetLavaFloorOptions({["realSpeed"] = realLavaSpeed})
		SH_HADEZ:SetLavaLevel(SH_HADEZ:GetLavaLevel()+realLavaSpeed)
		
		nextThink = CurTime() + 1
		
	end
	
	local entTbl = ents.GetAll()
	
	for i=1, #entTbl do
	
		local ent = entTbl[i]
		
		if ent:GetPos().z > SH_HADEZ:GetLavaLevel() then continue end
		if ent:IsPlayer() or ent:IsWorld() or ent:IsWeapon() or SH_HADEZ.SETTINGS.WHITELISTEDBURNENTITIES[ent:GetClass()] then continue end
		if !ent:IsNPC() and !ent:IsNextBot() and !SH_HADEZ:GetLavaFloorOption("igniteProps") then continue end

		ent:Ignite(5)
		ent.__nextEntityDamage = ent.__nextEntityDamage or 0
	
		if ent.__nextEntityDamage < CurTime() then
	
			if ent:Health() > 0 then
			
				local dmgInfo = DamageInfo()
				dmgInfo:SetDamage( math.Max(10,ent:GetMaxHealth()/5) )
				dmgInfo:SetAttacker( game.GetWorld() )
				dmgInfo:SetDamageType( DMG_BURN ) 
				
				ent:TakeDamageInfo(dmgInfo)
				
				ent.__nextEntityDamage = CurTime() + 1
				
			end
		end
	end
		
end
hook.Add("Think", "z_hadez_LavaFloor", Think)

local function PlayerPostThink(ply)

	if !SH_HADEZ:IsLavaFloorActive() then return end
	
	local curTime = CurTime()
	
	-- Make sure player is spectating valid player + switch every 10 seconds
	if ply.__killedByLava and SH_HADEZ:GetLavaFloorOption("spectate") then
	
		local spectateTarget = SH_HADEZ:GetLavaFloorSpectateTarget(ply)
	
		if !IsValid(spectateTarget) or !spectateTarget:Alive() or spectateTarget.__killedByLava or ((ply.__nextLavaFloorSpectate or 0) < curTime) then
			local spectateTarget = SV_HADEZ:GetLavaFloorSpectateTarget()
			
			-- If all players are dead, end the game!
			if !IsValid(spectateTarget) then
				SV_HADEZ:OnLavaFloorStop()
			end
			
			SH_HADEZ:SetLavaFloorSpectateTarget(ply, spectateTarget)
			
			ply.__nextLavaFloorSpectate = curTime + 10
		end
		
	end
	
	if ply.__killedByLava then return end
	
	local plyInLava = ply:GetPos().z <= SH_HADEZ:GetLavaLevel()
	
	if plyInLava then
	
		ply:Ignite(1)
		
		if (ply.__nextDamageApply or 0) < curTime then
			
			local damage = math.Min(ply:Health()-1, 20)
			
			if damage >= ply:Health() - 20 then
				ply.__killedByLava = true
				ply:Spawn()
			end
			
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage(damage)
			dmgInfo:SetAttacker( game.GetWorld() )
			dmgInfo:SetDamageType( DMG_BURN )
			
			ply:TakeDamageInfo(dmgInfo)
				
			ply.__nextDamageApply = curTime + 1
			
		end
	
	end
	
	if (ply.__nextMovementApply or 0) < curTime then
		
		if plyInLava then
			
			-- Reset velocity when player touches lava 
			if !ply.__wasInLava then
			
				local vel = ply:GetVelocity()
				ply:SetVelocity(-(vel*0.95)) -- Adds velocity (not sets)
				
			end
				
			ply:SetGravity(0.1)
			ply:SetLaggedMovementValue(0.5)
			ply.__wasInLava = true
			
		elseif ply.__wasInLava then
		
			ply.__wasInLava = false
			ply:SetLaggedMovementValue(1)
			ply:SetGravity(1)
			
		end
		
		ply.__nextMovementApply = curTime + 0.1
		
	end
	
end
hook.Add("PlayerPostThink", "z_hadez_LavaFloor", PlayerPostThink)

-- Force spectate if killed by lava
local function PlayerSpawn(ply)

	if !SH_HADEZ:IsLavaFloorActive() then return end
	
	if ply.__killedByLava then
	
		ply:GodEnable()
		SV_HADEZ:CloakPlayer(ply, true)
		
	end

end
hook.Add("PlayerSpawn", "z_hadez_LavaFloor", PlayerSpawn)

-- Render spectate targets
local function SetupPlayerVisibility(ply, viewEnt)

	if !SH_HADEZ:IsLavaFloorActive() then return end

	local spectateTarget = SV_HADEZ:GetLavaFloorSpectateTarget(ply)

	if IsValid(spectateTarget) then
		AddOriginToPVS(spectateTarget:GetPos()) -- Spectator can render target
	end

end
hook.Add("SetupPlayerVisibility", "z_hadez_LavaFloor", SetupPlayerVisibility)

local function StartCommand(ply, cmd)

	if !SH_HADEZ:IsLavaFloorActive() then return end
	
	if IsValid(SH_HADEZ:GetLavaFloorSpectateTarget(ply)) then	
		cmd:ClearMovement()
		cmd:ClearButtons()
	end	
	
end
hook.Add("StartCommand", "z_hadez_LavaFloor", StartCommand)