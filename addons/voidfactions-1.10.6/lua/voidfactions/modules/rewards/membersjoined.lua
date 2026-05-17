--SetValue
local REWARD = VoidFactions.RewardModules:NewReward()
REWARD:Name("reward_membersjoined")
REWARD:Description("reward_desc_membersjoined")

REWARD:DefaultIcon("7cPhKJK")

REWARD:Setup(function ()

    hook.Add("VoidFactions.Faction.MemberJoined", "VoidFactions.Rewards.MemberJoined", function (faction)
        REWARD:SetValue(faction, #faction.members)
    end)

end)

VoidFactions.RewardModules:AddReward(REWARD)