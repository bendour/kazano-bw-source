util.AddNetworkString("VoidFactions.Rewards.RequestRewards")
util.AddNetworkString("VoidFactions.Rewards.SendRewards")

util.AddNetworkString("VoidFactions.Rewards.CreateReward")
util.AddNetworkString("VoidFactions.Rewards.UpdateReward")
util.AddNetworkString("VoidFactions.Rewards.DeleteReward")

local L = VoidFactions.Lang.GetPhrase

-- Functions

function VoidFactions.Rewards:NetworkRewards()
	net.Start("VoidFactions.Rewards.SendRewards")
		net.WriteUInt(table.Count(VoidFactions.Rewards.List), 10)
		for k, reward in pairs(VoidFactions.Rewards.List) do
			VoidFactions.Rewards:WriteReward(reward)
		end
	net.Broadcast()
end

-- Net handlers

net.Receive("VoidFactions.Rewards.DeleteReward", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local rewardId = net.ReadUInt(10)
	local reward = VoidFactions.Rewards.List[rewardId]
	if (!reward) then return end

	local rewardName = reward.name

	VoidFactions.Rewards.List[rewardId] = nil

	VoidFactions.Rewards:NetworkRewards()
	VoidFactions.SQL:DeleteReward(reward)
	VoidLib.Notify(ply, L"success", L("rewardDeleted", rewardName), VoidUI.Colors.Green, 5)
end)

net.Receive("VoidFactions.Rewards.UpdateReward", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local rewardId = net.ReadUInt(10)
	local name = net.ReadString()
	local moduleName = net.ReadString()
	local requiredValue = net.ReadInt(32)
	local money = net.ReadUInt(32)
	local xp = net.ReadUInt(32)
	local icon = net.ReadString()

	local module = VoidFactions.RewardModules.List[moduleName]
	if (!module) then return end

	local reward = VoidFactions.Rewards.List[rewardId]
	if (!reward) then return end

	reward:SetName(name)
	reward:SetModule(module)
	reward:SetRequiredValue(requiredValue)
	reward:SetMoneyReward(money)
	reward:SetXPReward(xp)
	reward:SetIcon(icon)

	VoidFactions.Rewards:NetworkRewards()

	VoidFactions.SQL:UpdateReward(reward, name, module, requiredValue, money, xp, icon)
	VoidLib.Notify(ply, L"success", L("rewardEdited", reward.name), VoidUI.Colors.Green, 5)
end)

net.Receive("VoidFactions.Rewards.CreateReward", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

	local name = net.ReadString()
	local moduleName = net.ReadString()
	local requiredValue = net.ReadInt(32)
	local money = net.ReadUInt(32)
	local xp = net.ReadUInt(32)
	local icon = net.ReadString()

	local module = VoidFactions.RewardModules.List[moduleName]
	if (!module) then return end

	VoidFactions.SQL:CreateReward(name, module, requiredValue, money, xp, icon)
	VoidLib.Notify(ply, L"success", L("rewardCreated", name), VoidUI.Colors.Green, 5)
end)

net.Receive("VoidFactions.Rewards.RequestRewards", function (len, ply)
	-- Send net message
	if (ply.vf_rewardsSent) then return end
	ply.vf_rewardsSent = true

	net.Start("VoidFactions.Rewards.SendRewards")
		-- Write rewards
		net.WriteUInt(table.Count(VoidFactions.Rewards.List), 10)
		for k, reward in pairs(VoidFactions.Rewards.List) do
			VoidFactions.Rewards:WriteReward(reward)
		end
	net.Send(ply)
end)