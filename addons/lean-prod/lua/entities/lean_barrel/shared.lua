ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Lean Barrel"
ENT.Category = "Lean-Production"
ENT.Author = "JL"
ENT.Spawnable = true

--[[-------------------------------------------------------------------------
Preparing values to be shared between client and server
---------------------------------------------------------------------------]]
function ENT:SetupDataTables()
	-- Entities
	self:NetworkVar("Entity",0,"owning_ent")
	-- Integers
	self:NetworkVar("Int",0,"sprite_num")
	self:NetworkVar("Int",1,"codeine_num")
	self:NetworkVar("Int",2,"ranchers_num")
	self:NetworkVar("Int",3,"ice_num")
	self:NetworkVar("Int",4,"holding")
	self:NetworkVar("Int",5,"shook")
	-- Boolean
	self:NetworkVar("Bool",0,"full")
	self:NetworkVar("Bool",1,"extract")
	self:NetworkVar("Bool",2,"mixing")
end