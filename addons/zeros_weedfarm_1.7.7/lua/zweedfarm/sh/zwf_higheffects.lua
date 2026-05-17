zwf = zwf or {}
zwf.f = zwf.f or {}

if SERVER then

	//Screeneffects
	util.AddNetworkString("zwf_start_screeneffect")
	function zwf.f.CreateHighEffect(effectID,THC,Duration,ply)

		local effectData = {
			id = effectID,
			thc = THC,
			duration = Duration,
		}

		net.Start("zwf_start_screeneffect")
		net.WriteTable(effectData)
		net.Send(ply)
	end

	util.AddNetworkString("zwf_stop_screeneffect")
	function zwf.f.RemoveHighEffect(ply)
		if IsValid(ply) then
			net.Start("zwf_stop_screeneffect")
			net.Send(ply)
		end
	end
end

if CLIENT then

	// Screeneffects
	local effect_id = 0
	local effect_duration = 0
	local effect_strength = 0
	local effect_intensity = 0

	//Starts our screeneffect
	net.Receive("zwf_start_screeneffect", function(len)

		local effectData = net.ReadTable()

		if effectData == nil or effectData.id == nil or effectData.thc == nil or effectData.duration == nil then return end

		effect_id = effectData.id
		effect_intensity = effectData.thc
		effect_duration = effect_duration + ( 100 * effectData.duration)

		effect_duration = math.Clamp(effect_duration,0,100 * zwf.config.HighEffect.MaxDuration)
	end)

	//Stops our screeneffect
	net.Receive("zwf_stop_screeneffect", function(len)
		effect_duration = 0
		effect_strength = 0
		effect_intensity = 0
		effect_id = 0
		LocalPlayer():SetDSP(0,true)
		if LocalPlayer().zwf_WeedSoundObj and LocalPlayer().zwf_WeedSoundObj:IsPlaying() == true then
			LocalPlayer().zwf_WeedSoundObj:Stop()
		end
	end)

	function zwf.f.HasPlayerHighEffects()
		return effect_id > 0 or effect_duration > 0
	end

	if timer.Exists("zwf_screeneffect_counter") then
		timer.Remove("zwf_screeneffect_counter")
	end

	timer.Create("zwf_screeneffect_counter", 0.1, 0, function()
		if (effect_duration or 0) > 0 then
			effect_duration = effect_duration - 10
		else

			if zwf.f.HasPlayerHighEffects() and IsValid(LocalPlayer()) then
				LocalPlayer():SetDSP(0,true)
				effect_id = 0
				effect_duration = 0
			end
		end
	end)

	local lastSoundStop = 0
	function zwf.f.WeedMusic()

		if zwf.config.Plants[effect_id] == nil or zwf.config.Plants[effect_id].high_music == nil then return end

		local ply = LocalPlayer()
		local weedsound = CreateSound(ply, "zwf_weedmusic0" .. effect_id)


		if effect_duration > 0 then
			if ply.zwf_WeedSoundObj == nil then
				ply.zwf_WeedSoundObj = weedsound
			end

			if ply.zwf_WeedSoundObj:IsPlaying() == false then
				ply.zwf_WeedSoundObj:Play()
				ply.zwf_WeedSoundObj:ChangeVolume(0, 0)
				ply.zwf_WeedSoundObj:ChangeVolume(1, 2)
			end

		else
			if ply.zwf_WeedSoundObj == nil then
				ply.zwf_WeedSoundObj = weedsound
			end

			if ply.zwf_WeedSoundObj:IsPlaying() == true then
				ply.zwf_WeedSoundObj:ChangeVolume(0, 2)
				if ((lastSoundStop or CurTime()) > CurTime()) then return end
				lastSoundStop = CurTime() + 3

				timer.Simple(2, function()
					if IsValid(ply) and ply.zwf_WeedSoundObj and effect_duration <= 0 then
						ply.zwf_WeedSoundObj:Stop()
						ply.zwf_WeedSoundObj = nil
					end
				end)
			end
		end
	end

	hook.Add("RenderScreenspaceEffects", "a_zwf_HighEffect_RenderScreenspaceEffects", function()

		zwf.f.WeedMusic()

		if (effect_duration or 0) > 0 then


			effect_strength = math.Clamp(effect_strength + 100 * FrameTime(),0,effect_duration)

			local strength = math.Clamp((1 / 300) * effect_strength,0,1)


			if IsValid(LocalPlayer()) and effect_intensity > 5 then

				if effect_intensity >= zwf.config.Growing.max_thc * 0.75 then
					LocalPlayer():SetDSP(25,true)
				elseif effect_intensity > zwf.config.Growing.max_thc * 0.5 then
					LocalPlayer():SetDSP(20,true)
				elseif effect_intensity > zwf.config.Growing.max_thc * 0.25 then
					LocalPlayer():SetDSP(3,true)
				elseif effect_intensity > 0 then
					LocalPlayer():SetDSP(15,true)
				end

			end

			local effectData = zwf.config.HighEffect.Effects[zwf.config.Plants[effect_id].high_effect]

			local bloom_strength = 1 / 10 * effect_intensity
			DrawBloom(0, math.Clamp(bloom_strength, 0, 1) * strength, math.Clamp(bloom_strength, 0, 1.5) * strength, math.Clamp(bloom_strength, 0, 1.5) * strength, 15, 0.1, effectData.bloom[1], effectData.bloom[2], effectData.bloom[3])

			local tab = {
				["$pp_colour_addr"] = math.Clamp(math.Clamp(effectData.colormodify["pp_colour_addr"], 0, 1) * strength,0.4,1),
				["$pp_colour_addg"] = math.Clamp(math.Clamp(effectData.colormodify["pp_colour_addg"], 0, 1) * strength,0.4,1),
				["$pp_colour_addb"] = math.Clamp(math.Clamp(effectData.colormodify["pp_colour_addb"], 0, 1) * strength,0.4,1),

				["$pp_colour_brightness"] = effectData.colormodify["pp_colour_brightness"],
				["$pp_colour_contrast"] = math.Clamp(effectData.colormodify["pp_colour_contrast"] * strength,1,2),
				["$pp_colour_colour"] = math.Clamp(effectData.colormodify["pp_colour_colour"] * strength,1,2),

				["$pp_colour_mulr"] = math.Clamp(effectData.colormodify["pp_colour_mulr"], 0, 1),
				["$pp_colour_mulg"] = math.Clamp(effectData.colormodify["pp_colour_mulg"], 0, 1),
				["$pp_colour_mulb"] = math.Clamp(effectData.colormodify["pp_colour_mulb"], 0, 1)
			}

			DrawColorModify(tab)

			local blur_strength = 1 / 25 * effect_intensity
			DrawMotionBlur(math.Clamp(blur_strength, 0, 0.1) * strength, math.Clamp(blur_strength, 0, 2) * strength, 0.01)


			// Display material
			if GetConVar("zwf_cl_vfx_epilepsy"):GetInt() == 0 then

				local count = math.Clamp(math.Round((effect_intensity / 40) * strength), 0, 5)

				for i = 1, count do
					DrawMaterialOverlay(effectData.mat, 0)
				end

				// The refract material
				local ref_strength = (0.05 / zwf.config.Growing.max_thc) * effect_intensity
				ref_strength = ref_strength * strength
				DrawMaterialOverlay(effectData.warp_mat, math.Clamp(ref_strength,0,0.03))
			end
		end
	end)
end
