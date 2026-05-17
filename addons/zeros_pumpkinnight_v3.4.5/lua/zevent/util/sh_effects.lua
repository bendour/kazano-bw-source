/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/


/*
	Randomizes the fly direction of gibs
*/
local function PushGibs(pos,force,offset)
	for k,v in pairs(ents.FindByClass("class C_PhysPropClientside")) do
		if not IsValid(v) then continue end
		if v.zpn_GibUpdated then continue end
		if not zclib.util.InDistance(v:GetPos(), pos, 200) then return false end
		v.zpn_GibUpdated = true

		local phy = v:GetPhysicsObject()
		if IsValid(phy) then
			phy:SetMaterial( "default_silent" )
			phy:SetVelocityInstantaneous((VectorRand(-150, 150) + offset) * force)
			phy:SetAngleVelocityInstantaneous(VectorRand(-500, 500) * force)
		end
	end
end

zclib.NetEvent.AddDefinition("zpn_bomb_explode", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Effect.ParticleEffect("zpn_fireexplosion", ent:GetPos(), angle_zero, ent)
	ent:EmitSound("zpn_bomb_explode")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

zclib.NetEvent.AddDefinition("zpn_bomb_removefuse", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	ent:StopParticlesNamed("zpn_fuse")
end)

zclib.NetEvent.AddDefinition("zpn_partypopper_normal", {
	[1] = {
		type = "entity"
	},
	[2] = {
		type = "vector"
	},
	[3] = {
		type = "angle"
	},
}, function(received)
	local ent = received[1]
	local pos = received[2]
	local ang = received[3]
	if not IsValid(ent) then return end
	if pos == nil then return end
	if ang == nil then return end

	zclib.Effect.ParticleEffect("zpn_pumbkin_shot", pos, ang, ent)
	ent:EmitSound("zpn_partypopper")
end)

zclib.NetEvent.AddDefinition("zpn_partypopper_special", {
	[1] = {
		type = "entity"
	},
	[2] = {
		type = "vector"
	},
	[3] = {
		type = "angle"
	},
}, function(received)
	local ent = received[1]
	local pos = received[2]
	local ang = received[3]
	if not IsValid(ent) then return end
	if pos == nil then return end
	if ang == nil then return end

	zclib.Effect.ParticleEffect(zpn.Theme.PartyPopper_Projectile.effect_burst, pos, ang, ent)
	ent:EmitSound("zpn_partypopper_heavy")
end)

zclib.NetEvent.AddDefinition("zpn_destructable_destroy", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end

	if zpn.Theme.Destructibles.smash_effect then
		zclib.Effect.ParticleEffect(zpn.Theme.Destructibles.smash_effect, ent:GetPos(), ent:GetAngles(), ent)
	end

	if zpn.Theme.Destructibles.smash_sound then
		ent:EmitSound(zpn.Theme.Destructibles.smash_sound)
	end

	ent:GibBreakClient(Vector( math.Rand(0,200), math.Rand(0,200), 200))

	PushGibs(ent:GetPos(),2,vector_origin)

	if ent:GetClass() == "zpn_minion" then
		ent:StopParticlesNamed(zpn.Theme.Minions.effects["zpn_minion"])
		ent:StopParticlesNamed(zpn.Theme.Minions.effects["zpn_minion_eye"])
	end
end)

zclib.NetEvent.AddDefinition("zpn_slapper_open", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end

	zclib.Animation.PlayTransition(ent,"open", 1,"open_idle",1)
	ent:EmitSound("zpn_slapper_open")
end)

zclib.NetEvent.AddDefinition("zpn_slapper_trigger", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end

	zclib.Animation.Play(ent,"trigger", 1)

	timer.Simple(0.1,function()
		if IsValid(ent) then
			ent:EmitSound("zpn_slapper_trigger")
		end
	end)
	if ent.MakeBounch then ent:EmitSound("zpn_slapper_bounce") end

	if ent.OnTrigger then ent:OnTrigger() end

end)

local LootEffects = {
	"zmb_vgui_firework_blue",
	"zmb_vgui_firework_green",
	"zmb_vgui_firework_red",
	"zmb_vgui_firework_yellow",
}
zclib.NetEvent.AddDefinition("zpn_loot_collect", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end

	ent.Smashed = true

	if IsValid(ent.HullModel) then
		zclib.ClientModel.Remove(ent.HullModel)
	end

	zclib.Effect.ParticleEffect("zpn_loot01", ent:GetPos(),angle_zero, nil)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

	if zpn.Theme.Destructibles.smash_sound then
		ent:EmitSound("zpn_loot_collect")
	end

	ent:GibBreakClient(Vector( math.Rand(0,200), math.Rand(0,200), 200))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

	PushGibs(ent:GetPos(),2,vector_origin)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

zclib.NetEvent.AddDefinition("zpn_loot_spawn", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end

	zclib.Effect.ParticleEffect(LootEffects[math.random(#LootEffects)], ent:GetPos(),angle_zero, nil)
end)
