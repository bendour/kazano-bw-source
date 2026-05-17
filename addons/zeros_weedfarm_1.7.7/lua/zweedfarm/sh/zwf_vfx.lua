zwf = zwf or {}
zwf.f = zwf.f or {}




// Here we define diffrent effect groups which later make it pretty optimized to create Sound/Particle effects over the network
// The key will be used as the NetworkString
zwf.NetEffectGroups = {
	["zwf_joint_stop"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_joint_stop",ent)
		end,
	},
	["zwf_joint_start"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_joint_start",ent)
		end,
	},
	["zwf_cooking_flour"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_cooking_flour",ent)
		end,
	},
	["zwf_grab_weed"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_grab_weed",ent)
		end,
	},
	["zwf_cooking_dough"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_cooking_dough",ent)
		end,
	},
	["zwf_mixerbowl_add"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_mixerbowl_add",ent)
		end,
	},
	["zwf_mixerbowl_remove"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_mixerbowl_remove",ent)
		end,
	},
	["zwf_fuel_fill"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_fuel_fill",ent)
		end,
	},
	["zwf_generator_start_sucess"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_generator_start_sucess",ent)
		end,
	},
	["zwf_generator_start_fail"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_generator_start_fail",ent)
		end,
	},
	["zwf_generator_repair"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_generator_repair",ent)
			zwf.f.ParticleEffect("zwf_heal", ent:GetPos(), ent:GetAngles(), ent)
		end,
	},
	["zwf_muffin_eat"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_muffin_eat",ent)
		end,
	},
	["zwf_npc_wrongjob"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_npc_wrongjob",ent)
		end,
	},
	["zwf_selling"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_selling",ent)
		end,
	},
	["zwf_selling_effect"] = {
		action = function(pos)
			sound.Play(zwf.GlobalSounds["zwf_cash01"], pos, 75, 100, 1)
			zwf.f.ParticleEffect("zwf_sell", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["zwf_npc_sell"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_npc_sell",ent)
		end,
	},
	["zwf_place_jar"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_place_jar",ent)
		end,
	},
	["zwf_plant_heal"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_plant_heal",ent)
			zwf.f.ParticleEffect("zwf_heal", ent:GetPos(), ent:GetAngles(),ent)
		end,
	},
	["zwf_cable_connect"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_cable_connect",ent)
		end,
	},
	["zwf_cable_select"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_cable_select",ent)
		end,
	},
	["zwf_cable_deconnect"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_cable_deconnect",ent)
		end,
	},
	["zwf_sniff"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_sniff",ent)
		end,
	},
	["zwf_water_refill"] = {
		_type = "entity",

		action = function(ent)
			zwf.f.EmitSoundENT("zwf_water_refill",ent)
		end,
	},
}


if SERVER then


	// Creates a network string for all the effect groups
	for k, v in pairs(zwf.NetEffectGroups) do
		util.AddNetworkString("zwf_fx_" .. k)
	end

	// Sends a Net Effect Msg to all clients
	function zwf.f.CreateNetEffect(id,data)

		// Data can be a entity or position

		local EffectGroup = zwf.NetEffectGroups[id]

		// Some events should be called on server to
		if EffectGroup._server then
			EffectGroup.action(data)
		end

		net.Start("zwf_fx_" .. id)
		if EffectGroup._type == "entity" then
			net.WriteEntity(data)
		else
			net.WriteVector(data)
		end
		net.Broadcast()
	end



	// Player Animation
	util.AddNetworkString("zwf_PlayerSmokeAnim_Start")
	function zwf.f.PlayerSmokeAnim_Start(ply)
		net.Start("zwf_PlayerSmokeAnim_Start")
		net.WriteEntity(ply)
		net.Broadcast()
	end

	util.AddNetworkString("zwf_PlayerSmokeAnim_Stop")
	function zwf.f.PlayerSmokeAnim_Stop(ply)
		net.Start("zwf_PlayerSmokeAnim_Stop")
		net.WriteEntity(ply)
		net.Broadcast()
	end


	// Animation
	util.AddNetworkString("zwf_AnimEvent")

	local function ServerAnim(prop, anim, speed)
		local sequence = prop:LookupSequence(anim)
		prop:SetCycle(0)
		prop:ResetSequence(sequence)
		prop:SetPlaybackRate(speed)
		prop:SetCycle(0)
	end

	function zwf.f.CreateAnimTable(prop, anim, speed)
		//ServerAnim(prop, anim, speed)
		net.Start("zwf_AnimEvent")
		local animInfo = {}
		animInfo.anim = anim
		animInfo.speed = speed
		animInfo.parent = prop
		net.WriteTable(animInfo)
		net.SendPVS(prop:GetPos())
	end

	//Effects
	util.AddNetworkString("zwf_FX")
	function zwf.f.CreateEffectTable(effect, _sound, parent, angle, position, attach)
		local effectInfo = {}

		if sound and effect == nil then
			effectInfo.sound = _sound
			effectInfo.parent = parent
		else

			effectInfo.effect = effect
			effectInfo.sound = _sound
			effectInfo.pos = position
			effectInfo.ang = angle
			effectInfo.parent = parent
			effectInfo.attach = attach
		end

		net.Start("zwf_FX")
		net.WriteTable(effectInfo)
		net.SendPVS(parent:GetPos())
	end

	function zwf.f.GenericEffect(effect,vPoint)
		local effectdata = EffectData()
		effectdata:SetStart(vPoint)
		effectdata:SetOrigin(vPoint)
		effectdata:SetScale(1)
		util.Effect(effect, effectdata)
	end


	// Creates the bong exhale effect
	util.AddNetworkString("zwf_SmokeEffect")
	function zwf.f.SmokeEffect(weedid,amount,ply,bongid)
		local BongInfo = {}
		BongInfo.weedid = weedid
		BongInfo.amount = amount
		BongInfo.bongid = bongid
		BongInfo.ply = ply

		net.Start("zwf_SmokeEffect")
		net.WriteTable(BongInfo)
		net.SendPVS(ply:GetPos())
	end
end

if CLIENT then

	// Player Animation
	net.Receive("zwf_PlayerSmokeAnim_Start", function(len)
		local ply = net.ReadEntity()

		if IsValid(ply) then

			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_TAUNT_LAUGH, false )
		end
	end)

	net.Receive("zwf_PlayerSmokeAnim_Stop", function(len)
		local ply = net.ReadEntity()

		if IsValid(ply) then
			ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
		end
	end)


	// Animation
	function zwf.f.ClientAnim(prop, anim, speed)
		local sequence = prop:LookupSequence(anim)
		prop:SetCycle(0)
		prop:ResetSequence(sequence)
		prop:SetPlaybackRate(speed)
		prop:SetCycle(0)
	end

	net.Receive("zwf_AnimEvent", function(len, ply)
		local animInfo = net.ReadTable()

		if (animInfo and IsValid(animInfo.parent) and animInfo.anim) then
			zwf.f.ClientAnim(animInfo.parent, animInfo.anim, animInfo.speed)
		end
	end)

	// Effects
	net.Receive("zwf_FX", function(len, ply)

		local effectInfo = net.ReadTable()
		zwf.f.Debug("FX Net Length: " .. len)

		if effectInfo and IsValid(effectInfo.parent) then

			if (effectInfo.sound) then
				zwf.f.EmitSoundENT(effectInfo.sound,effectInfo.parent)
			end

			if (effectInfo.effect and zwf.f.InDistance(LocalPlayer():GetPos(), effectInfo.parent:GetPos(), 500)) then

				if (effectInfo.attach) then

					zwf.f.ParticleEffectAttach(effectInfo.effect, PATTACH_POINT_FOLLOW, effectInfo.parent, effectInfo.attach)
				else

					zwf.f.ParticleEffect(effectInfo.effect, effectInfo.pos, effectInfo.ang, effectInfo.parent)
				end
			end
		end
	end)

	// Effects
	net.Receive("zwf_SmokeEffect", function(len)

		local BongInfo = net.ReadTable()

		if GetConVar("zwf_cl_vfx_exhaleeffect"):GetInt() == 0 then return end


		if BongInfo == nil then return end
		if BongInfo.weedid  == nil then return end
		if BongInfo.amount  == nil then return end
		if BongInfo.bongid  == nil then return end
		if BongInfo.ply  == nil then return end

		local ply  = BongInfo.ply



		if IsValid(ply) and zwf.f.InDistance(LocalPlayer():GetPos(), ply:GetPos(), 500) then

			zwf.f.EmitSoundENT("zwf_bong_exhale_short", ply)

			local attach = ply:GetAttachment(ply:LookupAttachment("mouth"))

			if attach == nil then return end

			local pos = attach.Pos

			if ply.zwf_SmokeEmitter == nil or ply.zwf_SmokeEmitter == NULL then
				ply.zwf_SmokeEmitter = ParticleEmitter( pos , false )
			end


			local UseCount


			if BongInfo.bongid == 25 then
				UseCount = math.Round(zwf.config.DoobyTable.WeedPerJoint / zwf.config.Bongs.Use_Amount)
			else
				local SWEPData = zwf.config.Bongs.items[BongInfo.bongid]

				UseCount = math.Round(SWEPData.hold_amount / zwf.config.Bongs.Use_Amount)
			end

			local effect_length = (3 / UseCount) * BongInfo.amount

			if effect_length >= 3 then
				zwf.f.EmitSoundENT("zwf_bong_exhale_long", ply)
			elseif effect_length >= 1.5 then
				zwf.f.EmitSoundENT("zwf_bong_exhale_mid", ply)
			else
				zwf.f.EmitSoundENT("zwf_bong_exhale_short", ply)
			end

			local ParticleCount = effect_length / 0.05

			local delay = 0.05

			for i = 1,math.Round(ParticleCount) do

				timer.Simple(delay,function()
					if IsValid(ply) and ply.zwf_SmokeEmitter then
						attach = ply:GetAttachment(ply:LookupAttachment("mouth"))

						if attach then

							pos = attach.Pos
							local vel = attach.Ang:Forward() * 100

							local particle = ply.zwf_SmokeEmitter:Add("zerochain/zwf/particle/zwf_skankcloud", pos)
							particle:SetVelocity(vel)
							particle:SetAngles( Angle(math.random(0,360),math.random(0,360),math.random(0,360)) )
							particle:SetDieTime(math.random(2,9))
							particle:SetStartAlpha(150)
							particle:SetEndAlpha(0)
							particle:SetStartSize(math.random(1,3))
							particle:SetEndSize(math.random(50,75))

							local particleColor = zwf.default_colors["white01"]
							particleColor = zwf.config.Plants[BongInfo.weedid].color

							particle:SetColor(particleColor.r, particleColor.g, particleColor.b)
							particle:SetGravity(Vector(0, 0, -5))
							particle:SetAirResistance(55)
						end
					end
				end)
				delay = delay + 0.05
			end

			timer.Simple(effect_length,function()
				if IsValid(ply) and ply.zwf_SmokeEmitter and ply.zwf_SmokeEmitter ~= NULL then

					ply.zwf_SmokeEmitter:Finish()
					ply.zwf_SmokeEmitter = NULL
				end
			end)

		end
	end)


	function zwf.f.ParticleEffect(effect, pos, ang, ent)
		if GetConVar("zwf_cl_vfx_particleeffects"):GetInt() == 1 then
			ParticleEffect(effect, pos, ang, ent)
		end
	end

	function zwf.f.ParticleEffectAttach(effect, enum, ent, attachid)
		if GetConVar("zwf_cl_vfx_particleeffects"):GetInt() == 1 then
			ParticleEffectAttach(effect, enum, ent, attachid)
		end
	end

	for k, v in pairs(zwf.NetEffectGroups) do
		net.Receive("zwf_fx_" .. k, function(len)
			zwf.f.Debug("zwf_fx_" .. k .. " Len: " .. len)

			if v._type == "entity" then
				local ent = net.ReadEntity()

				if IsValid(ent) then

					zwf.NetEffectGroups[k].action(ent)
				end
			else
				local pos = net.ReadVector()
				if pos then
					zwf.NetEffectGroups[k].action(pos)
				end
			end
		end)
	end
end
