local PLAYER = FindMetaTable("Player")

function PLAYER:GetPointshop()
    return self:GetNWInt("BaseWars.Pointshop", 0)
end

function PLAYER:GetCredit()
    return self:GetNWInt("BaseWars.Credit", 0)
end