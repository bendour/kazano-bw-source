VoidFactions.API = VoidFactions.API or {}

local PLAYER = FindMetaTable("Player")

local DEFAULT_FALLBACK = "None"

function PLAYER:VF_GetFactionVar(varName, fallback)
    fallback = fallback or DEFAULT_FALLBACK
    
    -- before the second argument was a boolean, to return nil instead of a string,
    -- so we need this to not break other addons using the old implementation of the API
    if fallback == true then
        fallback = nil
    end
    
    if (SERVER) then
        local faction = self:GetVFFaction()
        return faction and faction[varName] or fallback
    else
        local plyData = VoidFactions.Utils.SyncedFactionPlayers[self]
        return plyData and plyData[varName] or fallback
    end
end

function PLAYER:VF_GetMemberVar(varName)
    if (SERVER) then
        local member = self:GetVFMember()
        return member and member[varName]
    end
end

function PLAYER:VF_GetFactionName(fallback)
    -- because the client doesn't know about the whole faction object, 
    -- 'faction' will return a string instead.
    local var = SERVER and "name" or "faction"
    return self:VF_GetFactionVar(var, fallback)
end

function PLAYER:VF_GetFactionLogo(fallback)
    return self:VF_GetFactionVar("factionLogo", fallback)
end

function PLAYER:VF_GetFactionTag(fallback)
    return self:VF_GetFactionVar("tag", fallback)
end

function PLAYER:VF_GetRankName(fallback)
    if (CLIENT) then
        return self:VF_GetFactionVar("rank", fallback)
    end
    
    fallback = fallback or DEFAULT_FALLBACK
    local rank = self:VF_GetMemberVar("rank")
    
    return rank and rank.name or fallback
end

function PLAYER:VF_GetRankTag(fallback)
    if (CLIENT) then
        return self:VF_GetFactionVar("rankTag", b)
    end
    
    fallback = fallback or DEFAULT_FALLBACK

    local rank = self:VF_GetMemberVar("rank")
    return rank and rank.tag or fallback
end

function PLAYER:VF_GetFactionColor(fallback)
    fallback = fallback or color_white
    return self:VF_GetFactionVar("factionColor", fallback)
end
