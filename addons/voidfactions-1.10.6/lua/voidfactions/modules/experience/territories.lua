local MODULE = VoidFactions.XP:Module()
MODULE:SetID("TerritoryCapped") -- Translation -> string.lower -> prepend xp_

MODULE:Setup(function ()
    hook.Add("VoidFactions.CapturePoints.PointCaptured", "VoidFactions.XP.PointCapped", function (faction)
        MODULE:AddXP(faction)
    end)
end)

VoidFactions.XP:AddModule(MODULE)