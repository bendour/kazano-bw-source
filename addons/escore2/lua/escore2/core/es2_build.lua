local format = string.format
local clamp = math.Clamp	

--Register new fonts
esclib:SetFontName("escore2")
esclib:SetFont("Montserrat")
esclib:RegisterAdaptiveFont("escore2")

esclib:SetFontName("escore2_alt")
esclib:SetFont("Preview")
esclib:RegisterAdaptiveFont("escore2_alt")


local function empty_fn() end

escore2.is_opened = false
escore2.EndAnim = empty_fn

local function format_time(time_format)
	local currentTime = os.date("*t")

	local hour = currentTime.hour
	local hours12 = hour
    local suffix = "AM"

    if hours12 >= 12 then
        suffix = "PM"
        if hours12 > 12 then
            hours12 = hours12 - 12
        end
    elseif hours12 == 0 then
        hours12 = 12
    end

	-- {hour}:{minute}:{second} --24 time format
	-- {hour12}:{minute}:{second} {am_pm} --12 hours format
	-- {time}, 24 hours time format
	-- {time12}, 12 hours time format
	local final_str = esclib.text:KeyFormat(time_format, {
		["hour"] = format("%02d", hour),
		["minute"] = format("%02d", currentTime.min),
		["second"] = format("%02d", currentTime.sec),
		["hour12"] = format("%02d", hours12),
		["am_pm"] = suffix,
	})

	return final_str
end


function escore2:Build()
	if not escore2.addon:GetVar("subtitle") then 
		print("[escore2][warning] Var from server isn't recieved.")
	end --When addon doesn't recieved data from server

	if self:IsValid() then escore2.bg:Remove() end
	local clr = escore2.addon:GetColors()
	local lply = LocalPlayer()

	local bg = vgui.Create("EditablePanel")
	bg:SetAlpha(0)
	bg:SetSize(esclib.scrw, esclib.scrh)
	bg:Hide()
	bg.MousePos = {["x"]=esclib.scrw*0.5, ["y"]=esclib.scrh*0.5}
	local draw_blur = escore2.addon:GetVar("blur")
	function bg:Paint(w,h)
		if draw_blur then
			esclib.draw:Blur(self,4)
		end

		draw.RoundedBox(0,0,0,w,h,clr.main.bg)
	end

	local particle_pnl = bg:Add("escore2.particle_panel")
	particle_pnl:SetSize(bg:GetWide(),bg:GetTall())

	if escore2.addon:GetVar("enable_effect") then
		local effect = (escore2.addon:GetVar("effect") or {})[1]
		if effect == "dots" then
			particle_pnl:SetEffectClass(escore2.DotsParticle)
			particle_pnl:CreateParticles(esclib:AdaptiveSize(100))
		elseif effect == "snow" then
			particle_pnl:SetEffectClass(escore2.SnowParticle)
			particle_pnl:CreateParticles(esclib:AdaptiveSize(100))
		end
	end

	local base_panel = bg:Add("DPanel")
	base_panel:SetSize(bg:GetWide()*escore2.addon:GetVar("size_w"), bg:GetTall())
	base_panel:SetX(bg:GetWide()*0.5 - base_panel:GetWide()*0.5)
	base_panel.Paint = nil


	local logo_mat = Material("error")
	local logo_w, logo_h = esclib:AdaptiveSize(escore2.addon:GetVar("logo_w")), esclib:AdaptiveSize(escore2.addon:GetVar("logo_h"))
	local clr_red = Color(255,0,0)
	local logo_url = escore2.addon:GetVar("logo_url") or ""
	escore2.addon:DownloadMaterial(logo_url, function(mat)
		logo_mat = mat or logo_mat
	end, function(errMsg)
		print("[escore2] Failed to download material <link:"..logo_url.."> Error message: ["..errMsg.."]")
	end)


	local font = esclib:AdaptiveFont("escore2", 26, 500)
	local title_pnl = base_panel:Add("DPanel")
	title_pnl:SetTall(draw.GetFontHeight(font)+logo_h)
	title_pnl:DockMargin(0,10,0,0)
	title_pnl:Dock(TOP)

	local time_fmt = (escore2.addon:GetVar("timeformat") or {})[1]
	if time_fmt == "s_12h_format" then
		time_fmt = "{hour12}:{minute} {am_pm}"
	else
		time_fmt = "{hour}:{minute}"
	end

	local format = escore2.addon:GetVar("subtitle") or ""

	local next_draw = 0
	local formatted_str = ""
	function title_pnl:Paint(w,h) 

		if next_draw < RealTime() then
			formated_str = esclib.text:KeyFormat(format, {
				["ping"] = tostring(lply:Ping()),
				["nick"] = tostring(lply:Nick()),
				["usergroup"] = tostring(lply:GetUserGroup()),
				["online"] = tostring(player.GetCount()) or "0",
				["time"] = format_time(time_fmt)
			})
			next_draw = RealTime()+1
		end
		esclib.draw:ShadowText(formated_str, font, w*0.5, h-5, clr.main.sub_title, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1)

		esclib.draw:Material(w*0.5-logo_w*0.5,0,logo_w,logo_h,clr.default.white,logo_mat)
	end


	local topbar_font = esclib:AdaptiveFont("escore2", 26, 500)
	local topbar_pnl = base_panel:Add("DPanel")
	topbar_pnl:SetTall(draw.GetFontHeight(topbar_font)+10)
	topbar_pnl:DockMargin(0,10,8,0)
	topbar_pnl:Dock(TOP)
	topbar_pnl:InvalidateParent(true)
	topbar_pnl.Paint = function(self,w,h)
		-- draw.RoundedBox(8,0,0,w,h,clr.main.bg2)
	end
	

	escore2:CalculateColumnWidths()
	local columns = escore2:GetAvailableColumns()
	local column_count = #columns


	---------------
	--# COLUMNS #--
	---------------
	for _, col_name in ipairs(columns) do
		local col_value = escore2:GetColumn(col_name)
		if not col_value then continue end
		if not col_value.init_topbar then continue end
		
		local middle_topbar = topbar_pnl:Add("DButton")
		middle_topbar:Dock(LEFT)
		middle_topbar:SetWide(topbar_pnl:GetWide() * col_value:GetWide())
		middle_topbar:SetText("")
		middle_topbar:SetFont(topbar_font)
		middle_topbar.name = col_name

		col_value.init_topbar(col_value, middle_topbar) --init panel values

		middle_topbar.DoClick = function(self) escore2:SortByCol(self.name) end
	end

	local player_base_panel = base_panel:Add("esclib.scrollpanel")
	escore2.player_base_panel = player_base_panel
	player_base_panel:Dock(FILL)
	player_base_panel:SetScrollSpeed(16)
	player_base_panel.VBar.btnGrip:Hide()
	-- player_base_panel.VBar.btnGrip.Paint = function(self, w,h)
	-- 	draw.RoundedBox(0,0,0,w,h,clr.player.bg)
	-- end
	player_base_panel:PerformLayout()
	player_base_panel:InvalidateParent(true)
	player_base_panel.ply_child = {}
	player_base_panel.Paint = function(self,w,h)
		-- draw.RoundedBox(0,0,0,w,h,Color(255,0,0))
	end


	--Populate category functions
	local categoryFunctions = {}
	for column_name,column_values in pairs(escore2:GetAllColumns()) do
		if isfunction(column_values["category_name_func"]) then
			categoryFunctions[column_name] = column_values["category_name_func"]
		end
	end

	function escore2:ClearCategories()
		if not IsValid(player_base_panel) then return end
		for _, pnl in pairs(player_base_panel.category_panels or {}) do
			if IsValid(pnl) then
				pnl:Remove()
			end
		end
		player_base_panel.category_panels = {}
	end

	function escore2:Update()

		escore2:ClearCategories()

		for i = #player_base_panel.ply_child, 1, -1 do
			local pnl = player_base_panel.ply_child[i]
			if not IsValid(pnl) or not IsValid(pnl:GetPlayer()) then
				table.remove(player_base_panel.ply_child, i)
			else
				if hook.Run("escore2.player_filter", pnl:GetPlayer()) then
					pnl:Hide()
				else
					pnl:Show()
				end
			end
		end
	
		for category, pnl in pairs(player_base_panel.category_panels or {}) do
			if not IsValid(pnl) then
				player_base_panel.category_panels[category] = nil
			end
		end
	
		local pos_y = 0
		local last_category = nil
		
		local category_font = esclib:AdaptiveFont("escore2", 30, 500)
		local list_material = escore2:GetMaterial("list.png")
		local interval = escore2.addon:GetVar("interval") or 3
		for k, v in ipairs(player_base_panel.ply_child) do
			if not v:IsVisible() then continue end
			if not IsValid(v:GetPlayer()) then continue end
			
			local sort_column = escore2.sort_column
			local column = escore2:GetColumn(sort_column)
			if not column then continue end

			local category = column:GetCategoryNameFunc() or ""
			if isfunction(category) then category = category(v:GetPlayer()) end
	
			if category ~= "" and category ~= last_category then
				last_category = category
	
				if not player_base_panel.category_panels then
					player_base_panel.category_panels = {}
				end
	
				if not player_base_panel.category_panels[category] then
					local cat_panel = player_base_panel:Add("escore2.category_pnl")
					
					cat_panel:SetSize(player_base_panel:GetWide()-8, draw.GetFontHeight(category_font) + 2)
					cat_panel:SetPos(cat_panel:GetX(), pos_y)
					cat_panel:SetText(category)
					cat_panel:SetFont(category_font)
					cat_panel:SetIcon(list_material)
					cat_panel:SetColor(clr.main.text)
					cat_panel:SetIconColor(clr.main.text)
					cat_panel:SetPlayer(v:GetPlayer())
					
					local init_fn = column:GetInitCategoryFunc()
					if isfunction(init_fn) then init_fn(column, cat_panel) end
					
					player_base_panel.category_panels[category] = cat_panel
					pos_y = pos_y + cat_panel:GetTall() + interval
				end
			end
	
			v:SetY(pos_y)
			pos_y = pos_y + v:GetTall() + interval
		end
		player_base_panel:Rebuild()
	end

	local player_panel_font = esclib:AdaptiveFont("escore2", 24, 500)
	local ply_panel_tall = draw.GetFontHeight(player_panel_font)+16
	function escore2:AddPlayerPanel(ply)
		local ply_panel = player_base_panel:Add("escore2.player_bar")
		ply_panel:SetWide(player_base_panel:GetWide()-8)
		ply_panel:SetTall(ply_panel_tall)
		ply_panel:SetPlayer(ply)
		ply_panel:SetFont(player_panel_font)
		timer.Simple(0, function()
			if not IsValid(ply_panel) then return end
			ply_panel:GenerateColumns(columns)
		end)
	
		function ply_panel:OnOpen()
			if not escore2.addon:GetVar("multi_open") and IsValid(player_base_panel.opened_panel) then
				player_base_panel.opened_panel:Close()
			end
			player_base_panel.opened_panel = self

			-- player_base_panel:ScrollToChild(self, true)
		end
	
		function ply_panel:OnClose()
			player_base_panel.opened_panel = nil
		end
	
		function ply_panel:OnRemove()
			self:Hide() -- to properly edit positions
		end

		function ply_panel:AnimTick()
			escore2:Update()
		end
	
		table.insert(player_base_panel.ply_child, ply_panel)
		escore2:Update()
	end

	function escore2:InitPlayers()
		player_base_panel:Clear()
		player_base_panel.ply_child = {}
		player_base_panel.opened_panel = nil
		player_base_panel.category_panels = {}
	
		for _, ply in ipairs(player.GetAll()) do
			escore2:AddPlayerPanel(ply)
		end
	end

	local bottom_panel = base_panel:Add("DPanel")
	bottom_panel:SetTall(base_panel:GetTall()*0.055)
	bottom_panel:Dock(BOTTOM)
	bottom_panel:InvalidateParent(true)
	bottom_panel.Paint = nil

	local layout = bottom_panel:Add("DIconLayout")
	layout:SetTall(bottom_panel:GetTall()-15)
	layout:SetY(10)
	layout:SetStretchWidth(true)
	layout:SetSpaceX(esclib:AdaptiveSize(15))
	layout:SetLayoutDir(LEFT)
	layout.Paint = nil

	local buttons = escore2:GetBottomButtons()
	local function compare(a,b)
		return a.position < b.position
	end
	local buttons_sorted = {}
	for _,btn in pairs(buttons) do
		table.insert(buttons_sorted, btn)
	end
	table.sort(buttons_sorted, compare)


	local white = Color(255,255,255)
	for _,v in ipairs(buttons_sorted) do
		local btn = layout:Add("DButton")
		btn:SetSize(layout:GetTall(), layout:GetTall())
		btn:SetText("")

		local hint_pnl = btn:eAddHint(v.name, nil, TEXT_ALIGN_TOP, bg)
		hint_pnl:SetTextColor(clr.main.text)
		hint_pnl:SetColor(color_transparent)
		hint_pnl:SetAccentColor(color_transparent)

		function btn:Paint(w,h)
			local hovered = self:IsHovered()
			esclib.draw:MaterialCenteredShadowed(w*0.5,h*0.5,h*0.48, hovered and v.hover_color or v.color, v.icon)
		end
		function btn:DoClick()
			v:OnClick()
		end
	end

	layout:SetX(bottom_panel:GetWide()*0.5 - layout:GetWide()*0.5)

	local search_base = bg:Add("EditablePanel")
	search_base:SetSize(bg:GetWide()*0.4, ply_panel_tall)
	search_base:SetPos(bg:GetWide()*0.5 - search_base:GetWide()*0.5, bottom_panel:GetY()+bottom_panel:GetTall()*0.5-search_base:GetTall()*0.5)
	search_base.opened = false
	search_base.busy = false
	search_base:Hide()
	search_base:SetKeyboardInputEnabled(true)
	function search_base:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,clr.search.bg)
	end
	escore2.search_base = search_base
	escore2.search_text = ""

	function search_base:OnKeyCodePressed(key)
		if key == KEY_TAB or key == KEY_ENTER then
			escore2:ToggleSearch()
			return true
		end

		if key == KEY_ESCAPE then
			escore2:ToggleSearch()
			escore2:Close()
			return true
		end
	end

	local close_btn = search_base:Add("DButton")
	close_btn:Dock(LEFT)
	close_btn:SetWidth(search_base:GetTall())
	close_btn:SetText("")
	local search_btn = escore2:GetBottomButton("search")
	local mat = search_btn.icon
	function close_btn:Paint(w,h)
		local hovered = self:IsHovered()
		esclib.draw:MaterialCenteredShadowed(h*0.5,h*0.5, h*0.35, hovered and search_btn.hover_color or search_btn.color, mat)
	end
	function close_btn:DoClick()
		escore2:ToggleSearch()
	end

	local font = esclib:AdaptiveFont("escore2", 26, 500)
	local tentry = search_base:Add("DTextEntry")
	tentry:Dock(FILL)
	tentry:Hide()
	tentry:SetText("")
	tentry:SetFont(font)
	local text = escore2.addon:Translate("search_placeholder")
	function tentry:Paint(w,h)
		if tentry:GetText() == "" then
			draw.SimpleText(text,font,5,h*0.5-2,clr.search.text_gray,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText("Enter / Tab",font,w-20,h*0.5-1,clr.search.text,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
		end

		self:DrawTextEntryText( clr.search.text, clr.search.highlight, clr.search.text )
	end


	function tentry:OnChange()
		escore2.search_text = tentry:GetText()
		escore2:SortPanels()
	end

	hook.Remove("escore2.player_filter", "escore2.search_hook")
	hook.Add("escore2.player_filter", "escore2.search_hook", function(ply)
		if not IsValid(tentry) then
			hook.Remove("escore2.player_filter", "escore2.search_hook")
			return
		end

		local value = tentry:GetText():lower()
		if not string.find(ply:Nick():lower(), value, nil, true) then

			if string.StartsWith(ply:SteamID():lower(), value) then
				return false
			end

			if string.StartsWith(ply:SteamID64(), value) then
				return false
			end

			return true
		end
	end)

	function tentry:AllowInput( char )
		if char == "`" then return true end
		return false
	end

	function tentry:OnKeyCode(key)
		if not search_base.busy then
			search_base:OnKeyCodePressed(key)
		end
	end

	function escore2:ToggleSearch()
		if search_base.opened then
			search_base.busy = true
			bottom_panel:Show()
			search_base.opened = false
			
			tentry:Hide()
			tentry:SetText("")
			tentry:OnChange()
			bg:SetKeyboardInputEnabled(false)

			search_base:SetAlpha(255)
			search_base:AlphaTo(0,0.1, 0, function()
				search_base.busy = false
				search_base:Hide()
			end)

			close_btn:Dock(NODOCK)
			close_btn:SetX(0)
			close_btn:MoveTo(search_base:GetWide()*0.5 - close_btn:GetWide()*0.5, 0, 0.1, 0, -1, function()
				close_btn:Dock(LEFT)
			end)
		else
			search_base.busy = true
			bottom_panel:Hide()
			search_base.opened = true
			
			tentry:Show()
			tentry:RequestFocus()

			tentry:SetParent(search_base)
			tentry:SetPos(500,500)

			search_base:SetKeyboardInputEnabled(true)
			search_base:MakePopup()
			search_base:SetPopupStayAtBack( true )

			close_btn:Dock(NODOCK)
			close_btn:SetX(search_base:GetWide()*0.5 - close_btn:GetWide()*0.5)
			close_btn:MoveTo(0, 0, 0.1, 0, -1, function()
				close_btn:Dock(LEFT)
			end)

			search_base:Show()
			search_base:SetAlpha(0)
			search_base:AlphaTo(255,0.1, 0, function()
				search_base.busy = false
			end)
		end
	end

	self:InitPlayers()
	self:InitSorts()

	escore2.bg = bg
	escore2.is_opened = false
	return bg
end

function escore2:IsValid()
	return IsValid(escore2.bg)
end

function escore2:IsOpened()
	return escore2.is_opened
end

function escore2:Open()
	if self.addon:GetVar("toggle_mode") and self:IsOpened() then
		self:Close()
		return
	end

	self:EndAnim()

	if not self:IsValid() then escore2:Build() end
	escore2.bg:Show()
	escore2:Update()
	gui.EnableScreenClicker( true )
	input.SetCursorPos( escore2.bg.MousePos["x"], escore2.bg.MousePos["y"] )

	escore2.EndAnim = esclib:NewAnimation(0.1, 0, 0.9, function()
		escore2.is_opened = true
		escore2.EndAnim = empty_fn
		escore2.bg:SetAlpha(255)
	end, function(frac)
		if not IsValid(escore2.bg) then return 1 end

		escore2.bg:SetAlpha(clamp(255*frac, 0, 255))
	end)
end

function escore2:Close()
    if not IsValid(escore2.bg) then return end
	if IsValid(escore2.search_base) and escore2.search_base.opened then 
		return 
	end

	self:EndAnim()
	
	--save cursor pos
	local mx, my = input.GetCursorPos()
	escore2.bg.MousePos["x"] = mx
	escore2.bg.MousePos["y"] = my
	gui.EnableScreenClicker( false )

	escore2.EndAnim = esclib:NewAnimation(0.05, 0, -1, function()
		escore2.is_opened = false
		escore2.bg:Hide()
		escore2.EndAnim = empty_fn
		escore2.bg:SetAlpha(0)
	end, function(frac)
		if not IsValid(escore2.bg) then return 1 end

		escore2.bg:SetAlpha(clamp(255*(1-frac), 0, 255))
	end)
end

concommand.Add("escore2_open", function()
	escore2:Open()
end)

concommand.Add("escore2_close", function()
	escore2:Close()
end)

concommand.Add("escore2_rebuild", function()
	escore2:Build()
end)

concommand.Add("escore2_clear_cache", function()
	escore2.addon:ClearDownloadCache()
	escore2:Build()
end)


--REMOVE STANDART GAMEMODE HOOKS
hook.Add("InitPostEntity", "escore2.removehooks", function()
	timer.Simple(0,function()
		GAMEMODE.ScoreboardShow = nil
		GAMEMODE.ScoreboardHide = nil

		hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
		hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
	end)
end)

hook.Add( "ScoreboardShow", "escore2.show", function()
	hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
	hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
	
	escore2:Open()
end )

hook.Add( "ScoreboardHide", "escore2.hide", function()
	if escore2.addon:GetVar("toggle_mode") then return end
	escore2:Close()
end )


hook.Add("escore2_skin_changed","escore2.skin_changed_reload",function(skin_name)
	if escore2:IsValid() then
		escore2:Build()
	end
end)

hook.Add("escore2_settings_changed","escore2.onsettings_change",function(needrestart, changed_vars)
	if escore2:IsValid() then
		timer.Simple(0,function()
			escore2:Build()
		end)
	end
end)

--Remove default scoreboard show after reload
hook.Add("OnReloaded","escore2.on_gm_reload",function()
	timer.Simple(0,function()
		GAMEMODE.ScoreboardShow = nil
		GAMEMODE.ScoreboardHide = nil
	end)
end)

--On resolution change
hook.Add( "OnScreenSizeChanged", "escore2.onscreenchange", function(oldw,oldh)
	
	if escore2:IsValid() then
		escore2.bg:Remove() --Need to rebuild panel
	end
	-- escore2:Build()
end)

function escore2:GetCurrentPlayerList()
	local player_list = {}

	for _,pnl in ipairs(escore2.player_base_panel.ply_child or {}) do
		local ply = pnl:GetPlayer()
		if not IsValid(ply) then continue end
		player_list[ply:SteamID64()] = true
	end

	return player_list
end

--Not Stable
gameevent.Listen("player_connect_client")
hook.Add( "player_connect_client", "escore2.on_player_connected", function( data )
	if escore2.AddPlayerPanel then
		if data and data.index then
			
			timer.Simple(1, function() --wait when entity is created
				local ply = Entity( data.index+1 )
				if not IsValid(ply) then return end

				local player_list = escore2:GetCurrentPlayerList()
				
				if not player_list[ply:SteamID64()] then
					escore2:AddPlayerPanel(ply)
					escore2:SortPanels()
				end
			end)
		end
	end
end)

function escore2:UpdateLoop()
	if not escore2:IsValid() then return end

	local player_list = escore2:GetCurrentPlayerList()

	for _,ply in ipairs(player.GetAll()) do
		if not player_list[ply:SteamID64()] then
			escore2:AddPlayerPanel(ply)
			escore2:SortPanels()
		end
	end
end

timer.Remove("es2.update_loop")
timer.Create("es2.update_loop", 10, -1, function() 
	escore2:UpdateLoop()
end)


--lua refresh
if escore2:IsValid() then
	escore2:Build()
end