ashop.itemShopEffects = ashop.itemShopEffects or {}
ashop.itemShopEffects[1] = ashop.itemShopEffects[1] or {}

local matCircle = Material('akulla/circle.png', 'smooth')
local grad = Material('akulla/gradient-d')

local eyePos = Vector()
local ang = Angle(0, 0, 0)
local grav = Vector( 0, 0, 0.2 )

ashop.itemShopEffects[1].preDraw = function(pnl, w, h, equipped, clr)
    if !pnl.clrEffect then
        local hue, sat, val = ColorToHSV(clr)
        sat = math.max(sat/2, 0)
        val = 0.8

        pnl.clrEffect = HSVToColor(hue, sat, val)
    end

    pnl.rarityClr25 = pnl.rarityClr25 or ColorAlpha(clr, 255*0.10)

    local curTime = (CurTime()/1.5)%2

    if curTime < 1 then
        pnl.rarityClr25.a = math.ease.InBounce(curTime)*30 + 60
    else
        pnl.rarityClr25.a = math.ease.InElastic(2 - curTime)*30 + 60
    end

    surface.SetMaterial(grad)
    surface.SetDrawColor(pnl.rarityClr25)
    surface.DrawTexturedRect(0, h*0.6, w, h*0.4 )

    local xS, yS = pnl:LocalToScreen(0, 0)
    cam.Start3D(eyePos, ang, nil, xS, yS, w, h)
        local p = eyePos + ang:Forward()*5 + ang:Up()*15

        if !pnl.particleEmitter then
            pnl.particleEmitter = ParticleEmitter(p)
            pnl.particleEmitter:SetNoDraw(true)
        end

        for i = 1, 5 do -- Do 100 particles
            local part = pnl.particleEmitter:Add( matCircle, p + Vector(0, math.random(-10, 15), -25) ) -- Create a new particle at pos
            if ( part ) then
                part:SetDieTime( 3 ) -- How long the particle should "live"
        
                part:SetStartAlpha( math.Rand(20, 170) ) -- Starting alpha of the particle
                part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
        
                part:SetStartSize( math.Rand(0.2, 0.5) ) -- Starting size
                part:SetEndSize( 0 ) -- Size when removed
                part:SetColor(pnl.clrEffect.r, pnl.clrEffect.g, pnl.clrEffect.b)
        
                part:SetGravity( grav ) -- Gravity of the particle

                local vec = VectorRand(-5, 5)
                vec.z = math.Rand(2, 10)
                vec.y = -5
                part:SetVelocity( vec ) -- Initial velocity of the particle
            end
        end

        pnl.particleEmitter:Draw()
    cam.End3D()

    surface.SetDrawColor(clr)
    surface.DrawRect(0, h-2, w, 2)

    return true
end