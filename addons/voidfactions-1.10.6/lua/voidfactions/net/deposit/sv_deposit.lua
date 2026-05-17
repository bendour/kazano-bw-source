util.AddNetworkString("VoidFactions.Deposit.DepositItem")
util.AddNetworkString("VoidFactions.Deposit.WithdrawItem")

util.AddNetworkString("VoidFactions.Deposit.DepositMoney")
util.AddNetworkString("VoidFactions.Deposit.WithdrawMoney")

local L = VoidFactions.Lang.GetPhrase

-- Functions

function VoidFactions.Deposit:NetworkDeposits(faction)
    if (VoidFactions.Settings:IsStaticFactions() and !VoidFactions.Config.DepositEnabled) then return end

    local players = {}
	for k, v in ipairs(faction.members or {}) do
		if (!IsValid(v.ply)) then continue end
		players[#players + 1] = v.ply
	end

	-- Network to players that already requested faction members/ranks 
	for k, ply in ipairs(player.GetHumans()) do
		if (ply.vf_requestedRanksFactions and ply.vf_requestedRanksFactions[faction.id]) then
			players[#players + 1] = ply
		end
	end

	net.Start("VoidFactions.Faction.UpdateFactionData")
		net.WriteUInt(faction.id, 20)
		net.WriteUInt(VoidFactions.Faction.Enums.DEPOSITS_UPDATE, 3)
        net.WriteUInt(faction.money, 32)
		net.WriteUInt(faction.deposits and table.Count(faction.deposits or {}) or 0, 16)
		for id, item in pairs(faction.deposits or {}) do
			VoidFactions.DepositItem:WriteItem(item)
		end

        net.WriteUInt(faction.transactions and #faction.transactions or 0, 16)
        for _, transaction in ipairs(faction.transactions or {}) do
            VoidFactions.Transactions:WriteTransaction(transaction)
        end
	net.Send(players)
end

-- Net handlers

net.Receive("VoidFactions.Deposit.DepositMoney", function (len, ply)
    local money = net.ReadUInt(32)

    local member = ply:GetVFMember()
    if (!member) then return end
    local faction = member.faction
    if (!faction) then return end

    if (!member:Can("DepositMoney", faction)) then return end

    local currency = VoidFactions.Currencies.List[VoidFactions.Config.DepositCurrency]
    if (!currency) then return end

    if (!currency:CanAfford(ply, money)) then return end
    currency:TakeMoney(ply, money)

    local formattedMoney = currency:FormatMoney(money)

    faction.money = faction.money + money
    VoidLib.Notify(ply, L"success", L("moneyDeposited", formattedMoney), VoidUI.Colors.Green, 5)

    VoidFactions.SQL:InsertTransactionHistory(faction, ply, money, "money")

    faction:SaveStatic()

    VoidFactions.Deposit:NetworkDeposits(faction)

    hook.Run("VoidFactions.Deposit.MoneyDeposted", faction)
end)

net.Receive("VoidFactions.Deposit.WithdrawMoney", function (len, ply)
    local money = net.ReadUInt(32)

    local member = ply:GetVFMember()
    if (!member) then return end
    local faction = member.faction
    if (!faction) then return end

    if (!member:Can("WithdrawMoney", faction)) then return end

    local currency = VoidFactions.Currencies.List[VoidFactions.Config.DepositCurrency]
    if (!currency) then return end

    local formattedMoney = currency:FormatMoney(money)

    if (faction.money - money < 0) then
        VoidLib.Notify(ply, L"error", L"noFactionMoney", VoidUI.Colors.Red, 5)
        return
    end

    currency:GiveMoney(ply, money)

    faction.money = faction.money - money
    VoidLib.Notify(ply, L"success", L("moneyWithdrawn", formattedMoney), VoidUI.Colors.Green, 5)

    VoidFactions.SQL:InsertTransactionHistory(faction, ply, -money, "money")

    faction:SaveStatic()

    VoidFactions.Deposit:NetworkDeposits(faction)    
end)

net.Receive("VoidFactions.Deposit.WithdrawItem", function (len, ply)
    local id = net.ReadUInt(20)
    local printName = net.ReadString()

    local member = ply:GetVFMember()
    if (!member) then return end
    local faction = member.faction
    if (!faction) then return end

    if (!member:Can("WithdrawItems", faction)) then return end

    local inventory = VoidFactions.Inventories.List[VoidFactions.Config.DepositInventory]
    if (!inventory) then return end

    local factionItem = faction.deposits[id]
    if (!factionItem) then return end

    inventory:GiveItem(ply, factionItem.class, factionItem.dropEnt, factionItem.model, factionItem.data)
    faction.deposits[id] = nil

    VoidFactions.SQL:WithdrawItem(faction, id)
    VoidFactions.SQL:InsertTransactionHistory(faction, ply, -1, factionItem.class)

    VoidLib.Notify(ply, L"success", L("itemWithdrawn", printName), VoidUI.Colors.Green, 5)
    
    VoidFactions.Deposit:NetworkDeposits(faction)

end)

net.Receive("VoidFactions.Deposit.DepositItem", function (len, ply)
    local itemClass = net.ReadString()
    local printName = net.ReadString()

    local member = ply:GetVFMember()
    if (!member) then return end
    local faction = member.faction
    if (!faction) then return end

    if (!member:Can("DepositItems", faction)) then return end

    local inventory = VoidFactions.Inventories.List[VoidFactions.Config.DepositInventory]
    if (!inventory) then return end

    if (!inventory:HasItem(ply, itemClass)) then return end

    local itemData = inventory:GetItemData(ply, itemClass)
    if (!itemData) then return end

    if (table.Count(faction.deposits or {}) + 1 > faction:GetMaxItems()) then return end

    inventory:TakeItem(ply, itemClass)

    VoidFactions.SQL:DepositItem(faction, itemClass, itemData.dropClass, itemData.model, itemData.data, false, function (id)
        VoidFactions.SQL:InsertTransactionHistory(faction, ply, 1, itemClass)

        VoidLib.Notify(ply, L"success", L("itemDeposited", printName), VoidUI.Colors.Green, 5)
        VoidFactions.Deposit:NetworkDeposits(faction)

        hook.Run("VoidFactions.Deposit.ItemDeposted", faction)
    end)
end)