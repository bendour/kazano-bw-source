if not CLIENT then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

zmlab.DropOffIndicators = zmlab.DropOffIndicators or {}

net.Receive("zmlab_AddDropOffHint", function()
	local dropoffPos = net.ReadVector()

	table.insert(zmlab.DropOffIndicators, {
		pos = dropoffPos,
		created = CurTime()
	})

	timer.Simple(zmlab.config.DropOffPoint.DeliverTime, function()
		if zmlab.DropOffIndicators[1] then
			table.remove(zmlab.DropOffIndicators, 1)
		end
	end)
end)

net.Receive("zmlab_RemoveDropOffHint", function()
	if zmlab.DropOffIndicators[1] then
		table.remove(zmlab.DropOffIndicators, 1)
	end
end)

function zmlab.f.methdropoff_indicator2d()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() then
		for k, v in pairs(zmlab.DropOffIndicators) do
			local pos = v.pos:ToScreen()
			local time = math.Round((v.created + zmlab.config.DropOffPoint.DeliverTime) - CurTime())
			local text = zmlab.language.dropoffpoint_title

			if zmlab.f.InDistance(ply:GetPos(), v.pos, 100) then return end

			surface.SetDrawColor(zmlab.default_colors["CircleColor"])
			draw.NoTexture()
			zmlab.f.draw_Circle( pos.x, pos.y, 45, 25)
			draw.DrawText("Time: " .. time, "zmlab_font5", pos.x, pos.y + 5, zmlab.default_colors["TextColor"], TEXT_ALIGN_CENTER)
			draw.DrawText(text, "zmlab_font5", pos.x, pos.y - 10, zmlab.default_colors["TextColor"], TEXT_ALIGN_CENTER)
		end
	end
end

hook.Add("HUDPaint", "a_zmlab_methdropoff_indicator2d", zmlab.f.methdropoff_indicator2d)
