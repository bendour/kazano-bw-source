if SERVER then return end

net.Receive("zwf_Palette_Update", function(len)
	local Palette = net.ReadEntity()
	local weedlist = net.ReadTable()

	if weedlist and istable(weedlist) and IsValid(Palette) then
		if Palette.WeedList == nil then
			Palette.WeedList = {}
		end

		Palette.WeedList = table.Copy(weedlist)
	end
end)
