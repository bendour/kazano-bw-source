local L = VoidFactions.Lang.GetPhrase

VoidFactions.API = VoidFactions.API or {}

function VoidFactions.API:KickMember(member)
    assert(member, "member is invalid!")
    assert(member.faction, "member is not in a faction!")

    assert(member.defaultFactionId != member.faction.id, "can't kick from default faction!")

    VoidFactions.SQL:KickMember(member)
    member:NetworkToPlayer()
end
