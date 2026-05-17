local REWARD = VoidFactions.RewardModules:NewReward()
REWARD:Name("reward_upgradesdeposited")
REWARD:Description("reward_desc_upgradesdeposited")

REWARD:DefaultIcon("vfk26on")

REWARD:Setup(function ()

    hook.Add("VoidFactions.Upgrades.UpgradeUnlocked", "VoidFactions.Rewards.UpgradeUnlocked", function (faction)
        REWARD:Increment(faction)
    end)

end)

VoidFactions.RewardModules:AddReward(REWARD)