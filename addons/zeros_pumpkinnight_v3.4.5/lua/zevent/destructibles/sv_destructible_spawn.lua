/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.PumpkinSpawner = zpn.PumpkinSpawner or {}

zpn.SpawnedPumpkins = zpn.SpawnedPumpkins or {}
zpn.PumpkinsSpawns = zpn.PumpkinsSpawns or {}

function zpn.PumpkinSpawner.GetCount()
    return table.Count(zpn.SpawnedPumpkins)
end

local function NearPumpkinSpawn(pos)
	local c_Distance = false
	for a, b in pairs(zpn.PumpkinsSpawns) do
		if b and zclib.util.InDistance(pos, b, 200) then
			c_Distance = true
			break
		end
	end
	return c_Distance
end

// Calculates new Spawn positions from Players
local NextCleanup = 0
function zpn.PumpkinSpawner.RefreshPositionTable()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

	// Clear the pumpkin spawn positions
	if NextCleanup and CurTime() > NextCleanup then
		zpn.PumpkinsSpawns = {}
		NextCleanup = CurTime() + 600
	end

    for k, v in pairs(zclib.Player.List) do
        if not IsValid(v) then
            zclib.Debug("RefreshPositionTable: Player Not Valid!")
            continue
        end
        if not v:Alive() then
            zclib.Debug("RefreshPositionTable: Player Not Alive!")
            continue
        end

        if v:InVehicle() then
            zclib.Debug("RefreshPositionTable: Player in Vehicle!")
            continue
        end

        if not v:OnGround() then
            zclib.Debug("RefreshPositionTable: Player not on the Ground!")
            continue
        end

        if zpn.Sign.EntityInDistance(v) then
            zclib.Debug("RefreshPositionTable: Player is near AntiGhost Sign!")
            continue
        end

        local newPos = v:GetPos()

        // Check if we are not too close to another spawn
        if not NearPumpkinSpawn(newPos) then
            zpn.PumpkinSpawner.AddPos(newPos)
        end
    end
end

// Adds a pumpkin spawn position to the list
function zpn.PumpkinSpawner.AddPos(pos)
    table.insert(zpn.PumpkinsSpawns, pos)
    zclib.Debug("PumpkinSpawner: Added New Pos at " .. tostring(pos) .. "!")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

// Removes any pumpkin spawns that are close to this position
function zpn.PumpkinSpawner.RemoveSpawnPos(pos,ply)

    local removed_pos = 0
    local old_pos = zpn.PumpkinsSpawns
    zpn.PumpkinsSpawns = {}

    for k, v in pairs(old_pos) do
        if v:Distance(pos) > 25 then
            table.insert(zpn.PumpkinsSpawns,v)
        else
            removed_pos = removed_pos + 1
        end
    end

    if removed_pos > 0 then
        timer.Simple(0,function()

            zpn.PumpkinSpawner.ShowAll(ply)
        end)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

// Creates a Pumpkin if nothing is in the Way
function zpn.PumpkinSpawner.Spawn()
    if #zpn.PumpkinsSpawns <= 0 then
        zclib.Debug("PumpkinSpawner: List is empty!")
        return
    end

	/*
		Lets just try multiple times finding a valid spawn position
	*/
	local ValidSpawnPos
	local TryCount = 0
	while not ValidSpawnPos and TryCount < 10 do

		local pos = zpn.PumpkinsSpawns[math.random(#zpn.PumpkinsSpawns)]
		if pos then

			local c_Distance = false
			for a, b in pairs(ents.FindInSphere(pos, 50)) do
				if IsValid(b) && b:GetClass() == "zpn_destructable" then
					c_Distance = b
					break
				end
			end

			if c_Distance then
				zclib.Debug("PumpkinSpawner: Too close to other Entity! [" .. tostring(c_Distance) .. "]")
			else
				ValidSpawnPos = pos
				break
			end
		end

		TryCount = TryCount + 1
	end

    if not ValidSpawnPos then
		zclib.Debug("PumpkinSpawner: No valid spawnpos found!")
		return
	end

    zclib.Debug("PumpkinSpawner: Spawned Pumpkin!")
    local ent = ents.Create("zpn_destructable")
    ent:SetPos(ValidSpawnPos)
    ent:Spawn()
    ent:Activate()
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetUseType(SIMPLE_USE)
    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd



// TOOLGUN
// Displays all the pumpkin spawns to the user
util.AddNetworkString("zpn_PumpkinSpawner_showall")
function zpn.PumpkinSpawner.ShowAll(ply)
    if not IsValid(ply) then return end

    local dataString = util.TableToJSON(zpn.PumpkinsSpawns)
    local dataCompressed = util.Compress(dataString)

    net.Start("zpn_PumpkinSpawner_showall")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end

// Hides all the pumpkin spawns for the user
util.AddNetworkString("zpn_PumpkinSpawner_hideall")
function zpn.PumpkinSpawner.HideAll(ply)
    if not IsValid(ply) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    net.Start("zpn_PumpkinSpawner_hideall")
    net.Send(ply)
end

// Setsup the saving / loading and removing of the entity for the map
zclib.STM.Setup("zpn_pumpkingspawns","zpn/" .. string.lower(game.GetMap()) .. "_pumpkinspawns" .. ".txt",function()
    local data = {}

    for u, j in pairs(zpn.PumpkinsSpawns) do
        if j then
            table.insert(data, j)
        end
    end

    return data
end,function(data)

    zpn.PumpkinsSpawns = {}

    if zpn.config.DestructableSpawner.UseCustomSpawns == false then return end

    zpn.PumpkinsSpawns = table.Copy(data)
    zpn.Print("Finished loading Pumpkin Spawns.")
end,function()
    zpn.PumpkinsSpawns = {}
end)

if zpn.config.DestructableSpawner.Enabled then

    local timerid = "zpn_pumpkinspawner"
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid, zpn.config.DestructableSpawner.Interval, 0, function()

        // Check Pumpkin Count
        if zpn.PumpkinSpawner.GetCount() < zpn.config.DestructableSpawner.Count then

            // If we dont have predefined spawns then lets generate some using player positions
            if not zpn.config.DestructableSpawner.UseCustomSpawns then
                // Get Spawn Pos
                zpn.PumpkinSpawner.RefreshPositionTable()
            end

            // Spawn Pumpkin
            if zclib.util.RandomChance(zpn.config.DestructableSpawner.Chance) then
				zpn.PumpkinSpawner.Spawn()
            end
        end
    end)
end

if zpn.config.Destructable.DespawnTime ~= -1 then
    local timerid = "zpn_pumpkin_despawner"
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid, zpn.config.Destructable.DespawnTime, 0, function()
        if zpn.SpawnedPumpkins and table.Count(zpn.SpawnedPumpkins) > 0 then
            for k, v in pairs(zpn.SpawnedPumpkins) do
                if IsValid(v) and v.DeSpawnTime < CurTime() and v.Smashed == false then
                    v:Remove()
                end
            end
        end
    end)
end


// Save function
concommand.Add( "zpn_save_pumpkinspawns", function( ply, cmd, args )

    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Pumpkin spawns have been saved for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Save("zpn_pumpkingspawns")
    end
end )

concommand.Add( "zpn_remove_pumpkinspawns", function( ply, cmd, args )

    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Pumpkin spawns have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("zpn_pumpkingspawns")
        zpn.PumpkinSpawner.HideAll(ply)
    end
end )
