
util.AddNetworkString("VoidFactions.Upgrades.SendUpgrades")

util.AddNetworkString("VoidFactions.Upgrades.CreateUpgrade")
util.AddNetworkString("VoidFactions.Upgrades.RequestUpgrades")
util.AddNetworkString("VoidFactions.Upgrades.UpdateUpgrade")
util.AddNetworkString("VoidFactions.Upgrades.DeleteUpgrade")

util.AddNetworkString("VoidFactions.Upgrades.CreatePoint")
util.AddNetworkString("VoidFactions.Upgrades.UpdatePoint")
util.AddNetworkString("VoidFactions.Upgrades.DeletePoint")

util.AddNetworkString("VoidFactions.Upgrades.PurchaseUpgrade")


local L = VoidFactions.Lang.GetPhrase

function VoidFactions.Upgrades:NetworkUpgrades()
	net.Start("VoidFactions.Upgrades.SendUpgrades")
		-- Upgrades
		net.WriteUInt(table.Count(VoidFactions.Upgrades.Custom), 10)
		for k, upgrade in pairs(VoidFactions.Upgrades.Custom) do
			VoidFactions.Upgrades:WriteUpgrade(upgrade)
		end

		-- Points
		net.WriteUInt(table.Count(VoidFactions.UpgradePoints.List), 10)
		for k, point in pairs(VoidFactions.UpgradePoints.List) do
			VoidFactions.Upgrades:WritePoint(point)
		end
	net.Broadcast()
end


-- Net handlers

net.Receive("VoidFactions.Upgrades.PurchaseUpgrade", function (len, ply)
	local member = ply:GetVFMember()
	if (!member) then return end
	if (!member.faction) then return end

	if (!member:Can("PurchasePerks", member.faction)) then return end

	local pointId = net.ReadUInt(10)
	local point = VoidFactions.UpgradePoints.List[pointId]
	if (!point) then return end

	-- Check if can afford and stuff
	local currency = point.upgrade.currency
	local cost = point.upgrade.cost

	if (!currency:CanAfford(ply, cost)) then return end

	currency:TakeMoney(ply, cost)

	if (member.faction.upgrades[pointId]) then return end

	point.upgrade.module:Equip(member.faction, point.upgrade.value)
	point.upgrade.module:Respawn(member.faction, point.upgrade.value)

	local pointsSpent = currency.name == "Upgrade Points" and cost or 0

	member.faction.spentUpgradePoints = member.faction.spentUpgradePoints + pointsSpent

	member.faction.upgrades[pointId] = true
	VoidFactions.Faction:UpdateFactionUpgrades(member.faction)
	
	VoidFactions.SQL:InsertFactionUpgrade(member.faction, point, pointsSpent)

	VoidLib.Notify(ply, L"success", L("upgradePurchased", point.upgrade.name), VoidUI.Colors.Green, 5)
	hook.Run("VoidFactions.Upgrades.UpgradeUnlocked", member.faction)
end)

net.Receive("VoidFactions.Upgrades.RequestUpgrades", function (len, ply)
	if (ply.vf_upgradesSent) then return end
	ply.vf_upgradesSent = true

	net.Start("VoidFactions.Upgrades.SendUpgrades")
		-- Upgrades
		net.WriteUInt(table.Count(VoidFactions.Upgrades.Custom), 10)
		for k, upgrade in pairs(VoidFactions.Upgrades.Custom) do
			VoidFactions.Upgrades:WriteUpgrade(upgrade)
		end

		-- Points
		net.WriteUInt(table.Count(VoidFactions.UpgradePoints.List), 10)
		for k, point in pairs(VoidFactions.UpgradePoints.List) do
			VoidFactions.Upgrades:WritePoint(point)
		end
	net.Send(ply)
end)

net.Receive("VoidFactions.Upgrades.DeleteUpgrade", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local id = net.ReadUInt(10)
	local upgrade = VoidFactions.Upgrades.Custom[id]
	if (!upgrade) then return end

	VoidFactions.SQL:DeleteUpgrade(upgrade)

	VoidLib.Notify(ply, L"success", L("upgradeDeleted", upgrade.name), VoidUI.Colors.Green, 5)

	VoidFactions.Upgrades.Custom[id] = nil
	VoidFactions.Upgrades:NetworkUpgrades()
end)

net.Receive("VoidFactions.Upgrades.CreatePoint", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local id = net.ReadUInt(10)
	local upgrade = VoidFactions.Upgrades.Custom[id]

	if (!upgrade) then return end

	local posX = net.ReadUInt(10)
	local posY = net.ReadUInt(10)

	VoidFactions.SQL:CreatePoint(upgrade, posX, posY)
end)

net.Receive("VoidFactions.Upgrades.UpdatePoint", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local id = net.ReadUInt(10)
	local point = VoidFactions.UpgradePoints.List[id]
	if (!point) then return end

	local posX = net.ReadUInt(16)
	local posY = net.ReadUInt(16)

	local relations = VoidFactions.Upgrades:ReadRelationships()

	point.to = {}

	local relationsTbl = {}
	for k, v in ipairs(relations) do
		local relationPoint = VoidFactions.UpgradePoints.List[v]
		point:AddTo(relationPoint)
	end

	point:SetPos(posX, posY)

	VoidFactions.SQL:UpdatePoint(point)
	VoidFactions.Upgrades:NetworkUpgrades()
end)

net.Receive("VoidFactions.Upgrades.DeletePoint", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local id = net.ReadUInt(10)
	local point = VoidFactions.UpgradePoints.List[id]
	if (!point) then return end

	VoidFactions.SQL:DeletePoint(point)
	VoidFactions.UpgradePoints.List[id] = nil

	VoidFactions.Upgrades:NetworkUpgrades()
end)

net.Receive("VoidFactions.Upgrades.CreateUpgrade", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local name = net.ReadString()
	local moduleName = net.ReadString()
	local value = net.ReadString()
	local currencyName = net.ReadString()
	local cost = net.ReadUInt(32)
	local icon = net.ReadString()

	local module = VoidFactions.Upgrades.Modules[moduleName]
	local currency = VoidFactions.Currencies.List[currencyName]

	if (!module or !currency) then
		VoidFactions.PrintWarning("Player " .. ply:Nick() .. " tried to create an upgrade with invalid module/currency!")
		return
	end

	VoidFactions.SQL:CreateUpgrade(name, module, value, currency, cost, icon)
	VoidLib.Notify(ply, L"success", L("upgradeCreated", name), VoidUI.Colors.Green, 5)
end)

net.Receive("VoidFactions.Upgrades.UpdateUpgrade", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end


	local upgrade = VoidFactions.Upgrades:ReadUpgrade()
	local svUpgrade = VoidFactions.Upgrades.Custom[upgrade.id]
	if (!svUpgrade) then return end

	if (!upgrade.module) then return end
	if (!upgrade.currency) then return end

	svUpgrade:SetName(upgrade.name)
	svUpgrade:SetModule(upgrade.module)
	svUpgrade:SetValue(upgrade.value)
	svUpgrade:SetCurrency(upgrade.currency)
	svUpgrade:SetCost(upgrade.cost)

	VoidFactions.SQL.UpdateUpgrade(svUpgrade)
	VoidFactions.Upgrades:NetworkUpgrades()
	VoidLib.Notify(ply, L"success", L("upgradeEdited", upgrade.name), VoidUI.Colors.Green, 5)
end)
