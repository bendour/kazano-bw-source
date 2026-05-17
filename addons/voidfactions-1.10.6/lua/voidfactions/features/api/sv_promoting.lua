local L = VoidFactions.Lang.GetPhrase

VoidFactions.API = VoidFactions.API or {}

function VoidFactions.API:ChangeMemberRank(member, promoteType, desiredRank)
    assert(member, "member is invalid!")
    assert(member.faction, "member is not in a faction!")
    assert(promoteType, "invalid promote type!")

    local newRank = promoteType == VoidFactions.Member.PromoteEnums.PROMOTE and member.faction:GetNextRank(member.rank)
	if (promoteType == VoidFactions.Member.PromoteEnums.DEMOTE) then
		newRank = member.faction:GetPrevRank(member.rank)
	end
	if (promoteType == VoidFactions.Member.PromoteEnums.RANK_UPDATE) then
		newRank = desiredRank
	end

    if (promoteType == VoidFactions.Member.PromoteEnums.PROMOTE and !newRank and member.faction.parentFaction) then
		newRank = member.faction.parentFaction:GetLowestRank()
	end

    assert(newRank, "no rank available!")

    if (newRank.faction != member.faction) then
		VoidFactions.Invites:JoinFaction(member, newRank.faction)
	end

    if (promoteType == VoidFactions.Member.PromoteEnums.PROMOTE) then
		member:SetLastPromotion(os.time())
		member:SetAutoPromoteDisabled(false)
	end

    if (promoteType == VoidFactions.Member.PromoteEnums.DEMOTE and member.rank.autoPromoteLevel != 0) then
		member:SetAutoPromoteDisabled(true)
	end

    local nextJob = nil

    -- Does the new rank contain the same job?? If so, then don't change it
    for k, job in pairs(newRank.jobs) do
        if (job == member.job) then
            nextJob = job
        end
    end

    member:SetRank(newRank)
    if (nextJob) then
        member:SetJob(nextJob)
    end

	member:SaveStatic()

    member:NetworkToPlayer()
    VoidFactions.NameTags:SetNameTag(member)

    VoidFactions.Faction:UpdateFactionMembers(member.faction)

    if (VoidFactions.Settings:IsStaticFactions()) then
        local msgType = promoteType == VoidFactions.Member.PromoteEnums.PROMOTE and "youPromoted" or "youDemoted"
        VoidLib.Notify(member.ply, L"info", L(msgType, member.rank.name), VoidUI.Colors.Blue, 5)

        -- Change job
        member:ChangeJob(member.job, true)
    else
        VoidLib.Notify(member.ply, L"info", L("youRankChanged", member.rank.name), VoidUI.Colors.Blue, 5)
    end
end

function VoidFactions.API:PromoteMember(member)
    VoidFactions.API:ChangeMemberRank(member, VoidFactions.Member.PromoteEnums.PROMOTE)
end

function VoidFactions.API:DemoteMember(member)
    VoidFactions.API:ChangeMemberRank(member, VoidFactions.Member.PromoteEnums.DEMOTE)
end

function VoidFactions.API:SetMemberRank(member, desiredRank)
    assert(desiredRank, "no desired rank supplied!")
    VoidFactions.API:ChangeMemberRank(member, VoidFactions.Member.PromoteEnums.RANK_UPDATE, desiredRank)
end