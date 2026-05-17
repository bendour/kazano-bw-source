zmlab = zmlab or {}
zmlab.f = zmlab.f or {}


// Used for Debug
function zmlab.f.Debug(mgs)
	if zmlab.config.Debug then
		if istable(mgs) then
			print("[    DEBUG    ] Table Start >")
			PrintTable(mgs)
			print("[    DEBUG    ] Table End <")
		else
			print("[    DEBUG    ] " .. mgs)
		end
	end
end

function zmlab.f.Debug_Sphere(pos,size,lifetime,color,ignorez)
	if zmlab.config.Debug then
		debugoverlay.Sphere( pos, size, lifetime, color, ignorez )
	end
end

if SERVER then

	concommand.Add("zmlab_give_meth", function(ply, cmd, args)
	    if zmlab.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()
	        local target = tr.Entity
	        if tr.Hit and IsValid(target) and target:IsPlayer() and target:Alive() and zmlab.f.InDistance(ply:GetPos(), target:GetPos(), 200) then
	            target.zmlab_meth = (target.zmlab_meth or 0) + zmlab.config.TransportCrate.Capacity
	            print(target:Nick() .. ": " .. target.zmlab_meth)
	        end
	    end
	end)

	concommand.Add("zmlab_debug_EntList", function(ply, cmd, args)
		if zmlab.f.IsAdmin(ply) then
			PrintTable(zmlab.EntList)
		end
	end)

	concommand.Add("zmlab_debug_spawn_methcrates", function(ply, cmd, args)
		if zmlab.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit then
				for i = 1, 4 do
					local ent = ents.Create("zmlab_collectcrate")
					ent:SetPos(tr.HitPos + Vector(0, 0, 10) * i)
					ent:Spawn()
					ent:Activate()
					zmlab.f.SetOwner(ent, ply)
					ent:SetMethAmount(zmlab.config.TransportCrate.Capacity)

					zmlab.f.TransportCrate_Delayed_UpdateVisuals(ent)
				end
			end
		end
	end)

	concommand.Add("zmlab_debug_spawn_frezzetray", function(ply, cmd, args)
		if zmlab.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit then
				for i = 1, 4 do
					local ent = ents.Create("zmlab_frezzingtray")
					ent:SetPos(tr.HitPos + Vector(0, 0, 10) * i)
					ent:Spawn()
					ent:Activate()
					zmlab.f.SetOwner(ent, ply)
					ent:SetInBucket(zmlab.config.FreezingTray.Capacity)
					zmlab.f.FreezingTray_ConvertSludge(ent)
				end
			end
		end
	end)

	concommand.Add("zmlab_saveents", function(ply, cmd, args)
	    if zmlab.f.IsAdmin(ply) then
	        zmlab.f.PublicEnts_Save(ply)
	    else
	        zmlab.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
	    end
	end)


	concommand.Add("zmlab_npc_save", function(ply, cmd, args)
	    if zmlab.f.IsAdmin(ply) then
	        zmlab.f.NPC_Save(ply)
	    else
	        zmlab.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
	    end
	end)

	concommand.Add("zmlab_npc_remove", function(ply, cmd, args)
		if zmlab.f.IsAdmin(ply) then
			zmlab.f.NPC_Remove()
		else
			zmlab.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
		end
	end)



	concommand.Add("zmlab_dropoff_save", function(ply, cmd, args)
		if zmlab.f.IsAdmin(ply) then
			zmlab.f.DropOff_Save(ply)
		else
			zmlab.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
		end
	end)

	concommand.Add("zmlab_dropoff_remove", function(ply, cmd, args)
		if zmlab.f.IsAdmin(ply) then
			zmlab.f.DropOff_Remove()
		else
			zmlab.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
		end
	end)
end
