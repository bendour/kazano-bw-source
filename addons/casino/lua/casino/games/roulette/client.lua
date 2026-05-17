-- Roulette Client-Side

if CLIENT then
	-- Recevoir le début du spin
	net.Receive("Casino_Roulette_SpinStart", function()
		local winningNumber = net.ReadUInt(8)
		local winningColor = net.ReadString()
		
		-- Appeler la fonction JavaScript
		if RouletteJS then
			RouletteJS.startSpin(winningNumber, winningColor)
		end
	end)
	
	-- Recevoir le résultat du spin
	net.Receive("Casino_Roulette_SpinResult", function()
		local winningNumber = net.ReadUInt(8)
		local winningColor = net.ReadString()
		local totalWin = net.ReadUInt(32)
		local winningBets = net.ReadTable()
		
		-- Appeler la fonction JavaScript
		if RouletteJS then
			RouletteJS.receiveSpinResult({
				winningNumber = winningNumber,
				winningColor = winningColor,
				totalWin = totalWin,
				winningBets = winningBets
			})
		end
	end)
	
	-- Recevoir la mise à jour du solde
	net.Receive("Casino_Roulette_UpdateBalance", function()
		local balance = net.ReadInt(32)
		
		if RouletteJS then
			RouletteJS.updatePlayerInfo(balance)
		end
	end)
	
	-- Recevoir la confirmation de pari
	net.Receive("Casino_Roulette_BetPlaced", function()
		local status = net.ReadString()
		local message = net.ReadString()
		
		if RouletteJS then
			RouletteJS.betPlaced(status, message)
		end
	end)
	
	-- Recevoir la mise à jour du timer
	net.Receive("Casino_Roulette_TimerUpdate", function()
		local timeRemaining = net.ReadUInt(16)
		local isSpinning = net.ReadBool()
		
		if RouletteJS then
			RouletteJS.updateTimer(timeRemaining, isSpinning)
		end
	end)
end
