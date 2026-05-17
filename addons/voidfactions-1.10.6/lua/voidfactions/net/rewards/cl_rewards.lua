VoidFactions.Rewards = VoidFactions.Rewards or {}

function VoidFactions.Rewards:RequestRewards()
	net.Start("VoidFactions.Rewards.RequestRewards")
	net.SendToServer()
end

function VoidFactions.Rewards:CreateReward(nameVal, moduleVal, valueVal, moneyVal, xpVal, iconVal)
	net.Start("VoidFactions.Rewards.CreateReward")
		net.WriteString(nameVal)
		net.WriteString(moduleVal.name)
		net.WriteInt(valueVal, 32)
		net.WriteUInt(moneyVal, 32)
		net.WriteUInt(xpVal, 32)
		net.WriteString(iconVal)
	net.SendToServer()
end

function VoidFactions.Rewards:UpdateReward(reward, nameVal, moduleVal, valueVal, moneyVal, xpVal, iconVal)
	net.Start("VoidFactions.Rewards.UpdateReward")
		net.WriteUInt(reward.id, 10)
		net.WriteString(nameVal)
		net.WriteString(moduleVal.name)
		net.WriteInt(valueVal, 32)
		net.WriteUInt(moneyVal, 32)
		net.WriteUInt(xpVal, 32)
		net.WriteString(iconVal)
	net.SendToServer()
end

function VoidFactions.Rewards:DeleteReward(reward)
	net.Start("VoidFactions.Rewards.DeleteReward")
		net.WriteUInt(reward.id, 10)
	net.SendToServer()
end

-- Net handlers

net.Receive("VoidFactions.Rewards.SendRewards", function (len, ply)
	local length = net.ReadUInt(10)

	local rewards = {}
	for i = 1, length do
		local reward = VoidFactions.Rewards:ReadReward()
		rewards[i] = reward
	end

	VoidFactions.Rewards.List = rewards

	hook.Run("VoidFactions.Rewards.RewardsReceived")
end)