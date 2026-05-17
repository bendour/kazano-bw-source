/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.Shop = zpn.Shop or {}

/*
	Returns the config data of the specified item
*/
function zpn.Shop.GetItemData(id)
	return zpn.config.Shop[id]
end

/*
	Returns the name of a item listed in the shop
*/
function zpn.Shop.GetItemName(id)
	local data = zpn.Shop.GetItemData(id)
	if not data then return "Unknown" end

	if data.type == "type_voidcase_item" then
		local item = VoidCases.Config.Items[data.item_id]
		if item and item.name then return item.name end
	end

	if data.name then return data.name end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	return "Unknown"
end

/*
	Returns the description of a item listed in the shop
*/
function zpn.Shop.GetItemDescription(id)
	local data = zpn.Shop.GetItemData(id)
	if not data then return "Unknown" end

	if data.desc then return data.desc end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

	return ""
end

/*
	Returns the name of a item listed in the shop
*/
function zpn.Shop.DrawItemImage(id,parent)
	local data = zpn.Shop.GetItemData(id)
	if not data then return end

	local pnl

	if data.type == "type_easyskins" then

		local _,skin_id = SH_EASYSKINS.GetSkinByName(data.skin_name)
		if skin_id == nil then return end

		local skin = SH_EASYSKINS.GetSkin(skin_id)
		if skin == nil then return end

		local skinpath =  skin.material.path
		if skinpath == nil then return end

		local image = CL_EASYSKINS.VMTToUnlitGeneric(skinpath)
		if image == nil then return end

		pnl = vgui.Create("DImage", parent)
		pnl:Dock(FILL)
		pnl:SetVisible(true)
		pnl:SetMaterial(image)

		return pnl
	end

	local mdl_path, mdl_skin, mdl_fov, mdl_ang, mdl_color = data.model, data.model_skin or 0, data.model_fov or 25, data.model_angle or Angle(0, 90, 0), data.model_color or color_white
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	if data.type == "type_voidcase_item" then
		local item = VoidCases.Config.Items[data.item_id]
		if item and item.info then
			if item.info.icon then mdl_path = item.info.icon end
			if item.info.caseColor then mdl_color = item.info.caseColor end
		end
	end

	if not mdl_path then return end

	pnl = vgui.Create("DModelPanel", parent)
	pnl:Dock(FILL)
	pnl:SetModel(mdl_path)
	pnl:SetColor(color_white)
	pnl:SetDirectionalLight( BOX_TOP, color_white )
	pnl:SetDirectionalLight( BOX_FRONT, color_white )

	pnl.Entity:SetSkin(mdl_skin)
	pnl.Entity:SetAngles(mdl_ang)
	pnl:SetColor(mdl_color)

	local size1, size2 = pnl.Entity:GetRenderBounds(0, 0)
	local size = (-size1 + size2):Length()
	pnl:SetFOV(mdl_fov)
	pnl:SetCamPos(Vector(size * 2, size * 1, size * 1))
	pnl:SetLookAt((size1 + size2) / 2)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

	return pnl
end


/*
	This will be used to fix up purchasetype ids in the shop/loot config
	If it detects that the purchase type is a number then it translates it to the correct string id
*/
local IDConversion = {
	[1] = "type_entity",
	[2] = "type_weapon",
	[3] = "type_health",
	[4] = "type_armor",
	[5] = "type_sh_acc",
	[6] = "type_pointshop01",
	[7] = "type_pointshop02_standard",
	[8] = "type_pointshop02_premium",
	[9] = "type_bu3",
	[10] = "type_underdone",
	[11] = "type_easyskins",
	[12] = "type_mtokens",
	[13] = "type_ass",
	[14] = "type_santosrp_giveitem",
	[15] = "type_wos_item",
	[16] = "type_wos_points",
	[17] = "type_wos_xp",
	[18] = "type_wos_level",
	[19] = "type_vrondakis_xp",
	[20] = "type_vrondakis_level",
	[21] = "type_glorified_xp",
	[22] = "type_glorified_level",
	[23] = "type_essentials_xp",
	[24] = "type_essentials_level",
	[25] = "type_elite_xp",
	[26] = "type_sreward_token",
	[27] = "type_zpc2_coin",
	[28] = "type_lua",
}

// Fix up old ids to new ids
for k,v in pairs(zpn.config.Shop) do
	if v.type and isnumber(v.type) then
		v.type = IDConversion[v.type]
	end
end

for k,v in pairs(zpn.config.Loot) do
	if v.type and isnumber(v.type) then
		v.type = IDConversion[v.type]
	end
end
