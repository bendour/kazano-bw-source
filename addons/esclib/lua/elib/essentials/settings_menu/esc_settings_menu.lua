local max = math.max
local min = math.min


local function tablesAreEqual(table1, table2)
	for k, v in pairs(table1) do
		if type(v) ~= type(table2[k]) then return false end
		if istable(v) and istable(table2[k]) then
			if not tablesAreEqual(v, table2[k]) then
				return false
			end
		elseif table2[k] ~= v then
			return false
		end
	end

	for k, _ in pairs(table2) do
		if table1[k] == nil then
			return false
		end
	end

	return true
end

local function VarsIsEqual(var1, var2)
	if type(var1) ~= type(var2) then return false end
	if istable(var1) and istable(var2) then return tablesAreEqual(var1, var2) end
	return var1 == var2
end


-------------
--# PANEL #--
-------------
local settab = settab or nil
function esclib:closesettings()
	if IsValid(settab) then
		settab:Remove()
		return true
	end
	return false
end

function esclib:opensettings(naddon, skip_anim)
	esclib:closesettings()

	local skin = esclib.addon:GetCurrentSkin()
	local clr = skin.colors
	local scrw, scrh = esclib.scrw, esclib.scrh
	local addons = esclib:GetAddons() or {}
	local addoncount = 0

	local c_addonpnl = nil
	local c_themepanel = nil

	for k,v in pairs(addons) do
		addoncount = addoncount + 1
	end

	local needaddon
	local needrestart = false

	if naddon then
		if not isstring(naddon) then
			naddon = tostring(naddon)
		end
		naddon = string.lower(naddon)
		
		if esclib:GetAddons()[naddon] then
			needaddon = true
		end
	end

	settab = vgui.Create("EditablePanel")
	if not skip_anim then
		settab:SetAlpha(0)
		settab:AlphaTo(255,esclib.addon:GetVar("animtime") or 0.1)
	else
		settab:SetAlpha(255)
	end
	settab:SetSize(scrw,scrh)
	settab:SetText("")
	settab:MakePopup()
	settab:SetKeyBoardInputEnabled(false)
	local draw_blur = esclib.addon:GetVar("drawblur")

	local setbutton = settab:Add("DButton")
	setbutton:SetSize(scrw,scrh)
	setbutton:SetText("")
	setbutton.Paint = nil

	local version = string.format("%s v%s", esclib.addon:GetBranch() or "", esclib.addon:GetVersion() or "")
	local hash = esclib:GetServerHash()

	local font = esclib:AdaptiveFont("esclib", 20, 500)
	local font_h = draw.GetFontHeight(font)
	local gradient_text = esclib.draw:GradientText(esclib.addon:GetName(), esclib:AdaptiveFont("esclib", 24, 500), Color(111,255,27), Color(0,255,128))

	local icon = esclib:GetMaterial("cog.png")
	local icon_tall = gradient_text["info"]["text_h"] + draw.GetFontHeight(font) * 2 + 6

	local btn = settab:Add("esclib.button")
	btn:SetSize(icon_tall*0.8, icon_tall*0.8)
	btn:SetText("")
	btn:SetIcon(icon)
	btn:SetPos(
		settab:GetWide()-btn:GetWide()-10, 
		settab:GetTall()-icon_tall*0.5-btn:GetTall()*0.5-5
	)
	btn:SetMouseInputEnabled(true)
	btn:SetIconSize(1.5)
	btn:SetBackgroundColor(color_transparent)
	btn:SetBackgroundHoverColor(color_transparent)
	function btn:DoClick()
		esclib:closesettings()
		esclib:opensettings("esclib")
	end

	local offset_x = btn:GetWide()
	function settab:Paint(w,h)
		if draw_blur then
			esclib.draw:Blur(self,6)
		end

		draw.RoundedBox(0, 0, 0, w, h, clr.background.col)

		gradient_text:Draw(w-offset_x-20, h-font_h*2-10, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		draw.SimpleText(version, font, w-offset_x-20, h-font_h-10, clr.frame.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText("SVUID "..hash, font, w-offset_x-20, h-7, clr.frame.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	if esclib.addon:GetVar("debug") then

		local offset = 5

		local text = "DEBUG MODE ACTIVE"
		local font = esclib:AdaptiveFont("esclib", 24, 500)
		local textw, texth = esclib.util:TextSize(text, font)
		local dbg_btn = setbutton:Add("esclib.button")
		dbg_btn:SetSize(textw+20, texth+5)
		dbg_btn:SetPos(offset, 5)
		dbg_btn:SetButtonText(text)
		dbg_btn:SetFont(font)
		dbg_btn:SetMouseInputEnabled(false)
		offset = offset + textw+25


		local text = "Fonts"
		font = esclib:AdaptiveFont("esclib", 24, 500)
		textw, texth = esclib.util:TextSize(text, font)

		dbg_btn = setbutton:Add("esclib.button")
		dbg_btn:SetSize(textw+20, texth+5)
		dbg_btn:SetPos(offset, 5)
		dbg_btn:SetButtonText(text)
		dbg_btn:SetFont(font)
		function dbg_btn:DoClick()
			local fonts = table.GetKeys(esclib.fonts.list)
			local count = #fonts
			if count < 1 then return end
			table.sort(fonts, function(a, b) return a:upper() < b:upper() end)

			local pnl = esclib:GeneratePopWindow(false)
			pnl:SetSize(esclib.scrw*0.7,esclib.scrh*0.8)
			pnl:SetPos(esclib.scrw*0.5 - pnl:GetWide()*0.5, esclib.scrh*0.5 - pnl:GetTall()*0.5)

			pnl:SetTitle(text.." ("..count..")")
			local content = pnl:GetContent()
			content:InvalidateParent()
			local scroll = content:Add("esclib.scrollpanel")
			scroll:SetSize(content:GetWide(),content:GetTall())


			local list = scroll:Add("DIconLayout")
			list:SetY(5)
			list:SetSize(content:GetWide(),content:GetTall()-10)
			list:SetSpaceY(5)
			list:SetBorder(esclib:AdaptiveSize(30))

			local adafont = esclib:AdaptiveFont("esclib", 20, 500)
			for id,font in pairs(fonts) do
				local text = "Preview 12345"
				local textw,texth = esclib.util:TextSize(text,font)

				local font_pnl = list:Add("DPanel")
				function font_pnl:Paint(w,h)
					draw.RoundedBox(0,0,0,w,h,clr.frame.accent)
				
					draw.SimpleText(id..". ["..font.."]",adafont, 5, 5, clr.frame.text_gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end

				local textw2,texth2 = esclib.util:TextSize(id,adafont)
				font_pnl:SetSize(list:GetWide()-list:GetBorder()*2, max(texth+6,texth2+6)+20)

				local font_lbl = font_pnl:Add("DLabel")
				font_lbl:SetSize(font_pnl:GetWide()-15, font_pnl:GetTall())
				font_lbl:SetX(textw2+15)
				font_lbl:SetY(10)
				font_lbl:SetText(text)
				font_lbl:SetFont(font)
				font_lbl:SetColor(clr.frame.text_hover)
			end

		end
		offset = offset + textw+25
	end

	local main = vgui.Create("esclib.frame", settab)
	if needaddon then main:Hide() end
	main:SetSize(scrw*0.5,scrh*0.6)
	main:SetPos(scrw*0.5 - main:GetWide()*0.5, scrh*0.5 - main:GetTall()*0.5)
	main:SetIcon(esclib:GetMaterial("cog.png"))
	main:SetTitle(esclib.addon:Translate("tab_settings"))
	function main:OnClose(callback)
		if IsValid(settab.c_themepanel) then settab.c_themepanel:Remove() end

		if IsValid(settab.c_addonpnl) then settab.c_addonpnl:Remove() end

		local animtime = esclib.addon:GetVar("animtime") or 0
		settab:AlphaTo(0,animtime,0,function()
			if callback then callback() end
			if IsValid(settab) then
				settab:Remove()
				return
			end
			if IsValid(main) then
				main:Remove()
			end
		end)
		gui.EnableScreenClicker(false)
	end
	function main:Close()
		self:OnClose()
		self:Remove()
	end

	local function settings_on_close_any(pnl)
		local animtime = skip_anim and 0 or (esclib.addon:GetVar("animtime") or 0)

		if IsValid(settab.c_themepanel) then
			if pnl ~= settab.c_themepanel then
				if settab.c_themepanel.OnClose then settab.c_themepanel:OnClose(self) end
			end
			settab.c_themepanel:AlphaTo(0,animtime,0,function()
				if IsValid(settab.c_themepanel) then settab.c_themepanel:Remove() end
			end)

			if IsValid(c_addonpnl) then
				c_addonpnl:Show()
				c_addonpnl:SetAlpha(0)
				c_addonpnl:AlphaTo(255,animtime)
			end
			return true
		end

		if IsValid(c_addonpnl) then
			if needaddon then
				main:Close()
				return
			end

			c_addonpnl:AlphaTo(0,animtime,0,function()
				c_addonpnl:Remove()
			end)
		end

		if not main:IsVisible() then
			main:Show()
			main:SetAlpha(0)
			main:AlphaTo(255,animtime)
		else
			main:Close()
		end

		return true
	end

	function setbutton:DoClick()
		if settings_on_close_any() then return end
		main:Close()
	end

	local content = main:GetContent()
	local scroll = content:Add("esclib.scrollpanel")
	scroll:SetSize(content:GetWide(),content:GetTall())

	local list = scroll:Add("DIconLayout")
	list:SetWide(content:GetWide())
	list:SetSpaceY(esclib:AdaptiveSize(10))
	list:SetSpaceX(list:GetSpaceY())
	list:SetBorder(esclib:AdaptiveSize(15))
	list:SetStretchHeight(true)

	local addon_list = {}
	for uid,addon in pairs(addons) do
		table.insert(addon_list, addon)
	end
	table.sort(addon_list, function(a,b)
		return a:GetSortOrder() < b:GetSortOrder()
	end)

	local total_height = 0
	for addon_num,add in ipairs(addon_list) do
		local uid = add.info.uid

		------------------
		--# ALL ADDONS #--
		------------------
		local name_font = esclib:AdaptiveFont("esclib", 24, 500)

		local addpan = list:Add("DButton")
		addpan:SetWide(content:GetWide()*0.25-list:GetBorder())
		addpan:SetTall(addpan:GetWide()+draw.GetFontHeight(name_font)+esclib:AdaptiveSize(20))
		addpan:SetText("")

		total_height = total_height + addpan:GetTall() + list:GetSpaceY()

		local drawicon = false
		if type((add.info.thumbnail or "")) == "IMaterial" then
			drawicon = true
		end

		local version = string.format("%s v%s", add:GetBranch() or "", add:GetVersion() or "")
		local version_wide, version_height = esclib.util:TextSize(version, esclib:AdaptiveFont("esclib", 16, 500))

		local font = esclib:AdaptiveFont("esclib", 16, 500)
		function addpan:Paint(w,h)
			local hovered = self:IsHovered()
			draw.RoundedBox(8, 0, 0, w, h, hovered and add.info.color or clr.button.hover)
			draw.RoundedBox(6, 2, 2, w - 4, h - 4, hovered and clr.frame.bg or clr.button.main)

			--version
			draw.SimpleText(version, font, w-version_wide-15, 10, clr.frame.text)
		end

		local icon_pnl = addpan:Add("DPanel")
		icon_pnl:Dock(TOP)
		local margin = esclib:AdaptiveSize(5)
		icon_pnl:SetTall(addpan:GetWide()-margin*2)
		icon_pnl:DockMargin(margin,margin,margin,margin)
		icon_pnl:SetMouseInputEnabled(false)
		local poly = nil
		function icon_pnl:Paint(w,h)
			esclib.draw:Mask(function() --draw poly
				if not poly then
					poly = esclib.util:PrecacheRoundedPoly(0, 0, w, h, 6, 3)
				end
				draw.NoTexture();
				surface.SetDrawColor( color_white )
				surface.DrawPoly( poly )
			end, 
			function() --draw main
				if drawicon then
					esclib.draw:Material(0,0,w,w,clr.default.white , add.info.thumbnail)
				else
					draw.RoundedBox(0,0,0, w, w, clr.frame.text)
				end
			end,false)

			esclib.draw:ShadowText(version, font, w-version_wide-15, 10, clr.default.white)
		end

		local info_pnl = addpan:Add("DPanel")
		info_pnl:Dock(FILL)
		info_pnl:SetMouseInputEnabled(false)
		function info_pnl:Paint(w,h)
			draw.SimpleText(add.info.name, name_font, w*0.5-2, h*0.5-3, clr.frame.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-------------------
		--# EDIT ADDONS #--
		-------------------
		local cur_realm = ""
		local cur_sub_realm = ""

		local tabnames = {
			"realm_Client",
			"realm_Server"
		}
		local function open_addon_edit()
			main:Hide()

			if IsValid(c_addonpnl) then c_addonpnl:Remove() end

			local changed_vars = {}

			local addon_settings_copy = table.Copy(add.data.settings) or {}
			local addon_vars_copy = table.Copy(add.data.vars)
			local addon_language = add:GetLanguage()
			local addon_active_skin = add.info.active_skin
			local addon_custom_skin = table.Copy(add:GetSkinByName("skin_custom"))
			local addon_lang = add:GetLanguage() --dont changes


			c_addonpnl = vgui.Create("esclib.frame",settab)
			settab.c_addonpnl = c_addonpnl
			c_addonpnl:SetAlpha(0)
			c_addonpnl:AlphaTo(255,esclib.addon:GetVar("animtime") or 0.05)
			c_addonpnl:SetSize(scrw*0.7,scrh*0.9)
			c_addonpnl:SetPos(scrw*0.5 - c_addonpnl:GetWide()*0.5, scrh*0.5 - c_addonpnl:GetTall()*0.5)
			c_addonpnl:SetIcon(esclib:GetMaterial("cog.png"))
			function c_addonpnl:OnClose()
				settings_on_close_any(self)
			end

			local sidebar = vgui.Create("DButton",settab)
			sidebar:SetWide(c_addonpnl:GetWide()*0.06)
			sidebar:SetText("")
			function sidebar:DoClick()
				-- setbutton:DoClick() --send close signal
			end
			function sidebar:Think()
				if not IsValid(c_addonpnl) then
					self:Remove()
					return
				end
				
				-- self:SetPos(c_addonpnl:GetX()-self:GetWide()-10, c_addonpnl:GetY()+c_addonpnl:GetTall()*0.5 - self:GetTall()*0.5) --by center
				self:SetPos(c_addonpnl:GetX()-self:GetWide()-10, c_addonpnl:GetY())
				self:SetAlpha(c_addonpnl:GetAlpha())
			end
			function sidebar:Paint(w,h)
				-- draw.RoundedBox(8, 0,0,w,h, clr.frame.bg)
				-- draw.RoundedBox(6, 2,2,w-4,h-4, clr.frame.accent)
			end

			local hover_color = Color(100,100,100,50)
			local total_tall = 0
			for _,sub_add in ipairs(addon_list) do
				local add_btn = sidebar:Add("DButton")
				add_btn:SetY(total_tall)
				add_btn:SetTall(sidebar:GetWide())
				add_btn:SetWide(add_btn:GetTall())
				add_btn:SetText("")
				add_btn:eAddHint(sub_add.info.name, esclib:AdaptiveFont("esclib", 22, 500), TEXT_ALIGN_LEFT, settab)
				function add_btn:Paint(w,h)
					if (sub_add.info.uid == add.info.uid) then
						-- draw.RoundedBox(16,0,0,w,h,clr.frame.accent2)
					end
				end
				function add_btn:DoClick()
					esclib:opensettings(sub_add.info.uid, true)
				end

				local drawicon = false
				if type((sub_add.info.thumbnail or "")) == "IMaterial" then
					drawicon = true
				end

				local logo_pnl = add_btn:Add("DPanel")
				logo_pnl:Dock(FILL)
				logo_pnl:DockMargin(2,2,2,2)
				logo_pnl:SetMouseInputEnabled(false)
				local poly = nil
				function logo_pnl:Paint(w,h)
					local hovered = add_btn:IsHovered()
					esclib.draw:Mask(function() --draw poly
						if not poly then
							poly = esclib.util:PrecacheRoundedPoly(0, 0, w, h, w*0.25, 8)
						end
						draw.NoTexture();
						surface.SetDrawColor( color_white )
						surface.DrawPoly( poly )
					end, 
					function() --draw main
						if drawicon then
							esclib.draw:Material(0,0,w,w,clr.default.white, sub_add.info.thumbnail)
						else
							draw.RoundedBox(0,0,0, w, w, clr.frame.text)
						end

						if hovered then 
							draw.RoundedBox(0,0,0,w,h,hover_color)
						end
					end,false)
				end

				total_tall = total_tall + add_btn:GetTall() + 2
			end
			sidebar:SetTall(total_tall)

			c_addonpnl:SetTitle(add.info.name.." - "..esclib.addon:Translate("tab_settings", addon_lang))
			local c_content = c_addonpnl:GetContent()

			local realm = c_content:Add("esclib.combolist")
			realm:Dock(FILL)
			realm:SetAccentColor(Color(125,125,255))

			function realm:OnChange(name)
				cur_realm = name
			end


			local function build_realm(rname)
				if not IsValid(realm) then return end
				local realm_name = esclib.addon:Translate(rname,add:GetLanguage())

				realm:RemoveTab(realm_name)

				local tab_pnl = realm:AddTab(realm_name, function(content)
					if not IsValid(content) then return end

					local addon_settings_copy = table.Copy(addon_settings_copy or {})
					local addon_vars_copy = table.Copy(addon_vars_copy or {})
					if rname == "realm_Server" then
						if table.IsEmpty(add.data.server_vars or {}) then 
							return 
						end

						addon_settings_copy = table.Copy(add.data.server_settings or {})
						addon_vars_copy = table.Copy(add.data.server_vars or {}) --recieved on request

						--use server vars
						for tab_name, tab in pairs(addon_settings_copy) do
							local vars = tab["vars"] or {}

							for var_name, var in pairs(vars) do
								var.value = addon_vars_copy[var_name]
							end
						end
					end

					local dobar_size = content:GetTall()*0.07
					local combolist = content:Add("esclib.combolist")
					combolist:SetAccentColor(clr.button.accent)
		
					local dobar = content:Add("DPanel")
					dobar:SetTall(dobar_size)
					dobar:Dock(BOTTOM)
					dobar:InvalidateParent(true)
					combolist.bottom_panel = dobar

					function combolist:GetBottomPanel()
						return self.bottom_panel
					end

					combolist:SetSize(content:GetWide(),content:GetTall()-dobar:GetTall())

					function combolist:OnChange(name)
						cur_sub_realm = name
					end

					local settings_changed = false 

					local function check_saved(varid,val)

						if rname == "realm_Client" then

							changed_vars[varid] = val

							if not table.IsEmpty(changed_vars) then
								settings_changed = true
							else
								settings_changed = false
							end

						elseif rname == "realm_Server" then
							if not esclib.util:IsValuesEqual(addon_vars_copy[varid] or {}, val) then
								settings_changed = true
							else
								settings_changed = false
							end

							changed_vars[varid] = val
						end
					end

					local function save_settings()
						if rname == "realm_Client" then
							if add.info.active_skin ~= addon_active_skin then
								settab:Remove()
	
								add:SetSkin(addon_active_skin)
								add:SaveCurrentSkin()
							end
	
							add:SetLanguage(addon_language)
							add:SaveLanguage()
	
							add:ReplaceSettings(addon_settings_copy) --Save automatically
	
							hook.Run(add.info.uid.."_settings_changed",true, changed_vars) -- HOOK
	
							-- if needrestart then
							-- 	settab:Remove()
							-- end
	
							table.Empty(changed_vars)
						elseif rname == "realm_Server" then
							if table.IsEmpty(changed_vars) then return end
									
							net.Start("esclib.SendServerConfig")
								net.WriteString(add.info.uid)
								esclib:NetWriteCompressedTable(changed_vars)
							net.SendToServer()

							addpan:DoClick()
						end

						settings_changed = false
					end

					local tabs_list = {}
					local settings_keys = table.GetKeys(addon_settings_copy)

					for k,v in ipairs(settings_keys) do
						local c_order = addon_settings_copy[v]["sortOrder"]
						table.insert(tabs_list,{ stype="settings", key=v, sortOrder=c_order })
					end

					for key,tab in pairs(add:GetAllCustomTabs()) do
						if not istable(tab) then continue end
						local c_order = tab["sortOrder"]
						local realm = tab["realm"]
						if rname ~= realm then continue end
						table.insert(tabs_list,{ stype="custom", key=key, sortOrder=c_order })
					end

					for key,tab in pairs(esclib:GetAllDefaultTabs()) do
						local realm = tab["realm"]
						if rname ~= realm then continue end

						local c_order = tab["sortOrder"]
						table.insert(tabs_list,{ stype="default", key=key, sortOrder=c_order })
					end

					--Sort by sortOrder key
					--SortOrder: 100 - language tab, 101 - theme tab
					table.sort(tabs_list,function(a,b)
						return ( (a.sortOrder or 99) < (b.sortOrder or 99) )
					end)

					for _,data in ipairs(tabs_list) do

						if data["stype"] == "settings" then
							local tabname = data["key"]
							local tabc = {}
							if rname == "realm_Server" then
								tabc = table.Copy(addon_settings_copy[tabname])
							else
								tabc = addon_settings_copy[tabname]
							end

							if not istable(tabc) then continue end

							if tabc.customCheck then
								if isfunction(tabc.customCheck) then 
									if not tabc.customCheck(tabc,add) then continue end
								end
							end

							local vars = tabc["vars"]
							local tabname_translated = add:Translate(tabc.name_tr) or tabc.name

							combolist:AddTab( tabname_translated, function(tab_content)
								
								local scroll = tab_content:Add("esclib.scrollpanel")
								scroll:SetSize(tab_content:GetWide(),tab_content:GetTall())

								local list = scroll:Add("DIconLayout")
								list:SetBorder(5)
								list:SetSize(tab_content:GetWide(),tab_content:GetTall()-6)
								list:SetSpaceX(5)
								list:SetSpaceY(5)

								local button_wide = list:GetWide()*0.332-list:GetBorder()
								local button_tall = list:GetTall()*0.08

								local sortedVars = table.GetKeys(vars)
								table.sort(sortedVars,function(a,b)
									return ( (vars[a]["sortOrder"] or math.huge) < (vars[b]["sortOrder"] or math.huge) )
								end)

								for _,varid in ipairs(sortedVars) do

									local varc = vars[varid]

									if varc.visible == false then continue end

									if varc.customCheck then
										if isfunction(varc.customCheck) then 
											if not varc.customCheck(varc,add) then continue end
										end
									end

									if (varc.name == nil and varc.name_tr == nil) then varc.name = varid end

									local vtype  = varc.type
									if esclib.allowed_settings_types[vtype] then

										local settings_type = esclib.allowed_settings_types[vtype]
										if isfunction(settings_type["Build"]) then
											local default_val = nil

											if add.data.default_settings[varid] ~= nil then
												default_val = add.data.default_settings[varid]
											elseif add.data.server_default_settings[varid] ~= nil then
												default_val = add.data.server_default_settings[varid]
											end

											local base_panel = list:Add("DPanel")
											base_panel:SetSize(button_wide, button_tall)
											base_panel.addon = add
											base_panel.var = varc
											base_panel.default_value = default_val
											base_panel.var_uid = varid
											base_panel.initial_values = addon_vars_copy
											base_panel.bg = settab
											base_panel.parent = list
											base_panel.Paint = nil

											function base_panel:ApplyValue()
												if varc["restart_addon"] then needrestart = true end
												check_saved(varid,varc.value)
											end

											function base_panel:SaveAll()
												save_settings()
												addpan:DoClick()
											end

											settings_type:Build(base_panel)
										end
									end

								end

								return scroll

							end)

						elseif data["stype"] == "custom" then
							local function callback(changed)
								settings_changed = changed
							end

							local name = data["key"]
							local cstm = add:GetAllCustomTabs()[name]

							cstm.func(add, settab, combolist, callback)

						elseif data["stype"] == "default" then
							local function callback(stype, ...)
								local vars = {...}
								if stype == "language" then
									addon_language = vars[1]
									if add.info.language ~= addon_language then
										settings_changed = true
									end
								elseif stype == "skin" then
									addon_active_skin = vars[1]
									if add.info.active_skin ~= addon_active_skin then
										settings_changed = true
									end
								elseif stype == "custom_skin" then
									settab.c_themepanel = vars[1]
									settings_on_close_any(settab.c_themepanel)
								end

								if settings_changed then
									needrestart = true
								end
							end

							local name = data["key"]
							local cstm = esclib:GetAllDefaultTabs()[name]

							cstm.func(add, settab, combolist, callback)
						end
					end


					local phrase_unsaved = esclib.addon:Translate("phrase_Unsaved", add:GetLanguage())
					function dobar:Paint(w,h)
						draw.RoundedBoxEx(skin.roundsize, 0,0,w,h, clr.frame.accent,false,false,true,true)

						if settings_changed then
							draw.SimpleText(phrase_unsaved.."!", esclib:AdaptiveFont("esclib", 22, 500), w-15, h*0.5, clr.default.red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
						end
					end

					local clearcfg_button = dobar:Add("esclib.button")
					clearcfg_button:SetSize(dobar:GetTall(),dobar:GetTall())
					clearcfg_button:SetX(dobar:GetWide()*0.5-clearcfg_button:GetWide())
					clearcfg_button:SetY(dobar:GetTall()*0.5-clearcfg_button:GetTall()*0.5)

					clearcfg_button:SetButtonText(esclib.addon:Translate("phrase_ReturnDefault", add:GetLanguage()))
					clearcfg_button:SetBorderRadius(16)

					function clearcfg_button:Paint(w,h)
						local hovered = self:IsHovered()
						esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.25,hovered and clr.button.discard_hover or clr.button.discard, esclib:GetMaterial("revert.png"))
					end
					local hint_pnl = clearcfg_button:eAddHint(clearcfg_button:GetButtonText(),esclib:AdaptiveFont("esclib", 24, 500),TEXT_ALIGN_CENTER,settab)
					hint_pnl:SetAccentColor(clr.button.discard)

					function clearcfg_button:DoClick()
						esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure", add:GetLanguage()),esclib.addon:Translate("phrase_SureToReturn", add:GetLanguage()),function(res)
							if res then
								if rname == "realm_Client" then
									add:ReturnSettingsToDefault()
									addpan:DoClick()
								elseif rname == "realm_Server" then
									net.Start("esclib.ClearServerConfig")
										net.WriteString(add.info.uid)
									net.SendToServer()
									addpan:DoClick()
								end
							end
						end)
					end

					local apply_button = dobar:Add("DButton")
					local text = esclib.addon:Translate("phrase_Save", add:GetLanguage())
					local font = esclib:AdaptiveFont("esclib", 24, 500)
					local textw, texth = esclib.util:TextSize(text, font)

					local offsety = dobar:GetTall()*0.2

					apply_button:SetSize(dobar:GetTall(),dobar:GetTall())
					apply_button:SetX(dobar:GetWide()*0.5)
					apply_button:SetY(dobar:GetTall()*0.5-apply_button:GetTall()*0.5)
					apply_button:SetText("")

					local save_mat = esclib:GetMaterial("save.png")

					local hint_pnl = apply_button:eAddHint(text, font, TEXT_ALIGN_CENTER, settab)
					hint_pnl:SetAccentColor(clr.button.apply)

					function apply_button:Paint(w,h)
						local hovered = self:IsHovered()
						esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.25,hovered and clr.button.apply_hover or clr.button.apply, save_mat)
					end
					function apply_button:DoClick()
						save_settings()
						addpan:DoClick()
					end

					if rname == "realm_Client" and esclib:HasAdminAccess(LocalPlayer()) then
						local send2server = dobar:Add("esclib.button")
						send2server:SetSize(dobar:GetTall(),dobar:GetTall())
						send2server:SetX(5)
						
						send2server:SetButtonText(esclib.addon:Translate("phrase_SetGlobalDefault", add:GetLanguage()))
						send2server:SetBorderRadius(16)

						local cloud_material = esclib:GetMaterial("cloud.png")
						function send2server:Paint(w,h)
							local hovered = self:IsHovered()
							esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.text_hover or clr.button.text, cloud_material)
						end
						send2server:eAddHint(send2server:GetButtonText(),esclib:AdaptiveFont("esclib", 20, 500),TEXT_ALIGN_CENTER,settab)

						function send2server:DoClick()
							esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure", add:GetLanguage()),"",function(res)
								if res then
									add:CurrentSettingsToGlobal()
									addpan:DoClick()
								end
							end)
						end


						local req2cleancfg = dobar:Add("esclib.button")
						req2cleancfg:SetSize(dobar:GetTall(),dobar:GetTall())
						req2cleancfg:SetX(send2server:GetX()+send2server:GetWide()+5)
						
						req2cleancfg:SetButtonText(esclib.addon:Translate("phrase_BackGlobalDefault", add:GetLanguage()))
						req2cleancfg:SetBorderRadius(16)

						function req2cleancfg:Paint(w,h)
							local hovered = self:IsHovered()
							esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.25,hovered and clr.button.text_hover or clr.button.text, esclib:GetMaterial("revert.png"))
						end
						req2cleancfg:eAddHint(req2cleancfg:GetButtonText(),esclib:AdaptiveFont("esclib", 24, 500),TEXT_ALIGN_CENTER,settab)

						function req2cleancfg:DoClick()
							esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure", add:GetLanguage()),esclib.addon:Translate("phrase_SureToReturn", add:GetLanguage()),function(res)
								if res then
									add:ClearGlobalConfig()
									addpan:DoClick()
								end
							end)
						end

						local infobtn = dobar:Add("esclib.button")
						infobtn:SetSize(dobar:GetTall(),dobar:GetTall())
						infobtn:SetX(req2cleancfg:GetX()+req2cleancfg:GetWide()+5)
						
						infobtn:SetButtonText(esclib.addon:Translate("phrase_AdminInfoButtons", add:GetLanguage()))
						infobtn:SetBorderRadius(16)

						function infobtn:Paint(w,h)
							esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.25,clr.default.orange, esclib:GetMaterial("info.png"))
						end
						infobtn:eAddHint(infobtn:GetButtonText(),esclib:AdaptiveFont("esclib", 20, 500),TEXT_ALIGN_CENTER,settab)
					end


					combolist:SetActive(cur_sub_realm, true)

					return combolist

				end)--build_realm

				if realm_name == cur_realm then
					timer.Simple(0, function()
						realm:SetActive(cur_realm, true)
					end)
				end
			end

			for _,rname in ipairs(tabnames) do
				if rname == "realm_Server" then
					-- build_realm(rname)
					add:RequestServerSettings(function()
						build_realm(rname)
					end)
				else
					build_realm(rname)
				end
			end

			if realm_name == cur_realm then
				realm:SetActive(cur_realm)
			end

		end

		if needaddon then
			if uid == naddon then
				open_addon_edit()
			end
		end

		function addpan:DoClick()
			open_addon_edit()
		end
	end
end

concommand.Add("esettings",function(ply,cmd,args)
	if table.IsEmpty(args) then
		esclib:opensettings()
		return
	end

	esclib:opensettings(args[1])
end)

hook.Add("OnPlayerChat","esclib.hook.open_settings",function(ply,text,isteam,isplydead)
	if ply ~= LocalPlayer() then return end
	if text == "!esettings" then
		RunConsoleCommand("esettings")
		return true
	end
end)