if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}


util.AddNetworkString("zwf_cable_update")

// A custom IsValid Function which also checks if the entity is not NULL
local function IsValidEnt(ent)
	return IsValid(ent) and ent ~= NULL
end

local ConnectionClasses = {
	["zwf_generator"] = true,
	["zwf_lamp"] = true,
	["zwf_ventilator"] = true,
	["zwf_outlet"] = true,
	["zwf_watertank"] = true,
	["zwf_pot_hydro"] = true,
}

local WaterClasses = {
	["zwf_watertank"] = true,
	["zwf_pot_hydro"] = true,
}


local AllowedConnections = {
	["zwf_generator"] = {
		input = false,
		output = true
	},
	["zwf_lamp"] = {
		input = true,
		output = true
	},
	["zwf_ventilator"] = {
		input = true,
		output = true
	},
	["zwf_outlet"] = {
		input = true,
		output = true
	},

	["zwf_watertank"] = {
		input = false,
		output = true
	},
	["zwf_pot_hydro"] = {
		input = true,
		output = true
	},
}

function zwf.f.CableSWEP_HasPowerSource(ent)
	local HasConnection = false
	local class = ent:GetClass()

	if class == "zwf_lamp" then
		HasConnection = IsValidEnt(ent:GetPowerSource())
	elseif class == "zwf_ventilator" then
		HasConnection = IsValidEnt(ent:GetPowerSource())
	elseif class == "zwf_outlet" then
		HasConnection = IsValidEnt(ent:GetPowerSource())


	elseif class == "zwf_pot_hydro" then
		HasConnection = IsValidEnt(ent:GetWaterSource())
	end


	zwf.f.Debug("HasPowerSource: " .. tostring(HasConnection))

	return HasConnection
end

local WaterEnts = {
	["zwf_watertank"] = true,
	["zwf_pot_hydro"] = true,
}


local EnergyEnts = {
	["zwf_generator"] = true,
	["zwf_lamp"] = true,
	["zwf_ventilator"] = true,
	["zwf_outlet"] = true,
}

function zwf.f.CableSWEP_TypeCheck(EntA, EntB)
	if EnergyEnts[EntA:GetClass()] and EnergyEnts[EntB:GetClass()] then
		return true
	elseif WaterEnts[EntA:GetClass()] and WaterEnts[EntB:GetClass()] then
		return true
	else
		return false
	end
end



function zwf.f.CableSWEP_Primary(swep)

	local tr = util.TraceLine( {
		start = swep:GetOwner():EyePos(),
		endpos = swep:GetOwner():EyePos() + swep:GetOwner():EyeAngles():Forward() * 1000,
		filter = function( ent )
			if ( ent:GetClass() == "zwf_plant" or ent == swep:GetOwner() ) then
				return false
			else
				return true
			end
		end
	} )


	if tr.Hit then
		local trEnt = tr.Entity

		if IsValidEnt(trEnt) and AllowedConnections[trEnt:GetClass()] then

			if zwf.f.IsOwner(swep:GetOwner(), trEnt) == false then return end


			local currentSeleceted = swep:GetSelectedEntity()

			// If we allready have something selected then we finish the connection here
			if IsValidEnt(currentSeleceted) then

				zwf.f.CableSWEP_Connect(swep, trEnt, currentSeleceted)
			else

				// If we have nothing selected then we select the entity
				if ConnectionClasses[trEnt:GetClass()] then

					if trEnt:GetClass() == "zwf_generator" and IsValidEnt(trEnt:GetOutput()) then return end
					if trEnt:GetClass() == "zwf_lamp" and IsValidEnt(trEnt:GetOutput()) then return end
					if trEnt:GetClass() == "zwf_ventilator" and IsValidEnt(trEnt:GetOutput()) then return end
					if trEnt:GetClass() == "zwf_outlet" and zwf.f.MultiConnection_GetFreePosID(trEnt) == nil then return end

					if trEnt:GetClass() == "zwf_watertank" and IsValidEnt(trEnt:GetOutput()) then return end
					if trEnt:GetClass() == "zwf_pot_hydro" and IsValidEnt(trEnt:GetOutput()) then return end

					zwf.f.CableSWEP_Select(swep, trEnt)
				end
			end
		end
	end
end

function zwf.f.CableSWEP_Connect(swep, trEnt,currentSeleceted)

	if trEnt == currentSeleceted then

		zwf.f.CableSWEP_Deselect(swep)
		return
	end


	if zwf.f.InDistance(trEnt:GetPos(), currentSeleceted:GetPos(), zwf.config.Cable.distance) == false then

		zwf.f.CableSWEP_Deselect(swep)
		zwf.f.Notify(swep:GetOwner(), zwf.language.General["CableDistanceFail"], 1)
		return
	end

	// If the second ent has no powersource then we connect it
	if zwf.f.CableSWEP_HasPowerSource(trEnt) == false and AllowedConnections[trEnt:GetClass()].input then

		if zwf.f.CableSWEP_TypeCheck(currentSeleceted, trEnt) == false then return end

		if currentSeleceted:GetClass() == "zwf_outlet" then
			local id = zwf.f.MultiConnection_GetFreePosID(currentSeleceted)

			if id then

				// Tells the parent its child
				if id == 1 then

					currentSeleceted:SetOutput01(trEnt)
				elseif id == 2 then
					currentSeleceted:SetOutput02(trEnt)
				elseif id == 3 then
					currentSeleceted:SetOutput03(trEnt)
				end

				if WaterClasses[trEnt:GetClass()] then

					// Tells the child its parent
					trEnt:SetWaterSource(currentSeleceted)

				else

					// Tells the child its parent
					trEnt:SetPowerSource(currentSeleceted)

				end

				trEnt.ConnectedID = id

				zwf.f.CableSWEP_Deselect(swep)

				zwf.f.CreateNetEffect("zwf_cable_connect",trEnt)

				zwf.f.Debug(currentSeleceted:GetClass() .. " connected to " .. trEnt:GetClass())

				// Tells all clients in the area that the entities connection got updated
				net.Start("zwf_cable_update" )
					net.WriteEntity(currentSeleceted)
				net.Broadcast()
			end
		else

			if WaterClasses[trEnt:GetClass()] then

				// Tells the child its parent
				trEnt:SetWaterSource(currentSeleceted)

			else

				// Tells the child its parent
				trEnt:SetPowerSource(currentSeleceted)

			end

			// Tells the parent its child
			currentSeleceted:SetOutput(trEnt)

			zwf.f.CableSWEP_Deselect(swep)

			zwf.f.CreateNetEffect("zwf_cable_connect",trEnt)


			zwf.f.Debug(currentSeleceted:GetClass() .. " connected to " .. trEnt:GetClass())
			// 167257878
			// Tells all clients in the area that the entities connection got updated
			net.Start("zwf_cable_update" )
				net.WriteEntity(currentSeleceted)
			net.Broadcast()
		end
	end
end

function zwf.f.CableSWEP_Select(swep, trEnt)
	swep:SetSelectedEntity(trEnt)
	zwf.f.Debug(trEnt:GetClass() .. "[" .. trEnt:EntIndex() .. "]: " .. "Selected!")

	zwf.f.CreateNetEffect("zwf_cable_select",trEnt)
end

function zwf.f.CableSWEP_Deselect(swep)
	swep:SetSelectedEntity(NULL)
	zwf.f.Debug("zwf.f.CableSWEP_Deselect")

	zwf.f.CreateNetEffect("zwf_cable_select",swep)
end



function zwf.f.CableSWEP_Secondary(swep)
	local tr = util.TraceLine( {
		start = swep:GetOwner():EyePos(),
		endpos = swep:GetOwner():EyePos() + swep:GetOwner():EyeAngles():Forward() * 1000,
		filter = function( ent )
			if ( ent:GetClass() == "zwf_plant" or ent == swep:GetOwner() ) then
				return false
			else
				return true
			end
		end
	} )

	if tr.Hit then
		local trEnt = tr.Entity

		if IsValidEnt(trEnt) and ConnectionClasses[trEnt:GetClass()] then
			if zwf.f.IsOwner(swep:GetOwner(), trEnt) == false then return end

			zwf.f.CableSWEP_Deconnect(trEnt)
		else

			zwf.f.CableSWEP_Deselect(swep)
		end
	end
end


function zwf.f.CableSWEP_Deconnect(trEnt)

	if trEnt:GetClass() == "zwf_generator" and IsValidEnt(trEnt:GetOutput()) then
		trEnt:GetOutput():SetPowerSource(NULL)
		trEnt:SetOutput(NULL)

	elseif trEnt:GetClass() == "zwf_lamp" and IsValidEnt(trEnt:GetOutput()) then
		trEnt:GetOutput():SetPowerSource(NULL)
		trEnt:SetOutput(NULL)
	elseif trEnt:GetClass() == "zwf_lamp" and IsValidEnt(trEnt:GetPowerSource()) then

		if trEnt:GetPowerSource():GetClass() == "zwf_outlet" then
			zwf.f.CableSWEP_Deconnect_Outlet(trEnt)
			trEnt:SetPowerSource(NULL)
		else
			trEnt:GetPowerSource():SetOutput(NULL)
			trEnt:SetPowerSource(NULL)
		end

	elseif trEnt:GetClass() == "zwf_ventilator" and IsValidEnt(trEnt:GetOutput()) then
		trEnt:GetOutput():SetPowerSource(NULL)
		trEnt:SetOutput(NULL)
	elseif trEnt:GetClass() == "zwf_ventilator" and IsValidEnt(trEnt:GetPowerSource()) then

		if trEnt:GetPowerSource():GetClass() == "zwf_outlet" then
			zwf.f.CableSWEP_Deconnect_Outlet(trEnt)
			trEnt:SetPowerSource(NULL)
		else
			trEnt:GetPowerSource():SetOutput(NULL)
			trEnt:SetPowerSource(NULL)
		end


	elseif trEnt:GetClass() == "zwf_outlet" then

		if IsValidEnt(trEnt:GetOutput01()) then
			trEnt:GetOutput01():SetPowerSource(NULL)
			trEnt:SetOutput01(NULL)
		end

		if IsValidEnt(trEnt:GetOutput02()) then
			trEnt:GetOutput02():SetPowerSource(NULL)
			trEnt:SetOutput02(NULL)
		end

		if IsValidEnt(trEnt:GetOutput03()) then
			trEnt:GetOutput03():SetPowerSource(NULL)
			trEnt:SetOutput03(NULL)
		end

	elseif trEnt:GetClass() == "zwf_watertank" and IsValidEnt(trEnt:GetOutput()) then
		trEnt:GetOutput():SetWaterSource(NULL)
		trEnt:SetOutput(NULL)
	elseif trEnt:GetClass() == "zwf_pot_hydro" and IsValidEnt(trEnt:GetOutput()) then
		trEnt:GetOutput():SetWaterSource(NULL)
		trEnt:SetOutput(NULL)
	elseif trEnt:GetClass() == "zwf_pot_hydro" and IsValidEnt(trEnt:GetWaterSource()) then

		trEnt:GetWaterSource():SetOutput(NULL)
		trEnt:SetWaterSource(NULL)

	end

	// Tells all clients in the area that the entities connection got updated
	net.Start("zwf_cable_update" )
		net.WriteEntity(trEnt)
	net.Broadcast()

	zwf.f.CreateNetEffect("zwf_cable_deconnect",trEnt)
end

function zwf.f.CableSWEP_Deconnect_Outlet(trEnt)

	if WaterClasses[trEnt:GetClass()] then
		if trEnt.ConnectedID == 1 then
			trEnt:GetWaterSource():SetOutput01(NULL)
		elseif trEnt.ConnectedID == 2 then
			trEnt:GetWaterSource():SetOutput02(NULL)
		elseif trEnt.ConnectedID == 3 then
			trEnt:GetWaterSource():SetOutput03(NULL)
		end

		net.Start("zwf_cable_update" )
			net.WriteEntity(trEnt:GetWaterSource())
		net.Broadcast()
	else
		if trEnt.ConnectedID == 1 then
			trEnt:GetPowerSource():SetOutput01(NULL)
		elseif trEnt.ConnectedID == 2 then
			trEnt:GetPowerSource():SetOutput02(NULL)
		elseif trEnt.ConnectedID == 3 then
			trEnt:GetPowerSource():SetOutput03(NULL)
		end

		net.Start("zwf_cable_update" )
			net.WriteEntity(trEnt:GetPowerSource())
		net.Broadcast()
	end
end
