--[[
	Give XP support
--]]
function CH_Advent.GiveXP( ply, amount, reason )
	if tonumber( amount ) <= 0 then
		return
	end
	
	-- Give XP (Vronkadis DarkRP Level System)
	if LevelSystemConfiguration then
		ply:addXP( amount, true )
	end
	
	-- Give XP (Sublime Levels)
	if Sublime and Sublime.Config and Sublime.Config.BaseExperience then
		ply:SL_AddExperience( amount, reason )
	end
	
	-- Give XP (Elite XP system)
	if EliteXP then
		EliteXP.CheckXP( ply, amount )
	end
	
	-- Give XP (DarkRP essentials & Brick's Essentials)
	if ( BRICKS_SERVER and BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) or ( DARKRP_ESSENTIALS and DARKRP_ESSENTIALS.CONFIG and DARKRP_ESSENTIALS.CONFIG.Enable_Leveling ) then
		ply:AddExperience( amount, reason )
	end

	-- Give XP (GlorifiedLeveling)
	if GlorifiedLeveling then
		GlorifiedLeveling.AddPlayerXP( ply, amount )
	end
	
	-- Give XP (gLevel)
	if gLevel then
		gLevel.giveExp( ply, amount )
	end
	
	-- Elixir XP
	if TSS and Elixir then
		TSS.Elixir.XP.Add_XP( ply, amount )
	end
	
	-- ELevels
	if elv then
		elv.giveXp( ply, amount )
	end
end