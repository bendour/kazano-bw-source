local random = math.random
local rand = math.Rand
local sqrt = math.sqrt
local sin = math.sin

local PANEL={}

local function extend(child, parent)
    setmetatable(child,{__index = parent}) 
end

--base class for particle
local Particle2D = {}
function Particle2D:New(parent_panel)
    if not IsValid(parent_panel) then error("No valid parent panel") end

    local obj = {}
    obj.panel = parent_panel

    obj.x = 0
    obj.y = 0
    obj.ix = 0 --inertia x
    obj.iy = 0 --inertia y

    obj.w = 4 --width
    obj.h = 4 --height

    obj.color = Color(255,255,255)
    
    setmetatable(obj, self)
    self.__index = self

    return obj
end

function Particle2D:Paint()
    surface.SetDrawColor( self.color.r, self.color.g, self.color.b, self.color.a )
    surface.DrawRect(self.x, self.y, self.w, self.h)
end

function Particle2D:Move(px, py)
    local w,h = self.panel:GetSize()

    local newx = self.x + px
    local newy = self.y + py
    if newx > w then
        newx = 0
        newy = random(1,h-1)
    elseif newx < 0 then
        newx = w
        newy = random(1,h-1)
    end

    if newy > h then
        newy = 0
        newx = random(1,w-1)
    elseif newy < 0 then
        newy = h
        newx = random(1,w-1)
    end

    self.x = newx
    self.y = newy
end

function Particle2D:Init()
    --for override
end

function Particle2D:Think()
    --for override
end


-------------------
--# DOTS EFFECT #--
-------------------
local DotsParticle = {}
extend(DotsParticle, Particle2D)
function DotsParticle:Init()
    local w,h = self.panel:GetSize()
    self.line_clr = Color(200,200,200,20)
    self.x = random(0,w)
    self.y = random(0,h)

    self.force_x = (random()-0.5)*0.7
    self.force_y = (random()-0.5)*0.7
    self.xinert = 0
    self.yinert = 0
end

function DotsParticle:Think()
    local ft = RealFrameTime()*100
    self:Move((self.force_x+self.xinert)*ft, (self.force_y+self.yinert)*ft)
end

function DotsParticle:Paint()
    surface.SetDrawColor( self.color.r, self.color.g, self.color.b, self.color.a )
    surface.DrawRect(self.x-self.w*0.5, self.y-self.h*0.5, self.w, self.h)

    local maxdist = 15000

    if escore2.addon:GetVar("mouse_interaction") then
        local mx, my = input.GetCursorPos()
        local dist_mouse = ((mx-self.x)*(mx-self.x) + (my-self.y)*(my-self.y))
        if dist_mouse < maxdist and dist_mouse > -maxdist then
            local dif = (maxdist / dist_mouse)*0.7
            surface.SetDrawColor( self.line_clr.r, self.line_clr.g, self.line_clr.b, self.line_clr.a*dif )
            surface.DrawLine(mx, my, self.x, self.y)

            local modifer = 50
            --attraction on lmb
            if input.IsMouseDown(MOUSE_LEFT) then
                modifer = -modifer
            end

            --x inertion
            if self.x >= mx then
                self.xinert = self.xinert + (self.x - mx)/(maxdist) * modifer
            elseif self.x <= mx then
                self.xinert = self.xinert - (mx - self.x)/(maxdist) * modifer
            end

            --y inertion
            if self.y >= my then
                self.yinert = self.yinert + (self.y - my)/(maxdist) * modifer
            elseif self.y <= my then
                self.yinert = self.yinert - (my - self.y)/(maxdist) * modifer
            end
        end

        --damping inertion
        self.xinert = Lerp(0.01, self.xinert, 0)
        self.yinert = Lerp(0.01, self.yinert, 0)
    end

    for _, v in ipairs(self.panel.particles) do
        local dist = ((v.x-self.x)*(v.x-self.x) + (v.y-self.y)*(v.y-self.y))
        if dist < maxdist and dist > -maxdist then
            local dif = (maxdist / dist)*0.7
            surface.SetDrawColor( self.line_clr.r, self.line_clr.g, self.line_clr.b, self.line_clr.a*dif )
            surface.DrawLine(v.x, v.y, self.x, self.y)
        end
    end
end
escore2.DotsParticle = DotsParticle


-------------------
--# SNOW EFFECT #--
-------------------
local SnowParticle = {}
extend(SnowParticle, Particle2D)
function SnowParticle:Init()
    local w,h = self.panel:GetSize()
    self.line_clr = Color(200,200,200,20)
    self.x = random(0,w)
    self.y = random(0,h)
    self.w = rand(2,5)
    self.h = self.w

    self.force_x = rand(0.1, 0.6)
    self.force_y = rand(0.5, 1.2)
    self.xinert = 0
    self.yinert = 0
    self.sin_shift = random(0, 100)

    local color_shift = random(-self.w * 50, -10)
    self.color.a = self.color.a + color_shift

    local blueness = random(0, 50)
    self.color.r = self.color.r - blueness
    self.color.g = self.color.g - blueness
end

function SnowParticle:Think()
    local ft = RealFrameTime()*100
    local move_x = sin(CurTime() + self.sin_shift)*self.force_x
    self:Move((move_x+self.xinert)*ft, (self.force_y+self.yinert)*ft)
end

function SnowParticle:Paint()
    -- surface.SetDrawColor( self.color.r, self.color.g, self.color.b, self.color.a )
    -- surface.DrawRect(self.x-self.w*0.5, self.y-self.h*0.5, self.w, self.h)

    esclib.draw:Circle(self.x, self.y, self.w, self.color)

    local maxdist = 15000

    if escore2.addon:GetVar("mouse_interaction") then
        local mx, my = input.GetCursorPos()
        local dist_mouse = ((mx-self.x)*(mx-self.x) + (my-self.y)*(my-self.y))
        if dist_mouse < maxdist and dist_mouse > -maxdist then
            local dif = (maxdist / dist_mouse)*0.7
            surface.SetDrawColor( self.line_clr.r, self.line_clr.g, self.line_clr.b, self.line_clr.a*dif )
            surface.DrawLine(mx, my, self.x, self.y)

            local modifer = 50
            --attraction on lmb
            if input.IsMouseDown(MOUSE_LEFT) then
                modifer = -modifer
            end

            --x inertion
            if self.x >= mx then
                self.xinert = self.xinert + (self.x - mx)/(maxdist) * modifer
            elseif self.x <= mx then
                self.xinert = self.xinert - (mx - self.x)/(maxdist) * modifer
            end

            --y inertion
            if self.y >= my then
                self.yinert = self.yinert + (self.y - my)/(maxdist) * modifer
            elseif self.y <= my then
                self.yinert = self.yinert - (my - self.y)/(maxdist) * modifer
            end
        end

        --damping inertion
        self.xinert = Lerp(0.01, self.xinert, 0)
        self.yinert = Lerp(0.01, self.yinert, 0)
    end
end
escore2.SnowParticle = SnowParticle



AccessorFunc(PANEL, "particle_class", "EffectClass")

function PANEL:Init()
    self.particles = {}

    self:SetMouseInputEnabled(false)
	self:SetSize(400,400)
    self:SetEffectClass(DotsParticle)
end

function PANEL:ClearParticles()
    table.Empty(self.particles)
end

function PANEL:CreateParticles(count)
    count = count or 200
    self:ClearParticles()
    for k = 1, count do
        local particle = self.particle_class:New(self)
        particle:Init()
        table.insert(self.particles, particle)
    end
end

function PANEL:Think()
    for _, v in ipairs(self.particles) do
        v:Think()
    end
end

function PANEL:Paint(w,h)
    for _, v in ipairs(self.particles) do
        v:Paint()
    end
end

vgui.Register( "escore2.particle_panel", PANEL, "DPanel" )

if IsValid(escore2.bg) then --lua refresh
    escore2:Build()
end