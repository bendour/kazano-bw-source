-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsInRocketLaunch(ply)
	return ply:GetNWBool("z_hadez_RocketLaunch")
end

if SERVER then

	function SV_HADEZ:SetInRocketLaunch(ply, bool)
		ply:SetNWBool("z_hadez_RocketLaunch", bool)
	end
	
end

if CLIENT then

	-- Smoke
	local function Think()
	
		local plys = player.GetAll()
		
		for i=1, #plys do
			
			local ply = plys[i]
			
			if SH_HADEZ:IsInRocketLaunch(ply) then
			
				local plyPos = ply:GetPos()
				local smokePos = plyPos - Vector(0,0,50)
				
				if !ply.z_hadez_rocketParticleSys then
					ply.z_hadez_rocketParticleSys = ParticleEmitter(plyPos)
				else
					ply.z_hadez_rocketParticleSys:SetPos(plyPos)
				end
				
				for i=0, 10 do
					
					local smokeParticle = ply.z_hadez_rocketParticleSys:Add( "particle/smokesprites_000"..math.random(1,9), smokePos)
					
					if (smokeParticle) then
						smokeParticle:SetVelocity(Vector(0,0,0))
						smokeParticle:SetDieTime( math.Rand( 2, 5 ) )
						smokeParticle:SetStartAlpha( 2 )
						smokeParticle:SetEndAlpha( 0 )
						smokeParticle:SetStartSize( math.Rand( 30, 40 ) )
						smokeParticle:SetEndSize( math.Rand( 100, 125 ) )
						smokeParticle:SetRoll( math.Rand(0, 360) )
						smokeParticle:SetRollDelta( math.Rand(-1, 1) )
						smokeParticle:SetColor( 200 , 200 , 200 ) 
						smokeParticle:SetAirResistance( 200 ) 
						smokeParticle:SetGravity( Vector( 100, 0, 0 ) ) 	
					end
					
				end
				
			end
			
		end
	
	end
	hook.Add("Think", "z_hadez_RocketLaunch", Think)
	
end