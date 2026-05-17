-- Simple file-based tags mapped by SteamID64.
-- Edit this file directly to add or change tags.
-- Example:
-- escore2.tags_sid64 = {
--     ["00000000000000000"] = {
--         ["rank_draw"] = true,
--         ["rank_name"] = "Owner",
--         ["rank_color1"] = Color(255, 100, 100),
--         ["rank_color2"] = Color(255, 200, 200),
--         ["rank_glow"] = true,
--     },
-- }

escore2 = escore2 or {}
escore2.tags_sid64 = escore2.tags_sid64 or {
     ["00000000000000000"] = { -- JL / Dev
         ["rank_draw"] = true,
         ["rank_name"] = "Développeur",
         ["rank_color1"] = Color(0, 0, 0),
         ["rank_color2"] = Color(0, 0, 0),
         ["rank_glow"] = true,
     },
     ["00000000000000000"] = { -- snow / responsable
         ["rank_draw"] = true,
         ["rank_name"] = "Responsable",
         ["rank_color1"] = Color(0, 0, 0),
         ["rank_color2"] = Color(0, 0, 0),
         ["rank_glow"] = true,
     },
     ["00000000000000000"] = { -- zerox / super-admin
         ["rank_draw"] = true,
         ["rank_name"] = "Super-Admin",
         ["rank_color1"] = Color(255, 140, 0),
         ["rank_color2"] = Color(255, 140, 0),
         ["rank_glow"] = true,
     },
}