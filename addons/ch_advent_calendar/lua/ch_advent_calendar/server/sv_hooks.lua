--[[
	Open menu via chat command
--]]
function CH_Advent.PlayerSay( ply, text )
	if string.lower( text ) == CH_Advent.Config.MenuChatCommand then
		if not CH_Advent.Config.UseChatCommand then
			return
		end
		
		-- Open the menu
		CH_Advent.OpenSquareMenu( ply )

		return ""
	end
end
hook.Add( "PlayerSay", "CH_Advent.PlayerSay", CH_Advent.PlayerSay )

net.Receive( "CH_Advent_Net_RequestSquareMenu", function( len, ply )
	-- Net delay
	local cur_time = CurTime()
	if ( ply.CH_Advent_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_Advent_NetDelay = cur_time + 0.5
	
	-- Open it
	CH_Advent.OpenSquareMenu( ply )
end )

function CH_Advent.OpenSquareMenu( ply )
	-- Check if player has access
	if not CH_Advent.HasAccess( ply ) then
		CH_Advent.Notify( ply, "Vous n'avez pas accès au calendrier de l'avent." )
		return
	end
	
	-- Get the current time
	local now = os.time()

	-- Get the current date
	local tmr_tbl = os.date( "*t", now )

	-- Set the date to the start of tomorrow (00:00)
	tmr_tbl.hour = 0
	tmr_tbl.min = 0
	tmr_tbl.sec = 0
	tmr_tbl.day = tmr_tbl.day + 1

	-- Calculate the time for the start of tomorrow
	local tomorrow = os.time( tmr_tbl )

	-- Get the difference in seconds
	local timeleft = tomorrow - now
	
	-- Get the day
	local day = os.date( "%d", os.time() )

	-- Open menu
	net.Start( "CH_Advent_Net_OpenDashboard" )
		net.WriteUInt( timeleft, 32 )
		net.WriteUInt( day, 5 )
	net.Send( ply )
end