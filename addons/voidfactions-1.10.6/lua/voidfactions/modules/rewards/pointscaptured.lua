local REWARD = VoidFactions.RewardModules:NewReward()
REWARD:Name("reward_pointscaptured")
REWARD:Description("reward_desc_pointscaptured")

REWARD:DefaultIcon("qVF75eP")

REWARD:Setup(function ()

    hook.Add("VoidFactions.CapturePoints.PointCaptured", "VoidFactions.Rewards.PointCapped", function (faction)
        REWARD:Increment(faction)
    end)

end)

VoidFactions.RewardModules:AddReward(REWARD)