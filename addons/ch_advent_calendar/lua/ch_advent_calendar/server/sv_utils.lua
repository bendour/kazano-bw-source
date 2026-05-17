--[[
	Notify function that works on all gamemodes.
--]]
function CH_Advent.Notify( ply, text )
	if DarkRP then
		DarkRP.notify( ply, 1, CH_Advent.Config.NotificationTime, text )
	elseif santosRP then
		ply:AddNote( text )
	else
		ply:ChatPrint( text )
	end
end

--[[
	Helper function for admins to get team names.
	Useful for bWhitelist reward
--]]
local function CH_Advent_bWhitelist_GetTeamNames( ply )
	if not ply:IsSuperAdmin() then
		CH_Advent.Notify( ply, CH_Advent.LangString( "Only administrators can perform this action." ) )
		return
	end

	PrintTable( team.GetAllTeams() )
end
concommand.Add( "ch_advent_printallteams", CH_Advent_bWhitelist_GetTeamNames )

--[[
	Function to check if player has access to calendar
--]]
function CH_Advent.HasAccess( ply )
	if not IsValid( ply ) then return false end
	
	-- Bypass ranks always have access
	if CH_Advent.Config.RanksToBypassChecks[ ply:GetUserGroup() ] then
		return true
	end
	
	-- Check in player data
	return ply.CH_Advent_HasAccess or false
end

--[[
	Function to give access to a player
--]]
function CH_Advent.GiveAccess( steamid64, admin_name )
	admin_name = admin_name or "Console"
	
	-- Vérifier si le joueur existe déjà dans la base
	CH_Advent.SQL.Query( "SELECT SteamID64 FROM ch_advent_players WHERE SteamID64 = '".. steamid64 .."';", function( data )
		if data then
			-- Le joueur existe, on fait un UPDATE
			CH_Advent.SQL.Query( "UPDATE ch_advent_players SET HasAccess = 1 WHERE SteamID64 = '".. steamid64 .."';" )
		else
			-- Le joueur n'existe pas, on fait un INSERT
			CH_Advent.SQL.Query( "INSERT INTO ch_advent_players ( Nick, Squares, Coal, SteamID64, HasAccess ) VALUES( 'Unknown', '{}', '0', '".. steamid64 .."', 1 );" )
		end
		
		local ply = player.GetBySteamID64( steamid64 )
		if IsValid( ply ) then
			ply.CH_Advent_HasAccess = true
			CH_Advent.Notify( ply, "Vous avez reçu l'accès au calendrier de l'avent !" )
		end
		
		print( "[CH Advent] " .. admin_name .. " gave calendar access to " .. steamid64 )
	end, true )
end

--[[
	Function to remove access from a player
--]]
function CH_Advent.RemoveAccess( steamid64, admin_name )
	admin_name = admin_name or "Console"
	
	CH_Advent.SQL.Query( "UPDATE ch_advent_players SET HasAccess = 0 WHERE SteamID64 = '".. steamid64 .."';" )
	
	local ply = player.GetBySteamID64( steamid64 )
	if IsValid( ply ) then
		ply.CH_Advent_HasAccess = false
		CH_Advent.Notify( ply, "Votre accès au calendrier de l'avent a été retiré." )
	end
	
	print( "[CH Advent] " .. admin_name .. " removed calendar access from " .. steamid64 )
end

--[[
	Command to give access
--]]
local function CH_Advent_GiveAccess_Command( ply, cmd, args )
	if IsValid( ply ) and not ply:IsSuperAdmin() then
		CH_Advent.Notify( ply, CH_Advent.LangString( "Only administrators can perform this action." ) )
		return
	end
	
	if not args[1] then
		local msg = IsValid( ply ) and ply:Nick() or "Console"
		print( "[CH Advent] " .. msg .. " usage: ch_advent_giveaccess <steamid64>" )
		return
	end
	
	local admin_name = IsValid( ply ) and ply:Nick() or "Console"
	CH_Advent.GiveAccess( args[1], admin_name )
end
concommand.Add( "ch_advent_giveaccess", CH_Advent_GiveAccess_Command )

--[[
	Command to remove access
--]]
local function CH_Advent_RemoveAccess_Command( ply, cmd, args )
	if IsValid( ply ) and not ply:IsSuperAdmin() then
		CH_Advent.Notify( ply, CH_Advent.LangString( "Only administrators can perform this action." ) )
		return
	end
	
	if not args[1] then
		local msg = IsValid( ply ) and ply:Nick() or "Console"
		print( "[CH Advent] " .. msg .. " usage: ch_advent_removeaccess <steamid64>" )
		return
	end
	
	local admin_name = IsValid( ply ) and ply:Nick() or "Console"
	CH_Advent.RemoveAccess( args[1], admin_name )
end
concommand.Add( "ch_advent_removeaccess", CH_Advent_RemoveAccess_Command )

--[[
	Console command to reset DB
--]]
local confirmed = false

local function CH_Advent_Reset_Database( ply )
	if IsValid( ply ) then
		if not ply:IsSuperAdmin() then
			CH_Advent.Notify( ply, CH_Advent.LangString( "Only administrators can perform this action." ) )
			return
		end
	end
	
	-- Check confirm status
	if not confirmed then
		MsgC( Color( 255, 0, 0, 255 ), "[CH Advent] YOU ARE ABOUT TO ERASE THE ADVENT CALENDAR DATABASE!\n" )
		MsgC( Color( 255, 0, 0, 255 ), "[CH Advent] TYPE THE COMMAND AGAIN TO CONFIRM AND ERASE!\n" )
		
		confirmed = true
		
		return
	end
	
	-- Run it
	CH_Advent.SQL.Query( "DELETE FROM ch_advent_players;", function( data )
		for k, v in ipairs( player.GetAll() ) do
			CH_Advent.InitializePlayer( v )
		end
		
		CH_Advent.Leaderboard = {}
		CH_Advent.LeaderboardFetched = 0
		
		MsgC( Color( 255, 0, 0, 255 ), "[CH Advent] ALL PLAYER DATA HAS BEEN ERASED!\n" )
	end, true )
	
	CH_Advent.SQL.Query( "DELETE FROM ch_advent_history;", function( data )
		CH_Advent.History = {}
		CH_Advent.HistoryFetched = 0
		
		MsgC( Color( 255, 0, 0, 255 ), "[CH Advent] ALL PLAYER HISTORY DATA HAS BEEN ERASED!\n" )
	end, true )
end
concommand.Add( "ch_advent_reset", CH_Advent_Reset_Database )

--[[
	Look up unique id's to make sure they're unique or else notify in console!
--]]
local last_checked = 0

for k, v in ipairs( CH_Advent.Rewards ) do
	if k != v.UniqueID then
		ErrorNoHalt( "Your reward ".. v.Name .." does not have a UniqueID that matches it's key!\n" )
		print( "Please see the information at the top of sh_rewards.lua to understand how it works!" )
	end
	
	if last_checked == v.UniqueID then
		ErrorNoHalt( "Your reward ".. v.Name .." does not have a UniqueID!\n" )
		print( "Please see the information at the top of sh_rewards.lua to understand how it works!" )
	end
	
	last_checked = last_checked + 1
end