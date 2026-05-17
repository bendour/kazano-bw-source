net.Receive("Coinflip.Create", function(len)
	local id = net.ReadUInt(24)
	local author = net.ReadEntity()
	local money = net.ReadUInt(32)
	local announceCreation = net.ReadBool()
	local currency = net.ReadString()

	Coinflip.Games[id] = {
		author = author,
		bet = money,
		currency = currency
	}

	if (announceCreation) then
		local str = Coinflip.i18n:get("chat.created", {
			creator = author:Nick(),
			money = Coinflip:GetCurrency(currency):Format(money)
		}, ":creator: have made a coinflip worth :money:")

		chat.AddText(Coinflip.Config.ChatPrefixColor, Coinflip.Config.ChatPrefix, color_white, str)
	end

	hook.Run("Coinflip.Created", id)
end)

net.Receive("Coinflip.Create.Error", function(len)
	local str = net.ReadString()

	XeninUI:Notify(str, NOTIFY_ERROR, 5, XeninUI.Theme.Red)

	hook.Run("Coinflip.Create.Error", str)
end)

net.Receive("Coinflip.Remove", function(len)
	local id = net.ReadUInt(24)

	Coinflip.Games[id] = nil

	hook.Run("Coinflip.Removed", id)
end)

net.Receive("Coinflip.Join", function(len)
	local id = net.ReadUInt(24)
	local winner = net.ReadEntity()
	local rnd = net.ReadFloat()

	hook.Run("Coinflip.Join", id, winner, rnd)
	Coinflip.Games[id] = nil
	hook.Run("Coinflip.Removed", id)
end)

net.Receive("Coinflip.Join.Error", function(len)
	local str = net.ReadString()

	XeninUI:Notify(str, NOTIFY_ERROR, 5, XeninUI.Theme.Red)

	hook.Run("Coinflip.Join.Error", str)
end)

net.Receive("Coinflip.PlayerJoined", function(len)
	local id = net.ReadUInt(24)
	local challenger = net.ReadEntity()
	local winner = net.ReadEntity()
	local rnd = net.ReadFloat()

	hook.Run("Coinflip.PlayerJoined", id, challenger, winner, rnd)
	Coinflip.Games[id] = nil
	hook.Run("Coinflip.Removed", id)
end)

net.Receive("Coinflip.AnnounceWinner", function(len)
	local winner = net.ReadEntity()
	local money = net.ReadUInt(32)
	local loser = net.ReadEntity()
	local currency = net.ReadString()
	if (!IsValid(winner)) then return end
	if (!IsValid(loser)) then return end

	local str = Coinflip.i18n:get("chat.done", {
		winner = winner:Nick(),
		loser = loser:Nick(),
		money = Coinflip:GetCurrency(currency):Format(money)
	}, ":winner: have won :money: in a coinflip against :loser:")

	chat.AddText(Coinflip.Config.ChatPrefixColor, Coinflip.Config.ChatPrefix, color_white, str)
end)

hook.Add("Coinflip.Join", "Coinflip", function(id, winner, time)
	Coinflip:CreateGame(id, LocalPlayer(), winner, time)
end)

hook.Add("Coinflip.PlayerJoined", "Coinflip", function(id, challenger, winner, time)
	Coinflip:CreateGame(id, challenger, winner, time)
end)

function Coinflip:CreateGame(id, challenger, winner, time)
	local tbl = Coinflip.Games[id]
	if (!tbl) then return end
	
	local frame = vgui.Create("Coinflip.Games.Flip")
	frame:SetInfo({
		author = tbl.author,
		challenger = challenger,
		winner = winner,
		time = time,
		money = tbl.bet * 2,
		currency = tbl.currency
	})
end

local function Menu()
	if (IsValid(Coinflip.Frame)) then return end
	
	local frame = vgui.Create("Coinflip.Frame")
  local width = math.min(ScrW(), 960)
  local height = math.min(ScrH(), 720)
  frame:SetSize(width, height)
  frame:Center()
  frame:MakePopup()
  frame:SetTitle(Coinflip.Config.MenuTitle)
end

net.Receive("Coinflip.Menu", Menu)
concommand.Add("xenin_coinflip", Menu)