ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_weedfarm/zwf_weedstick.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "WeedStick"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "WeedAmount")
    self:NetworkVar("Float", 1, "StartDryTime")
    self:NetworkVar("Int",1,"Progress")
    if (SERVER) then
        self:SetWeedAmount(50)
        self:SetStartDryTime(-1)
        self:SetProgress(-1)
    end
end
