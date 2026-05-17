if not CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.f.Cable = zwf.f.Cable or {}


local zwf_generators = {
	["zwf_generator"] = true,
	["zwf_lamp"] = true,
	["zwf_ventilator"] = true,
	["zwf_outlet"] = true,

	["zwf_watertank"] = true,
	["zwf_pot_hydro"] = true,
}

local zwf_EnergyUser = {
	["zwf_lamp"] = true,
	["zwf_ventilator"] = true,
	["zwf_outlet"] = true,

	["zwf_pot_hydro"] = true,
}

local zwf_CPoints = {
	["zwf_generator"] = {
		output = Vector(-9, 19, 16)
	},
	["zwf_lamp"] = {
		[1] = {
			input = Vector(39, 0, 0),
			output = Vector(-27, 0, 0)
		},
		[2] = {
			input = Vector(39, 0, 0),
			output = Vector(-44, 0, 0)
		}
	},
	["zwf_ventilator"] = {
		input = Vector(0, -3, 26),
		output = Vector(0, -3, 26)
	},
	["zwf_outlet"] = {
		input = Vector(-9.5, 0, 3),
		output = {
			[1] = Vector(-6, 0, 5),
			[2] = Vector(0, 0, 5),
			[3] = Vector(6, 0, 5),
		}
	},


	["zwf_watertank"] = {
		output = Vector(0, 34, 16)
	},
	["zwf_pot_hydro"] = {
		input = Vector(13, 0, 12.5),
		output = Vector(-13, 0, 12.5)
	},
}

local rope_render_distance = 1000



// Tells use if the provided entity has a output entity, which means it has a connection
function zwf.f.Cable.HasConnection(ent)
	local HasConnection = false
	local class = ent:GetClass()

	if class == "zwf_generator" then
		HasConnection = IsValid(ent:GetOutput())
	elseif class == "zwf_lamp" then
		HasConnection = IsValid(ent:GetOutput())
	elseif class == "zwf_ventilator" then
		HasConnection = IsValid(ent:GetOutput())
	elseif class == "zwf_outlet" then
		if IsValid(ent:GetOutput01()) or IsValid(ent:GetOutput02()) or IsValid(ent:GetOutput03()) then
			HasConnection = true
		end


	elseif class == "zwf_watertank" then
		HasConnection = IsValid(ent:GetOutput())
	elseif class == "zwf_pot_hydro" then
		HasConnection = IsValid(ent:GetOutput())
	end

	return HasConnection
end


// Gets all the entites in radius that have a connection and generates the "ConnectedEntities" table
function zwf.f.Cable.Cache_Client()
	local ply = LocalPlayer()

	for k, v in pairs(zwf.EntList) do
		if not IsValid(v) then continue end

		if zwf.f.InDistance(v:GetPos(), ply:GetPos(), rope_render_distance) == false or zwf.f.Cable.HasConnection(v) == false then
			v.Cached_Rope = false
			continue
		end

		if v.Cached_Rope == true then
			continue
		end

		local input = v
		if v:GetClass() == "zwf_outlet" then

			v.ConnectedEntities = {}

			for i = 1, 3 do
				local output

				if i == 1 then
					output = v:GetOutput01()
				elseif i == 2 then
					output = v:GetOutput02()
				elseif i == 3 then
					output = v:GetOutput03()
				end

				if IsValid(output) then
					local genOutPos = zwf_CPoints[v:GetClass()].output[i]
					local entInPos = zwf_CPoints[output:GetClass()].input

					if output:GetClass() == "zwf_lamp" then
						local lampid = output:GetLampID()
						entInPos = zwf_CPoints["zwf_lamp"][lampid].input
					else
						entInPos = zwf_CPoints[output:GetClass()].input
					end

					table.insert(v.ConnectedEntities, {
						ent = output,
						RopeStart = genOutPos,
						RopeEnd = entInPos
					})
				end
			end

			v.Cached_Rope = true
			v.RopeRefresh = true

			zwf.f.Debug(v:GetClass() .. "[" .. v:EntIndex() .. "]: " .. "Cached_Rope")
		else

			local output = v:GetOutput()

			if IsValid(output) then
				local genOutPos
				local entInPos

				if input:GetClass() == "zwf_lamp" then
					local lampid = input:GetLampID()
					genOutPos = zwf_CPoints["zwf_lamp"][lampid].output
				else
					 genOutPos = zwf_CPoints[input:GetClass()].output
			 	end

				if output:GetClass() == "zwf_lamp" then
					local lampid = output:GetLampID()
					entInPos = zwf_CPoints["zwf_lamp"][lampid].input
				else
					entInPos = zwf_CPoints[output:GetClass()].input
				end


				v.ConnectedEntities = {}

				table.insert(v.ConnectedEntities, {
					ent = output,
					RopeStart = genOutPos,
					RopeEnd = entInPos
				})

				v.Cached_Rope = true
				v.RopeRefresh = true
				zwf.f.Debug(v:GetClass() .. "[" .. v:EntIndex() .. "]: " .. "Cached_Rope")
			end
		end


	end
end
hook.Add("Think", "a_zwf_think_cables_cl", zwf.f.Cable.Cache_Client)

if zwf_ropes == nil then
	zwf_ropes = {}
end


local length = 10
local gravity = Vector(0, 0, -10)
local damping = 0.7

// Builds the Rope points for the ConnectedEntities for the entity
function zwf.f.BuildRopeData(Generator)
	if Generator.ConnectedEntities == nil then return end

	local genID = Generator:EntIndex()

	zwf_ropes[genID] = {}

	for k, v in pairs(Generator.ConnectedEntities) do
		local ent = v.ent
		if IsValid(ent) then

			// This rebuilds the rope points
			local machineID = ent:EntIndex()

			zwf_ropes[genID][machineID] = {}

			for point = 1, length do
				zwf_ropes[genID][machineID][point] = {
					position = Generator:LocalToWorld(v.RopeStart),
					velocity = ent:GetVelocity()
				}
			end

			local rp = zwf_ropes[genID][machineID]

			if rp and table.Count(rp) > 0 then
				rp[1].position = Generator:LocalToWorld(v.RopeStart)
				rp[length].position = ent:LocalToWorld(v.RopeEnd)
			end
		end
	end

	zwf.f.Debug("zwf.f.BuildRopeData for " .. Generator:GetClass() .. "[" .. genID .. "]")
end

// Updates the Rope points to move physicly
function zwf.f.UpdateRopePhysics(Generator)

	local genID = Generator:EntIndex()

	if zwf_ropes[genID] == nil then return end

	for k, v in pairs(Generator.ConnectedEntities) do
		local ent = v.ent
		if IsValid(ent) then

			// This makes the rope be more physical
			local machineID = ent:EntIndex()

			local rp = zwf_ropes[genID][machineID]
			if rp and table.Count(rp) > 0 then

				rp[1].position = Generator:LocalToWorld(v.RopeStart)
				rp[length].position = ent:LocalToWorld(v.RopeEnd)

				for point = 1, length do

					local position1 = rp[math.Clamp(point - 1, 1, length)].position - rp[point].position
					local length1 = math.max(position1:Length(), 1)
					local position2 = rp[math.Clamp(point + 1, 1, length)].position - rp[point].position
					local length2 = math.max(position2:Length(), 1)
					local velocity = (position1 / length1) + (position2 / length2) + (gravity * 0.001)

					rp[point].velocity = rp[point].velocity * damping  + (velocity * 0.3)
					rp[point].position = rp[point].position + rp[point].velocity
				end
			end
		end
	end
end

net.Receive( "zwf_cable_update", function( len, pl )
	local ent = net.ReadEntity()
	if IsValid(ent) then
		ent.Cached_Rope = false
	end
end )

function zwf.f.UpdateRopeData()

	// Cleans up the rope table if some entity becomes invalid
	for k, v in pairs(zwf_ropes) do
		local generator = Entity(k)

		if IsValid(generator) and zwf_generators[generator:GetClass()] then

			for i,o in pairs(zwf_ropes[k]) do

				local machine = Entity(i)
				if IsValid(machine) and zwf_EnergyUser[machine:GetClass()] then
					if o == nil or table.Count(o) < 0 then
						zwf_ropes[k][i] = nil
					end
				else
					zwf_ropes[k][i] = nil
				end
			end
		else
			zwf_ropes[k] = nil
		end
	end

	for k, v in pairs(zwf.EntList) do
		if IsValid(v) and zwf_generators[v:GetClass()] then
			local genID = v:EntIndex()

			if zwf.f.InDistance(v:GetPos(), LocalPlayer():GetPos(), rope_render_distance) and zwf.f.Cable.HasConnection(v) then

				if v.RopeRefresh then

					zwf.f.BuildRopeData(v)
					v.RopeRefresh = false
				else

					zwf.f.UpdateRopePhysics(v)
				end
			else
				v.RopeRefresh = true
				zwf_ropes[genID] = nil
			end
		end
	end
end





local material = Material("cable/new_cable_lit")
function zwf.f.RenderRope(ropePoints,color,size)
	cam.Start3D(EyePos(), EyeAngles())
		render.SetMaterial(material)
		render.StartBeam(length)

		for point = 1, length do
			if ropePoints[point] then
				render.AddBeam(ropePoints[point].position, size, 0.25, color)
			end
		end

		render.EndBeam()
	cam.End3D()
end

hook.Add("RenderScreenspaceEffects", "a_zwf_renderscreenspaceeffects_rope", function()

	// This creates/updates the ropes
	zwf.f.UpdateRopeData()


	// This renders the rope per frame
	for k, v in pairs(zwf_ropes) do
		local gen = Entity(k)
		local color = zwf.default_colors["white01"]
		local size = 1

		if gen:GetClass() == "zwf_generator" or gen:GetClass() == "zwf_lamp" or gen:GetClass() == "zwf_ventilator" or gen:GetClass() == "zwf_outlet" then
			color = zwf.default_colors["cable"]
			size = 1
		else
			color = zwf.default_colors["water"]
			size = 2
		end

		for i, o in pairs(zwf_ropes[k]) do
			zwf.f.RenderRope(o,color,size)
		end
	end
end)
