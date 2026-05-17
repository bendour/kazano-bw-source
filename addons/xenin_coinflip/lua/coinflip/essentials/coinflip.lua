
function Coinflip:CreateGame(ply, money, announceCreation, announceWinner, timeLimit, currency)
	local curr = Coinflip:GetCurrency(currency)
	curr:Add(ply, -money)

	local id = table.insert(self.Games, {
		author = ply,
		money = money,
		announceWinner = announceWinner,
		timeLimit = timeLimit,
		currency = currency,
		createdAt = CurTime(),
	})

	timer.Create("Coinflip.Game." .. id, timeLimit * 60, 1, function()
		Coinflip:RefundGame(id)
	end)

	XeninUI:Notify(ply, Coinflip.i18n:get("chat.createdNotification", { id = id }, "Created coinflip with ID :id:"), 1)

	return id
end

function Coinflip:RefundGame(id, deletion)
	local tbl = self.Games[id]
	if (!tbl) then return end
	local ply = tbl.author
	if (!IsValid(ply)) then return end
	if (tbl.claimed) then return end
	tbl.claimed = true

	local curr = Coinflip:GetCurrency(tbl.currency)
	curr:Add(ply, tbl.money)
	if (!deletion) then
		local str = Coinflip.i18n:get("chat.deleted.timeLimit", {
			id = id,
			money = curr:Format(tbl.money)
		}, "Your coinflip with ID :id: has reached its timelimit. You have been refunded :money:")

		XeninUI:Notify(ply, str, ply, 10)
	else
		local str = Coinflip.i18n:get("chat.deleted.user", {
			id = id,
			money = curr:Format(tbl.money)
		}, "You deleted your coinflip with ID :id:. You have been refunded :money:")

		XeninUI:Notify(ply, str, ply, 10)
	end

	timer.Remove("Coinflip.Game." .. id)

	Coinflip.Database:DeleteGame(id, ply:SteamID64())

	net.Start("Coinflip.Remove")
		net.WriteUInt(id, 24)
	net.Broadcast()
end

hook.Add("PlayerSay", "Coinflip", function(ply, text)
  if (Coinflip.Config.ChatCommands[text:lower()]) then
    net.Start("Coinflip.Menu")
    net.Send(ply)
  end
end)