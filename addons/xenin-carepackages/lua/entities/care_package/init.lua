AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel(CarePackage.Config.Model)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  local phys = self:GetPhysicsObject()
  if (phys) then
    phys:EnableMotion(false)
  end

  self:SetBeenUsed(false)
  self:RollContents()
  self:SetProgress(0)
  self:SetBodygroup(2, 1)

  self.ClaimedItems = 0

  timer.Simple(CarePackage.Config.DespawnTime, function()
    if (!IsValid(self)) then return end

    self:Remove()
  end)
end

function ENT:RollContents()
  self.Contents = {}

  for i = 1, CarePackage.Config.ItemsPerDrop do
    local id = CarePackage:GetRandomDrop()
    self.Contents[i] = { id = id }
  end
end

function ENT:StartProgress()
  if (self:GetProgress() > 0) then return end

  local time = 0
  local openTime = CarePackage.Config.OpenTime * 10
  timer.Create("CarePackage.Timer." .. self:EntIndex(), 0.1, openTime, function()
    time = time + 1

    if (time >= openTime) then
      self.Opened = true
    end

    self:SetProgress(time / openTime)
  end)

  timer.Simple(openTime + CarePackage.Config.DespawnTimeOpened, function()
    if (!IsValid(self)) then return end

    self:Remove()
  end)
end

function ENT:Use(ply)
  if (CarePackage.Config.OpenTime > 0) then
    if (!self:GetBeenUsed()) then
      self:SetBeenUsed(true)
      self:StartProgress()

      hook.Run("CarePackage.Opened", ply)
    end

    if (self.Opened) then
      net.Start("CarePackage.Menu")
        net.WriteEntity(self)
        net.WriteTable(self.Contents)
      net.Send(ply)
    end
  else
    net.Start("CarePackage.Menu")
      net.WriteEntity(self)
      net.WriteTable(self.Contents)
    net.Send(ply)

    if (!self.Opened) then
      hook.Run("CarePackage.Opened", ply)

      self.Opened = true
    end
  end
end