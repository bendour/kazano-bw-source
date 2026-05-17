if( SERVER ) then return end

-- shorthand
local tbl = dtj.weaponHud

--[[
	Add an icon to the spawnmenu context menu
]]--
if( tbl.config.sandboxMods == true ) then
	list.Set( "DesktopWindows", "Weapon Drawer Settings", {
		title = "Weapon HUD",
		icon = "dtj/weaponhud/context_weaponhud.png",
		
		init = function( icon, window )
			tbl.showSettings();
		end
	} )
end

--[[
	Loads this servers config file
--]]
function tbl.loadServerConfig( force )
	if( tbl.loadedSlotConfig and not force ) then return end
	tbl.loadedSlotConfig = true
	
	local guid = tbl.serverGuid();
	local fileName = "dtj/weaponhud/slot_config_" .. guid .. ".txt"
	
	if( not file.Exists( fileName, "DATA" ) ) then
		tbl.print( "Attempted to load missing config file '" .. fileName .. "'" );
		if( file.Exists( "download/data" .. fileName, "GAME" ) ) then
			fileName = "download/data/" .. fileName
			tbl.print( "Found inside download folder instead" ); -- can't see "data" when it's added like a resource file????
		end
		return 
	end
	
	local fileData = file.Read( fileName, "DATA" );
	local t = util.JSONToTable( fileData );
	
	if( not t ) then
		tbl.print( "failed to convert file data into table. file: '" .. fileName .. "' length: '" .. fileData:len() .. "'" );
		return
	end
	
	tbl.serverConfig = t
	tbl.print( "Loaded server-side slot configuration table" );
end
	
--[[
	Saveing & Loading the HUD settings
	Uses Get/SetPData, with a JSON string from a table
--]]

function tbl.loadSettings()
	if( tbl.settingsLoaded ) then
		return
	end
	
	local forceTheme = false
	tbl.settingsLoaded = true
	
	-- load a forced theme, if enabled
	if( tbl.config.useThemes == true ) then
		if( tbl.config.forceTheme and tbl.themes.isValid( tbl.config.forceTheme ) ) then
			tbl.themes.select( tbl.config.forceTheme );
			forceTheme = true
		end
	end
	
	-- 0 = disables
	-- 1 = enabled, but disallow client settings
	-- 2 = enabled, allow client settings
	if( tbl.enabled() ~= 2 ) then return end
	
	local settings = LocalPlayer():GetPData( "dtj_weaponHud" );
	if( not settings or settings:len() < 1 ) then
		return
	end
	
	local t = util.JSONToTable( settings );
	if( not t ) then
		ErrorNoHalt( "failed to obtain settings table. string '" .. settings .. "'" );
		return
	end
	
	tbl.config.mainColor 	= t.mc
	tbl.config.selectColor	= t.sc
	tbl.config.titleColor	= t.tc
	tbl.config.slotColor	= t.ssc or tbl.config.slotColor
	
	tbl.config.showIcons	= t.si
	tbl.config.showToolTips	= t.st
	tbl.config.showTitles	= t.stt
	
	tbl.config.mouseSensitivity	= t.mw
	tbl.config.offset			= t.o
	
	if( tbl.config.useThemes == true and forceTheme == false ) then
		if( t.t ) then
			if( tbl.themes.isValid( t.t ) ) then tbl.themes.select( t.t ); end
		end
	end
	
	tbl.print( "Loaded custom Weapon Drawer settings.." );
end

function dtj.weaponHud.saveSettings()
	local settings = {
		mc = tbl.config.mainColor,
		sc = tbl.config.selectColor,
		tc = tbl.config.titleColor,
		ssc = tbl.config.slotColor,
		si = tbl.config.showIcons,
		st = tbl.config.showToolTips,
		stt = tbl.config.showTitles,
		mw = tbl.config.mouseSensitivity,
		o = tbl.config.offset,
		t = tbl.themes.getSelected(),
	}
	
	local json = util.TableToJSON( settings );
	
	if( not json ) then
		ErrorNoHalt( "failed to convert table into string" );
		return
	end
	
	LocalPlayer():SetPData( "dtj_weaponHud", json );
	tbl.notify( tbl.lang["saved"] );
end

net.Receive( "dtj_w_slotconfig", function( length )
	local bit = net.ReadBit() or 0
	
	if( bit == 0 ) then
		tbl.notify( tbl.lang["access_denied"] );
		return 
	end
	
	local fileExists = net.ReadBool();
	local jsonString = net.ReadString();
	local slotTable = {}
	
	if( fileExists == true ) then
		slotTable = util.JSONToTable( jsonString );
	end
	
	tbl.slotEditorPost( fileExists, slotTable );
	tbl.print( "Received server info.. File exists: '" .. tostring( fileExists ) .. "' and data len: '" .. length .. "'" );
end );


function tbl.slotEditor()
	if( not LocalPlayer():dtjNetCooldown() ) then
		tbl.notify( tbl.lang["too_soon"] );
		return
	end
	
	-- ask the server if we have permission to do this 
	-- and request the slot config information table
	net.Start( "dtj_w_slotconfig" );
		net.WriteBit( 1 ) -- 1 == obtain current slot configuration
	net.SendToServer();
	
	tbl.notify( tbl.lang["asking_server"] );
end

local function createCheckBox( parent, x, y, text, color, checked, fnChange )
	local c = parent:Add( "DCheckBoxLabel" );
	
	c:SetPos( x, y );
	c:SetChecked( checked );
	c:SetText( text );
	c:SetDark( true );
	c.OnChange = fnChange
	
	return c
end

local function createLabel( parent, text, noDock, noBold, noDark )
	local label = vgui.Create( "DLabel", parent );
	label:SetText( text );
	
	if( not noDock ) then label:Dock( TOP ); end
	if( not noBold ) then label:SetFont( "DermaDefaultBold" ); end
	
	if( noDark ) then
		label:SetTextColor( { r = 255, g = 255, b = 255, a = 255 } );
	else
		label:SetTextColor( { r = 0, g = 0, b = 0, a = 255 } );
	end
	
	label:SizeToContents();
	return label
end

-- the standard hl2 weapons
-- in their pre-determined slot order
local defaultWeapons = {}
table.insert( defaultWeapons, { "weapon_crowbar", "weapon_physcannon", "weapon_physgun" } );
table.insert( defaultWeapons, { "weapon_pistol", "weapon_357" } );
table.insert( defaultWeapons, { "weapon_smg2", "weapon_ar2" } );
table.insert( defaultWeapons, { "weapon_crossbow", "weapon_shotgun" } );
table.insert( defaultWeapons, { "weapon_frag", "weapon_rpg" } );

function tbl.slotEditorPost( fileExists, tableData )
	if( fileExists and tableData ) then table.Merge( defaultWeapons, tableData ); end
	
	local width, height = 900 * tbl.uiScale, 800 * tbl.uiScale
	local f = vgui.Create( "DFrame" );
	
	f:SetTitle( "" );
	f:SetSize( width, height );
	f:Center();
	f:MakePopup();
	
	-- holds the DListLayouts for each slot
	-- 1 -> maxSlots
	local slotLayouts = {}
	
	local frameBgColor 	= Color( 44, 62, 80, 225 )
	local bgColor 		= Color( 0, 0, 0, 200 );
	local slotBgColor 	= Color( 127, 140, 141, 100 );
	local weaponColor	= Color( 41, 128, 185, 200 );
	local hoverColor	= Color( 51, 51, 100, 200 );
	
	f.Paint = function( self, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, frameBgColor );
		draw.SimpleText( "Slot Configuration", "dtjVGUI", (width / 2), 20, _, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
	end
	
	local r = function( receiver, tableOfDroppedPanels, isDropped, menuIndex, x, y )
		if( isDropped ) then
			receiver:Add( tableOfDroppedPanels[1] );
			print(tableOfDroppedPanels[1])
			PrintTable(receiver:GetChildren());
		end
	end
	
	local slotBtnFnc = function( self )
		local menu = DermaMenu()
		
		menu:AddOption( "Rename Slot", function() 
		end ):SetIcon( "icon16/note_edit.png" );
		
		menu:AddSpacer();
		
		menu:AddOption( "Empty Slot", function() 
		end ):SetIcon( "icon16/delete.png" );
		
		menu:Open()
	end
	
	local list = function( parent, width, height )
		local container = vgui.Create( "EditablePanel", parent );
		container:SetWidth( width );
		
		local b = vgui.Create( "DButton", container );
		b:Dock( TOP );
		b:SetText( "SLOT" );
		b:DockMargin( 0, 0, 0, 5 );
		b.DoClick = slotBtnFnc
		
		local sp = vgui.Create( "DScrollPanel", container );
		sp:Dock( TOP );
		sp:SetTall( height - 65 );
		
		sp.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, slotBgColor );
		end
		
		local list = vgui.Create( "DListLayout", sp );
		list:SetWidth( width );
		list:SetTall( height );
		
		list:Receiver( "dtjWeaponItem", r );
		list:MakeDroppable( "dtjWeaponItem_Entry" );
		list.slotHeaderBtn = b
		
		return container, list
	end
	
	local weaponName = function( weaponTbl )
		if( not weaponTbl ) then return "" end
		local name = weaponTbl.ClassName or ""
		
		if( weaponTbl.PrintName ) then name = weaponTbl.PrintName end
		if( weaponTbl.Name ) then name = weaponTbl.Name end
		
		return name
	end
	
	local weaponPanel = function( weaponTbl )
		local name = weaponName( weaponTbl )
		if( not name or string.len( name ) < 1 ) then return end
		
		local p = vgui.Create( "DLabel" );
		
		p:Droppable( "dtjWeaponItem" );
		p:SetText( "" );
		p:SetToolTip( name .. " (" .. weaponTbl.ClassName .. ")" );
		
		p.wpnClass = weaponTbl.ClassName
		
		surface.SetFont( "DermaDefaultBold" );
		local tW, tH = surface.GetTextSize( name );
		
		p:SetSize( tW + 5, tH + 5 );
		
		p.Paint = function( self, w, h )
			if( self:IsHovered() ) then
				draw.RoundedBox( 4, 0, 0, w, h, hoverColor );
			else
				draw.RoundedBox( 4, 0, 0, w, h, weaponColor);
			end
			
			draw.SimpleText( name, "DermaDefaultBold", w/2, h/2, _, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
		end
		
		return p
	end
	
	local p = f:Add( "DPanel" );
	p:Dock( FILL );
	p:DockPadding( 5, 5, 5, 5 );
	p:SetPaintBackground( false );
	
	local buttons = vgui.Create( "DPanel", p );
	buttons:SetTall( math.max( ( height * 0.05 ), 30 ) );
	
	buttons:Dock( BOTTOM );
	buttons:DockMargin( 0, 5, 0, 0 );
	buttons:DockPadding( 5, 5, 5, 5 );
	buttons.Paint = function( self, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, bgColor );
	end
	
	local function genSlotTable( submitToServer )
		local t = {}
		
		for i = 1, #slotLayouts do
			t[i] = { title = slotLayouts[i].slotHeaderBtn:GetText() }
			for k, v in pairs( slotLayouts[i]:GetChildren() ) do
				table.insert( t[i], v.wpnClass );
			end
		end
		PrintTable( t );
		if( submitToServer ) then
			local json = util.TableToJSON( t ) or ""
			local dataLen = json:len()
			
			if( dataLen >= 65533 ) then
				tbl.notify( "This slot configuration is too large. Please see your console." );
				ErrorNoHalt( "Slot configuration too large to send to client, please submit a support ticket. Size: '" .. datalen .. "'" );
			end
			
			if( dataLen <= 1 ) then
				ErrorNoHalt( "Error generating slot config table" );
				return
			end
			
			net.Start( "dtj_w_slotconfig" );
			
			net.WriteBit( 0 );
			net.WriteString( json );
			
			net.SendToServer();
			
			tbl.notify( tbl.lang["sending"] );
		end
	end
	
	local b = buttons:Add( "DButton" );
	b:SetText( "Save" );
	b:Dock( RIGHT );
	b.DoClick = function()
		genSlotTable( true );
	end
	
	local b = buttons:Add( "DButton" );
	b:SetText( "Help" );
	b:Dock( LEFT );
	b.DoClick = function()
		gui.OpenURL( "https://www.gmodstore.com/scripts/view/4777" );
	end
	
	local scroll = p:Add( "DScrollPanel" );
	scroll:Dock( BOTTOM );
	scroll:SetTall( ( height * 0.60 ) - 50 );
	scroll:DockPadding( 5, 5, 5, 5 );
	
	scroll.Paint = function( self, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, bgColor );
	end
	
	local label = createLabel(p, "Available Weapons:", true, _, true );
	label:Dock( BOTTOM );
	label:DockMargin( 5, 5, 5, 5 );
	
	local wLayout = scroll:Add( "DIconLayout" );
	wLayout:Dock( FILL );
	wLayout:SetSpaceY( 5 );
	wLayout:SetSpaceX( 5 );
	wLayout:SetBorder( 8 );
	wLayout:Receiver( "dtjWeaponItem", r );
	
	tbl.test = wLayout
	
	-- load all weapons avaiable to us
	local loadedSweps = weapons.GetList();
	
	-- attempt to sort alphabetically
	table.sort( loadedSweps, function( a, b )
		local name1 = a.PrintName or a.Name or a.ClassName
		local name2 = b.PrintName or b.Name or b.ClassName
		return ( name1 < name2 )
	end );
	
	for k, v in pairs( loadedSweps ) do
		local p = weaponPanel( v );
		local item = nil
		
		if( not IsValid( p ) ) then
			tbl.print( "failed to verify weapon: '" .. v.ClassName .. "'" );
		else
			item = wLayout:Add( p );
		end
	end
	
	--createLabel(p, "Current Layout:" );
	local label = createLabel(p, "Current Layout:", true, _ , true );
	label:Dock( TOP );
	label:DockMargin( 0, 0, 0, 5 );
	
	local slotContainer = p:Add( "DPanel" );
	slotContainer:Dock( TOP );
	slotContainer:SetTall( ( height * 0.40 ) - 85 );
	slotContainer:DockPadding( 5, 5, 5, 5 );
	
	slotContainer.Paint = function( self, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, bgColor );
	end
	
	local listWidth = ( width / tbl.config.maxSlots ) - 10
	local listHeight = ( height * 0.40 ) - 60
	
	for i = 1, tbl.config.maxSlots do
		local l, listLayout = list( slotContainer, listWidth, listHeight );
		l:Dock( LEFT );
		l:DockMargin( 0, 0, 5, 0 );
		
		if( defaultWeapons[i] ) then
			for k = 1, #defaultWeapons[i] do
				local weaponClass = defaultWeapons[i][k]
				local weaponTbl = weapons.GetStored( weaponClass );
				
				if( weaponTbl ) then
					listLayout:Add( weaponPanel( weaponTbl ) );
				else
					listLayout:Add( weaponPanel( { ClassName = weaponClass } ) );
				end
			end
		end
		
		slotLayouts[i] = listLayout
	end
end

function tbl.showSettings()
	local width, height = 600 * tbl.uiScale, 350 * tbl.uiScale
	tbl.showMenu();
	
	local p = vgui.Create( "DFrame" );
	p:SetSize( width, height );
	p:SetTitle( "Weapons HUD Settings" );
	p:Center();
	p.OnClose = function()
		tbl.hideMenu();
	end
	
	-- account for padding
	local width = ( 580 / 3 );
	
	p.left = vgui.Create( "DPanel" );
	p.left:SetParent( p );
	p.left:Dock( LEFT );
	p.left:SetWidth( width );
	p.left:DockPadding( 5, 5, 5, 5 );
	p.left:DockMargin( 0, 0, 5, 0 );
	
	createLabel( p.left, "Colors" );
	
	local cMixer = p.left:Add( "DColorMixer" );
	cMixer:SetPalette( false );
	cMixer:Dock( TOP );
	cMixer:DockMargin( 0, 5, 0, 15 );
	cMixer:SetHeight( 180 );
	cMixer:SetColor( tbl.config.mainColor );
	cMixer.selectedColor = 1
	
	cMixer.ValueChanged = function( self, color )
		if( self.selectedColor == 1 ) then
			tbl.config.mainColor = color
		elseif( self.selectedColor == 2 ) then
			tbl.config.selectColor = color
		elseif( self.selectedColor == 3 ) then
			tbl.config.titleColor = color
		elseif( self.selectedColor == 4 ) then
			tbl.config.slotColor = color
		end
	end
	
	-- DISABLED FOR THIS MINUTE
	--if( false ) then
		CAMI.PlayerHasAccess( LocalPlayer(), tbl.config.priv, function( hasAccess, reason )
			if( hasAccess == true ) then
				local adminBtn = p.left:Add( "DButton" );
				adminBtn:Dock( BOTTOM );
				adminBtn:SetText( "Admin Configuration" );
				adminBtn.DoClick = function()
					tbl.hideMenu( true );
					
					p:Remove();
					
					tbl.slotEditor();
				end
			end
		end )
	--end
	
	local defaults = p.left:Add( "DButton" );
	defaults:Dock( BOTTOM );
	defaults:SetText( "Reset to Defaults" );
	defaults:DockMargin( 0, 5, 0, 5 );
	defaults.DoClick = function()
		tbl.hideMenu( true );
		if( tbl.config.useThemes == true ) then tbl.themes.select( "default" ); end
		
		-- cheap, but works
		include( "dtj_w_sh_config.lua" );
		
		p:Remove();
		tbl.showSettings();
	end
	
	local cbox = p.left:Add( "DComboBox" );
	cbox:Dock( BOTTOM );
	cbox:SetSortItems( false );
	
	cbox:AddChoice( "Main Color", { 1, tbl.config.mainColor } );
	cbox:AddChoice( "Select Color", { 2, tbl.config.selectColor } );
	cbox:AddChoice( "Title Color", { 3, tbl.config.titleColor } );
	cbox:AddChoice( "Slot Header Color", { 4, tbl.config.slotColor } );
	
	cbox:ChooseOptionID( 1 );
	cbox.OnSelect = function( self, index, value, data )
		cMixer.selectedColor = data[1]
		cMixer:SetColor( data[2] );
	end
	
	p.right = vgui.Create( "DPanel" );
	p.right:SetParent( p );
	p.right:Dock( FILL );
	p.right:SetWidth( width );
	p.right:DockPadding( 5, 5, 5, 5 );
	
	createLabel( p.right, "Features" );
	
	local x, y = 5, 25
	local enabled = ( tbl.enabled() ~= 0 )
	
	local cb0 = createCheckBox( p.right, x, y, "Enabled", { r = 0, g = 0, b = 0, a = 255 }, enabled, 
		function( self, bVal ) tbl.clEnabled:SetBool( bVal ); 
	end );
	
	local cb1 = createCheckBox( p.right, x, y * 2, "Show Icons", { r = 0, g = 0, b = 0, a = 255 }, tbl.config.showIcons, 
		function( self, bVal ) tbl.config.showIcons = bVal; 
	end );
	
	local cb2 = createCheckBox( p.right, x, y * 3, "Show Tooltips", { r = 0, g = 0, b = 0, a = 255 }, tbl.config.showTooltip,
		function( self, bVal ) tbl.config.showTooltip = bVal;
	end );
	
	local cb3 = createCheckBox( p.right, x, y * 4, "Show Titles", { r = 0, g = 0, b = 0, a = 255 }, tbl.config.showTitles,
		function( self, bVal ) tbl.config.showTitles = bVal;
	end );
	
	if( GetConVar( "dtj_weaponhud_enabled" ):GetInt() ~= 2 ) then
		local l = createLabel( p.right, "The server currently has the custom Weapon HUD disabled.\nYou can still however make changes.", true );
		l:SetPos( x, y * 5);
	end
	
	local t = p.right:Add( "DTextEntry" );
	t:SetNumeric( true );
	t:SetValue( tbl.config.showTime );
	t:SetPos( x + 150, y );
	t.OnValueChange = function( self, value )
		value = tonumber( value or 0 );
		tbl.config.showTime = value
	end
	
	local label = createLabel( p.right, "Display time (in seconds)\nUse 0 to stay open", true, true );
	label:SetPos( x + 225, y );
	
	-- a forced theme isn't set, allow us to change it
	if( tbl.config.forceTheme == "" and tbl.config.useThemes == true ) then
		label = p.right:Add( "DLabel" );
		label:SetText( "Theme" );
		label:SetDark( true );
		label:SizeToContents()
		label:SetPos( x + 150, y + 45 );
		
		local theme = p.right:Add( "DComboBox" );
		theme:SetWidth( 200 );
		theme:SetPos( x + 150, y + 60 );
		theme:SetSortItems( false );
		theme.OnSelect = function( index, value, data )
			tbl.themes.select( data );
		end
		
		local selectedTheme = tbl.themes.getSelected();
		
		for k, v in pairs( tbl.themes ) do
			if( type( tbl.themes[k] ) == "table" ) then
				if( tbl.themes.isValid( k ) ) then 
					if( k == selectedTheme ) then
						theme:AddChoice( string.upper( k ), k, true );
					else
						theme:AddChoice( string.upper( k ), k );
					end
				end
			end
		end
	end
	
	local saveBtn = p.right:Add( "DButton" );
	saveBtn:Dock( BOTTOM );
	saveBtn:SetText( "Save" );
	saveBtn.DoClick = function()
		tbl.saveSettings();
	end
	
	local s2 = p.right:Add( "DNumSlider" );
	s2:Dock( BOTTOM );
	s2:SetText( "Top Offset" )
	s2:SetDark( true );
	s2:SetMinMax( 0, ScrH() / 2 );
	s2:SetDecimals( 0 );
	s2:SetValue( tbl.config.offset )
	s2.OnValueChanged = function( self, value )
		tbl.config.offset = value or 0
	end
	
	local mouseWheel = p.right:Add( "DComboBox" );
	mouseWheel:Dock( BOTTOM );
	mouseWheel:SetSortItems( false );
	mouseWheel:DockMargin( 0, 0, 0, 5 );
	
	mouseWheel:AddChoice( "High", "high" );
	mouseWheel:AddChoice( "Medium", "medium" );
	mouseWheel:AddChoice( "Low", "low" );
	mouseWheel.OnSelect = function( self, index, value, data )
		tbl.config.mouseSensitivity = data
	end
	
	local id = 1
	
	if( tbl.config.mouseSensitivity == "high" ) then
		id = 1
	elseif( tbl.config.mouseSensitivity == "medium" ) then
		id = 2
	else
		id = 3
	end
	
	mouseWheel:ChooseOptionID( id );
	
	label = p.right:Add( "DLabel" );
	label:SetText( "Mouse Wheel Sensitivity" );
	label:Dock( BOTTOM );
	label:SetTextColor( { r = 0, g = 0, b = 0, a = 255 } );
	
	local reloadBtn = p.right:Add( "DButton" );
	reloadBtn:Dock( BOTTOM );
	reloadBtn:SetText( "Reload Weapon Drawer" );
	reloadBtn:DockMargin( 0, 0, 0, 10 );
	reloadBtn.DoClick = function()
		if( IsValid( tbl.panel ) ) then tbl.panel:Remove(); end
		dtj.weaponHud.showMenu();
	end
	
	p:MakePopup();
end

concommand.Add( "dtj_weaponhud_settings", function()
	dtj.weaponHud.showSettings();
end );