CH_Advent.History = CH_Advent.History or {}
CH_Advent.HistoryFetched = 0

--[[
	Net to retrieve the history from DB and show the menu
--]]
net.Receive( "CH_Advent_Net_RetrieveHistory", function( len, ply )
	-- Net delay
	local cur_time = CurTime()
	if ( ply.CH_Advent_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_Advent_NetDelay = cur_time + 0.5
	
	-- Read net
	local timeleft = net.ReadUInt( 32 )
	local day = net.ReadUInt( 5 )

	-- Fetch history from DB or cached and show
	if os.time() > ( CH_Advent.HistoryFetched + CH_Advent.Config.HistoryCacheTime ) then
		CH_Advent.SQL.Query( "SELECT * FROM ch_advent_history", function( data )
			if data then
				-- Update vars
				CH_Advent.HistoryFetched = os.time()
				CH_Advent.History = data

				-- Show menu
				local history_len = #data
				
				net.Start( "CH_Advent_Net_ShowHistory" )
					net.WriteUInt( timeleft, 32 )
					net.WriteUInt( day, 5 )
					net.WriteUInt( history_len, 32 )
					
					for k, v in ipairs( data ) do
						net.WriteString( v.Nick )
						net.WriteUInt( v.Square, 5 )
						net.WriteUInt( v.Reward, 8 )
						net.WriteUInt( v.Date, 32 )
					end
				net.Send( ply )
			end
		end, false )
	
	else
		-- Show menu
		local history_len = #CH_Advent.History
		
		net.Start( "CH_Advent_Net_ShowHistory" )
			net.WriteUInt( timeleft, 32 )
			net.WriteUInt( day, 5 )
			net.WriteUInt( history_len, 32 )
			
			for k, v in ipairs( CH_Advent.History ) do
				net.WriteString( v.Nick )
				net.WriteUInt( v.Square, 5 )
				net.WriteUInt( v.Reward, 8 )
				net.WriteUInt( v.Date, 32 )
			end
		net.Send( ply )
	end
end )