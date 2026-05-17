
--[[
	Give player a random ps2 item
--]]
function CH_Advent.GiveRandomPS2Item( ply )
	local items = Pointshop2.GetRegisteredItems()
	local itemClass = table.Random( items )
	
	return ply:PS2_EasyAddItem( itemClass.className )
end

--[[
	Give random crypto to player
--]]
function CH_Advent.GiveRandomCrypto( ply, amt )
	local list_of_random = {}
	
	-- Insert all into list
	for k, v in ipairs( CH_CryptoCurrencies.Config.Currencies ) do
		table.insert( list_of_random, v.Currency )
	end

	-- Give them random crypto
	local crypto_to_give = table.Random( list_of_random )
	CH_CryptoCurrencies.GiveCrypto( ply, crypto_to_give, amt )
	
	-- Notify
	CH_Advent.Notify( ply, CH_Advent.LangString( "This square contained" ) .." ".. amt .." ".. crypto_to_give )
end

--[[
	Run the reward function
--]]
function CH_Advent.GiveReward( ply )
    -- Collect enabled rewards and their entries values
    local enabled_rewards = {}
	
	-- Cur date as string
	local day = os.date( "%d", os.time() )

	-- Insert enabled rewards
	for _, reward in ipairs( CH_Advent.Rewards ) do
		-- Skip if not enabled
		if not reward.Enabled then
			continue
		end
		
		-- Skip if dates specified and today is not there
		if reward.DateSpecific and not reward.DateSpecific[ day ] then
			continue
		end

		-- Insert each reward multiple times based on its entries
		for i = 1, reward.Entries do
			table.insert( enabled_rewards, reward )
		end
	end

	-- Randomly select a reward from the list based on entries
	local selected_reward = table.Random( enabled_rewards )
	selected_reward.RewardFunction( ply )

	return selected_reward.UniqueID
end
