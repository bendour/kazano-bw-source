Coinflip.RateLimiter = Coinflip.RateLimiter or {}

function Coinflip.RateLimiter:Can(key, cooldown)
    if (!self[key]) then
        self[key] = {
            LastAttempt = 0
        }
    end

    local data = self[key]

    if (data.LastAttempt + cooldown > CurTime()) then
        return false
    end

    data.LastAttempt = CurTime()

    return true
end