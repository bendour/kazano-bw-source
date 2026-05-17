-- CREDITS Garry & Rubat https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/sandbox/entities/effects/balloon_pop.lua

function EFFECT:Init( data )
	local offset = data:GetOrigin()
	local clr = data:GetStart()
	
	local num = 50
	local emitter = ParticleEmitter( offset, true )
	
	for i = 0, num do
		local pos = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )
		local particle = emitter:Add( "particles/balloon_bit", offset + pos * 8 )
		
		if particle then
			particle:SetVelocity( pos * 800 )
		
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 15 )
		
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )
		
			local Size = math.Rand( 1, 4 )
			particle:SetStartSize( Size )
			particle:SetEndSize( 0 )
		
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-2, 2) )
		
			particle:SetAirResistance( 400 )
			particle:SetGravity( Vector( 0, 0, -300 ) )
		
			local rand_dark = math.Rand( 0.8, 1.0 )
			particle:SetColor( clr.r * rand_dark, clr.g * rand_dark, clr.b * rand_dark )
		
			particle:SetCollide( true )
		
			particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ), math.Rand( -160, 160 ), math.Rand( -160, 160 ) ) ) 
		
			particle:SetBounce( 1 )
			particle:SetLighting( true )
		end
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end