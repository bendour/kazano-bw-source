ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_nutritionbottle.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Nutrition"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "NutritionID")

    if (SERVER) then
        self:SetNutritionID(-1)
    end
end
