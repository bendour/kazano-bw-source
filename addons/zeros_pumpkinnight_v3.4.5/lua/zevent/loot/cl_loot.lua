/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.Loot = zpn.Loot or {}
zpn.Loot.List = zpn.Loot.List or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function zpn.Loot.Initialize(Loot)
    zclib.Debug("zpn.Loot.Initialize")
end

function zpn.Loot.OnDraw(Loot)
	Loot:DrawModel()

	if not zpn.Loot.List[Loot] then zpn.Loot.List[Loot] = true end

	if not Loot.Smashed and zclib.util.InDistance(Loot:GetPos(), LocalPlayer():GetPos(), 2000) then
		if not IsValid(Loot.HullModel) then
			local ent = zclib.ClientModel.AddProp()
			if IsValid(ent) then
				ent:SetPos(Loot:GetPos())
				ent:SetModel(Loot:GetModel())
				ent:SetAngles(Loot:GetAngles())
				ent:Spawn()
				ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
				ent:SetNoDraw(true)
				Loot.HullModel = ent
			end
		end
	else
		if IsValid(Loot.HullModel) then
			zclib.ClientModel.Remove(Loot.HullModel)
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

function zpn.Loot.OnRemove(Loot)
	if IsValid(Loot.HullModel) then
		zclib.ClientModel.Remove(Loot.HullModel)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

local CrackMaterial = Material("zerochain/props_christmas/present_cracks")
zclib.Hook.Remove("PostDrawTranslucentRenderables", "zpn.Loot.OnDraw")
zclib.Hook.Add("PostDrawTranslucentRenderables", "zpn.Loot.OnDraw", function(depth, bDrawingSkybox, isDraw3DSkybox)
	if not isDraw3DSkybox then
		for ent, _ in pairs(zpn.Loot.List) do
			if not IsValid(ent) then continue end
			if not IsValid(ent.HullModel) then continue end

			ent.RndColorTick = (ent.RndColorTick or 0) + 1

			local col = HSVToColor(ent.RndColorTick,1,1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

			render.MaterialOverride(CrackMaterial)
			render.SetColorModulation((1/255) * col.r, (1/255) * col.g,(1/255) * col.b)
			ent.HullModel:SetPos(ent:GetPos())
			ent.HullModel:SetAngles(ent:GetAngles())
			ent.HullModel:DrawModel()
			render.MaterialOverride()
			render.SetColorModulation(1, 1, 1)
		end
	end
end)
