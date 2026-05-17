
VoidFactions.NameTags = VoidFactions.NameTags or {}

function VoidFactions.NameTags:GetPrefix(member)
    local prefix = ""

    if (!VoidFactions.Settings:IsStaticFactions() and VoidFactions.Config.NametagsDisabled) then
        return ""
    end
        
    if (member.faction and member.faction.tag and member.faction.tag != "") then
        prefix = prefix .. member.faction.tag .. " "
    end

    if (member.rank and member.rank.tag and member.rank.tag != "" and VoidFactions.Settings:IsStaticFactions()) then
        prefix = prefix .. member.rank.tag .. " "
    end
    
    return prefix
end

function VoidFactions.NameTags:UpdateFactionTags(faction)
    for k, member in ipairs(faction.members or {}) do
		VoidFactions.NameTags:SetNameTag(member)
	end
end

function VoidFactions.NameTags:SetNameTag(member, nick, newName)
    if (!DarkRP) then return end
    if (!member) then return end
    
    local ply = member.ply
    if (!IsValid(ply)) then return end

    local prefix = VoidFactions.NameTags:GetPrefix(member)
    local name = VoidChar and ply:GetCharacter().name or (nick or ply.vf_noPrefixName)
	
    if (newName) then
        name = newName
    end
	
    local cloneId = ""
    local hashtag = ""

    -- uhh idk...
    if VoidChar then
        cloneId = (ply:GetCharacter() and (ply:GetCharacter().clone_id != "NULL" and ply:GetCharacter().clone_id .. " " or "") or "")
		
	if (VoidChar.Config.ShowHashtag and VoidChar.Config.CustomSymbol and ply:GetCharacter().clone_id != "NULL") then
            hashtag = VoidChar.Config.CustomSymbol
	end
    end
		
    ply:setDarkRPVar("rpname", prefix .. hashtag .. cloneId .. name)
end

hook.Add("onPlayerChangedName", "VoidFactions.NameTags.OnNameChange", function (ply, oldName, newName)
    ply.vf_noPrefixName = newName
    timer.Simple(0, function ()
        local member = ply:GetVFMember()
        if (!member) then return end
        VoidFactions.NameTags:SetNameTag(member, newName)
    end)
end)

hook.Add("VoidChar.CharacterModified", "VoidFactions.NameTags.VoidCharCharModify", function (ply, char)
    ply.vf_noPrefixName = ply:Nick()

    local member = ply:GetVFMember()
    VoidFactions.NameTags:SetNameTag(member, nil, char.name)
end)

hook.Add("VoidFactions.SQL.MemberLoaded", "VoidFactions.NameTags.SetTag", function (ply)
    timer.Simple(0, function ()
        local member = ply:GetVFMember()
        ply.vf_noPrefixName = ply:Nick()
        VoidFactions.NameTags:SetNameTag(member)
    end)
end)
