-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local nukeDelay = 45
local nukeRadius = 100000

util.AddNetworkString("z_hadez_NukeLaunch")
local function NukeLaunch(len, ply)

	if !SH_HADEZ:HasAccess(ply, "nukeLaunch") then return end
	
	local target = net.ReadEntity()
	
	local nukeOptions = {
		countdown = net.ReadBool(),
		sound = net.ReadBool()
	}
	
	SV_HADEZ:OnNukeStart(target, nukeOptions)
	SV_HADEZ:OnPowerToggled(target, "nukeLaunch", true)
	
	SV_HADEZ:LogFeature("nukeLog", "nukeLaunch", ply, target, function(ply)
		return true
	end)

end
net.Receive("z_hadez_NukeLaunch",NukeLaunch)

util.AddNetworkString("z_hadez_NukeCountdown")
function SV_HADEZ:OnNukeStart(target, options)
	
	if !IsValid(target) or SH_HADEZ:IsNukeActive() then return end
	
	local delay = options.countdown and nukeDelay or 0
	
	SV_HADEZ:LaunchNuke(target, delay, options)

	if options.countdown then
		timer.Simple(1, function()
			net.Start("z_hadez_NukeCountdown")
				net.WriteBool(options.sound)
			net.Broadcast()
		end)
	end
	
end

function SV_HADEZ:OnNuke(target, backupPos, options)

	local impactPos = IsValid(target) and target:GetPos() or backupPos
	
	local effectdata = EffectData()
	effectdata:SetMagnitude( 0.5 )
	effectdata:SetOrigin( impactPos )
	effectdata:SetScale( 0.5 )
	
	SV_HADEZ:BroadcastSound("ambient/levels/labs/teleport_preblast_suckin1.wav", 511, impactPos, nukeRadius)
	
	-- Rumble
	timer.Simple(1, function()
	
		util.ScreenShake( impactPos, 2000, 2000, 20, nukeRadius )
		util.Effect( "z_hadez_nuke_effect_air", effectdata )
		util.Effect( "z_hadez_nuke_effect_ground", effectdata )
		
		if options.sound then
			SV_HADEZ:BroadcastSound("ambient/explosions/exp1.wav", 511, impactPos, nukeRadius)
		end
		
	end)
	
	-- Explosion
	timer.Simple(2, function()
		
		-- Forced impact radius kill
		local entTbl = ents.FindInSphere( impactPos, 2500 )
		
		for i=1, #entTbl do
			
			local ent = entTbl[i]
			
			if !IsValid(ent) then continue end
			
			ent:TakeDamage( 999999, game.GetWorld(), game.GetWorld() )
			
			-- For when damage is blocked
			if ent:IsPlayer() and ent:Alive() then
				ent:Kill()
			end
			
			
		end
		
		-- Blast damage
		util.BlastDamage( game.GetWorld(), game.GetWorld(), impactPos, nukeRadius, 10000 )
		
		util.Effect( "z_hadez_nuke_blastwave", effectdata )
		
		if options.sound then
			SV_HADEZ:BroadcastSound("ambient/explosions/explode_6.wav", 511, impactPos, nukeRadius)
		end
		
	end)
	
	-- Sound pass
	if options.sound then
	
		timer.Simple(7, function()
			SV_HADEZ:BroadcastSound("ambient/levels/labs/teleport_preblast_suckin1.wav", 511, impactPos, nukeRadius)
		end)
		
	end
	
	SV_HADEZ:OnNukeEnd(target)
	
end

function SV_HADEZ:OnNukeEnd(target)
	SV_HADEZ:OnPowerToggled(target, "nukeLaunch", false)
end