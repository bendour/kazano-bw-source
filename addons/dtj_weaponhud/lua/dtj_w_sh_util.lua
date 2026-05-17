local tbl = dtj.weaponHud
local meta = FindMetaTable( "Player" );

--[[
	Purpose: Simple wrapper functions for notifying the player
--]]
local c = Color( 25, 125, 175 );
function dtj.weaponHud.print( varargs )
	if( not tbl.config.showMessages ) then return end
	MsgC( c, "[DTJ Weapon Drawer] " );
	MsgC( c, varargs );
	Msg( "\n" );
end

function dtj.weaponHud.notify( text )
	notification.AddLegacy( text, NOTIFY_GENERIC, 6.0 );
	surface.PlaySound( "buttons/button15.wav" );
	dtj.weaponHud.print( text );
end

-- ADMIN MOD INTERFACE
CAMI.RegisterPrivilege( {
	Name = tbl.config.priv or "dtj_weaponhud",
	MinAccess = "superadmin",
	Description = "Ability to modify the Weapon Drawer server-wide"
} );

-- shared convar to allow setting in runtime
CreateConVar( "dtj_weaponhud_enabled", "2", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, 
	"0 = hud disabled. 1 = hud forced enabled, with default/server settings. 2 = user can enable/disable, and adjust settings." );
	
CreateConVar( "dtj_weaponhud_serverslots", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, 
	"0 = ignore server slot config, 1 = use server configured slots" );
	
CreateConVar( "dtj_weaponhud_guid", "", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, 
	"DO NOT TOUCH" );
	
if( CLIENT ) then
	tbl.clEnabled = CreateClientConVar( "dtj_weaponhud_draw", "1", _, _, "Enables/Disables drawing of the replacement Weapon HUD" );
end

local enabledVar 	= GetConVar( "dtj_weaponhud_enabled" );
local serverSlots	= GetConVar( "dtj_weaponhud_serverslots" );
local serverGuid	= GetConVar( "dtj_weaponhud_guid" );
local fastSwitch 	= GetConVar( "hud_fastswitch" );

function tbl.enabled()
	if( CLIENT ) then
		if( tbl.clEnabled:GetBool() == false ) then return 0 end
	end
	return enabledVar:GetInt();
end

function tbl.serverSlots()
	return serverSlots:GetBool();
end

function tbl.serverGuid()
	return serverGuid:GetString();
end

function tbl.fastSwitch()
	return fastSwitch:GetBool()
end

--[[
	Prevent players from sending/requesting net info
	too soon.
--]]
function meta:dtjNetCooldown()
	local curTime = CurTime();
	local plTime = self.dtjCooldown or ( curTime - 120 )
	
	if( curTime - plTime < 1 ) then
		return false
	end
	
	self.dtjCooldown = curTime
	return true
end


if( CLIENT ) then
	tbl.uiScale = math.Clamp( ( ScrW() / 2000 ) * math.Clamp( tbl.config.scale or 1, 0.5, 1.5 ), 0.5, 1.0 );
	tbl.fontScale = math.Clamp( ( ScrH() / 1000 ) * math.Clamp( tbl.config.scale or 1, 0.5, 1.5 ), 0.5, 1.0 );
	
	-- Wrapper for sound playing
	-- surface.PlaySound is actually way to loud??
	function tbl.playSound( sndFile )
		EmitSound( sndFile, LocalPlayer():GetPos(), LocalPlayer():EntIndex(), CHAN_AUTO, 1, 35 );
	end
	
	surface.CreateFont( "dtjVGUI", {
		font = "Coolvetica",
		size = 24 * tbl.fontScale,
		weight = 500,
		antialias = true,
		additive = true,
		outline = true
	} )
	
	surface.CreateFont( "dtjWeaponSlotID", {
		font = "Roboto",
		size = 20,
		weight = 500,
		antialias = true,
		additive = true,
		outline = true
	} )
	
	surface.CreateFont( "dtjWeaponInfoBold", {
		font = "Tahoma",
		size = 15,-- * tbl.fontScale,
		weight = 1500,
		additive = true
	} )
	
	surface.CreateFont( "dtjWeaponInfo", {
		font = "Tahoma",
		size = 15,-- * tbl.fontScale,
		antialias = true
	} )
	
	surface.CreateFont( "dtjWeaponError", {
		font = "Roboto",
		size = 24 * tbl.fontScale;
		weight = 500,
		antialias = true,
		scanlines = 2
	} )
	
	surface.CreateFont( "dtjWeaponErrorSmall", {
		font = "Roboto",
		size = 19 * tbl.fontScale,
		antialias = true,
		blursize = 1,
		scanlines = 2
	} )
	
	surface.CreateFont( "dtjWeaponName", {
		font = "Roboto Bk",
		size = 24 * tbl.fontScale,
		weight = 500,
		antialias = true,
		additive = true,
		outline = true
	} )
	
	surface.CreateFont( "dtjWeaponNameQV", {
		font = "Roboto Bk",
		size = 18 * tbl.fontScale,
		weight = 500,
		antialias = true,
		additive = true,
		outline = true
	} )
	
	surface.CreateFont( "dtjWeaponSlotName", {
		font = "Roboto",
		size = 18 * tbl.fontScale;
		weight = 500,
		antialias = true,
		additive = true
	} )
	
	surface.CreateFont( "dtjHL2", {
		font = "HalfLife2",
		size = 124 * tbl.fontScale,
		weight = 500,
		scanlines = 2,
	} )
	
	tbl.cstrike = IsMounted( "cstrike" );
	if( tbl.cstrike == true ) then
		surface.CreateFont( "dtjCStrike", {
			font = "csd",
			size = 128 * tbl.fontScale,
			weight = 500,
			scanlines = 2
		} )
	end
	
	surface.CreateFont( "dtjWeaponNameSmall", {
		font = "Roboto Bk",
		size = 19 * tbl.fontScale,
		weight = 500,
		bold = true,
		antialias = true,
		additive = true,
		outline = true
	} )
	
	surface.CreateFont( "dtjWeaponName", {
		font = "Roboto Bk",
		size = 24 * tbl.fontScale,
		weight = 500,
		antialias = true,
		additive = true,
		outline = true
	} )
	
	-- cache font size
	surface.SetFont( "dtjWeaponNameSmall" );
	local _, tH = surface.GetTextSize( "XXX / XXX" );
	
	-- height of the ammo text
	tbl.ammoHeight = tH
	
	surface.SetFont( "dtjWeaponName" );
	local _, tH = surface.GetTextSize( "THIS IS MY WEAPON NAME" );
	
	-- height of the weapon name text
	tbl.weaponNameHeight = tH
	
	-- chars for the HL2 font
	dtj.weaponHud.hl2Icons = {}
	dtj.weaponHud.hl2Icons["weapon_357"] = 'e';
	dtj.weaponHud.hl2Icons["weapon_annabelle"] = 'b';
	dtj.weaponHud.hl2Icons["weapon_ar2"] = 'l';
	dtj.weaponHud.hl2Icons["weapon_bugbait"] = 'j';
	dtj.weaponHud.hl2Icons["weapon_crossbow"] = 'g';
	dtj.weaponHud.hl2Icons["weapon_crowbar"] = 'c';
	dtj.weaponHud.hl2Icons["weapon_frag"] = 'k';
	dtj.weaponHud.hl2Icons["weapon_physcannon"] = 'm';
	dtj.weaponHud.hl2Icons["weapon_physgun"] = 'h';
	dtj.weaponHud.hl2Icons["weapon_pistol"] = 'd';
	dtj.weaponHud.hl2Icons["weapon_rpg"] = 'i';
	dtj.weaponHud.hl2Icons["weapon_shotgun"] = 'b';
	dtj.weaponHud.hl2Icons["weapon_smg1"] = 'a';
	dtj.weaponHud.hl2Icons["weapon_stunstick"] = 'n';
	dtj.weaponHud.hl2Icons["weapon_slam"] = 'o';
	
	-- override weapon class slot positions, regardless of SWEP slotpos settings
	-- by default this layout matches the HL2 default
	dtj.weaponHud.slotPos = {
		["weapon_crowbar"] = -3,
		["weapon_physcannon"] = -2,
		["weapon_physgun"] = -1,
			
		["weapon_pistol"] = -3,
		["weapon_357"] = -2,
		
		["weapon_smg1"] = -3,
		["weapon_ar2"] = -2,
		
		["weapon_crossbow"] = -3,
		["weapon_shotgun"] = -2,
		
		["weapon_frag"] = -3,
		["weapon_rpg"] = -2,
	}
end -- CLIENT

--[[
	Hooks and overrides
]]

if( CLIENT ) then
	-- disable the default weapon hud panel
	hook.Add( "HUDShouldDraw", "dtjHideDefaultHUD", function( name )
		if( tbl.enabled() > 0 and ( name == "CHudWeaponSelection" or name == "TTTWSwitch" ) ) then return false end;
	end );
	
	-- player commands
	-- lastinv, inv next/prev (mouse wheel typically)
	
	-- used for maintaining the position while in "fastswitch" mode
	tbl.mWheel = tbl.mWheel or 0
	tbl.slotSelection = tbl.slotSelection or 0
	
	hook.Add( "PlayerBindPress", "dtjWeaponChange_PlayerBind", function( ply, bind, down )
		if( not down or not ply:IsValid() or not ply:Alive() ) then 
			return 
		end
		
		-- terrortown workaround
		-- when "spectating" the player is still alive
		if( ply.Spec and ply:Spec() ) then
			return
		end
		 
		if( tbl.enabled() <= 0 ) then
			return
		end
		
		-- sandbox allows moving objects via the physgun and mousewheel, don't open weapon selector if we are "doing" that.
		local wep = ply:GetActiveWeapon();
		if( IsValid( wep ) ) then
			if( wep:GetClass() == "weapon_physgun" ) then
				if( bind ~= "+attack" and input.IsMouseDown( MOUSE_LEFT ) ) then return end
			end
			
			-- CW Weapon
			if( wep.CW20Weapon and wep.dt and ( wep.dt.State == 2 or wep.dt.State == 4 ) ) then return end
			
			--[[
				CW_IDLE = 0
				CW_RUNNING = 1
				CW_AIMING = 2
				CW_ACTION = 3
				CW_CUSTOMIZE = 4
				CW_HOLSTER_START = 5
				CW_HOLSTER_END = 6
				CW_PRONE_BUSY = 7 -- entering/leaving prone state
				CW_PRONE_MOVING = 8 -- crawling while prone
			-]]
		end
		
		-- select this weapon
		if( bind == "+attack" or input.WasMousePressed( MOUSE_LEFT ) ) then
			if( not tbl.panel or not IsValid( tbl.panel ) ) then
				return
			end
			
			tbl.hideMenu();
			--print("SWITCHING TO: " .. tbl.panel.wpn:GetClass())
			tbl.switchWeapon( tbl.panel.wpn );
			
			return true 
		end
		
		-- gives you the ability to close the menu with the secondary attack/mouse2
		if( IsValid( tbl.panel ) and ( bind == "+attack2" or input.IsMouseDown( MOUSE_RIGHT ) ) ) then
			tbl.hideMenu(); 
			return true
		end
		
		-- last weapon swap
		if( bind == "lastinv" and ply.LastInv ) then
			tbl.switchWeapon( ply.LastInv );
			return true
		end
		
		local fast = fastSwitch:GetBool();
		if( bind:sub( 1, 3 ) == "inv" ) then
			if( bind == "invnext" or bind == "invprev" ) then
				-- if we allow weapon switching in vehicles, don't allow the mousewheel scroll (zooming in and out in thirdperson for vehicles)
				-- just allow the slot selection/viewing
				if( tbl.config.inVehicle == true and ply:InVehicle() ) then
					return
				end
				
				-- inhibit scrolling too fast, if enabled.
				if( tbl.lastScroll and tbl.lastScroll > SysTime() ) then 
					return
				end
				
				tbl.updateWeaponTbl();
				if( not tbl.plWeapons or tbl.plWeapons.count < 1 ) then return end;
				
				-- some users are expressing 'nil'
				tbl.mWheel = tbl.mWheel or 0
				
				if( bind == "invnext" ) then
					if( tbl.mWheel >= tbl.plWeapons.count ) then
						tbl.mWheel = 0
					end

					if( tbl.mWheel < tbl.plWeapons.count ) then
						tbl.mWheel = tbl.mWheel + 1
					end
				else
					if( tbl.mWheel <= 1 ) then
						tbl.mWheel = tbl.plWeapons.count + 1
					end
	 
					if( tbl.mWheel > 1 ) then
						tbl.mWheel = tbl.mWheel - 1
					end
				end
				
				local s = tbl.config.mouseSensitivity
				if( s ~= "high" ) then
					local scrollTime = 0.05;
					
					if( s == "low" ) then
						scrollTime = 0.10;
					elseif( s == "medium" ) then
						scollTime = 0.05
					end
					
					tbl.lastScroll = SysTime() + scrollTime;
				end
				
				local slot, section = dtj.weaponHud.idToSlot( tbl.mWheel );
				--print( "mwheel: " .. tbl.mWheel .. " s: " .. slot .. " section: " .. section )
				if( fast == true ) then
					tbl.switchWeapon( tbl.plWeapons[slot][section] );
				else
					dtj.weaponHud.showMenuAndSlot( slot, section );
				end
			end
			return
		end
		
		-- !TODO!
		-- Make this handle "hud fastswitch". Currently this still opens the drawer
		if( bind:sub( 1, 4 ) == "slot" ) then
			local slot = tonumber( bind[5] );
			local maxSlots = tbl.config.maxSlots or 6
			
			-- only handle slots 1-maxSlots
			if( slot and ( slot <= maxSlots and slot >= 1 ) ) then
				dtj.weaponHud.showMenuAndSlot( slot );
				-- keep mouse wheel selection in-sync
				tbl.mWheel = dtj.weaponHud.weaponSlotId( tbl.panel.wpn );
				--return true;
				return
			end
			
			return
		end
	end)
	
end -- CLIENT

if( CLIENT ) then
	--[[
		Proper weapon switching
		See: http://wiki.garrysmod.com/page/CUserCmd/SelectWeapon
	--]]

	function meta:SelectWeapon( class )
		if( not self:HasWeapon( class ) ) then 
			return 
		end
		
		self.DoWeaponSwitch = self:GetWeapon( class );
	end
	
	hook.Add( "CreateMove", "WeaponSwitch", function( cmd )
		local lp = LocalPlayer();
		
		if( not IsValid( lp.DoWeaponSwitch ) ) then
			return 
		end

		cmd:SelectWeapon( lp.DoWeaponSwitch );

		if( lp:GetActiveWeapon() == lp.DoWeaponSwitch ) then
			lp.DoWeaponSwitch = nil
		end
	end )

	function tbl.switchWeapon( weaponObj, noSound )
		if( weaponObj and IsValid( weaponObj ) ) then
			local lp = LocalPlayer();
			
			lp.LastInv = lp:GetActiveWeapon();
			
			if( lp:GetActiveWeapon() == weaponObj ) then
				return
			end
			
			lp:SelectWeapon( weaponObj:GetClass() );
			
			if( not noSound and tbl.config.selectedSound ) then
				tbl.playSound( tbl.config.selectedSound );
			end
		end
	end

	--[[
		Resize a width & height, and maintain a decent aspect ratio.
		Used for the icons shown on the weapon drawer
	]]--
	function tbl.resizeImage( w, h, desiredWidth, desiredHeight )
		local newWidth, newHeight = w, h
		
		if( w <= desiredWidth ) then
			newWidth = w;
		end
		
		newHeight = h * newWidth / w
		
		if( newHeight > desiredHeight ) then
			newWidth = w * desiredHeight / h
			newHeight = desiredHeight
		end
		
		return newWidth, newHeight
	end
	
	--[[
		Cache any custom icons given in the config
		Material() loads or RETURNS, but the wiki states call Material() outside of frame calls?
	--]]
	local matCache = {}
	function tbl.getIconMat( icon )
		if( not matCache[icon] ) then
			matCache[ icon ] = Material( icon )
		else
			return matCache[icon]
		end
		return matCache[icon]
	end
	
	--[[
		Cache the markup created for this weapon object
	]]
	local markupCache = {}
	local markupCacheSmall = {}
	
	-- hook a theme change
	-- when it does, clear our cache (incase the theme changed our font)
	hook.Add( "dtjThemeSelected", "dtjClearCache", function()
		tbl.print( "theme selected, clearing cache.." );
		markupCache = {}
	end );
	
	function tbl.nameMarkup( wepObject, name, maxWidth, small, font )
		if( small ) then
			if( markupCacheSmall[ wepObject ] ) then 
				return markupCacheSmall[ wepObject ] 
			end
			
			markupCacheSmall[ wepObject ] = markup.Parse( "<font=dtjWeaponNameQV>" .. name .. "</font>", maxWidth );
			return markupCacheSmall[ wepObject] 
		end
		
		if( markupCache[ wepObject ] ) then return markupCache[ wepObject ] end
		
		local m = nil
		if( font ) then
			m = markup.Parse( string.format( "<font=%s>%s</font>", font, name ), maxWidth );
		else
			m = markup.Parse( "<font=dtjWeaponName>" .. name .. "</font>", maxWidth );
		end
		
		markupCache[ wepObject ] = m
		
		return m
	end
	
	--[[
		Attempt to automatically fix up some weapon names
	--]]
	local nameCache = {}
	local lg = language.GetPhrase
	local bold = tbl.config.bold
	
	function tbl.fixupWeaponName( wep )
		local wepName = wep:GetPrintName() or wep.PrintName or "..."
		wepName = lg( wepName ); -- attempt to use garry's mod built in language phrase
		
		if( nameCache[wepName] ) then
			return nameCache[ wepName ]
		end
		
		-- TTT has it's own function to grab weapon names
		local gamemode = engine.ActiveGamemode();
		if( gamemode == "terrortown" ) then
			if( LANG and LANG.TryTranslation ) then
				nameCache[wepName] = LANG.TryTranslation( wepName );
				return nameCache[wepName]
			end
		end
		
		if( bold ) then
			nameCache[wepName] = wepName:upper();
		else
			nameCache[wepName] = wepName
		end
		
		return nameCache[wepName]
	end
	
	--[[
		Returns the largest slot title width
		Used to help scale the slot headers, to make sure the titles always fit
	--]]
	function tbl.getSlotNameWidth()
		if( tbl.config.customMenu == true ) then
		else
			local t = table.Copy( tbl.config.titles );
			
			table.sort( t, function( a, b ) 
				return a:len() > b:len(); 
			end );
			
			surface.SetFont( "dtjWeaponName" );
			local tW, _ = surface.GetTextSize( t[1] );
			
			return tW;
		end
	end
	
	function tbl.getSlotHeight( slot )
		return #tbl.plWeapons[slot] * tbl.config.expandedHeight
	end
	
	--[[
		Converts a number between 1 - total equiped weapons
		into a slot, and position in slot value
	--]]
	function tbl.idToSlot( selection )
		local slot, section = 1, 1
		local count = 0
		
		for a = 1, #tbl.plWeapons do
			for b = 1, #tbl.plWeapons[a] do
				count = count + 1
				if( count == selection ) then
					slot = a
					section = b
					return slot, section
				end
			end
		end
		
		return slot, section
	end

	--[[
		Returns the value used for idToSlot() based on the passed weapon entity
	--]]
	function tbl.weaponSlotId( wpn )
		local count = 0
		
		for a = 1, #tbl.plWeapons do
			for b = 1, #tbl.plWeapons[a] do
				count = count + 1
				if( tbl.plWeapons[a][b] == wpn ) then
					return count
				end
			end
		end
		
		return count
	end

	--[[
		Find this weapon entity in our custom menu
		Then return it's slot number, and it's position in the table (SlotPos)
	--]]
	function tbl.getMenuSlot( wepObject )
		local maxSlots = tbl.config.maxSlots
		local class = wepObject:GetClass();
		
		for i = 1, maxSlots do
			for k = 1, #tbl.customMenu[i] do
				if( tbl.customMenu[i][k] == class ) then return i, k end
			end
		end
		
		local overflow = tbl.config.slotOverflow
		if( not overflow or overflow == 0 ) then overflow = maxSlots end
		
		-- we didn't find this weapon class 
		-- return our overflow slot, or position in the last slot
		return overflow, wepObject.SlotPos
	end

	--[[
		This will populate a table full of our weapons
		As well as sort them based on multiple sources and configurations
	--]]
	local showTitles 	= ( tbl.config.showTitles == true )
	local useCustom 	= ( tbl.config.useCustom == true )
	local autoSlot		= ( tbl.config.autoSlot == true )
	local hl2Slots		= ( tbl.config.hl2Slots == true )
	local maxSlots 		= tbl.config.maxSlots or 6
	
	function tbl.updateWeaponTbl( doForce )
		local p = LocalPlayer();
		if( not IsValid( p ) ) then return end
		
		local weapons = p:GetWeapons();
		
		-- don't update unless our weapon amount changed
		-- we force an update when we open the drawer for the first time
		if( not doForce and ( tbl.plWeapons and tbl.plWeapons.count == #weapons ) ) then return end
		
		-- let the gc clean up the old table
		tbl.plWeapons = {}
		tbl.plWeapons.count = 0
		
		local slotSize 		= {}
		local scrH 			= ScrH() - 350
		
		if(	useCustom and ( #tbl.customMenu ~= tbl.config.maxSlots ) ) then
			error( "Invalid custom menu size (" .. #tbl.customMenu .. ") while max slots (" .. tbl.config.maxSlots .. ") they must match!" );
			return
		end
		
		-- we want to use the server provided config
		-- attempt to load it
		if( not tbl.loadedSlotConfig and tbl.serverSlots() == true ) then tbl.loadServerConfig(); end
		
		for i = 1, maxSlots do
			slotSize[ i ] = tbl.config.expandedHeight
			
			if( showTitles or useCustom ) then
				if( not useCustom ) then 
					tbl.plWeapons[i] = { title = tbl.config.titles[i] or nil }
				else
					tbl.plWeapons[i]= { title = tbl.customMenu[i].title or nil }
				end
			else
				tbl.plWeapons[i] = {}
			end
		end
		
		for i = 1, #weapons do
			local v = weapons[i]
			if( IsValid ( v ) ) then
				local slot = math.min( math.abs( v:GetSlot() + 1 ), tbl.config.maxSlots );
				local class = v:GetClass()
				
				-- we are using a custom menu
				-- attempt to find out which slot we want, and it's position
				if( useCustom == true ) then
					if( hl2Slots == false or not tbl.slotPos[class] ) then
						slot, v.SlotPos = tbl.getMenuSlot( v );
					end
				end
				
				-- even if using a custom menu, re-position hl2 weapons
				if( hl2Slots == true ) then
					local class = v:GetClass()
					if( tbl.slotPos[class] ) then v.SlotPos = tbl.slotPos[ class ] end
				end
				
				if( autoSlot == true ) then
					for k = slot, #slotSize do
						if( slotSize[ k ] < scrH ) then slot = k break end
					end
					slotSize[slot] = slotSize[ slot ] + tbl.config.collapsedHeight
				end
				
				tbl.plWeapons[ slot ][ #tbl.plWeapons[slot] + 1 ] = v
				tbl.plWeapons.count = tbl.plWeapons.count + 1
			end
		end
		
		--[[
			This will sort the table (as it should be) 
				based on the SlotPos (some SlotPos values get modified above)
		--]]
		
		local tb = table.sort
		for slot = 1, maxSlots do
			tb( tbl.plWeapons[ slot ], function( a, b )
				a.SlotPos = a.SlotPos or 10
				b.SlotPos = b.SlotPos or 10
				return a.SlotPos < b.SlotPos
			end );
		end
	end
	
	--[[
		Client commands
		Showing the menu without selecting a slot/using the mouse wheel. Makes the menu show in it's "quickview" layout
	--]]
	concommand.Add( "+dtj_weaponhud_show", function()
		dtj.weaponHud.showMenu( true );
	end );

	concommand.Add( "-dtj_weaponhud_show", function() 
		dtj.weaponHud.hideMenu();
	end );
	
end -- CLIENT