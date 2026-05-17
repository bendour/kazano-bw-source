-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_BarrierPlayers")
local function BulletTimePlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "barrier") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local barrierOptions = {
		invincible = net.ReadBool(),
		killPly = net.ReadBool(),
		killNpc = net.ReadBool(),
		health = net.ReadBool(),
		armor = net.ReadBool(),
		noDamage = net.ReadBool(),
		inverse = net.ReadBool(),
		sound = net.ReadBool(),
		range = net.ReadString()
	}

	barrierOptions.range = string.Split(barrierOptions.range, 'm')[1]*20
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		local enabled = !SH_HADEZ:HasBarrier(target)
	
		if enabled then
			SV_HADEZ:SetBarrierOptions(target, barrierOptions)
			SV_HADEZ:OnBarrierStart(target)
		else
			SV_HADEZ:OnBarrierStop(target)
		end
		
		SV_HADEZ:OnPowerToggled(target, "barrier", enabled)
		
	end
	
	SV_HADEZ:LogFeature("barrierLog", "barrier", ply, targets, function(ply)
		return SH_HADEZ:HasBarrier(ply)
	end)
	
end
net.Receive("z_hadez_BarrierPlayers", BulletTimePlayers)

local barrierSounds = {}

function SV_HADEZ:OnBarrierStart(ply)

	SV_HADEZ:SetBarrier(ply, true)
	
	-- No Damage
	if SH_HADEZ:GetBarrierOption(ply, "invincible") then
		ply:GodEnable()
	end
	
	-- Barrier sound
	if SH_HADEZ:GetBarrierOption(ply, "sound") then
		
		if !barrierSounds[ply] then
			barrierSounds[ply] = CreateSound(ply, "ambient/machines/combine_shield_loop3.wav")
			
			local range = SH_HADEZ:GetBarrierOption(ply, "range", 1)
			barrierSounds[ply]:SetSoundLevel(math.Clamp(40,range/2.25,160))
		end
		
		barrierSounds[ply]:Play()
	
	end
	
	-- Make sure godmode is off
	local function PlayerDisconnected(ply)

		local plys = player.GetAll()

		for i=1, #plys do
			
			local p = plys[i]
			
			if SV_HADEZ:GetBarrierOwner(p) == ply then
				p:GodDisable()
				SV_HADEZ:SetInBarrier(p, NULL)
			end
			
		end
	
	end
	hook.Add("PlayerDisconnected", "z_hadez_Barrier_"..ply:UniqueID(), PlayerDisconnected)

end

function SV_HADEZ:OnBarrierStop(ply)

	SV_HADEZ:SetBarrier(ply, false)
	
	-- No Damage
	if SH_HADEZ:GetBarrierOption(ply, "invincible") then
		ply:GodDisable()
	end
	
	-- Barrier sound
	if barrierSounds[ply] then
		barrierSounds[ply]:FadeOut(0.5)
	end
	
	-- Toggle godmode off from everyone in this barrier
	local plys = player.GetAll()
	
	for i=1, #plys do
		
		local p = plys[i]
		
		if SV_HADEZ:GetBarrierOwner(p) == ply then
			p:GodDisable()
			SV_HADEZ:SetInBarrier(p, NULL)
		end
		
	end
	
	-- Cleanup
	hook.Remove("PlayerDisconnected", "z_hadez_Barrier_"..ply:UniqueID())

end

local specialNPCDestroyInputs = {
	["npc_combinegunship"] = "SelfDestruct",
	["npc_helicopter"] = "SelfDestruct",
	["npc_combinedropship"] = "SelfDestruct",
	["npc_turret_floor"] = "SelfDestruct",
	["npc_strider"] = "Break",
	["npc_combinedropship"] = "Break",
	["npc_rollermine"] = "Ignite",
}

local function PlayerPostThink(ply)
	
	local curTime = CurTime()

	if (ply.z_hadez_nextBarrierCheck or 0) > curTime then return end
	ply.z_hadez_nextBarrierCheck = curTime+0.1
	
	if !SH_HADEZ:HasBarrier(ply) or !ply:Alive() then return end
	
	local killPly = SH_HADEZ:GetBarrierOption(ply, "killPly")
	local killNpc = SH_HADEZ:GetBarrierOption(ply, "killNpc")
	local regHealth = SH_HADEZ:GetBarrierOption(ply, "health")
	local regArmor = SH_HADEZ:GetBarrierOption(ply, "armor")
	local noDamage = SH_HADEZ:GetBarrierOption(ply, "noDamage")
	local range = SH_HADEZ:GetBarrierOption(ply, "range")
	local inverse = SH_HADEZ:GetBarrierOption(ply, "inverse")

	local entTbl = ents.FindInSphere(ply:GetPos()+Vector(0,0,40), range)
	
	if inverse then
	
		local allEnts = ents.GetAll()
		local barrierEnts = table.Copy(entTbl)
		local entsOutsideBarrier = {}
		
		for i=1, #allEnts do
			
			local ent = allEnts[i]
			
			-- Remove entities inside barrier from table to speedup loop over time
			if table.HasValue( barrierEnts, ent ) then
				table.RemoveByValue( barrierEnts, ent )
				continue
			end
		
			table.insert(entsOutsideBarrier, ent)
			
		end
		
		entTbl = entsOutsideBarrier
	
	end
	
	local playersInBarrier = {}
	
	for i=1, #entTbl do
	
		local ent = entTbl[i]
		
		if !IsValid(ent) then continue end
		
		local isPly = ent == ply
		local isPlayer = ent:IsPlayer()
		local isNPC = ent:IsNPC()
		
		if ent:IsWeapon() or ent:IsWorld() or ent:IsVehicle() then continue end
		
		-- Killing players and npcs
		if !isPly and (killPly or killNpc) then
		
			if (killPly and isPlayer) or (killNpc and (isNPC or ent:IsNextBot())) then
				
				if isPlayer and ent:HasGodMode() then
					ent:GodDisable()
				end
			
				local barrierDmgInfo = DamageInfo()
				barrierDmgInfo:SetDamage( 999999 )
				barrierDmgInfo:SetDamageType( DMG_DISSOLVE )
				barrierDmgInfo:SetAttacker(game.GetWorld())
				barrierDmgInfo:SetInflictor(game.GetWorld())
				
				ent:TakeDamageInfo( barrierDmgInfo )
				
				-- For when damage is blocked (hl2 jeep)
				if isPlayer and ent:Alive() then
					ent:Kill()
				end
				
				if isNPC then
			
					local specialCase = specialNPCDestroyInputs[ent:GetClass()]
					
					if specialCase and !ent.z_hadez_didKillInput then
						ent.z_hadez_didKillInput = true
						ent:Input(specialCase)
					end
				
				end
				
			end

		end
		
		if isPlayer and ent:Alive() then
		
			-- Regenerating health
			if regHealth then
			
				local newHealth = math.min(ent:Health()+1,ent:GetMaxHealth())
			
				ent:SetHealth(newHealth)
				
			end
			
			-- Regenerating armor
			if regArmor then
				
				local newArmor = math.min(ent:Armor()+1,ent:GetMaxArmor())
				
				ent:SetArmor(newArmor)
				
			end
			
			-- Mark player present in this barrier
			playersInBarrier[ent] = true

		end
	
	end
	
	if !noDamage then return end
	
	local plys = player.GetAll()
	
	for i=1, #plys do
		
		local p = plys[i]
		local isInBarrier = playersInBarrier[p]
		
		if isInBarrier and !p:HasGodMode() then
		
			SV_HADEZ:SetInBarrier(p, ply)
			p:GodEnable()
			
		elseif !isInBarrier and p:HasGodMode() and SV_HADEZ:GetBarrierOwner(p) == ply then
		
			p:GodDisable()
			SV_HADEZ:SetInBarrier(p, NULL)
			
		end
		
	end
	
end
hook.Add("PlayerPostThink", "z_hadez_Barrier", PlayerPostThink)