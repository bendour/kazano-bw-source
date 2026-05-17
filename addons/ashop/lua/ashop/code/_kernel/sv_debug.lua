concommand.Add("ashop_keep_one_render", function(ply)
    if IsValid(ply) then return end

    print("[ashop] Keep one render")
    local firstRender = next(ashop.render)

    for k, v in pairs(ashop.object_types) do
        ashop.EditRender(firstRender, false, k)
    end

    ashop.SQL.query('UPDATE ashop_object_types SET renderBy = ' .. firstRender)
    ashop.SQL.query('DELETE FROM ashop_render WHERE id != ' .. firstRender)

    for k, v in pairs(ashop.render) do
        if k == firstRender then continue end

        net.Start('ashop_Render_Delete')
            net.WriteUInt(k, ashop.Config.BitsRender)
        net.Broadcast()
    end
end)

if ashop.HardReset then
    concommand.Add("ashop_hardreset", function(ply)
        if IsValid(ply) then return end

        for k, v in ipairs(player.GetAll()) do
            v:Kick("Hard reset AShop")
        end

        ashop.SQL.query([[
            DROP TABLE ashop_equip;
            DROP TABLE ashop_logs_players;
            DROP TABLE ashop_logs;
            DROP TABLE ashop_carmaterials;
            DROP TABLE ashop_weaponmaterials;
            DROP TABLE ashop_rankpromotions;
            DROP TABLE ashop_players;
            DROP TABLE ashop_bought;
            DROP TABLE ashop_currenciesTrades;
            DROP TABLE ashop_items;
            DROP TABLE ashop_sub_types;
            DROP TABLE ashop_pac3;
            DROP TABLE ashop_groupranks;
            DROP TABLE ashop_render;
            DROP TABLE ashop_rarity;
            DROP TABLE ashop_object_types;]], function()
            print("[ashop] Hard reset done. Force reboot the server now")
            while true do end
        end)
    end)
end