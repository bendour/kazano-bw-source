net.Receive("BaseWars:ThirdPerson", function()
    local ply = LocalPlayer()

    ply.ThirdPerson = not ply.ThirdPerson
end)

hook.Add( "CalcView", "BaseWars:ThirdPersone", function(_, pos, ang, fov)
    local ply = LocalPlayer()

    if ply.ThirdPerson then
        local dist = 100
        local view = {}
        local trace = {}
        trace.start = pos
        trace.endpos = pos - (ang:Forward() * dist)
        trace.filter = ply

        trace = util.TraceLine(trace)
        if trace.HitPos:Distance(pos) < dist - 10 then
            dist = trace.HitPos:Distance(pos) - 10
        end

        view.origin = pos - (ang:Forward() * dist)
        view.angles = ang
        view.fov = fov

        return view
    end
end)

hook.Add("ShouldDrawLocalPlayer", "BaseWars:ThirdPersone", function()
    return LocalPlayer().ThirdPerson
end)