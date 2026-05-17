AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

--[[-------------------------------------------------------------------------
Making sure the NPC has the proper collisions
---------------------------------------------------------------------------]]
function ENT:Initialize()
	self:SetModel(lean_updated.npcmodel.val)
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:CapabilitiesAdd( CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
end

--[[-------------------------------------------------------------------------
Allowing lean to be sold ( 2 ways )
---------------------------------------------------------------------------]]
function ENT:AcceptInput(name,act,ply)
	if name == "Use" && IsValid(ply) then
		if lean_updated.usetosell.val && ply.lean == 0 then
			net.Start("lean_msg")
			net.WriteString(lean_updated.nolean.val)
			net.Send(ply)
		end
		if lean_updated.usetosell.val && ply.lean >= 1 then
			local count = ply.lean
			local sellprice = lean_updated.sellprice.val * count
			if lean_updated.usevrondakis.val then
				local xpamt = lean_updated.vrondakisamt.val * count
				ply:addXP(xpamt)
			end
			lean_config.addMoney(ply, sellprice)
			ply.lean = 0
			net.Start("lean_msg")
			net.WriteString("Sold " .. count .. " cups for " .. lean_updated.currency.val .. sellprice)
			net.Send(ply)
			hook.Run("lean_soldLean", ply, count, sellprice)
		elseif !lean_updated.usetosell.val then
			for k, v in ipairs(ents.FindInSphere(self:GetPos(),100)) do
				if v:GetClass() == "lean_crate" || v:GetClass() == "lean_smallcrate" then
					local count = v:Getholding()
					if count >= 1 then
						local sellprice = lean_updated.sellprice.val * count
						if lean_updated.usevrondakis.val then
							local xpamt = lean_updated.vrondakisamt.val * count
							ply:addXP(xpamt)
						end
						lean_config.addMoney(ply, sellprice)
						net.Start("lean_msg")
						net.WriteString("Sold " .. count .. " cups for " .. lean_updated.currency.val .. sellprice)
						net.Send(ply)
						hook.Run("lean_soldLean", ply, count, sellprice)
						v:Remove()
						return
					end
				end
			end
			net.Start("lean_msg")
			net.WriteString(lean_updated.nolean.val)
			net.Send(ply)
		end
	end
end

--[[-------------------------------------------------------------------------
Making sure we get rid of their bottles on death
---------------------------------------------------------------------------]]
hook.Add("PlayerSpawn", "lean_deathReset", function(ply)
	ply.lean = 0
end)

--[[-------------------------------------------------------------------------
Making sure noone manages to damage / kill the NPC
---------------------------------------------------------------------------]]
function ENT:OnTakeDamage()
	return 0
end