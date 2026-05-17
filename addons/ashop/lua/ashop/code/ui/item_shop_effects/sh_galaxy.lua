ashop.itemShopEffects = ashop.itemShopEffects or {}
ashop.itemShopEffects[4] = ashop.itemShopEffects[4] or {
    noCircle = true
}

local grad = Material('akulla/gradient-d')
local bg = Material('akulla/galaxy.jpg', 'smooth')
local matCirclefill = Material('akulla/circlefill.png', 'smooth')
local matCircle = Material('akulla/circle.png', 'smooth')

local eyePos = Vector()
local ang = Angle(0, 0, 0)
local emptyVec = Vector()

ashop.itemShopEffects[4].preDraw = function(pnl, w, h, equipped, clr)
    pnl.rarityClr25 = pnl.rarityClr25 or ColorAlpha(clr, 255*0.05)

    surface.SetMaterial(bg)
    surface.SetDrawColor(255, 255, 255)
    surface.DrawTexturedRect(-(h - w)/2, 0, w + (h - w), h)

    surface.SetMaterial(grad)
    surface.SetDrawColor(pnl.rarityClr25)
    surface.DrawTexturedRect(0, h*0.6, w, h*0.4 )

    local xS, yS = pnl:LocalToScreen(0, 0)
    local c = CurTime()
    pnl.lastspawn = pnl.lastspawn or 0

    cam.Start3D(eyePos, ang, nil, xS, yS, w, h)
        local p = eyePos + ang:Forward()*5 + ang:Up()*15

        if !pnl.particleEmitter then
            pnl.particleEmitter = ParticleEmitter(p)
            pnl.particleEmitter:SetNoDraw(true)
        end

        if pnl.lastspawn + 0.1 < c then
            pnl.lastspawn = c
            local vec = Vector(10, math.Rand(20, -20), math.Rand(-40, 10))

            local part2 = pnl.particleEmitter:Add( matCircle, p + vec )
            if ( part2 ) then
                part2:SetDieTime( 3 ) -- How long the particle should "live"
            
                part2:SetStartAlpha( 10 ) -- Starting alpha of the particle
                part2:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

                part2:SetStartSize( math.Rand(4, 6) ) -- Starting size
                part2:SetEndSize( 0.2 ) -- Size when removed
                part2:SetColor(255, 255, 255)
            
                part2:SetGravity( emptyVec ) -- Gravity of the particle
                part2:SetVelocity( emptyVec ) -- Initial velocity of the particle
            end

            local part = pnl.particleEmitter:Add( matCirclefill, part2:GetPos() )
            if ( part ) then
                part:SetDieTime( 3 ) -- How long the particle should "live"
            
                part:SetStartAlpha( 255 ) -- Starting alpha of the particle
                part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

                part:SetStartSize( math.Rand(0.4, 0.8) )
                part:SetEndSize( 0.2 )
                part:SetColor(255, 255, 255)
            
                part:SetGravity( part2:GetGravity() ) -- Gravity of the particle
                part:SetVelocity( emptyVec ) -- Initial velocity of the particle
            end

        end

        pnl.particleEmitter:Draw()
    cam.End3D()

    surface.SetDrawColor(clr)
    surface.DrawRect(0, h-2, w, 2)

    return true
end