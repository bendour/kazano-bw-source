ashop.itemShopEffects = ashop.itemShopEffects or {}
ashop.itemShopEffects[5] = ashop.itemShopEffects[5] or {}

if SERVER then return end

local tex = GetRenderTarget( "AShopGlitch", ScrW(), ScrH() )

local myMat = CreateMaterial( "AShopGlitch2", "UnlitGeneric", {
	["$basetexture"] = tex:GetName(),
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1
} )

local rands = {
    x = math.random(),
    y = math.random(),
    w = math.random(0, 20),
    h = math.random(0, 20)
}

local lastRand = 0

local function refreshRands()
    rands = {
        x = math.random(-0.05, 1.05),
        y = math.random(),
        w = math.random(),
        h = math.random(),
        xPos = math.random(),
        yPos = math.random()
    }
end

refreshRands()

ashop.itemShopEffects[5].preDraw = function(pnl, w, h, equipped, clr)
    local c = CurTime()
    if lastRand < c then
        // TODO: Check Epilepsy warning, we make the colors less flashy ?
        // Time should be fine, I think ?
        lastRand = c + 0.1
        refreshRands()
    end

    local xS, yS = pnl:LocalToScreen(0, 0)
    local cursorX = math.max(rands.x * (w - rands.w*w), 0)
    local cursorY = math.max(rands.y * (h - rands.h*w), 0)

    surface.SetDrawColor(ColorRand())
    surface.SetMaterial(myMat)
    surface.DrawTexturedRectUV(0, 0, w, h, 
        (cursorX + xS) / ScrW(), (cursorY + yS)/ScrH(), (cursorX + xS + rands.w*w) / ScrW(), (cursorY + yS + rands.h*h)/ScrH())

    surface.SetDrawColor(ColorRand())
    surface.DrawTexturedRectUV(rands.xPos*(w - rands.w*w), rands.yPos * (h - rands.h*w), rands.w*w, rands.h*w, 
        (cursorX + xS) / ScrW(), (cursorY + yS)/ScrH(), (cursorX + xS + rands.w*w) / ScrW(), (cursorY + yS + rands.h*h)/ScrH())
end

hook.Add('PostRender', 'ashop_copyRT', function()
    render.CopyRenderTargetToTexture( tex )
end)