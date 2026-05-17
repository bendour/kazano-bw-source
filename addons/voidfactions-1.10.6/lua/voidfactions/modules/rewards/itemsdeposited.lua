local REWARD = VoidFactions.RewardModules:NewReward()
REWARD:Name("reward_itemsdeposited")
REWARD:Description("reward_desc_itemsdeposited")

REWARD:DefaultIcon("KANmpki")

REWARD:Setup(function ()

    hook.Add("VoidFactions.Deposit.ItemDeposted", "VoidFactions.Rewards.ItemDeposited", function (faction)
        REWARD:SetValue(faction, table.Count(faction.deposits))
    end)

end)

VoidFactions.RewardModules:AddReward(REWARD)