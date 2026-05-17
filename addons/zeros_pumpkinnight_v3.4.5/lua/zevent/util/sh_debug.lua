/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}

if SERVER then
	concommand.Add("zpn_candyadd", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local amount = args[1]

	        if amount == nil then return end
	        amount = tonumber(amount)
	        if isnumber(amount) == false then return end
	        if amount <= 0 then return end
	        local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:Alive() then
	            zpn.Candy.AddPoints(tr.Entity, amount)
	            zclib.Notify(ply, "Added " .. amount .. " Candypoints to " .. tr.Entity:Nick() .. "!", 0)
	            zclib.Notify(tr.Entity, "You received " .. amount .. " Candypoints!", 0)
	        end
	    end
	end)



	concommand.Add( "zpn_data_reset", function( ply, cmd, args )

	    if zclib.Player.IsAdmin(ply) then

	        zpn.Candy.SetPoints(ply, 0)
	        zpn.Score.SetPoints(ply, 0)

	        zpn.data.Save(ply)
	    end
	end )

	concommand.Add( "zpn_data_purge", function( ply, cmd, args )

	    if zclib.Player.IsAdmin(ply) then

	        for k, v in pairs(zclib.Player.List) do

	            if IsValid(v) then
	                zpn.Candy.SetPoints(v, 0)
	                zpn.Score.SetPoints(v, 0)
	            end
	        end

	        local files, dirs = file.Find("zpn/data/*", "DATA")
	        for k, v in pairs(files) do
	            if file.Exists("zpn/data/" .. v, "DATA") then
	                file.Delete("zpn/data/" .. v)
	            end
	        end
	    end
	end )

	concommand.Add( "zpn_data_migrate_from_mrevent", function( ply, cmd, args )

	    if zclib.Player.IsAdmin(ply) then
	        local info_tbl = {}
	        for k, v in pairs(zclib.Player.List) do

	            if IsValid(v) then

	                local migration_check = v:GetPData("zpn/mrevent/migrated", nil)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

	                if migration_check ~= nil then
	                    continue
	                end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	                local data_str = v:GetPData("zhc/money/database", nil)

	                if data_str == nil then
	                    continue
	                end


	                local convert = util.JSONToTable(data_str)

	                if convert and istable(convert) and convert.money and convert.money > 0 then
	                    zpn.Candy.AddPoints(v, convert.money)

	                    table.insert(info_tbl, {
	                        candypoints = convert.money,
	                        steamid = zclib.Player.GetID(v),
	                        _name = v:Nick()
	                    })

	                    v:SetPData("zpn/mrevent/migrated", true)

	                    zclib.Notify(v, "Successfully migrated your " .. tostring(convert.money) .. " Candypoints from Mr.Event to Zero´s PumpkinNight!", 0)
	                end
	            end
	        end
	        print("-------------------------------")
	        print("Migrated Candypoints for")
	        PrintTable(info_tbl)
	        print("-------------------------------")
	    end
	end )



	concommand.Add( "zpn_ghost_removeall", function( ply, cmd, args )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

	    if zclib.Player.IsAdmin(ply) then

	        for k, v in pairs(zpn.Ghost.List) do
	            if IsValid(v) then
	                v:Remove()
	            end
	        end

	        zpn.Ghost.List = {}
	    end
	end )


	concommand.Add("zpn_debug_spawncandy", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()
			if tr.Hit and tr.HitPos then
				local ent = ents.Create("zpn_candy")
				ent:SetPos(tr.HitPos)
				ent:Spawn()
				ent:Activate()
			end
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851
