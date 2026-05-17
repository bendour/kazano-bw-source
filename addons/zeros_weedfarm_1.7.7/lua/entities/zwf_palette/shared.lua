ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/props_junk/wood_pallet001a.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Palette"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Money")

    if (SERVER) then
        self:SetMoney(0)
    end
end


function ENT:GetBlockCount()
    if self.WeedList then
        return table.Count(self.WeedList)
    else
        return 0
    end
end
