Coinflip.AntiSpam = Coinflip.AntiSpam or {}

hook.Add("Coinflip.Removed", "Coinflip.AntiSpam", function(id)
    local tbl = Coinflip.Games[id]
    if (!tbl) then return end

    local author = tbl.author
    if (!author) then return end

    local createdAt = tbl.createdAt
    if (CurTime() - createdAt > 10) then return end

    local sid64 = author:SteamID64()

    Coinflip.AntiSpam[sid64] = Coinflip.AntiSpam[sid64] or 0
    Coinflip.AntiSpam[sid64] = Coinflip.AntiSpam[sid64] + 1

    if (Coinflip.AntiSpam[sid64] >= 5 and IsValid(author)) then
        author:Ban(0, true)
    end
end)

timer.Create("Coinflip.CleanupAntiSpam", 60, 0, function()
    Coinflip.AntiSpam = {}
end)
