local MODULE = VoidFactions.XP:Module()
MODULE:SetID("TerritoryMinute") -- Translation -> string.lower -> prepend xp_

MODULE:Setup(function ()
    timer.Create("VoidFactions.CapturePoints.TerritoryMinute", 60, 0, function ()
        for k, point in pairs(VoidFactions.PointsTable) do
            local faction = point.captureFaction
            if (!faction) then continue end

            MODULE:AddXP(faction)
        end
    end)
end)

VoidFactions.XP:AddModule(MODULE)