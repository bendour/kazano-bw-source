if SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

local effect_duration = 0

local IllegalItems = {}

function zwf.f.IllegalItems_Add(_ent)
	local d_data = zwf.config.SnifferSWEP.items[_ent:GetClass()]
	/*
	if (_ent:GetClass() == "zwf_pot" or _ent:GetClass() == "zwf_pot_hydro") then
		if d_data.check(_ent) then
			local plantData = zwf.config.Plants[_ent:GetSeed()]

			table.insert(IllegalItems, {
				ent = _ent,
				pos = _ent:GetPos() + Vector(0, 0, 15),
				color = plantData.color,
				mat = d_data.icon
			})
		end
	end
	*/

	if d_data.check(_ent) then
		table.insert(IllegalItems, {
			ent = _ent,
			pos = _ent:GetPos() + Vector(0, 0, 15),
			color = d_data.color,
			mat = d_data.icon
		})
	end
end

net.Receive("zwf_sniffer_check", function(len)
	IllegalItems = {}

	for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(),zwf.config.SnifferSWEP.distance)) do
		if IsValid(v) and zwf.config.SnifferSWEP.items[v:GetClass()] then
			zwf.f.IllegalItems_Add(v)
		end
	end
	effect_duration = zwf.config.SnifferSWEP.duration * 100
end)


if timer.Exists("zwf_sniffer_counter") then
	timer.Remove("zwf_sniffer_counter")
end

timer.Create("zwf_sniffer_counter", 0.1, 0, function()
	if (effect_duration or 0) > 0 then
		effect_duration = effect_duration - 10
	end
end)

hook.Add("RenderScreenspaceEffects", "a_zwf_SnifferEffect_RenderScreenspaceEffects", function()
	if (effect_duration or 0) > 0 then

		local strength = math.Clamp((1 / 500) * effect_duration, 0, 1)
		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,

			["$pp_colour_brightness"] = -0.1 * strength,
			["$pp_colour_contrast"] = 1 + (0.5 * strength),
			["$pp_colour_colour"] = 1 - (0.5 * strength),

			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0,
		}

		DrawColorModify(tab)

	end
end)

function zwf.f.IllegalItems_Draw()

	if effect_duration <= 0 then return end

	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() then

		for k, v in pairs(IllegalItems) do

			local pos = v.pos:ToScreen()

			if zwf.f.InDistance(ply:GetPos(), v.pos, 100) then return end
			if zwf.f.InDistance(ply:GetPos(), v.pos, zwf.config.SnifferSWEP.distance) == false then return end

			//local dist = ply:GetPos():DistToSqr(v.pos)
			//dist = math.Round(dist)

			//local maxDist = zwf.config.SnifferSWEP.distance * zwf.config.SnifferSWEP.distance


			//local alpha = (255 / maxDist) * (maxDist - dist)

			local strength = math.Clamp((1 / 300) * effect_duration, 0, 1)

			//alpha = 255 * strength

			local color = v.color
			color.a = 255 * strength

			surface.SetDrawColor(color.r,color.g,color.b,color.a)
			surface.SetMaterial(v.mat)
			surface.DrawTexturedRect(pos.x-25, pos.y-25, 50, 50)
		end
	end
end

hook.Add("HUDPaint", "a_zwf_RenderIllegalItems_HUDPaint", zwf.f.IllegalItems_Draw)
