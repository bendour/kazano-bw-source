VoidFactions.Upgrades = VoidFactions.Upgrades or {}

function VoidFactions.Upgrades:CreateUpgrade(name, moduleName, value, currencyName, cost, icon)
	net.Start("VoidFactions.Upgrades.CreateUpgrade")
		net.WriteString(name)
		net.WriteString(moduleName)
		net.WriteString(value)
		net.WriteString(currencyName)
		net.WriteUInt(cost, 32)
		net.WriteString(icon)
	net.SendToServer()
end

function VoidFactions.Upgrades:UpdateUpgrade(upgrade, name, moduleName, value, currencyName, cost, icon)
	net.Start("VoidFactions.Upgrades.UpdateUpgrade")
		net.WriteUInt(upgrade.id, 10)
		net.WriteString(name)
		net.WriteString(moduleName)
		net.WriteString(value)
		net.WriteString(currencyName)
		net.WriteUInt(cost, 32)
		net.WriteString(icon)
	net.SendToServer()
end

function VoidFactions.Upgrades:PurchaseUpgrade(point)
	net.Start("VoidFactions.Upgrades.PurchaseUpgrade")
		net.WriteUInt(point.id, 10)
	net.SendToServer()
end

function VoidFactions.Upgrades:DeleteUpgrade(upgrade)
	net.Start("VoidFactions.Upgrades.DeleteUpgrade")
		net.WriteUInt(upgrade.id, 10)
	net.SendToServer()
end

function VoidFactions.Upgrades:CreatePoint(upgrade, posX, posY)
	net.Start("VoidFactions.Upgrades.CreatePoint")
		net.WriteUInt(upgrade.id, 10)
		net.WriteUInt(posX, 10)
		net.WriteUInt(posY, 10)
	net.SendToServer()
end

function VoidFactions.Upgrades:UpdatePoint(id, posX, posY, relations)
	net.Start("VoidFactions.Upgrades.UpdatePoint")
		net.WriteUInt(id, 10)
		net.WriteUInt(posX, 16)
		net.WriteUInt(posY, 16)
		VoidFactions.Upgrades:WriteRelationships(relations)
	net.SendToServer()
end

function VoidFactions.Upgrades:DeletePoint(point)
	net.Start("VoidFactions.Upgrades.DeletePoint")
		net.WriteUInt(point.id, 10)
	net.SendToServer()
end

function VoidFactions.Upgrades:RequestUpgrades(faction)
	net.Start("VoidFactions.Upgrades.RequestUpgrades")
	net.SendToServer()
end

-- Net handlers

net.Receive("VoidFactions.Upgrades.SendUpgrades", function ()
	-- Upgrades
	local upgradeLength = net.ReadUInt(10)

	local upgrades = {}
	for i = 1, upgradeLength do
		local upgrade = VoidFactions.Upgrades:ReadUpgrade()
		upgrades[upgrade.id] = upgrade
	end

	VoidFactions.Upgrades.Custom = upgrades

	-- Points
	local pointLength = net.ReadUInt(10)

	local points = {}
	local pointsKeys = {}
	for i = 1, pointLength do
		local point = VoidFactions.Upgrades:ReadPoint()
		points[i] = point
		pointsKeys[point.id] = point
	end

	-- Assign the to's Tables
	for k, v in ipairs(points) do
		v.to = {}
		for _, to in ipairs(v.toIds) do
			local toPoint = pointsKeys[to]
			v:AddTo(toPoint)
		end
	end

	VoidFactions.UpgradePoints.List = pointsKeys

	hook.Run("VoidFactions.Upgrade.UpgradesReceived", upgrades)
end)
