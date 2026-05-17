--[[
	Function to open a square
--]]
net.Receive( "CH_Advent_Net_OpenSquare", function( len, ply )
	-- Net delay
	local cur_time = CurTime()
	if ( ply.CH_Advent_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_Advent_NetDelay = cur_time + 0.5
	
	-- Read net
	local square = net.ReadUInt( 5 )
	
	-- Check if player has access
	if not CH_Advent.HasAccess( ply ) then
		CH_Advent.Notify( ply, "Vous n'avez pas accès au calendrier de l'avent." )
		return
	end
	
	-- If we're not in a bypass rank
	if not CH_Advent.Config.RanksToBypassChecks[ ply:GetUserGroup() ] then
		-- Check if advent calendar is locked to month
		local cur_month_name = os.date( os.date( "%B", os.time() ) )
		if CH_Advent.Config.LockToSpecificMonth and cur_month_name != CH_Advent.Config.LockedToMonth then
			CH_Advent.Notify( ply, CH_Advent.LangString( "The advent calendar is only available during" ) .." ".. CH_Advent.Config.LockedToMonth )
			return
		end
		
		-- Check if we've already opened this square
		if ply.CH_Advent_Squares[ square ] then
			CH_Advent.Notify( ply, CH_Advent.LangString( "You have already opened this square!" ) )
			return
		end
		
		-- If we disallow opening missed squares then check if this is square for today
		local day = tonumber( os.date( "%d", os.time() ) )

		if not CH_Advent.Config.CanOpenMissedSquares then
			if day != square then
				CH_Advent.Notify( ply, CH_Advent.LangString( "You can only open square" ) .." ".. day )
				return
			end
		elseif CH_Advent.Config.CanOpenMissedSquares and square > day then
			CH_Advent.Notify( ply, CH_Advent.LangString( "You can only open today and previous days!" ) )
			return
		end
	end

	-- ALL OK NOW UPDATE
	local sid64 = ply:SteamID64()

	-- Give reward
	local reward_num = CH_Advent.GiveReward( ply )
	
	-- Update tbl
	ply.CH_Advent_Squares[ square ] = reward_num
	
	-- Update squares
	CH_Advent.SQL.Query( "UPDATE ch_advent_players SET Squares = '".. util.TableToJSON( ply.CH_Advent_Squares ) .."' WHERE SteamID64 = '".. sid64 .."';" )
	
	-- Update coal
	if reward_num == 1 then
		CH_Advent.SQL.Query( "SELECT Coal FROM ch_advent_players WHERE SteamID64 = '".. sid64 .."';", function( data )
			if data then
				local cur_coal = tonumber( data.Coal )
				local new_coal = tonumber( cur_coal + 1 )
				
				CH_Advent.SQL.Query( "UPDATE ch_advent_players SET Coal = '".. new_coal .."' WHERE SteamID64 = '".. sid64 .."';" )
			end
		end, true )
	else
		-- Sound and confetti if enabled
		if CH_Advent.Config.ConfettiOnReward then
			local EffectPos = ply:GetPos()
			local effectdata = EffectData()
			effectdata:SetStart( EffectPos )
			effectdata:SetOrigin( EffectPos )
			effectdata:SetScale( 1 )
			util.Effect( "ch_advent_confetti", effectdata )
		end
		
		if CH_Advent.Config.SoundEmitOnReward then
			ply:EmitSound( "craphead_scripts/ch_advent_calendar/reward.mp3" )
		end
	end
	
	-- Add to history
	CH_Advent.SQL.Query( "INSERT INTO ch_advent_history ( Nick, Square, Reward, Date, SteamID64 ) VALUES( '".. CH_Advent.SQL.Escape( ply:Nick() ) .."', '".. tonumber( square ) .."', '".. tonumber( reward_num ) .."', '".. tonumber( os.time() ) .."', '".. sid64 .."');" )
	
	-- Network
	CH_Advent.NetworkSquares( ply )
	
	-- XP support
	if CH_Advent.Config.RewardXPOnOpenSquare then
		CH_Advent.GiveXP( ply, CH_Advent.Config.RewardXPAmount, CH_Advent.LangString( "XP for opening an advent calendar square." ) )
	end
	
	-- Hook (blogs)
	local reward_name = CH_Advent.Rewards[ reward_num ] and CH_Advent.Rewards[ reward_num ].Name or "Deleted Reward"
	hook.Run( "CH_Advent_OpenSquare", ply, square, reward_name )
end )

--[[
	Networks the players squares
--]]
function CH_Advent.NetworkSquares( ply )
	local len = table.Count( ply.CH_Advent_Squares )
	
	net.Start( "CH_Advent_Net_NetworkSquares" )
		net.WriteUInt( len, 5 )
		
		for k, v in pairs( ply.CH_Advent_Squares ) do
			net.WriteUInt( k, 5 )
			net.WriteString( v )
		end
	net.Send( ply )
end