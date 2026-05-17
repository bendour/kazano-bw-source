-- Le Bandit - Machine à Sous Client-Side

-- Recevoir le résultat du spin
net.Receive("Casino_Slots_SpinResult", function()
	local status = net.ReadString()
	
	if status == "error" then
		local message = net.ReadString()
		if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
			Casino.UI.HTML:Call(string.format("showNotification('%s', 'error')", message))
		end
		return
	end
	
	if status == "success" then
		local result = net.ReadTable()
		
		-- Envoyer le résultat au HTML
		if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
			Casino.UI.HTML:Call(string.format("receiveSpinResult(%s)", util.TableToJSON(result)))
		end
	end
end)

-- Mettre à jour le solde
net.Receive("Casino_Slots_UpdateBalance", function()
	local balance = net.ReadInt(32)
	
	if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
		Casino.UI.HTML:Call(string.format("updatePlayerInfo(%d)", balance))
	end
end)
