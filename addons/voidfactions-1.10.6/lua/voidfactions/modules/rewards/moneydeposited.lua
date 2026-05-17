local REWARD = VoidFactions.RewardModules:NewReward()
REWARD:Name("reward_moneydeposited")
REWARD:Description("reward_desc_moneydeposited")

REWARD:DefaultIcon("Hbhkhdd")

REWARD:Setup(function ()

    hook.Add("VoidFactions.Deposit.MoneyDeposted", "VoidFactions.Rewards.MoneyDeposited", function (faction)
        REWARD:SetValue(faction, faction.money)
    end)

end)

VoidFactions.RewardModules:AddReward(REWARD)