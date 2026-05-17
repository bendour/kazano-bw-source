ashop.itemShopEffects = ashop.itemShopEffects or {}
ashop.itemShopEffects[3] = ashop.itemShopEffects[3] or {}

local grad = Material('akulla/gradient-d')
local l = {
    Material('akulla/pixel_1.png', 'smooth'),
    Material('akulla/pixel_2.png', 'smooth'),
    Material('akulla/pixel_3.png', 'smooth'),
    Material('akulla/pixel_4.png', 'smooth'),
}

local eyePos = Vector()
local ang = Angle()
local grav = Vector( 0, 0, 0.2 )

ashop.itemShopEffects[3].preDraw = function(pnl, w, h, equipped, clr)
    pnl.rarityClr25 = pnl.rarityClr25 or ColorAlpha(clr, 255*0.25)

    surface.SetMaterial(grad)
    surface.SetDrawColor(pnl.rarityClr25)
    surface.DrawTexturedRect(0, h*0.6, w, h*0.4 )

    pnl.lastSpawn = {}

    local xS, yS = pnl:LocalToScreen(0, 0)
    cam.Start3D(eyePos, ang, nil, xS, yS, w, h)
        local p = eyePos + ang:Forward()*5 + ang:Up()*15
        local c = CurTime()

        if !pnl.particleEmitter then
            pnl.particleEmitter = ParticleEmitter(p)
            pnl.particleEmitter:SetNoDraw(true)
        end

        local randomY = math.Round(math.random(-6, 6))

        if pnl.lastSpawn[randomY] and pnl.lastSpawn[randomY]+0.2 > c then return end

        pnl.lastSpawn[randomY] = c
        local hV, s, v = ColorToHSV(clr)
        hV = hV + math.random(-45, 45)
        v = math.max(v - 0.1, 0)

        local cM = HSVToColor(hV, v, s)

        local part = pnl.particleEmitter:Add( l[math.random(1, 4)], p + Vector(0, randomY, -25) )
        if ( part ) then
            part:SetDieTime( 3 ) -- How long the particle should "live"
        
            part:SetStartAlpha( 255 ) -- Starting alpha of the particle
            part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

            part:SetStartSize( math.Rand(0.3, 0.5) * (w >= h and 0.75 or 1) ) -- Starting size
            part:SetEndSize( part:GetStartSize() ) -- Size when removed
            part:SetColor(cM.r, cM.g, cM.b)
        
            part:SetGravity( grav ) -- Gravity of the particle

            local vec = VectorRand(-5, 5)
            vec.z = 10
            vec.x = 0
            vec.y = 0
            part:SetVelocity( vec ) -- Initial velocity of the particle
        end

        pnl.particleEmitter:Draw()
    cam.End3D()

    surface.SetDrawColor(clr)
    surface.DrawRect(0, h-2, w, 2)

    return true
end