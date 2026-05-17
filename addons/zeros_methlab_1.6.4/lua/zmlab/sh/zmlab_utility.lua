zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

//////////////////////////////////////////////////
///////////////  Default Utilities  //////////////
//////////////////////////////////////////////////
if SERVER then

	// Basic notify function
	function zmlab.f.Notify(ply, msg, ntfType)
		BaseWars:Notify(ply, msg, ntfType, 5)
	end

	// This saves the owners SteamID
	function zmlab.f.SetOwnerByID(ent, id)
		ent:SetNWString("zmlab_Owner", id)
	end

	// This saves the owners SteamID
	function zmlab.f.SetOwner(ent, ply)
		if IsValid(ply) then

			ent:SetNWString("zmlab_Owner", zmlab.f.Player_GetID(ply))

			if CPPI then
				ent:CPPISetOwner(ply)
			end
		else
			ent:SetNWString("zmlab_Owner", "world")
		end
	end

	// Creates a util.Effect
	function zmlab.f.Destruct(ent,effect)
		local vPoint = ent:GetPos()
		local effectdata = EffectData()
		effectdata:SetStart(vPoint)
		effectdata:SetOrigin(vPoint)
		effectdata:SetScale(1)
		util.Effect(effect, effectdata)

		SafeRemoveEntity(ent)
	end
end

if (CLIENT) then
	// Creates/Stops a Looped Sound, use self:StopSound() on Client ENT:OnRemove()
	function zmlab.f.LoopedSound(ent, soundfile, shouldplay)
		if shouldplay and zmlab.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 500) then
			if ent.Sounds == nil then
				ent.Sounds = {}
			end

			if ent.Sounds[soundfile] == nil then
				ent.Sounds[soundfile] = CreateSound(ent, soundfile)
			end

			if ent.Sounds[soundfile]:IsPlaying() == false then
				ent.Sounds[soundfile]:Play()
				ent.Sounds[soundfile]:ChangeVolume(1, 0)
			end
		else
			if ent.Sounds == nil then
				ent.Sounds = {}
			end

			if ent.Sounds[soundfile] ~= nil and ent.Sounds[soundfile]:IsPlaying() == true then
				ent.Sounds[soundfile]:ChangeVolume(0, 0)
				ent.Sounds[soundfile]:Stop()
				ent.Sounds[soundfile] = nil
			end
		end
	end

	// Creates a Color that Lerps according to t
	function zmlab.f.LerpColor(t, c1, c2)
		local c3 = Color(0,0,0,0)
		c3.r = Lerp(t, c1.r, c2.r)
		c3.g = Lerp(t, c1.g, c2.g)
		c3.b = Lerp(t, c1.b, c2.b)
		c3.a = Lerp(t, c1.a, c2.a)

		return c3
	end

	// Switches to a diffrent font depending on string length
	function zmlab.f.GetFontFromTextSize(str,len,font01,font02)
		local size = string.len(str)
		if size < len then
			return font01
		else
			return font02
		end
	end

	// Checks if the entity did not got drawn for certain amount of time and call update functions for visuals
	function zmlab.f.UpdateEntityVisuals(ent)
		if zmlab.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 1000) then

			local curDraw = CurTime()

			if ent.LastDraw == nil then
				ent.LastDraw = CurTime()
			end

			if ent.LastDraw < (curDraw - 1) then

				ent:UpdateVisuals()
			end

			ent.LastDraw = curDraw
		end
	end

	// Draws a Circle
	function zmlab.f.draw_Circle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end
end

//Used to fix the Duplication Glitch
function zmlab.f.CollisionCooldown(ent)
	if ent.zmlab_CollisionCooldown == nil then
		ent.zmlab_CollisionCooldown = true

		timer.Simple(0.1,function()
			if IsValid(ent) then
				ent.zmlab_CollisionCooldown = false
			end
		end)

		return false
	else
		if ent.zmlab_CollisionCooldown then
			return true
		else
			ent.zmlab_CollisionCooldown = true

			timer.Simple(0.1,function()
				if IsValid(ent) then
					ent.zmlab_CollisionCooldown = false
				end
			end)
			return false
		end
	end
end


// Returns the player rank / usergroup
function zmlab.f.GetPlayerRank(ply)
	if SG then
		return ply:GetSecondaryUserGroup() or ply:GetUserGroup()
	else
		return ply:GetUserGroup()
	end
end

// Returns the players job
function zmlab.f.GetPlayerJob(ply)
	return team.GetName( ply:Team() )
end

// Here we check if the string has invalid characts
function zmlab.f.String_ValidCharacter(aString)
	local str = string.gsub( aString, " ", "" )
	local Valid = true

	if string.match(str, "%W", 1) then
		Valid = false
	end

	return Valid
end

// Tells us if the string is too long
function zmlab.f.String_TooShort(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooShort = false

	if string.len(str) <= size then
		_TooShort = true
	end

	return _TooShort
end

// Tells us if the string is too short
function zmlab.f.String_TooLong(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooLong = false

	if string.len(str) > size then
		_TooLong = true
	end

	return _TooLong
end

// This returns the entites owner SteamID
function zmlab.f.GetOwnerID(ent)
	return ent:GetNWString("zmlab_Owner", "nil")
end

// Checks if both entities have the same owner
function zmlab.f.OwnerID_Check(ent01,ent02)

	if IsValid(ent01) and IsValid(ent02) then

		if zmlab.f.GetOwnerID(ent01) == zmlab.f.GetOwnerID(ent02) then
			return true
		else
			return false
		end
	else
		return false
	end
end

// This returns the owner
function zmlab.f.GetOwner(ent)
	if (IsValid(ent)) then
		local id = ent:GetNWString("zmlab_Owner", "nil")
		local ply = player.GetBySteamID(id)

		if (IsValid(ply)) then
			return ply
		else
			return false
		end
	else
		return false
	end
end

// This returns true if the player is a admin
function zmlab.f.IsAdmin(ply)
	if IsValid(ply) then
		if xAdmin then
			//xAdmin Support
			return ply:IsAdmin()
		elseif sam then
			return ply:IsAdmin()
		else
			if zmlab.config.AdminRanks[zmlab.f.GetPlayerRank(ply)] then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

// Checks if the distance between pos01 and pos02 is smaller then dist
function zmlab.f.InDistance(pos01, pos02, dist)
	local inDistance = pos01:DistToSqr(pos02) < (dist * dist)
	return  inDistance
end

// Randomly Returns true depending on Chance
function zmlab.f.RandomChance(chance)
	if math.random(0, 100) < math.Clamp(chance,0,100) then
		return true
	else
		return false
	end
end

// Takes a table and returns a randomized version of it
function zmlab.f.table_randomize( t )
	local out = { }

	while #t > 0 do
		table.insert( out, table.remove( t, math.random( #t ) ) )
	end

	return out
end

// Returns a clamped amount depending on cap
function zmlab.f.Calculate_AmountCap(hAmount, cap)
	return math.Clamp(hAmount,0,cap)
end

// Tells us if the function is valid
function zmlab.f.FunctionValidater(func)
	if (type(func) == "function") then return true end

	return false
end

// Creates a Timer if the function is valid
function zmlab.f.Timer_Create(timerid,time,rep,func)
	// 206725927
	if zmlab.f.FunctionValidater(func) then
		timer.Create(timerid, time, rep,func)
	end
end

// Removes a timer if it exists
function zmlab.f.Timer_Remove(timerid)
	if timer.Exists(timerid) then
		timer.Remove(timerid)
	end
end

//////////////////////////////////////////////////
//////////////////////////////////////////////////



//////////////////////////////////////////////////
///////////////  Script Utilities  ///////////////
//////////////////////////////////////////////////

// Checks if the player is the owner of the entitiy
function zmlab.f.IsOwner(ply, ent)
	if IsValid(ent) and IsValid(ply) then
		local id = ent:GetNWString("zmlab_Owner", "nil")
		local ply_id = zmlab.f.Player_GetID(ply)

		if zmlab.config.SharedOwnership then
			return true
		else
			if id == ply_id or id == "world" then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

// Returns the players job
function zmlab.f.GetPlayerJob(ply)
	return ply:Team()
end

// Returns the players job name
function zmlab.f.GetPlayerJobName(ply)
	return team.GetName( zmlab.f.GetPlayerJob(ply) )
end

// Does the player has the correct job
function zmlab.f.Player_CheckJob(ply)
	if BaseWars or table.Count(zmlab.config.Jobs) <= 0 then
		return true
	else
		if zmlab.config.Jobs[zmlab.f.GetPlayerJob(ply)] then
			return true
		else
			return false
		end
	end
end

// Does the player has meth?
function zmlab.f.HasPlayerMeth(ply)
	if (ply.zmlab_meth and ply.zmlab_meth > 0) then
		return true
	else
		zmlab.f.Notify(ply, zmlab.language.methbuyer_nometh, 1)

		return false
	end
end

//////////////////////////////////////////////////
//////////////////////////////////////////////////
