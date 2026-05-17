ENT.Type = "anim"
ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Coinflip NPC"
ENT.Author = "JL"
ENT.Category = "Xenin"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end