local t = {}

for k, v in ipairs({"his", "her"}) do
    for acc, j in pairs({"", "_eye"}) do
        for i = 0, 4 do
            table.insert(t, {
                name = "Theater Mask" .. (k == 1 and " Male" or " Female") .. (acc == 1 and "" or " Eye") .. (i == 0 and "" or (" " .. i)),
                rendering = INSERT,
                metadata = {
                    [1] = 'models/mask/mask_' .. v .. j .. '.mdl',
                    [3] = Vector(-1.71875, -4.71875, -0.0625),
                    [4] = Angle(-0.25, -74.65625, -90.40625),
                    [10] = false,
                    [11] = i,
                },
            })
        end
    end
end

ashop.RegisterPremade("Theater Mask", {
        requireWorkshop = "173676413",

        objectTypes = {
            {
                "Wearables",
                {"ValveBiped.Bip01_Head1"},
                "Facemask"
            },
        },

        items = t
    }
)