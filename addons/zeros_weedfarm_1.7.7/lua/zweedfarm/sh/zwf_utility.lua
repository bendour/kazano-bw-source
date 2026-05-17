zwf = zwf or {}
zwf.f = zwf.f or {}

if SERVER then

	// Basic notify function
	function zwf.f.Notify(ply, msg, ntfType)
		BaseWars:Notify(ply, msg, ntfType, 8)
	end
end

if (CLIENT) then

	function zwf.f.LerpColor(t, c1, c2)
		local c3 = Color(0, 0, 0)
		c3.r = Lerp(t, c1.r, c2.r)
		c3.g = Lerp(t, c1.g, c2.g)
		c3.b = Lerp(t, c1.b, c2.b)
		c3.a = Lerp(t, c1.a, c2.a)

		return c3
	end

	function zwf.f.GetFontFromTextSize(str,len,font01,font02)
		local size = string.len(str)
		if size < len then
			return font01
		else
			return font02
		end
	end

	// Checks if the entity did not got drawn for certain amount of time and call update functions for visuals
	function zwf.f.UpdateEntityVisuals(ent)
		if zwf.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 1000) then

			local curDraw = CurTime()

			if ent.LastDraw == nil then
				ent.LastDraw = CurTime()
			end

			if ent.LastDraw < (curDraw - 1) then
				//print("Entity: " .. ent:EntIndex() .. " , Call UpdateVisuals() at " .. math.Round(CurTime()))

				ent:UpdateVisuals()
			end

			ent.LastDraw = curDraw
		end
	end

	function zwf.f.LoopedSound(ent, soundfile, shouldplay)
		if shouldplay and zwf.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 500) then
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

	function zwf.f.StopLoopedSound(ent)
		if IsValid(ent) and ent.Sounds and istable(ent.Sounds) and table.Count(ent.Sounds) > 0 then
			for k, v in pairs(ent.Sounds) do
				if v and v:IsPlaying() then
					v:Stop()
				end
			end
		end
	end
end


////////////////////////////////////////////
////////////////// Util ////////////////////
////////////////////////////////////////////

//Used to fix the Duplication Glitch
function zwf.f.CollisionCooldown(ent)
	if ent.zwf_CollisionCooldown == nil then
		ent.zwf_CollisionCooldown = true

		timer.Simple(0.1,function()
			if IsValid(ent) then
				ent.zwf_CollisionCooldown = false
			end
		end)

		return false
	else
		if ent.zwf_CollisionCooldown then
			return true
		else
			ent.zwf_CollisionCooldown = true

			timer.Simple(0.1,function()
				if IsValid(ent) then
					ent.zwf_CollisionCooldown = false
				end
			end)
			return false
		end
	end
end

// Here we check if the string has invalid characts
function zwf.f.String_ValidCharacter(aString)
	local str = string.gsub( aString, " ", "" )
	local Valid = true

	if string.match(str, "%W", 1) then
		Valid = false
	end

	return Valid
end

function zwf.f.String_TooShort(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooShort = false

	if string.len(str) <= size then
		_TooShort = true
	end

	return _TooShort
end

function zwf.f.String_TooLong(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooLong = false

	if string.len(str) > size then
		_TooLong = true
	end

	return _TooLong
end

// Checks if the distance between pos01 and pos02 is smaller then dist
function zwf.f.InDistance(pos01, pos02, dist)
	local inDistance = pos01:DistToSqr(pos02) < (dist * dist)
	return  inDistance
end

function zwf.f.RandomChance(chance)
	if math.random(0, 100) < math.Clamp(chance,0,100) then
		return true
	else
		return false
	end
end

function zwf.f.table_randomize( t )
	local out = { }

	while #t > 0 do
		table.insert( out, table.remove( t, math.random( #t ) ) )
	end

	return out
end

function zwf.f.Calculate_AmountCap(hAmount, cap)
	local sAmount

	if hAmount > cap then
		sAmount = cap
	else
		sAmount = hAmount
	end

	return sAmount
end

// Tells us if the functions is valid
function zwf.f.FunctionValidater(func)
	if (type(func) == "function") then return true end
	// 167257878
	return false
end

function zwf.f.TableKeyToString(tbl)
	local str = ""

	for k, v in pairs(tbl) do
		if v then
			str = str .. tostring(k) .. ", "
		end
	end

	return str
end

function zwf.f.GetTeamNameList(tbl)
	local str = ""

	for k, v in pairs(tbl) do
		if v and k then
			str = str .. tostring(team.GetName(k)) .. ", "
		end
	end

	return str
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////////// Timer ////////////////////
////////////////////////////////////////////
concommand.Add("zwf_debug_Timer_PrintAll", function(ply, cmd, args)
	if zwf.f.IsAdmin(ply) then
		zwf.f.Timer_PrintAll()
	end
end)

if zwf_TimerList == nil then
	zwf_TimerList = {}
end

function zwf.f.Timer_PrintAll()
	PrintTable(zwf_TimerList)
end

function zwf.f.Timer_Create(timerid,time,rep,func)
	if zwf.f.FunctionValidater(func) then
		timer.Create(timerid, time, rep,func)
		table.insert(zwf_TimerList, timerid)
	end
end

function zwf.f.Timer_Remove(timerid)
	if timer.Exists(timerid) then
		timer.Remove(timerid)
		table.RemoveByValue(zwf_TimerList, timerid)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////////// OWNER ////////////////////
////////////////////////////////////////////

if SERVER then
	// This saves the owners SteamID
	function zwf.f.SetOwnerByID(ent, id)
		ent:SetNWString("zwf_Owner", id)
	end

	// This saves the owners SteamID
	function zwf.f.SetOwner(ent, ply)
		if (IsValid(ply)) then
			ent:SetNWString("zwf_Owner", ply:SteamID())

			if CPPI and zwf.config.CPPI[ent:GetClass()] then
				ent:CPPISetOwner(ply)
			end
		else
			ent:SetNWString("zwf_Owner", "world")
		end
	end
end

// This returns the entites owner SteamID
function zwf.f.GetOwnerID(ent)
	return ent:GetNWString("zwf_Owner", "nil")
end

// Checks if both entities have the same owner
function zwf.f.OwnerID_Check(ent01,ent02)

	if IsValid(ent01) and IsValid(ent02) then

		if zwf.f.GetOwnerID(ent01) == zwf.f.GetOwnerID(ent02) then
			return true
		else
			return false
		end
	else
		return false
	end
end

// This returns the owner
function zwf.f.GetOwner(ent)
	if IsValid(ent) then
		local id = ent:GetNWString("zwf_Owner", "nil")
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

// Checks if the player is the owner of the entitiy
function zwf.f.IsOwner(ply, ent)
	if IsValid(ent) and IsValid(ply) then
		local id = ent:GetNWString("zwf_Owner", "nil")
		local ply_id = ply:SteamID()

		if id == ply_id or id == "world" then

			return true
		else
			return false
		end
	else
		return false
	end
end

// Checks if the player is the owner of the plant
function zwf.f.IsPlantOwner(ply, plant)
	if zwf.config.Sharing.Plants then
		return true
	else

		return zwf.f.IsOwner(ply, plant)
	end
end

// Checks if the player is the owner of the seed
function zwf.f.IsSeedOwner(ply, seed)
	if zwf.config.Sharing.Seeds then
		return true
	else

		return zwf.f.IsOwner(ply, seed)
	end
end

// Checks if the player is the owner of the packingtable
function zwf.f.IsPackingTableOwner(ply, packingtable)
	if zwf.config.Sharing.Packing then
		return true
	else

		return zwf.f.IsOwner(ply, packingtable)
	end
end

// This returns true if the player is a admin
function zwf.f.IsAdmin(ply)
	if IsValid(ply) then

		//xAdmin Support
		if xAdmin then
			return ply:IsAdmin()
		// sAdmin support
        elseif sAdmin then
            return ply:IsAdmin()
		// SAM Support
		elseif sam then
			return ply:IsAdmin()
		else
			if zwf.config.AdminRanks[zwf.f.GetPlayerRank(ply)] then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
////////////// Rank / Job //////////////////
////////////////////////////////////////////
// Returns the player rank / usergroup
function zwf.f.GetPlayerRank(ply)
	if SG then
		return ply:GetSecondaryUserGroup() or ply:GetUserGroup()
	else
		return ply:GetUserGroup()
	end
end

function zwf.f.PlayerRankCheck(ply,ranks)
	if xAdmin then

		local HasRank = false
		for k, v in pairs(ranks) do
			if ply:IsUserGroup(k) then
				HasRank = true
				break
			end
		end
		return HasRank
	else
		if ranks[zwf.f.GetPlayerRank(ply)] == nil then
			return false
		else
			return true
		end
	end
end

// Returns the players job
function zwf.f.GetPlayerJob(ply)
	return ply:Team()
end

// Returns the players job name
function zwf.f.GetPlayerJobName(ply)
	return team.GetName( zwf.f.GetPlayerJob(ply) )
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////////// CUSTOM ////////////////////
////////////////////////////////////////////
// Checks if the player is allowed to sell weed
function zwf.f.IsWeedSeller(ply)
	return true
end

// Checks if the player is allowed to buy a bong
function zwf.f.CanBuyBongs(ply)
	if table.Count(zwf.config.NPC.Customers) > 0 then
		if zwf.config.NPC.Customers[zwf.f.GetPlayerJob(ply)] then
			return true
		else
			return false
		end
	else
		return true
	end
end
////////////////////////////////////////////
////////////////////////////////////////////
