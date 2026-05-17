ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Pet"
ENT.Category = "AShop"
ENT.Author = "JL"
ENT.Spawnable = true

function ENT:Initialize()
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
end