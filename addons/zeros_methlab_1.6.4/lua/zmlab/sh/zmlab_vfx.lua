zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

if SERVER then
	//Screeneffects
	util.AddNetworkString("zmlab_screeneffect")
	function zmlab.f.CreateScreenEffectTable(ply)
		net.Start("zmlab_screeneffect")
		net.Send(ply)
	end

	util.AddNetworkString("zmlab_stop_screeneffects")
	function zmlab.f.StopScreenEffect(ply)
		net.Start("zmlab_stop_screeneffects")
		net.Send(ply)
	end
end

if CLIENT then
	// Screeneffects
	local screeneffect_duration = 0
	local ScreenEffectAmount = 0

	//Starts our screeneffect
	net.Receive("zmlab_screeneffect", function(len)
		screeneffect_duration = zmlab.config.Meth.EffectDuration
		ScreenEffectAmount = zmlab.config.Meth.EffectDuration * 100
	end)

	//Stops our screeneffect
	net.Receive("zmlab_stop_screeneffects", function(len, ply)
		screeneffect_duration = 0
		ScreenEffectAmount = 0
	end)

	if timer.Exists("zmlab_screeneffect_counter") then
		timer.Remove("zmlab_screeneffect_counter")
	end
	timer.Create("zmlab_screeneffect_counter", 0.1, 0, function()
		if (ScreenEffectAmount or 0) > 0 then
			ScreenEffectAmount = ScreenEffectAmount - 10

		else
			if (screeneffect_duration > 0) then
				screeneffect_duration = 0
			end

			if (ScreenEffectAmount > 0) then
				ScreenEffectAmount = 0
			end

			if IsValid(LocalPlayer()) then
				LocalPlayer():SetDSP(0)
			end
		end
	end)


	local lastSoundStop
	function zmlab.f.MethMusic()
		local ply = LocalPlayer()

		if ScreenEffectAmount > 0 then
			if ply.zmlab_MethSoundObj == nil then
				ply.zmlab_MethSoundObj = CreateSound(ply, "sfx_meth_consum_music")
			end

			if ply.zmlab_MethSoundObj:IsPlaying() == false then
				ply.zmlab_MethSoundObj:Play()
				ply.zmlab_MethSoundObj:ChangeVolume(0, 0)
				ply.zmlab_MethSoundObj:ChangeVolume(1, 2)
			end
		else
			if ply.zmlab_MethSoundObj == nil then
				ply.zmlab_MethSoundObj = CreateSound(ply, "sfx_meth_consum_music")
			end

			if ply.zmlab_MethSoundObj:IsPlaying() == true then
				ply.zmlab_MethSoundObj:ChangeVolume(0, 2)
				if ((lastSoundStop or CurTime()) > CurTime()) then return end
				lastSoundStop = CurTime() + 3

				timer.Simple(2, function()
					if (IsValid(ply)) then
						ply.zmlab_MethSoundObj:Stop()
					end
				end)
			end
		end
	end

	hook.Add("RenderScreenspaceEffects", "a_zmlab_RenderScreenspaceEffects", function()
		if zmlab.config.Meth.EffectMusic then
			zmlab.f.MethMusic()
		end

		if (ScreenEffectAmount or 0) > 0 then
			local alpha = 1 / (100 * screeneffect_duration) * ScreenEffectAmount

			LocalPlayer():SetDSP(3)

			DrawBloom(alpha * 0.3, alpha * 2, alpha * 8, alpha * 8, 15, 1, 0, 0.8, 1)
			DrawMotionBlur(0.1 * alpha, alpha, 0)
			DrawSharpen(0.2 * alpha, 10 * alpha)
			DrawSunbeams(1 * alpha, 0.1 * alpha, 0.08 * alpha, 0, 0)

			DrawMaterialOverlay("effects/tp_eyefx/tpeye3", -0.2 * alpha)
			DrawMaterialOverlay("effects/water_warp01", 0.1 * alpha)

			local tab = {}
			tab["$pp_colour_colour"] = 0.5
			tab["$pp_colour_contrast"] = math.Clamp(2 * alpha, 1, 2)
			tab["$pp_colour_brightness"] = math.Clamp(-0.3 * alpha, -1, 1)
			tab["$pp_colour_addb"] = 0.3 * alpha
			tab["$pp_colour_addg"] = 0.2 * alpha
			DrawColorModify(tab)
		end
	end)
end






//zmlab.f.CreateNetEffect(id,data)

// Here we define diffrent effect groups which later make it pretty optimized to create Sound/Particle effects over the network
// The key will be used as the NetworkString
zmlab.NetEffectGroups = {
	["zmlab_crate_close"] = {
		_type = "entity",
		_server = true,
		action = function(ent)

			if CLIENT then
				zmlab.f.ClientAnim(ent, "close", 1)
			else
				zmlab.f.ServerAnim(ent, "close", 1)
			end
		end,
	},
	["zmlab_combiner_load_liquid"] = {
		_type = "entity",
		action = function(ent)
			zmlab.f.ParticleEffectAttach("zmlab_methylamin_fill", PATTACH_POINT_FOLLOW, ent, 1)
			ent:EmitSound("Methylamin_filling")
		end,
	},
	["zmlab_combiner_load_alum"] = {
		_type = "entity",
		action = function(ent)
			zmlab.f.ParticleEffectAttach("zmlab_aluminium_fill01", PATTACH_POINT_FOLLOW, ent, 1)
			ent:EmitSound("Aluminium_filling")
		end,
	},
	["zmlab_breakice"] = {
		action = function(pos)
			sound.Play(zmlab.GlobalSounds["zmlab_breakice"][math.random(#zmlab.GlobalSounds["zmlab_breakice"])], pos, 60, math.random(70,90), 0.5)
			zmlab.f.ParticleEffect("zmlab_meth_breaking", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["zmlab_sell_small"] = {
		action = function(pos)

			sound.Play(zmlab.GlobalSounds["zmlab_sell"], pos, 60, 100, 1)
			zmlab.f.ParticleEffect("zmlab_sell_effect_small", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["zmlab_sell_big"] = {
		action = function(pos)

			sound.Play(zmlab.GlobalSounds["zmlab_sell"], pos, 60, 100, 1)
			zmlab.f.ParticleEffect("zmlab_sell_effect_big", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["zmlab_crate_fill"] = {
		_type = "entity",
		action = function(ent)

			zmlab.f.ParticleEffectAttach("zmlab_meth_filling", PATTACH_POINT_FOLLOW, ent, 1)
			ent:EmitSound("progress_fillingcrate")
		end,
	},
	["zmlab_crate_collect"] = {
		_type = "entity",
		action = function(ent)

			ent:EmitSound("progress_fillingcrate")
		end,
	},
	["zmlab_tray_convert"] = {
		_type = "entity",
		action = function(ent)

			ent:EmitSound("ConvertingSludge")
		end,
	},

	["zmlab_combiner_clean"] = {
		action = function(pos)
			sound.Play(zmlab.GlobalSounds["zmlab_clean"][math.random(#zmlab.GlobalSounds["zmlab_clean"])], pos, 60, math.random(90,95), 1)
			zmlab.f.ParticleEffect("zmlab_cleaning", pos, Angle(0,0,0), Entity(1))
		end,
	},
}

if SERVER then


	// Creates a network string for all the effect groups
	for k, v in pairs(zmlab.NetEffectGroups) do
		util.AddNetworkString("zmlab_fx_" .. k)
	end

	// Sends a Net Effect Msg to all clients
	function zmlab.f.CreateNetEffect(id,data)

		// Data can be a entity or position

		local EffectGroup = zmlab.NetEffectGroups[id]

		// Some events should be called on server to
		if EffectGroup._server then
			EffectGroup.action(data)
		end

		net.Start("zmlab_fx_" .. id)
		if EffectGroup._type == "entity" then
			net.WriteEntity(data)
		else
			net.WriteVector(data)
		end
		net.Broadcast()
	end

	// Animation
	function zmlab.f.ServerAnim(prop, anim, speed)
		local sequence = prop:LookupSequence(anim)
		prop:SetCycle(0)
		prop:ResetSequence(sequence)
		prop:SetPlaybackRate(speed)
		prop:SetCycle(0)
	end

	function zmlab.f.GenericEffect(effect,vPoint)
		local effectdata = EffectData()
		effectdata:SetStart(vPoint)
		effectdata:SetOrigin(vPoint)
		effectdata:SetScale(1)
		util.Effect(effect, effectdata)
	end
end

if CLIENT then

	// Animation
	function zmlab.f.ClientAnim(prop, anim, speed)
		local sequence = prop:LookupSequence(anim)
		prop:SetCycle(0)
		prop:ResetSequence(sequence)
		prop:SetPlaybackRate(speed)
		prop:SetCycle(0)
	end

	function zmlab.f.ParticleEffect(effect, pos, ang, ent)
		if GetConVar("zmlab_cl_vfx_particleeffects"):GetInt() == 1 then
			ParticleEffect(effect, pos, ang, ent)
		end
	end

	function zmlab.f.ParticleEffectAttach(effect, enum, ent, attachid)
		if GetConVar("zmlab_cl_vfx_particleeffects"):GetInt() == 1 then
			ParticleEffectAttach(effect, enum, ent, attachid)
		end
	end

	for k, v in pairs(zmlab.NetEffectGroups) do
		net.Receive("zmlab_fx_" .. k, function(len)
			zmlab.f.Debug("zmlab_fx_" .. k .. " Len: " .. len)

			if v._type == "entity" then
				local ent = net.ReadEntity()

				if IsValid(ent) then

					zmlab.NetEffectGroups[k].action(ent)
				end
			else
				local pos = net.ReadVector()
				if pos then
					zmlab.NetEffectGroups[k].action(pos)
				end
			end
		end)
	end
end
