/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if SERVER then return end
zpn = zpn or {}
local ply = LocalPlayer()

local function HasToolActive()
	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

local zpn_PumpkinSpawn_Hints = {}

net.Receive("zpn_PumpkinSpawner_showall", function(len)
	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)

	ply = LocalPlayer()

	if positions then
		zpn_PumpkinSpawn_Hints = positions
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

		zclib.Hook.Remove("PostDrawTranslucentRenderables", "zpn_ToolGun")
		zclib.Hook.Add("PostDrawTranslucentRenderables", "zpn_ToolGun", function()
			if HasToolActive() then
				local tr = ply:GetEyeTrace()

				if tr.Hit and not IsValid(tr.Entity) and zclib.util.InDistance(tr.HitPos, ply:GetPos(), 300) then
					render.SetColorMaterial()
					render.DrawWireframeSphere(tr.HitPos, 1, 4, 4, zpn.Theme.Design.color01, false)
				end
			else
				zclib.Hook.Remove("PostDrawTranslucentRenderables", "zpn_ToolGun")
			end
		end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

		zclib.Hook.Remove("HUDPaint", "zpn_PumpkinSpawnHints")
		zclib.Hook.Add("HUDPaint", "zpn_PumpkinSpawnHints", function()
			if HasToolActive() and zpn_PumpkinSpawn_Hints and table.Count(zpn_PumpkinSpawn_Hints) > 0 then
				for k, v in pairs(zpn_PumpkinSpawn_Hints) do
					if v then
						local pos = v:ToScreen()
						local size = 10
						surface.SetDrawColor(zpn.Theme.Design.color01)
						surface.DrawRect(pos.x - (size * zclib.wM) / 2, pos.y - (size * zclib.hM) / 2, size * zclib.wM, size * zclib.hM)
					end
				end
			else
				zclib.Hook.Remove("HUDPaint", "zpn_PumpkinSpawnHints")
			end
		end)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

net.Receive("zpn_PumpkinSpawner_hideall", function(len)
	zpn_PumpkinSpawn_Hints = {}
	zclib.Hook.Remove("PostDrawTranslucentRenderables", "zpn_ToolGun")
	zclib.Hook.Remove("HUDPaint", "zpn_PumpkinSpawnHints")
end)
