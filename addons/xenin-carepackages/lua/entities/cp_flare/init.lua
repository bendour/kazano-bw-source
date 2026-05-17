AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel("models/items/ar2_grenade.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  local phys = self:GetPhysicsObject()
  if (IsValid(phys)) then
    phys:Wake()
    phys:EnableGravity(true)
		phys:SetBuoyancyRatio(0)
  end

  local col = CarePackage.Config.SmokeColor or XeninUI.Theme.Red
  self:SetColor(col)
  util.SpriteTrail(self, 0, col, true, 1, 25, 5, 0.85, "trails/smoke.vmt")
  util.SpriteTrail(self, 0, Color(90, 90, 90, 125), true, 2, 1, 3, 0.125, "trails/smoke.vmt")
  timer.Simple(120, function()
    if (!IsValid(self)) then return end

    self:Remove()
  end)

  self.Created = CurTime()
end

local function traceFunc(ent, flare)
  return !ent:IsPlayer() or (ent:GetClass() != "env_spritetail" or ent != flare)
end

function ENT:Think()
  if (self.StillInfo) then return end

  if (self:IsStill() and self.Created < (CurTime() + 1)) then
    self.StillInfo = {
      Pos = self:GetPos(),
      Ang = self:GetAngles()
    }

    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
      phys:EnableMotion(false)
    end

    local pos = self.StillInfo.Pos
    if (!self.AllPlayers) then
      self.AllPlayers = player.GetAll()
    end
    local tbl = self.AllPlayers
    local tr = util.QuickTrace(pos, Vector(pos.x, pos.y, pos.z + 99999), function(ent)
      traceFunc(ent, self)
    end)

    local owner = self:GetOwner()
    local size = 37.5
    local min = self:LocalToWorld(Vector(-size, -size, 0))
    local max = self:LocalToWorld(Vector(size, size, size * 2))
    local ents = ents.FindInBox(min, max)
    local tbl = {}
    local positionClear = true
    for i, v in ipairs(ents) do
      if (v:GetClass() == "prop_physics" or v:GetClass() == "prop_ragdoll") then
        positionClear = nil
      end
    end

    if (tr.HitSky and positionClear and (!tr.Entity or tr.Entity == Entity(0))) then
      CarePackage:MessagePlayer(self:GetOwner(), CarePackage:GetPhrase("Flare.Valid"))

      hook.Run("CarePackage.PreFlareDropped", self, self.StillInfo.Pos)
      hook.Run("CarePackage.FlareDropped", self, self.StillInfo.Pos)
    else
      hook.Run("CarePackage.FlareInvalid", self)

      CarePackage:MessagePlayer(self:GetOwner(), CarePackage:GetPhrase("Flare.Invalid"))
    end
  end
end
