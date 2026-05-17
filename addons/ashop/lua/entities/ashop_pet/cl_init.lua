include("shared.lua")

ENT.AutomaticFrameAdvance = true

local clr = ashop.GetColor('blurpleBg', 150)

function ENT:RegenerateClientsideModel()
    if IsValid(self.cm) then
        return
    end

    local item = self.ashop_item
    self.cm = ClientsideModel(item.metadata[1])
    self.cm:SetPos(self.owner:GetPos())
    self.cm:SetNoDraw(true)

    if item.metadata[2] then
        self.cm:SetSkin(item.metadata[2])
    end

    if item.metadata[9] then
        self.cm:SetModelScale(math.Clamp(item.metadata[9], 0.1, 2))
    end

    local offsetY = item.metadata[3] or 0
    local offsetYVec = Vector(0, 0, offsetY)
    self.cm.offsetY = offsetYVec
    self.cm:Spawn()
end

function ENT:OnRemove()
    if IsValid(self.cm) then
        self.cm:Remove()
    end
end

local ang09090 = Angle(0, 90, 90)
local lp

function ENT:RenderOverride()
    if !self.owner then return end
    self:DestroyShadow()
    lp = lp or (IsValid(LocalPlayer()) and LocalPlayer() or nil)
    self:RegenerateClientsideModel()
    local camAng = self.cm:GetAngles() + ang09090
    local r = math.AngleDifference(self.owner:EyeAngles().y, camAng.y)
    local plyItem = self.ashop_plyitem

    //
    local old = self.cm:GetCycle()

    // wtf ?
    if old == nil then return end

    self.cm:SetCycle((CurTime() * (self.cm.seqSpeed or 1) / self.cm:SequenceDuration()) % 1)

    if old > self.cm:GetCycle() then
        self.cm.canAnimReset = true
    end

    self:SetNextPos()

    //
    if IsValid(self.cm) then
        self.cm:DrawModel()
    end

    if !plyItem or !plyItem.metadata[8] then return end
    if lp:GetPos():DistToSqr(self:GetPos()) > 300 * 300 then return end

    local a = r
    if a > 30 and a < (90 + 60) then
        self.cm.viewAng = self.cm.viewAng or Vector(0, 0, -self.cm:GetModelBounds().z + 10)
        self.cm.viewAng.z = -self.cm:GetModelBounds().z + 10

        cam.Start3D2D(self.cm:GetPos() + self.cm.viewAng, camAng, 0.1)
            surface.SetDrawColor(clr)

            if self.txW then
                surface.DrawRect(-self.txW/2, -self.txH/2, self.txW, self.txH)
            end
            local w, h = draw.SimpleText(plyItem.metadata[8], 'ashop_3D2D_18', 0, 0, color_white, 1, 1)
            self.txW = w + 20
            self.txH = h + 10
        cam.End3D2D()
    end
end

local heightVec = Vector(0, 0, 60)
local function isInfront(ply, pos)
    local diff = pos - (ply:GetShootPos() + ply:GetAimVector() * 40)
    return ply:GetAimVector():Dot(diff) / diff:Length() > 0
end

local limit = 3
local function clampAngle(source, yTarget)
    if ashop.Config.PetSnapAngle then
        source.y = yTarget
        return source
    end


    local y = math.Round(math.AngleDifference( yTarget, source.y ))

    if y != 0 then
        source.y = source.y + math.Clamp(yTarget, -limit, limit)
    end

    return source
end

local vector005 = Vector(0, 0, 5)
local distMove = ashop.Config.PetDistanceBeforeMoving or 256
distMove = distMove * distMove

function ENT:SetNextPos()
    if !self.owner then return end
    if !self.ashop_item then return end

    local item = self.ashop_item
    local owner = self.owner
    local self = self.cm
    local selfPos = self:GetPos()
    selfPos.z = selfPos.z - (self.offsetY.z or 0)
    local ownerPos = owner:GetPos()

    local ownerVelocity = owner:GetVelocity()
    ownerVelocity.z = 0
    local static = ownerVelocity:LengthSqr() < 9999
    local selfAng = self:GetAngles()

    local ownerAng = owner:GetAngles()
    local mins, maxs = self:GetHitBoxBounds(0, 0)

    if !mins or !maxs then return end

    self.accel = self.accel or 100

    // Fix positions, so traceHull are more precise
    maxs.z = maxs.z - mins.z
    mins.z = 0

    if selfPos:DistToSqr(ownerPos) < distMove and static then
        local cA = clampAngle(selfAng, (ownerPos - selfPos):Angle().y)

        self:SetAngles(cA)
        if self.canAnimReset or self.animTypePet != 1 then
            local item = item
            local seq = item.metadata[5]
            local t = seq[math.random(#seq)]

            self.seqSpeed = t[2]

            self:SetSequence(t[1])
            self.animTypePet = 1
            self.canAnimReset = false
        end

        self.accel = 0
        return
    else
        local onGround = owner:IsOnGround()
        local targetAnim = onGround and 2 or 3
        if self.animTypePet != targetAnim then
            self.canAnimReset = true
        end

        if !onGround and table.IsEmpty(item.metadata[7]) then
            onGround = true
        end

        if self.canAnimReset then
            local item = item
            local seq = item.metadata[onGround and 4 or 7]
            local t = seq[math.random(#seq)]

            self.seqSpeed = t[2]
            self:SetSequence(t[1])
            self.animTypePet = 2
            self.canAnimReset = false
        end

        self.accel = math.min(self.accel + RealFrameTime()*0.5, 1)
    end

    ownerAng.x = 0
    local ownerForward, ownerRight = ownerAng:Forward(), ownerAng:Right()
    local idealPos, idealDist

    // Check what is the closest pos, between left and right
    for side = -1, 1, 2 do
        local p = ownerPos + ownerForward * 120 + ownerRight * (30 * side)
        local d = ownerPos:DistToSqr(p)

        if !idealDist or d < idealDist then
            // Check if we can reach it, atleast
            local heightCheck = util.TraceHull({
                start = p + heightVec,
                endpos = p - heightVec,
                mins = mins,
                maxs = maxs
            })

            if !heightCheck.Hit or heightCheck.HitPos == (p + heightVec) then continue end

            idealPos = heightCheck.HitPos
        end
    end

    if !idealPos then return end
    l = idealPos
    
    // Can we reach our pos ? If no, we are stuck
    //local tr = util.TraceLine({
    //    start = selfPos + Vector(0, 0, 40),
    //    endpos = idealPos + Vector(0, 0, 40)
    //})

    // Can we continue walking ?
    local cl = (selfPos - idealPos)
    cl.z = 0
    local clNorm5 = cl:GetNormalized()*5

    // Can we walk without going in air
    local canMove = false

    for i = 1, -1, -1 do
        local v = Vector(0, 0, 20) * i
        local tr = util.TraceHull({
            start = selfPos + v,
            endpos = selfPos + v + clNorm5,
            mins = mins,
            maxs = maxs
        })

        if !tr.Hit then
            canMove = true
            break
        end
    end

    if canMove then
        // Simple case, we setpos our pet
        self.oldPlayerPos = self.oldPlayerPos or owner:GetPos()
        local diffPly = owner:GetPos() - self.oldPlayerPos
        self.oldPlayerPos = owner:GetPos()

        local diff = idealPos - selfPos

        local diffRatio = math.min((diffPly:Length() / diff:Length())*(1 + math.ease.OutCirc(self.accel)*0.25), 1.25)
        //local diffRatio = diff * diff:Length() / diffPly:Length()
        local targetPos = selfPos + (diff * diffRatio)

        local heightCheck = util.TraceHull({
            start = targetPos + heightVec,
            endpos = targetPos - heightVec,
            mins = mins,
            maxs = maxs
        })
        
        // WE ARE STUCK
        if heightCheck.Hit then
            // We need to accelerate the diff vector, based on player speed, and distance between them
            self:SetPos(heightCheck.HitPos + self.offsetY)

            local ang = clampAngle(selfAng, owner:GetAbsVelocity():Angle().y)
            ang:Normalize()
            self:SetAngles(ang)

            return
        end
    end

    // Step-pet is stuck
    // Idealpos should be available, from the HitPos == start check above
    // In this case, find a pos where we can TP outside of the owner FOV
    if !isInfront(owner, self:GetPos()) then
        for xSide = -1, 1, 2 do
            for ySide = -1, 1, 2 do
                local p = ownerPos + ownerForward * 100 * ySide + ownerRight * 30 * xSide

                local heightCheck = util.TraceHull({
                    start = p + heightVec,
                    endpos = p - heightVec,
                    mins = mins,
                    maxs = maxs
                })

                if !heightCheck.Hit or heightCheck.HitPos == (p + heightVec) then continue end

                local wallCheck = util.TraceHull({
                    start = p + vector005,
                    endpos = ownerPos + vector005,
                    mins = mins,
                    maxs = maxs
                })

                if isInfront(owner, p) or wallCheck.Hit then continue end

                self:SetPos(p + self.offsetY)
                return
            end
        end
    end
end