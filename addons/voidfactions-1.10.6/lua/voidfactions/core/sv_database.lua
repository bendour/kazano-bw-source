
VoidFactions.SQL = VoidFactions.SQL or {}

local database = VoidLib.Database:Create(VoidFactions.DatabaseDetails)
local L = VoidFactions.Lang.GetPhrase

--[[---------------------------------------------------------
	Name: Database init
-----------------------------------------------------------]]

function database:OnConnected()
	hook.Run("VoidFactions.DatabaseConnected")
	VoidFactions.Print("Successfully connected to the database!")

	local query = database:Create("voidfactions_factions")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")

		query:Create("name", "VARCHAR(80) NOT NULL") -- Max faction name length: 80 characters
		query:Create("description", "TEXT") -- only for static
		query:Create("tag", "VARCHAR(10)")
		query:Create("max_members", "INTEGER") -- Only for static facitons!

		query:Create("can_capture_territory", "TINYINT(1)") -- for static factions
		query:Create("invite_required", "TINYINT(1)")
		query:Create("show_board", "TINYINT(1)")
		query:Create("is_default_faction", "TINYINT(1)")

		-- dynamic factions
		query:Create("money", "INTEGER DEFAULT 0")

		query:Create("owner", "VARCHAR(35)") -- steamid64, only for dynamic factions
		query:Create("faction_level", "INTEGER DEFAULT 1")
		query:Create("faction_xp", "INTEGER DEFAULT 0")
		query:Create("parent_faction", "INTEGER")
		query:Create("logo", "VARCHAR(15)") -- Imgur ID (only for dynamic)
		query:Create("color", "VARCHAR(20) NOT NULL")
		query:PrimaryKey("id")
	query:Execute()

	local query = database:Create("voidfactions_factionupgrades")
		query:Create("faction_id", "INTEGER NOT NULL")
		query:Create("point_id", "INTEGER NOT NULL")

		query:Create("upgrade_points", "INTEGER") -- amount of upgrade points

		query:PrimaryKey("faction_id, point_id")
	query:Execute()

	local query = database:Create("voidfactions_upgrades")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("name", "VARCHAR(80) NOT NULL")
		query:Create("module_name", "VARCHAR(100) NOT NULL")
		query:Create("value", "VARCHAR(120) NOT NULL") -- if it's a number, we will convert from string
		query:Create("currency", "VARCHAR(50) NOT NULL")
		query:Create("cost", "INTEGER NOT NULL")

		query:Create("icon", "VARCHAR(15) NOT NULL")

		query:PrimaryKey("id")
	query:Execute()

	local query = database:Create("voidfactions_rewards")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("name", "VARCHAR(80) NOT NULL")
		query:Create("module_name", "VARCHAR(50)")
		query:Create("required_value", "INTEGER NOT NULL")

		query:Create("money_amount", "INTEGER NOT NULL")
		query:Create("xp_amount", "INTEGER NOT NULL")

		query:Create("icon", "VARCHAR(15) NOT NULL")
		query:PrimaryKey("id")
	query:Execute()

	local query = database:Create("voidfactions_requiredgroups")
		query:Create("faction_id", "INTEGER NOT NULL")
		query:Create("usergroup", "VARCHAR(130) NOT NULL")

		query:PrimaryKey("faction_id, usergroup")
	query:Execute()

	local query = database:Create("voidfactions_rewardmodules")
		query:Create("name", "VARCHAR(100) NOT NULL")
		query:Create("faction_id", "INTEGER NOT NULL")

		query:Create("value", "INTEGER DEFAULT 0")
		query:PrimaryKey("name, faction_id")
	query:Execute()

	local query = database:Create("voidfactions_factionrewards")
		query:Create("id", "INTEGER NOT NULL")
		query:Create("faction_id", "INTEGER NOT NULL")

		query:PrimaryKey("id, faction_id")
	query:Execute()

	local query = database:Create("voidfactions_deposititems")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("item_faction_id", "INTEGER NOT NULL")

		query:Create("class", "VARCHAR(100) NOT NULL")
		query:Create("drop_ent", "VARCHAR(100) NOT NULL")
		query:Create("model", "VARCHAR(100)")
		query:Create("data", "TEXT")
		query:Create("is_external", "TINYINT(1) DEFAULT FALSE") -- if is external, then it's not an entity/weapon
		query:PrimaryKey("id")
	query:Execute()

	local query = database:Create("voidfactions_transactionhistory")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("faction_id", "INTEGER NOT NULL")

		query:Create("time", "INTEGER NOT NULL")

		query:Create("sid", "VARCHAR(35) NOT NULL")
		query:Create("amount_difference", "INTEGER") -- if positive then deposit, else withdraw
		query:Create("item_class", "VARCHAR(100) NOT NULL") -- 'money' is money
		query:PrimaryKey("id")
	query:Execute()

	local query = database:Create("voidfactions_upgradepoints")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("upgrade_id", "INTEGER NOT NULL")
		query:Create("pos", "VARCHAR(50) NOT NULL")

		query:PrimaryKey("id")
	query:Execute()

	local query = database:Create("voidfactions_upgraderelationships")
		query:Create("from_id", "INTEGER")
		query:Create("to_id", "INTEGER")

		query:PrimaryKey("from_id, to_id")
	query:Execute()

	local query = database:Create("voidfactions_members")
		query:Create("sid", "VARCHAR(35) NOT NULL")
		query:Create("faction_id", "INTEGER") -- NULL if no faction

		query:Create("xp", "INTEGER DEFAULT 0")
		query:Create("level", "INTEGER DEFAULT 1")

		query:Create("playtime", "INTEGER DEFAULT 0") -- Amount of minutes played
		query:Create("last_promotion", "INTEGER DEFAULT 0")
		query:Create("last_seen", "INTEGER DEFAULT 0")
		query:Create("faction_joined", "INTEGER DEFAULT 0")

		query:Create("default_faction_id", "INTEGER") -- only in static
		query:Create("autopromote_disabled", "TINYINT(1)")

		query:Create("job", "VARCHAR(30)")
		query:Create("rank_id", "INTEGER")
		query:PrimaryKey("sid")
	query:Execute()

	local query = database:Create("voidfactions_ranks")
		query:Create("rank_id", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("faction_id", "INTEGER") -- there is no NOT NULL because of is_template
		query:Create("rank_name", "VARCHAR(60) NOT NULL")
		query:Create("weight", "INTEGER DEFAULT 10")
		query:Create("tag", "VARCHAR(30)")

		query:Create("minimum_level", "INTEGER") -- Minimum level needed to join (only static)

		query:Create("max_members", "INTEGER") -- Only for static facitons!

		query:Create("can_invite", "TINYINT(1) NOT NULL") -- Why doesn't sqlite have a boolean type?

		query:Create("can_promote", "SMALLINT NOT NULL") -- 1 -> disabled, 2->only faction members, 3->subfaction and faction (IF USING dynamic, then this is for setting ranks and boolean!)
		query:Create("can_demote", "SMALLINT")  -- 1 -> disabled, 2->only faction members, 3->subfaction and faction
 
		query:Create("can_purchase_perks", "TINYINT(1)")
		query:Create("kick_members", "SMALLINT NOT NULL") -- 1 -> disabled, 2->only faction members, 3->subfaction and faction
		query:Create("manage_faction", "TINYINT(1) NOT NULL") -- probably useless for static factions?

		-- Assets
		query:Create("can_deposit_money", "TINYINT(1)")
		query:Create("can_withdraw_money", "TINYINT(1)")

		query:Create("can_deposit_items", "TINYINT(1)")
		query:Create("can_withdraw_items", "TINYINT(1)")

		query:Create("is_template", "TINYINT(1)") -- is the rank a template rank?
		query:Create("autopromote_level", "INTEGER")

		query:Create("jobs", "VARCHAR(200)") -- probably max 10 jobs
		query:Create("promote_default", "VARCHAR(200)")

		query:PrimaryKey("rank_id")
	query:Execute()

	local query = database:Create("voidfactions_capturepoints")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		
		query:Create("pos", "VARCHAR(80)")
		query:Create("radius", "INTEGER NOT NULL")
		query:PrimaryKey("id")
	query:Execute()

	local query = database:Create("voidfactions_settings")
		query:Create("setting_key", "VARCHAR(50) NOT NULL")
		query:Create("value", "TEXT")
		query:PrimaryKey("setting_key")
	query:Execute()

	VoidFactions.SQL:BackwardsCompatibility()
end

-- Connects to the database
database:Connect()

concommand.Add("voidfactions_dropdatabases", function (ply)
	if (ply == NULL) then
		VoidFactions.SQL:DropDatabases(true)
	end
end)

function VoidFactions.SQL:DropDatabases(shouldRestart, keepSettings)
	local function wipe()
		database:Drop("voidfactions_factions"):Execute()
		if (!keepSettings) then
			database:Drop("voidfactions_settings"):Execute()
		end
		database:Drop("voidfactions_ranks"):Execute()
		database:Drop("voidfactions_members"):Execute()
		database:Drop("voidfactions_upgrades"):Execute()
		database:Drop("voidfactions_capturepoints"):Execute()
		database:Drop("voidfactions_upgraderelationships"):Execute()
		database:Drop("voidfactions_upgradepoints"):Execute()
		database:Drop("voidfactions_transactionhistory"):Execute()
		database:Drop("voidfactions_deposititems"):Execute()
		database:Drop("voidfactions_factionrewards"):Execute()
		database:Drop("voidfactions_rewards"):Execute()
		database:Drop("voidfactions_factionupgrades"):Execute()
	end

	pcall(wipe)

	if (shouldRestart) then
		VoidFactions.Print("Databases wiped. Restarting server in 5 seconds!")
		timer.Simple(5, function ()
			RunConsoleCommand("_RESTART")
		end)
	else
		VoidFactions.Print("Databases wiped. Please restart your server!")
	end
end

function VoidFactions.SQL:BackwardsCompatibility()

	-- primary key sqlite rename
	if (database.module == "sqlite") then
		local q = database:Select("voidfactions_settings")
		q:Callback(function (result)
			if (result and result[1] and result[1].key) then
				VoidFactions.Print("Backwards database compatibility started!")

				database:RawQuery("ALTER TABLE voidfactions_settings RENAME TO voidfactions_settings_temp;")
				local query = database:Create("voidfactions_settings")
					query:Create("setting_key", "VARCHAR(50) NOT NULL")
					query:Create("value", "TEXT")
					query:PrimaryKey("setting_key")
				query:Callback(function ()
					database:RawQuery([[
						INSERT INTO voidfactions_settings(setting_key, value)
						SELECT key, value
						FROM voidfactions_settings_temp;
					]], function ()
						database:Drop("voidfactions_settings_temp"):Execute()

						VoidFactions.Print("Backwards database compatibility finished!")
					end)
				end)
				query:Execute()
			end
		end)
		q:Execute()
	end

	local q = database:Select("voidfactions_ranks")
		q:Callback(function (result)
			local hasPromoteDefault = false
			for k, v in ipairs(result or {}) do
				if (v.promote_default) then
					hasPromoteDefault = true
				end
			end
			if (result and result[1] and !hasPromoteDefault) then
				VoidFactions.Print("Backwards database compatibility started! (ranks promote default)")

				local query = database:Alter("voidfactions_ranks")
					query:Add("promote_default", "VARCHAR(200)")
					query:Callback(function (result)
						VoidFactions.Print("Backwards database compatibility finished! (ranks promote default)")

						local subQ = database:Update("voidfactions_ranks")
							subQ:Update("promote_default", "[]")
						subQ:Execute()
					end)
				query:Execute()
			end
		end)
	q:Execute()

	local q = database:Select("voidfactions_deposititems")
		q:Callback(function (result)
			if (result and result[1] and !result[1].data) then
				VoidFactions.Print("Backwards database compatibility started! (deposit items data)")

				local query = database:Alter("voidfactions_deposititems")
					query:Add("data", "TEXT")
					query:Callback(function (result)
						VoidFactions.Print("Backwards database compatibility finished! (deposit items data)")

						local subQ = database:Update("voidfactions_deposititems")
							subQ:Update("data", "[]")
						subQ:Execute()
					end)
				query:Execute()
			end
		end)
	q:Execute()
end

hook.Add("VoidFactions.Settings.Loaded", "VoidFactions.SQL.PreloadFactions", function ()
	-- We need to wait until all the settings are loaded until we can preload the static factions
	VoidFactions.SQL:LoadStaticFactions()
	VoidFactions.SQL:LoadCapturePoints()

	if (VoidFactions.Settings:IsStaticFactions()) then
		VoidFactions.SQL:LoadRankTemplates()

		if (VoidFactions.Config.UpgradesEnabled) then
			VoidFactions.SQL:LoadUpgrades()
		end
	end

	if (VoidFactions.Settings:IsDynamicFactions()) then
		VoidFactions.SQL:LoadUpgrades()
		VoidFactions.SQL:LoadRewards()
	end
end)

--[[---------------------------------------------------------
	Name: Player data
-----------------------------------------------------------]]

local function finalizeNetworkPlayerData(member, members, varargs)
	member.faction:SetMembers(members)
	member:NetworkToPlayer(unpack(varargs))

	-- Clear it! the GC will collect it later (or reassign something else to its address)
	member.faction.members = nil
	members = nil

	VoidFactions.PrintDebug("Offline faction members fetched, and cleared from memory!")
end

function VoidFactions.SQL:NetworkMemberData(ply, ...)
	local member = ply:GetVFMember()
	if (!member) then
		VoidFactions.PrintError("Tried to network member data, but member object is not initialized!")
		return
	end

	local varargs = {...}

	local areMembersPreloaded = member.faction and member.faction.isPreloaded

	if (member.faction and !areMembersPreloaded) then
		VoidFactions.PrintDebug("Offline faction members are not preloaded, fetching them!")
		VoidFactions.SQL:GetFactionMembers(member.faction, function (members)
			if (!IsValid(ply)) then return end

			if (VoidChar) then
				VoidFactions.SQL:VoidCharSetMemberNames(members, function ()
					finalizeNetworkPlayerData(member, members, varargs)
				end)
			else
				finalizeNetworkPlayerData(member, members, varargs)
			end
		end)
	else
		member:NetworkToPlayer(...)
	end
end

function VoidFactions.SQL:InitFactionInstance(member, sid, data, ply, callback)
	VoidFactions.PrintDebug("Waiting for rank load until we network data..")

	-- If passing a function, then the callback will be called once all ranks/members are loaded
	VoidFactions.SQL:LoadFaction(data, nil, nil, function (faction)
		VoidFactions.PrintDebug("Networking player data, ranks/members loaded!")
		member = VoidFactions.Members[sid]
		member.ply = ply

		VoidFactions.Factions[faction.id] = faction

		if (!ply or IsValid(ply)) then
			local rank = faction.ranks[data.rank_id]
			member:SetRank(rank)

			if (ply) then
				VoidFactions.Faction:NetworkNewFaction(faction)
				VoidFactions.Faction:NetworkFactions(ply)
				VoidFactions.SQL:NetworkMemberData(ply, nil, true)
			end

			if (callback) then
				callback(member)
			end
		end

		
	end)
	
end


function VoidFactions.SQL:LoadFactionInstance(member, sid, data, ply, callback)
	local faction = VoidFactions.Factions[data.faction_id]
	if (!faction.ranks or !faction.members) then
		-- Load the ranks because static factions preload all the factions without ranks
		VoidFactions.PrintDebug("Faction loaded, but ranks/members are missing! Loading ranks/members..")
		VoidFactions.SQL:LoadFactionRanksAndMembers(faction, function ()
			if (ply and !IsValid(ply)) then return end

			member = VoidFactions.Members[sid]
			member.ply = ply

			local rank = faction.ranks[data.rank_id]
			member:SetRank(rank)

			if (!faction.isPreloaded) then
				faction.members[#faction.members + 1] = member
			end

			if (ply) then
				VoidFactions.Faction:NetworkNewFaction(faction)
				VoidFactions.SQL:NetworkMemberData(ply, nil, true)
			end

			if (callback) then
				callback(member)
			end
		end)
	else
		VoidFactions.PrintDebug("Faction loaded, and ranks/members are loaded too.")

		member = VoidFactions.Members[sid]
		if (!member) then
			-- Load the member
			VoidFactions.PrintDebug("Member " .. sid .. " is not loaded! Loading..")

			data.faction_id = tonumber(data.faction_id)
			data.rank_id = tonumber(data.rank_id)
			data.default_faction_id = tonumber(data.default_faction_id)
			data.last_promotion = tonumber(data.last_promotion)
			data.faction_joined = tonumber(data.faction_joined)

			data.autopromote_disabled = tobool(data.autopromote_disabled)

			local rank = faction.ranks[data.rank_id]

			local job = nil
			if (VoidFactions.Settings:IsStaticFactions() and data.job and data.job != "NULL") then
				local tblJob = DarkRP.getJobByCommand(data.job)
				if (tblJob) then
					job = tblJob.team
				else
					job = (GAMEMODE or GM).DefaultTeam or RPExtraTeams[1].team
					VoidFactions.PrintError("Member " .. data.sid .. " has a non-existing job, falling back to GAMEMODE.DefaultTeam! You will need to fix this conflict!")
				end
			end

			member = VoidFactions.Member:InitMember(sid, ply, faction, data.xp, data.level, data.playtime, data.last_promotion, rank, job, nil, data.last_seen, data.default_faction_id, data.autopromote_disabled, data.faction_joined)
			member.ply = ply
			VoidFactions.Members[sid] = member

			if (VoidChar) then
				local id = string.Split(sid, "-")[2]
				VoidFactions.SQL:GetCharacterName(id, function (name)
					if (ply and !IsValid(ply)) then return end
					member:SetName(name)

					VoidFactions.SQL:NetworkMemberData(ply, nil, true)
					if (callback) then callback(member) end
				end)

				return
			end
		end

		member.ply = ply

		-- here
		if (!faction.isPreloaded) then
			faction.members[#faction.members + 1] = member
			VoidFactions.Faction:UpdateFactionMembers(faction)
		end

		VoidFactions.SQL:NetworkMemberData(ply, nil, true)

		if (callback) then
			callback(member)
		end
	end
end


function VoidFactions.SQL:LoadPlayerData(ply, sid, callback)

	if (ply and ply:IsBot()) then return end

	if (ply) then
		VoidFactions.PrintDebug("Loading " .. ply:Name() .. "'s data..")
	end

	if (ply) then
		VoidFactions.Faction:NetworkFactions(ply)
	end

	sid = ply and ply:SteamID64() or sid

	if (VoidChar and ply) then -- if ply not passed, then the dash is already there
		sid = sid .. "-" .. ply:GetCharacterID()
	end

	-- If the server does not have VoidChar installed, and it contains a dash, remove it
	if (!VoidChar and string.find(sid, "-")) then
		local index = string.find(sid, "-")
		sid = string.sub(sid, 1, index - 1)
		VoidFactions.PrintWarning("Member has a character ID, but VoidChar is not installed! Character ID stripped!")
	end


	local query = database:Select("voidfactions_members")
		query:LeftJoin("voidfactions_members", "voidfactions_factions", "faction_id", "id")
		query:Where("sid", sid)
		query:Callback(function (result)
			-- If the ply parameter was passed, and the player is not valid, return
			if (ply and !IsValid(ply)) then return end

			if (result and #result > 0) then
				local data = result[1]

				local member = VoidFactions.Members[sid]

				data.faction_id = tonumber(data.faction_id)
				data.rank_id = tonumber(data.rank_id)
				data.default_faction_id = tonumber(data.default_faction_id)

				-- Load faction
				if (data.faction_id) then

					if (!VoidFactions.Factions[data.faction_id]) then
						-- Create a faction instance (this will only occur for dynamic factions, because static are preloaded)
						VoidFactions.SQL:InitFactionInstance(member, sid, data, ply, function (result)
							if (callback) then
								callback(result)
							end
							if (IsValid(ply)) then
								hook.Run("VoidFactions.SQL.MemberLoaded", ply)
							end
						end)
					else
						-- Load the faction instance
						VoidFactions.SQL:LoadFactionInstance(member, sid, data, ply, function (result)
							if (callback) then
								callback(result)
							end
							if (IsValid(ply)) then
								hook.Run("VoidFactions.SQL.MemberLoaded", ply)
							end
						end)
					end
					
				else
					-- Create member instance here (without a faction)
					data.last_promotion = tonumber(data.last_promotion)

					member = VoidFactions.Member:InitMember(sid, ply, nil, data.xp, data.level, data.playtime, data.last_promotion, nil, nil, nil, data.last_seen, data.default_faction_id)
					VoidFactions.Members[sid] = member

					if (VoidChar) then
						local id = string.Split(sid, "-")[2]
						VoidFactions.SQL:GetCharacterName(id, function (name)
							if (ply and !IsValid(ply)) then return end
							member:SetName(name)

							VoidFactions.Faction:NetworkFactions(ply)
							VoidFactions.SQL:NetworkMemberData(ply, nil, true)
							if (callback) then callback(member) end
						end)
					else

						VoidFactions.Faction:NetworkFactions(ply)
						VoidFactions.SQL:NetworkMemberData(ply, nil, true)
						if (callback) then callback(member) end
					end

					if (IsValid(ply)) then
						hook.Run("VoidFactions.SQL.MemberLoaded", ply)
					end
				end

			else
				if (!ply) then return nil end
				VoidFactions.SQL:CreatePlayerEntry(ply)
			end
		end)
	query:Execute()
end

function VoidFactions.SQL:CreatePlayerEntry(ply)

	local sid = ply:SteamID64()

	if (VoidChar) then
		sid = sid .. "-" .. ply:GetCharacterID()
	end

	if (VoidFactions.Members[sid]) then return end

	local query = database:Insert("voidfactions_members")
		query:Insert("sid", sid)
		query:Insert("autopromote_disabled", false)
	query:Execute()

	local member = VoidFactions.Member:InitMember(sid, ply, nil, 0, 1, 0, nil, nil, nil, nil, os.time(), nil)
	VoidFactions.Members[sid] = member
	VoidFactions.SQL:NetworkMemberData(ply, nil, true)

	hook.Run("VoidFactions.SQL.MemberLoaded", ply)
end

function VoidFactions.SQL:UnloadPlayerData(ply)
	local sid = ply:SteamID64()
	if (VoidChar) then
		local charId = ply:GetCharacterID()
		if (!charId) then return end
		sid = sid .. "-" .. charId
	end

	local member = ply:GetVFMember()
	if (!member) then return end
	local faction = member.faction

	if (VoidFactions.Settings:IsDynamicFactions()) then
		if (faction) then
			local shouldUnload = true
			for id, mem in ipairs(faction.members or {}) do
				if (IsValid(mem.ply)) then
					shouldUnload = false
				end
			end

			if (shouldUnload) then
				for id, mem in ipairs(faction.members or {}) do
					VoidFactions.Members[mem.sid] = nil
				end

				VoidFactions.PrintDebug("Unloaded faction " .. faction.name .. "!")

				VoidFactions.Factions[faction.id] = nil
				faction = nil
			end
		end
	end

	-- Don't unload preloaded members
	if (faction and faction.isPreloaded) then return end

	VoidFactions.PrintDebug("Unloading player " .. ply:Nick() .. " from memory..")

	if (faction) then
		for id, mem in ipairs(faction.members or {}) do
			if (mem.sid == sid) then
				table.remove(faction.members, id)
			end
		end
	end
	VoidFactions.Members[sid] = nil
end

hook.Add("VoidLib.PlayerFullLoad", "VoidFactions.SQL.LoadPlayerInfo", function (ply)
	if (VoidChar) then
		VoidFactions.Settings:NetworkVoidCharFactions()
		return
	end
	VoidFactions.SQL:LoadPlayerData(ply)
end)

hook.Add("VoidChar.CharacterDeleted", "VoidFactions.SQL.DeleteVoidCharMember", function (ply, character)
	-- Unload from memory
        if (!ply) then return end
        if (isnumber(character)) then return end
		
	local id = character.id
	local sid = ply:SteamID64()
	local memberId = sid .. "-" .. id
	local member = VoidFactions.Members[memberId]
	if (!member) then return end

	local faction = member.faction
	if (faction) then
		for k, mem in ipairs(faction.members or {}) do
			if (mem.sid == memberId) then
				table.remove(faction.members, k)
			end
		end

		VoidFactions.Faction:UpdateFactionMembers(faction)
	end

	member:NetworkToPlayer()

	local query = database:Delete("voidfactions_members")
		query:Where("sid", memberId)
	query:Execute()

	VoidFactions.Members[memberId] = nil

	VoidFactions.PrintDebug("[VoidChar Support] Deleted member " .. memberId .. " from database!")
end)

-- Load the data after a character has been selected if using VoidChar

local function characterSelect(ply, justCreated, data)
	if (!VoidChar) then return end

	local member = ply:GetVFMember()
	if (member) then
		VoidFactions.SQL:UnloadPlayerData(ply)
	end

	ply:SetNWInt("VoidFactions.CharID", ply:GetCharacterID())
	VoidFactions.PrintDebug("Character selected!")

	if (justCreated) then
		hook.Add("VoidFactions.SQL.MemberLoaded", "VoidFactions.SQL.VCListenForMember" .. ply:SteamID64(), function (_ply)
			if (ply != _ply) then return end

			hook.Remove("VoidFactions.SQL.MemberLoaded", "VoidFactions.SQL.VCListenForMember" .. ply:SteamID64())

			local mem = ply:GetVFMember()
			if (!mem) then return end

			local faction = data.faction
			if (!faction) then return end

			-- God forbid if you name two factions with the same name
			local factionFound = false
			local vfFaction = nil
			for k, v in pairs(VoidFactions.Factions) do
				if (v.name == faction and v.isDefaultFaction) then
					factionFound = true
					vfFaction = v
				end
			end

			if (!vfFaction) then return end

			local rank = vfFaction:GetLowestRank()
			local jobs = rank.jobs

			if (!table.HasValue(jobs, data.job)) then return end

			if (!mem.defaultFactionId) then
				mem:SetDefaultFactionId(vfFaction.id)
				mem:SaveStatic()

				local networkTbl = {{"defaultFactionId", vfFaction.id}}
				VoidFactions.Member:UpdateMemberFields(mem, networkTbl)
			end

			if (!mem.faction) then
				local b = VoidFactions.Invites:JoinFaction(mem, vfFaction)
				if (b) then
					VoidLib.Notify(ply, L"success", L("memberJoinedFaction", vfFaction.name), VoidUI.Colors.Green, 5)

					mem:ChangeJob(data.job, true)
				end
			end
				
			hook.Run("VoidFactions.SQL.MemberCharacterReady")

		end)
	end

	VoidFactions.SQL:LoadPlayerData(ply)
end

hook.Add("VoidChar.CharacterSelected", "VoidFactions.SQL.LoadPlayerInfoVoidChar", function (ply)
	characterSelect(ply)
end)

hook.Add("VoidChar.CharacterCreated", "VoidFactions.SQL.LoadPlayerInfoVoidCharCreate", function (ply, data)
	characterSelect(ply, true, data)
end)

hook.Add("PlayerDisconnected", "VoidFactions.SQL.ClearPlayerData", function (ply)
	VoidFactions.SQL:UnloadPlayerData(ply)
end)


--[[---------------------------------------------------------
	Name: Member & Faction DB
	Info: All member actions related with factions go here
-----------------------------------------------------------]]


function VoidFactions.SQL:KickMember(member)

	local faction = member.faction
	local factionId = faction.id
	local defaultFaction = nil
	if (VoidFactions.Settings:IsStaticFactions()) then
		if (!member.defaultFactionId) then
			VoidFactions.PrintError("Member " .. member.sid .. " doesn't have a default faction!'")
			return
		end

		defaultFaction = VoidFactions.Factions[member.defaultFactionId]
		if (!defaultFaction) then
			VoidFactions.PrintError("Member " .. member.sid .. "'s default faction does not exist!!'")
			return
		end

		if (faction.id == defaultFaction.id) then return end
	end

	member:SetRank(nil)
	member:SetJob(nil)
	for i, mem in ipairs(faction.members or {}) do
		if (mem.sid == member.sid) then
			table.remove(faction.members, i)
			break
		end
	end

	if (VoidFactions.Settings:IsDynamicFactions()) then
		member:SetFaction(nil)
	end

	faction = VoidFactions.Factions[factionId]

	VoidFactions.Faction:UpdateFactionMembers(faction)

	VoidFactions.NameTags:SetNameTag(member)


	if (VoidFactions.Settings:IsStaticFactions()) then
		local usedRank = nil
		local skipFirst = VoidFactions.Config.SkipFirstRank
		if (skipFirst) then
			usedRank = defaultFaction:GetNextRank(defaultFaction:GetLowestRank())
		end
		VoidFactions.Invites:JoinFaction(member, defaultFaction, usedRank)
	else
		member:SaveStatic()
	end

	VoidFactions.PrintDebug("Member " .. member.sid .. " was kicked/left!")
	hook.Run("VoidFactions.MemberLeft", member)
end

--[[---------------------------------------------------------
	Name: VoidChar support
-----------------------------------------------------------]]

function VoidFactions.SQL:GetCharacterName(id, callback)
	local query = database:Select("VoidChar_characters")
	query:Select("name")
	query:Where("id", id)
	query:Callback(function (result)
		if (result and result[1]) then
			local char = result[1]
			local name = char.name
			local cloneId = char.clone_id or ""
			if (char.clone_id and VoidChar.Config.ShowHashtag) then
				cloneId = "#" .. cloneId
			end
			local finalName = (cloneId and cloneId .. " " .. name) or name
			callback(finalName)
		else
			VoidFactions.PrintError("[VoidChar Support] Character ID " .. id .. " does not exist!")
			callback("Unknown")
		end
	end)
	query:Execute()
end



--[[---------------------------------------------------------
	Name: Deposit items
-----------------------------------------------------------]]

function VoidFactions.SQL:DepositItem(faction, class, dropEnt, model, data, isExternal, callback)
	local query = database:Insert("voidfactions_deposititems")
		query:Insert("item_faction_id", faction.id)
		query:Insert("class", class)
		query:Insert("drop_ent", dropEnt)
		query:Insert("model", model)
		query:Insert("data", util.TableToJSON(data or {}))
		query:Insert("is_external", isExternal)

		query:Callback(function (result, status, lastID)
			local item = VoidFactions.DepositItem:New(lastID, faction, class, dropEnt, model, data, isExternal)

			if (!faction.deposits) then
				faction.deposits = {}
			end

			faction.deposits[item.id] = item

			VoidFactions.PrintDebug("Deposited item " .. item.class .. " for faction " .. faction.name)

			if (callback) then
				callback(lastID)
			end
		end)
	query:Execute()
end

function VoidFactions.SQL:WithdrawItem(faction, id)
	local query = database:Delete("voidfactions_deposititems")
		query:Where("id", id)
	query:Execute()
end

function VoidFactions.SQL:LoadDepositItems(faction, callback)

	if (!VoidFactions.Settings:IsDynamicFactions() and !VoidFactions.Config.DepositEnabled) then
		callback()
		return
	end

	local query = database:Select("voidfactions_deposititems")
		query:Where("item_faction_id", faction.id)
		query:Callback(function (result)
			local items = {}
			for k, v in ipairs(result or {}) do
				local id = tonumber(v.id)
				local class = v.class
				local model = v.model
				local dropEnt = v.drop_ent
				local data = util.JSONToTable(v.data or "[]")
				local isExternal = v.is_external

				local item = VoidFactions.DepositItem:New(id, faction, class, dropEnt, model, data, isExternal)
				items[item.id] = item

				VoidFactions.PrintDebug("Loaded item " .. item.class .. " for faction " .. faction.name)
			end
			faction:SetDeposits(items)

			if (callback) then
				callback()
			end
		end)
	query:Execute()
end

--[[---------------------------------------------------------
	Name: Rank Templates
-----------------------------------------------------------]]

function VoidFactions.SQL:LoadRankTemplates()
	local query = database:Select("voidfactions_ranks")
		query:Callback(function (result)
			local ranks = VoidFactions.SQL:LoadFactionRanks(result, faction)
			VoidFactions.RankTemplates = ranks
			VoidFactions.PrintDebug("Loaded rank templates!")
		end)
		query:Where("is_template", "1", true)
		query:Where("is_template", "true", true)
	query:Execute()
end

--[[---------------------------------------------------------
	Name: Transaction history
-----------------------------------------------------------]]

function VoidFactions.SQL:InsertTransactionHistory(faction, ply, difference, itemClass)

	local transaction = VoidFactions.TransactionHistory:New(os.time(), faction, ply:SteamID64(), difference, itemClass)
	if (itemClass == "money") then
		transaction:SetIsMoney()
	end

	if (!faction.transactions) then
		faction.transactions = {}
	end
	faction.transactions[#faction.transactions + 1] = transaction

	local query = database:Insert("voidfactions_transactionhistory")
		query:Insert("faction_id", faction.id)
		query:Insert("sid", ply:SteamID64())
		query:Insert("amount_difference", difference)
		query:Insert("item_class", itemClass)
		query:Insert("time", os.time())
	query:Execute()
end

function VoidFactions.SQL:LoadTransactionHistory(faction, callback)

	if (!VoidFactions.Settings:IsDynamicFactions() and !VoidFactions.Config.DepositEnabled) then
		callback()
		return
	end

	local query = database:Select("voidfactions_transactionhistory")
		query:Where("faction_id", faction.id)
		query:Limit(50)
		query:Callback(function (result)
			local history = {}
			faction.transactions = {}

			for k, v in ipairs(result or {}) do
				v.amount_difference = tonumber(v.amount_difference)
				v.time = tonumber(v.time)

				local transaction = VoidFactions.TransactionHistory:New(v.time, faction, v.sid, v.amount_difference, v.item_class)
				if (v.item_class == "money") then
					transaction:SetIsMoney()
				end

				faction.transactions[#faction.transactions + 1] = transaction
			end
			VoidFactions.PrintDebug("Loaded " .. #faction.transactions .. " transactions for faction " .. faction.name)

			if (callback) then
				callback()
			end
		end)
	query:Execute()
end

--[[---------------------------------------------------------
	Name: Upgrade Points
-----------------------------------------------------------]]

function VoidFactions.SQL:GetUpgradePoints(callback)
	local query = database:Select("voidfactions_upgradepoints")
		query:Callback(function (result)
			callback(result or {})
		end)
	query:Execute()
end

function VoidFactions.SQL:GetPointRelations(callback)
	local query = database:Select("voidfactions_upgraderelationships")
		query:Callback(function (result)
			callback(result or {})
		end)
	query:Execute()
end

function VoidFactions.SQL:CreatePoint(upgrade, posX, posY)
	local query = database:Insert("voidfactions_upgradepoints")
		query:Insert("upgrade_id", upgrade.id)
		query:Insert("pos", VoidLib.SerializeVector(Vector(posX, posY)))
		query:Callback(function (result, _, id)
			local point = VoidFactions.UpgradePoints:New(id, upgrade, posX, posY, nil)
			VoidFactions.UpgradePoints.List[point.id] = point

			VoidFactions.Upgrades:NetworkUpgrades()

			VoidFactions.PrintDebug("Created new point with id " .. id)
		end)
	query:Execute()
end

function VoidFactions.SQL:UpdatePoint(point)
	local query = database:Update("voidfactions_upgradepoints")
		query:Where("id", point.id)
		query:Update("pos", VoidLib.SerializeVector(Vector(point.posX, point.posY)))
	query:Execute()

	local query = database:Delete("voidfactions_upgraderelationships")
	query:Callback(function ()

		local relationships = {}
		for _, relPoint in pairs(VoidFactions.UpgradePoints.List) do 
			for k, to in pairs(relPoint.to) do
				-- to is point
				local q = database:Replace("voidfactions_upgraderelationships")
					q:Insert("from_id", relPoint.id)
					q:Insert("to_id", to.id)
				q:Execute()
			end
		end

	end)
	query:Execute()
end

function VoidFactions.SQL:DeletePoint(point)
	local query = database:Delete("voidfactions_upgradepoints")
		query:Where("id", point.id)
	query:Execute()

	local query = database:Delete("voidfactions_upgraderelationships")
		query:Where("from_id", point.id, true)
		query:Where("to_id", point.id, true)
	query:Execute()
end

function VoidFactions.SQL:LoadUpgradePoints()
	VoidFactions.SQL:GetPointRelations(function (relations)
		local froms = {}
		for k, v in ipairs(relations) do
			v.from_id = tonumber(v.from_id)
			v.to_id = tonumber(v.to_id)

			if (v.from_id) then
				local relation = froms[v.from_id]
				if (!relation) then
					froms[v.from_id] = {v.to_id}
				else
					froms[v.from_id][#relation + 1] = v.to_id
				end
			end
		end
	
		VoidFactions.SQL:GetUpgradePoints(function (result)
			for k, v in ipairs(result) do
				local id = tonumber(v.id)
				local upgrade = VoidFactions.Upgrades.Custom[tonumber(v.upgrade_id)]

				if (!upgrade) then
					VoidFactions.PrintError("Upgrade point id " .. v.id .. " has a nonexisting upgrade!")
					continue
				end

				local pos = VoidLib.DeserializeVector(v.pos)
				local posX, posY = pos.x, pos.y

				local point = VoidFactions.UpgradePoints:New(id, upgrade, posX, posY, nil)
				VoidFactions.UpgradePoints.List[point.id] = point

				VoidFactions.PrintDebug("Loaded upgrade point ID " .. point.id .. "!")
			end

			for k, point in pairs(VoidFactions.UpgradePoints.List) do
				local fromsPoints = {}
				for k, v in ipairs(froms[point.id] or {}) do
					local relPoint = VoidFactions.UpgradePoints.List[v]
					fromsPoints[k] = relPoint
				end
				point:SetTo(fromsPoints)

				VoidFactions.PrintDebug("Loaded upgrade point ID " .. point.id .. " relationships!")
			end

			hook.Run("VoidFactions.Upgrades.Loaded")
			VoidFactions.SQL.UpgradesLoaded = true

		end)
		
	end)
end

--[[---------------------------------------------------------
	Name: Rewards
-----------------------------------------------------------]]

function VoidFactions.SQL:GetRewards(callback)
	local query = database:Select("voidfactions_rewards")
		query:Callback(function (result)
			callback(result or {})
		end)
	query:Execute()
end

function VoidFactions.SQL:UpdateReward(reward, name, module, requiredValue, money, xp, icon)
	local query = database:Insert("voidfactions_rewards")
		query:Update("name", name)
		query:Update("module_name", module.name)
		query:Update("required_value", requiredValue)
		query:Update("money_amount", money)
		query:Update("xp_amount", xp)
		query:Update("icon", icon)
		query:Where("id", reward.id)
	query:Execute()
end

function VoidFactions.SQL:DeleteReward(reward)
	local query = database:Delete("voidfactions_rewards")
		query:Where("id", reward.id)
	query:Execute()
end

function VoidFactions.SQL:CreateReward(name, module, requiredValue, money, xp, icon)
	local query = database:Insert("voidfactions_rewards")
		query:Insert("name", name)
		query:Insert("module_name", module.name)
		query:Insert("required_value", requiredValue)
		query:Insert("money_amount", money)
		query:Insert("xp_amount", xp)
		query:Insert("icon", icon)

		query:Callback(function (result, _, id)
			local reward = VoidFactions.Rewards:New(id, name, module, requiredValue, money, xp, icon)
			VoidFactions.Rewards.List[reward.id] = reward

			VoidFactions.Rewards:NetworkRewards()
			
			VoidFactions.PrintDebug("Created new reward with id " .. id)
		end)
	query:Execute()
end

function VoidFactions.SQL:UnlockFactionRewardClaim(faction, reward)
	faction.factionRewards[reward.id] = true

	faction:AddXP(reward.xp)
	faction:SetMoney(faction.money + reward.money)

	faction:SaveStatic()

	faction:NotifyMembers(L"success", L("unlockedReward", reward.name), VoidUI.Colors.Green, 5)

	VoidFactions.Deposit:NetworkDeposits(faction)

	local query = database:Insert("voidfactions_factionrewards")
		query:Insert("faction_id", faction.id)
		query:Insert("id", reward.id)
	query:Execute()
end

function VoidFactions.SQL:LoadFactionRewardsClaims(faction)
	local query = database:Select("voidfactions_factionrewards")
		query:Callback(function (result)
			local tbl = {}
			for k, v in ipairs(result or {}) do
				local id = tonumber(v.id)
				tbl[id] = true
			end

			faction:SetFactionRewards(tbl)
			VoidFactions.PrintDebug("Loaded faction reward claims for faction " .. faction.name .. "!")
		end)
		query:Where("faction_id", faction.id)
	query:Execute()
end

function VoidFactions.SQL:LoadRewards()
	VoidFactions.SQL:GetRewards(function (result)
		local rewards = {}
		for k, v in ipairs(result) do
			local id = tonumber(v.id)
			local name = v.name
			local requiredValue = tonumber(v.required_value)
			local moneyAmount = tonumber(v.money_amount)
			local xpAmount = tonumber(v.xp_amount)
			local icon = v.icon

			local module = VoidFactions.RewardModules.List[v.module_name]
			if (!module) then continue end

			local reward = VoidFactions.Rewards:New(id, name, module, requiredValue, moneyAmount, xpAmount, icon)
			rewards[reward.id] = reward

			VoidFactions.PrintDebug("Loaded custom reward " .. name .. "!")
		end

		VoidFactions.Rewards.List = rewards

	end)
end

-- This loads the values
function VoidFactions.SQL:LoadRewardValues(faction, callback)
	local query = database:Select("voidfactions_rewardmodules")
		query:Where("faction_id", faction.id)
		query:Callback(function (result)
			local resultKeys = {}
			local rewards = {}
			for k, v in ipairs(result or {}) do
				resultKeys[v.name] = true

				local module = VoidFactions.RewardModules.List[v.name]
				if (!module) then continue end

				local reward = VoidFactions.FactionRewards:New(module, tonumber(v.value))
				rewards[v.name] = reward

				VoidFactions.PrintDebug("Loaded reward values " .. v.name .. " from database for faction " .. faction.name)
			end

			for name, reward in pairs(VoidFactions.RewardModules.List) do
				if (!resultKeys[name]) then
					local q = database:Insert("voidfactions_rewardmodules")
						q:Insert("name", name)
						q:Insert("faction_id", faction.id)
						q:Insert("value", 0)
					q:Execute()

					local module = VoidFactions.RewardModules.List[name]
					if (!module) then continue end
					
					local reward = VoidFactions.FactionRewards:New(module, 0)
					rewards[name] = reward

					VoidFactions.PrintDebug("Inserted reward values " .. name .. " into database for faction " .. faction.name)
				end
			end

			faction:SetRewardValues(rewards)

			if (callback) then
				callback()
			end
		end)
	query:Execute()
end

function VoidFactions.SQL:UpdateRewardValues(reward, faction, updateQuery)
	local query = database:Update("voidfactions_rewardmodules")
		query:Update("value", updateQuery, true)
		query:Where("faction_id", faction.id)
		query:Where("name", reward.name)
	query:Execute()

	local factionReward = faction.rewardValues and faction.rewardValues[reward.name]
	if (factionReward and isnumber(tonumber(updateQuery))) then
		factionReward:SetValue(updateQuery)
	end

	if (factionReward) then
		VoidFactions.Faction:UpdateFactionReward(faction, factionReward)
	end

	VoidFactions.SQL:CheckRewardUnlocks(reward)

	VoidFactions.PrintDebug("Updated reward module " .. reward.name .. " with value " .. updateQuery)
end

function VoidFactions.SQL:CheckRewardUnlocks(rewardModule)
	VoidFactions.PrintDebug("Checking reward unlocks..")
	for k, faction in pairs(VoidFactions.Factions) do
		local rewardValue = faction.rewardValues and faction.rewardValues[rewardModule.name]
		if (rewardValue) then
			-- Get all rewards
			for _, reward in pairs(VoidFactions.Rewards.List) do
				if (reward.module == rewardModule and rewardValue.value >= reward.requiredValue and !faction.factionRewards[reward.id]) then
					VoidFactions.SQL:UnlockFactionRewardClaim(faction, reward)
				end
			end
		end
	end
end

function VoidFactions.SQL:IncrementReward(reward, faction, incr)
	local factionReward = faction.rewardValues[reward.name]
	factionReward:SetValue(factionReward.value + incr)

	VoidFactions.SQL:UpdateRewardValues(reward, faction, "value + " .. incr)
end

--[[---------------------------------------------------------
	Name: Upgrades
-----------------------------------------------------------]]

function VoidFactions.SQL:LoadFactionUpgrades(faction, callback)
	if (VoidFactions.Settings:IsStaticFactions() and !VoidFactions.Config.UpgradesEnabled) then
		if (callback) then callback() end
		return
	end

	VoidFactions.PrintDebug("Loading upgrades for faction " .. faction.name .. "...")

	local query = database:Select("voidfactions_factionupgrades")
		query:Where("faction_id", faction.id)
		query:Callback(function (result)
			local upgrades = {}
			local spentPoints = 0
			for k, v in ipairs(result or {}) do
				local pointId = tonumber(v.point_id)
				upgrades[pointId] = true
				spentPoints = spentPoints + tonumber(v.upgrade_points)
			end

			faction:SetUpgrades(upgrades)
			faction:SetSpentUpgradePoints(spentPoints)
			VoidFactions.PrintDebug("Loaded " .. #upgrades .. " upgrades for faction " .. faction.name)

			if (callback) then
				callback()
			end
		end)
	query:Execute()
end

function VoidFactions.SQL:InsertFactionUpgrade(faction, point, capPoints)
	local query = database:Insert("voidfactions_factionupgrades")
		query:Insert("faction_id", faction.id)
		query:Insert("point_id", point.id)
		query:Insert("upgrade_points", capPoints)
	query:Execute()
end

function VoidFactions.SQL:LoadUpgrades()
	VoidFactions.SQL:GetUpgrades(function (result)
		for k, v in ipairs(result) do
			local module = VoidFactions.Upgrades.Modules[v.module_name]
			local currency = VoidFactions.Currencies.List[v.currency]

			local upgrade = VoidFactions.CustomUpgrades:New(tonumber(v.id), v.name, module, v.value, currency, tonumber(v.cost), v.icon)
			VoidFactions.Upgrades.Custom[upgrade.id] = upgrade

			VoidFactions.PrintDebug("Loaded upgrade name " .. upgrade.name .. "!")
		end

		VoidFactions.SQL:LoadUpgradePoints()
	end)
end

function VoidFactions.SQL:CreateUpgrade(name, module, value, currency, cost, icon)
	local query = database:Insert("voidfactions_upgrades")
		query:Insert("name", name)
		query:Insert("module_name", module.name)
		query:Insert("value", tostring(value))
		query:Insert("currency", currency.name)
		query:Insert("cost", cost)
		query:Insert("icon", icon)
		query:Callback(function (result, _, id)
			local upgrade = VoidFactions.CustomUpgrades:New(id, name, module, value, currency, cost, icon)
			VoidFactions.Upgrades.Custom[id] = upgrade

			VoidFactions.Upgrades:NetworkUpgrades()

			module:Load(value, id)

			VoidFactions.PrintDebug("Created new upgrade with name " .. name)
		end)
	query:Execute()
end

function VoidFactions.SQL.UpdateUpgrade(upgrade)
	local query = database:Update("voidfactions_upgrades")
		query:Update("name", upgrade.name)
		query:Update("module_name", upgrade.module.name)
		query:Update("value", tostring(upgrade.value))
		query:Update("currency", upgrade.currency.name)
		query:Update("cost", upgrade.cost)
		query:Update("icon", upgrade.icon)
		query:Where("id", upgrade.id)
	query:Execute()
end


function VoidFactions.SQL:DeleteUpgrade(upgrade)
	local query = database:Delete("voidfactions_upgrades")
		query:Where("id", upgrade.id)
	query:Execute()
end

function VoidFactions.SQL:GetUpgrades(callback)
	local query = database:Select("voidfactions_upgrades")
		query:Callback(function (result)
			callback(result or {})
		end)
	query:Execute()
end


--[[---------------------------------------------------------
	Name: Capture points
-----------------------------------------------------------]]

function VoidFactions.SQL:LoadCapturePoints()
	local query = database:Select("voidfactions_capturepoints")
		query:Callback(function (res)
			for k, v in ipairs(res or {}) do
				local point = VoidFactions.CapturePoints:InitCapturePoint(tonumber(v.id), VoidLib.DeserializeVector(v.pos), tonumber(v.radius))
				VoidFactions.PointsTable[point.id] = point

				VoidFactions.PrintDebug("Loaded capture point ID " .. point.id .. "!")
			end
		end)
	query:Execute()
end

function VoidFactions.SQL:CreateCapturePoint(pos, radius, callback)
	local query = database:Insert("voidfactions_capturepoints")
		query:Insert("pos", VoidLib.SerializeVector(pos))
		query:Insert("radius", radius)
		query:Callback(function (res, _, id)
			if (callback) then callback(id) end
		end)
	query:Execute()
end

function VoidFactions.SQL:DeleteCapturePoint(point)
	local query = database:Delete("voidfactions_capturepoints")
		query:Where("id", point.id)
	query:Execute()
end

--[[---------------------------------------------------------
	Name: Faction DB
-----------------------------------------------------------]]

-- This loads all the static faction on start to memory.
-- Dynamic factions are not loaded on start, because they are dynamic (not needed)
function VoidFactions.SQL:LoadStaticFactions()
	if (!VoidFactions.Settings:IsStaticFactions()) then return end

	VoidFactions.PrintDebug("Preloading static factions!")

	local query = database:Select("voidfactions_factions")
		query:Callback(function (result)
			if (!result or #result < 1) then return end

			local resultTbl = {}
			for _, data in ipairs(result) do
				resultTbl[tonumber(data.id)] = data
			end

			local subQ = database:Select("voidfactions_members")
			subQ:Select("faction_id, COUNT(*)", true)
			subQ:GroupBy("faction_id")

			local totalCallbacksDone = 0
			local hasToWait = false
			local totalFactions = 0

			for id, data in pairs(resultTbl) do
				if (!data) then continue end
				-- We will load the ranks when a member with the faction joins, or when an admin requests to
				if (!VoidFactions.Factions[id]) then
					local faction = VoidFactions.SQL:LoadFaction(data, true, resultTbl) -- yes, passing a third parameter for this..
					VoidFactions.Factions[id] = faction
					totalFactions = totalFactions + 1

					VoidFactions.PrintDebug("Preloaded faction " .. data.name .. " (" .. data.id .. ").")
				end
			end

			for k, faction in pairs(VoidFactions.Factions) do
				hasToWait = true
				local query = database:Select("voidfactions_ranks")
					query:Callback(function (result)
						VoidFactions.SQL:LoadFactionRanks(result, faction)
						totalCallbacksDone = totalCallbacksDone + 1

						if (totalCallbacksDone == totalFactions) then
							hook.Run("VoidFactions.SQL.StaticFactionsPreloaded")
						end
					end)
					query:Where("faction_id", faction.id)
				query:Execute()
			end

			if (!hasToWait) then
				hook.Run("VoidFactions.SQL.StaticFactionsPreloaded")
			end

			subQ:Callback(function (result)
				for k, v in ipairs(result or {}) do
					local count = tonumber(v["COUNT(*)"])
					local factionId = tonumber(v.faction_id)
					if (VoidFactions.Factions[factionId]) then
						VoidFactions.Factions[factionId]:SetMemberCount(count)
					end
				end
			end)
			subQ:Execute()

		end)
	query:Execute()
end

function VoidFactions.SQL:CreateDynamicFaction(name, tag, color, logo, inviteRequired, owner)
	local query = database:Insert("voidfactions_factions")
		query:Insert("name", name)
		query:Insert("tag", tag)
		query:Insert("color", color)
		query:Insert("logo", logo)
		query:Insert("invite_required", inviteRequired)
		query:Insert("owner", owner:SteamID64())
		query:Callback(function (result, status, lastID)
			local data = {}
			data.id = lastID
			data.name = name
			data.tag = tag
			data.color = string.FromColor(color)
			data.logo = logo
			
			data.invite_required = inviteRequired

			data.faction_xp = 0
			data.faction_level = 0
			local faction = VoidFactions.SQL:LoadFaction(data)

			VoidFactions.Factions[faction.id] = faction

			VoidFactions.Faction:NetworkFactions()
		end)
	query:Execute()
end

function VoidFactions.SQL:InsertUsergroups(faction, tbl)
	local query = database:Delete("voidfactions_requiredgroups")
	query:Where("faction_id", faction.id)
	query:Callback(function ()
		for k, v in pairs(tbl) do
			local q = database:Insert("voidfactions_requiredgroups")
			q:Insert("faction_id", faction.id)
			q:Insert("usergroup", v)
			q:Execute()
		end
	end)
	query:Execute()
end

function VoidFactions.SQL:CheckDuplicateFactionNames(name, tag, id, callback)
	local query = database:Select("voidfactions_factions")
		query:Where("name", name, true)
	        if (tag and tag != "") then
			query:Where("tag", tag, true)
		end
		query:Callback(function (result)
			if (!result or #result == 0) then 
				callback(false)
				return
			end

			local bFound = false
			for k, v in ipairs(result) do
				if (tonumber(v.id) != id) then
					callback(v)
					bFound = true
					break
				end
			end

			if (!bFound) then
				callback(false)
			end
		end)
	query:Execute()
end

function VoidFactions.SQL:CreateFaction(name, tag, color, maxMembers, subfactionOf, logo, inviteRequired, canCaptureTerritory, showOnBoard, isDefaultFaction, description, owner, usergroups)


	local query = database:Insert("voidfactions_factions")
		query:Insert("name", name)
		query:Insert("description", description)
		query:Insert("tag", tag)
		query:Insert("max_members", tonumber(maxMembers))
		if (subfactionOf) then
			query:Insert("parent_faction", subfactionOf.id)
		end
		query:Insert("color", color)
		query:Insert("logo", logo)
		query:Insert("owner", owner and owner:SteamID64())
		

		query:Insert("invite_required", inviteRequired)
		query:Insert("can_capture_territory", canCaptureTerritory)
		query:Insert("show_board", showOnBoard)
		query:Insert("is_default_faction", isDefaultFaction)

		query:Callback(function (result, status, lastID)
			local data = {}
			data.id = lastID
			data.name = name
			data.tag = tag
			data.color = string.FromColor(color)
			data.maxMembers = tonumber(maxMembers)
			data.parent_faction = subfactionOf and subfactionOf.id or nil
			data.description = description
			data.logo = logo

			data.money = 0
			
			data.invite_required = inviteRequired
			data.can_capture_territory = canCaptureTerritory
			data.show_board = showOnBoard
			data.is_default_faction = isDefaultFaction

			data.faction_xp = 0
			data.faction_level = 1

			data.requiredUsergroups = usergroups or {}


			VoidFactions.SQL:LoadFaction(data, nil, nil, function (faction)
				VoidFactions.Factions[faction.id] = faction

				-- NETWORK IT!!
				VoidFactions.Faction:NetworkFactions()

				if (VoidFactions.Settings:IsDynamicFactions()) then
					VoidFactions.SQL:CreateRank(faction, VoidFactions.Config.DefaultRankName, 1, nil, nil, true, 2, nil, true, 2, true, nil, nil, true, true, true, true, nil, {}, function ()
						VoidFactions.Invites:JoinFaction(owner:GetVFMember(), faction)
					end)
				end

				if (VoidFactions.Settings:IsStaticFactions()) then
					VoidFactions.SQL:InsertUsergroups(faction, usergroups or {})

					local callbacksDone = 0
					local rankTemplateLength = table.Count(VoidFactions.RankTemplates)
					-- promises/tasks pls??
					for k, v in pairs(VoidFactions.RankTemplates or {}) do
						VoidFactions.SQL:CreateRank(faction, v.name, v.weight, v.tag, v.maxMembers, v.canInvite, v.canPromote, v.canDemote, v.canPurchasePerks, v.kickMembers, v.manageFaction, v.jobs, v.minLevel, v.canWithdrawMoney, v.canDepositMoney, v.canWithdrawItems, v.canDepositItems, v.autoPromoteLevel, v.promoteDefault, function ()
							callbacksDone = callbacksDone + 1
							if (callbacksDone == rankTemplateLength) then
								VoidFactions.Faction:UpdateFactionRanks(faction)
								VoidFactions.Settings:RefreshVoidCharFactions()
							end
						end)
					end

					if (rankTemplateLength == 0) then
						VoidFactions.Settings:RefreshVoidCharFactions()
					end
				end
			end)


		end)
	query:Execute()


end

function VoidFactions.SQL:LoadFaction(data, noRanks, resultTbl, callback)

	if (!data) then
		VoidFactions.PrintError("Tried to load a non-existing faction! ID: " .. data.id)
		return
	end

	local parentFaction = nil
	if (data.parent_faction and data.parent_faction != "NULL") then
		-- load the parent faction
		VoidFactions.PrintDebug("Loading parent faction of " .. data.name .. "..")
		if (VoidFactions.Factions[tonumber(data.parent_faction)]) then
			parentFaction = VoidFactions.Factions[tonumber(data.parent_faction)]
			VoidFactions.PrintDebug("Got a reference when loading a parent faction")
		else
			if (resultTbl) then
				VoidFactions.PrintDebug("Loading a parent faction without a reference!")
				local factionData = resultTbl[tonumber(data.parent_faction)]
				-- load it recursively
				parentFaction = VoidFactions.SQL:LoadFaction(factionData, noRanks, resultTbl)
				VoidFactions.Factions[parentFaction.id] = parentFaction
				VoidFactions.PrintDebug("Initialized parent faction " .. parentFaction.name .. "!")
			end
		end
	end

	data.id = tonumber(data.id)
	data.invite_required, data.can_capture_territory, data.show_board, data.is_default_faction = tobool(data.invite_required), tobool(data.can_capture_territory), tobool(data.show_board), tobool(data.is_default_faction)
	
	-- Honestly i have no idea why this happens, but it happens, fucking sqlite bullshit (there is no image with the ID of null on imgur, so it's okay i guess)
	if (data.logo == "NULL") then
		data.logo = nil
	end
	
	local faction = VoidFactions.Faction:InitFaction(data.id, data.name, data.logo, string.ToColor(data.color), data.faction_xp, data.faction_level, parentFaction, tonumber(data.max_members), data.tag, data.invite_required, data.can_capture_territory, data.show_board, data.is_default_faction, data.description, tonumber(data.money))
	
	VoidFactions.PrintDebug("Loading faction ID: " .. faction.id)

	if (callback) then
		if (!noRanks) then
			-- a fucking pyramid lol 
			VoidFactions.SQL:LoadFactionRanksAndMembers(faction, function ()
				VoidFactions.SQL:LoadFactionUpgrades(faction, function ()
					
						VoidFactions.SQL:LoadDepositItems(faction, function ()
							VoidFactions.SQL:LoadTransactionHistory(faction, function ()
								VoidFactions.SQL:LoadRewardValues(faction, function ()
									if (VoidFactions.Settings:IsDynamicFactions()) then
										VoidFactions.SQL:LoadFactionRewardsClaims(faction)

										hook.Run("VoidFactions.Factions.FactionLoaded", faction)
										callback(faction)
									else
										VoidFactions.SQL:LoadRequiredGroups(faction, function ()
											hook.Run("VoidFactions.Factions.FactionLoaded", faction)
											callback(faction)
										end)
									end
									
								end)
							end)
						end)
				end)
			end)
		end
	else
		-- If no ranks, then don't load ranks and members
		if (!noRanks) then
			VoidFactions.SQL:LoadFactionRanksAndMembers(faction, function ()
				hook.Run("VoidFactions.Factions.FactionLoaded", faction)
			end)
			if (VoidFactions.Settings:IsDynamicFactions()) then
				VoidFactions.SQL:LoadDepositItems(faction)
				VoidFactions.SQL:LoadTransactionHistory(faction)
				VoidFactions.SQL:LoadRewardValues(faction)
				VoidFactions.SQL:LoadFactionRewardsClaims(faction)
			end
		end

		VoidFactions.SQL:LoadFactionUpgrades(faction)

		if (VoidFactions.Settings:IsStaticFactions()) then
			VoidFactions.SQL:LoadRequiredGroups(faction)

			if (VoidFactions.Config.DepositEnabled) then
				VoidFactions.SQL:LoadDepositItems(faction)
				VoidFactions.SQL:LoadTransactionHistory(faction)
			end
		end
		
		return faction
	end
end

function VoidFactions.SQL:LoadRequiredGroups(faction, callback)
	local query = database:Select("voidfactions_requiredgroups")
		query:Callback(function (result)
			local tbl = {}
			for k, v in pairs(result or {}) do
				local strGroup = v.usergroup
				tbl[#tbl + 1] = strGroup
			end
			faction:SetRequiredUsergroups(tbl)

			if (callback) then
				callback()
			end
		end)
		query:Where("faction_id", faction.id)
	query:Execute()
end

function VoidFactions.SQL:FetchFactionRanks(faction, callback)
	local query = database:Select("voidfactions_ranks")
		query:Callback(function (result)
			VoidFactions.SQL:LoadFactionRanks(result, faction)
			if (callback) then
				callback()
			end
		end)
		query:Where("faction_id", faction.id)
	query:Execute()
end

-- Callback occurs when all queries are done!
function VoidFactions.SQL:LoadFactionRanksAndMembers(faction, callback, bForce)
	local memberCount = faction.memberCount or 0
	local preloadMembers = (VoidFactions.Settings:IsStaticFactions() and memberCount < VoidFactions.Settings.Hardcoded.MembersMaxPreload) or bForce
	if (VoidFactions.Settings:IsDynamicFactions()) then
		preloadMembers = true
	end

	local function loadMembers()
		VoidFactions.SQL:GetFactionMembers(faction, function (members)
			VoidFactions.SQL:LoadFactionMembers(faction, members, preloadMembers, function ()
				if (callback) then
					callback(preloadMembers)
				end
			end)
		end)
	end

	-- if ranks and members are not loaded, load both
	if (!faction.ranks and !faction.members) then
		VoidFactions.SQL:FetchFactionRanks(faction, function ()
			loadMembers()
		end)
	end

	-- if ranks already laoded, but members not, load members
	if (faction.ranks and !faction.members) then
		loadMembers()
	end
end

function VoidFactions.SQL:GetFactionRanks(id, callback)
	local query = database:Select("voidfactions_ranks")
		query:Callback(function (result)
			callback(result)
		end)
		query:Where("faction_id", id)
	query:Execute()
end

function VoidFactions.SQL:GetFactionRank(faction, callback)
	local query = database:Select("voidfactions_factions")
		query:Select("COUNT(*)", true)
		query:WhereLT("id", "(SELECT id FROM voidfactions_factions WHERE id = " .. faction.id .. ")", true)
		query:Callback(function (result)
			callback(result[1]["COUNT(*)"] + 1)
		end)
	query:Execute()
end

function VoidFactions.SQL:GetFactionsRanking(page, callback, totalEntries)
	
	totalEntries = totalEntries or 6

	local query = database:Select("voidfactions_factions")
		query:OrderByDesc("faction_level")
		query:OrderByDesc("faction_xp")
		query:Limit(totalEntries)
		query:Offset( math.max(page * totalEntries - totalEntries, 0) )
		query:Callback(function (result)
			local subQ = database:Select("voidfactions_members")
				subQ:Select("faction_id, COUNT(*)", true)
				subQ:GroupBy("faction_id")
				subQ:Callback(function (memRes)
					for k, v in ipairs(memRes or {}) do
						local count = tonumber(v["COUNT(*)"])
						local factionId = tonumber(v.faction_id)

						for k, v in ipairs(result or {}) do
							if (tonumber(v.id) == factionId) then
								v.memberCount = count
							end
						end
					end

					local q = database:Select("voidfactions_factions")
						q:Select("COUNT(*)", true)
						q:Callback(function (r)
							local totalFactions = r[1]["COUNT(*)"]
							callback(result or {}, totalFactions)
						end)
					q:Execute()
				end)
			subQ:Execute()
		end)
	query:Execute()
end

function VoidFactions.SQL:GetFactionMembers(faction, callback)
	local query = database:Select("voidfactions_members")
		query:Callback(function (result)
			local members = {}
			for id, data in ipairs(result or {}) do

				data.faction_id = tonumber(data.faction_id)
				data.rank_id = tonumber(data.rank_id)
				data.default_faction_id = tonumber(data.default_faction_id)
				data.last_promotion = tonumber(data.last_promotion)

				local existingMember = VoidFactions.Members[data.sid]
				if (existingMember) then
					members[id] = existingMember
					continue
				end

				if (!faction.ranks) then
					VoidFactions.PrintError("Race condition detected! Tried to load members, but ranks are not loaded yet (faction " .. faction.name .. ")")
					continue
				end

				-- Load the member (this function should be called only when the faction is fully initialized)
				local rank = faction.ranks[data.rank_id]

				-- Load the member's job if using static factions
				local job = nil
				if (VoidFactions.Settings:IsStaticFactions() and data.job and data.job != "NULL") then
					local tblJob = DarkRP.getJobByCommand(data.job)
					if (tblJob) then
						job = tblJob.team
					else
						job = (GAMEMODE or GM).DefaultTeam or RPExtraTeams[1].team
						VoidFactions.PrintError("Member " .. data.sid .. " has a non-existing job, falling back to GAMEMODE.DefaultTeam! You will need to fix this conflict!")
					end
				end

				data.autopromote_disabled = tobool(data.autopromote_disabled)
				data.faction_joined = tonumber(data.faction_joined)

				local lowestRank = faction:GetLowestRank()
				if (rank and lowestRank and lowestRank.id == rank.id) then
					faction:SetLowestRankMemberCount((faction.lowestRankMemberCount or 0) + 1)
				end

				local member = VoidFactions.Member:InitMember(data.sid, NULL, faction, data.xp, data.level, data.playtime, data.last_promotion, rank, job, nil, data.last_seen, data.default_faction_id, data.autopromote_disabled, data.faction_joined)
				members[id] = member
			end
			callback(members)
		end)
		query:Where("faction_id", faction.id)
	query:Execute()
end

function VoidFactions.SQL:VoidCharSetMemberNames(members, callback)
	local query = database:Select("VoidChar_characters")
	query:Select("name")
	query:Select("sid")
	query:Select("id")
	for _, member in ipairs(members) do
		local sid = string.Split(member.sid, "-")[1]
		query:Where("sid", sid, true)
	end
	query:Callback(function (result)
		for k, v in ipairs(result or {}) do
			local id = v.sid .. "-" .. v.id
			local member = nil
			for _, mem in ipairs(members) do
				if (mem.sid == id) then
					member = mem
				end
			end
			if (member) then
				VoidFactions.PrintDebug("Setting name of " .. id .. " to " .. v.name)
				member:SetName(v.name)
			end
		end

		if (callback) then
			callback()
		end
	end)
	query:Execute()
end

-- Callback because of VoidChar support
function VoidFactions.SQL:LoadFactionMembers(faction, members, preloadMembers, callback)
	local memberTbl = {}
	for id, member in ipairs(members) do
		local sid64 = VoidChar and string.Split(member.sid, "-")[1] or member.sid
		local shouldLoad = IsValid(player.GetBySteamID64(sid64)) or preloadMembers
		if (shouldLoad) then
			VoidFactions.Members[member.sid] = member
			table.insert(memberTbl, member)
		end
	end

	faction:SetPreloaded(preloadMembers)

	faction:SetMembers(memberTbl)
	VoidFactions.PrintDebug("Preloaded " .. #memberTbl .. " members for faction " .. faction.name)

	if (VoidChar) then
		-- Load nicks
		VoidFactions.SQL:VoidCharSetMemberNames(memberTbl, callback)
	else
		if (callback) then
			callback()
		end
	end

end


function VoidFactions.SQL:LoadFactionRanks(result, faction)
	local ranks = {}
	for k, v in ipairs(result or {}) do
		local jobCommands = VoidFactions.Settings:IsStaticFactions() and VoidLib.CSVToTable(v.jobs) or {}
		local jobs = {}
		for _, cmd in ipairs(jobCommands) do
			local tbl, job = DarkRP.getJobByCommand(cmd)
			if (!job) then
				VoidFactions.PrintError("Tried to load job with command " .. cmd .. ", but job does not exist!")
				continue
			end

			local str = (istable(faction) and faction.name) or "TEMPLATE"

			VoidFactions.PrintDebug("Loaded job " .. team.GetName(job) .. " for faction " .. str .. ".")
			jobs[#jobs + 1] = job
		end

		if (VoidFactions.Settings:IsStaticFactions() and #jobs < 1) then
			VoidFactions.PrintError("Rank " .. v.rank_name .. " has no jobs! Adding a default fallback job. YOU WILL NEED TO FIX THIS CONFLICT!")
			jobs[#jobs + 1] = (GAMEMODE or GM).DefaultTeam or RPExtraTeams[1].team
		end

		v.can_promote = tonumber(v.can_promote)
		v.kick_members = tonumber(v.kick_members)
		v.can_demote = tonumber(v.can_demote)
		v.weight = tonumber(v.weight)
		v.autopromote_level = tonumber(v.autopromote_level)

		v.can_deposit_items = tobool(v.can_deposit_items)
		v.can_withdraw_items = tobool(v.can_withdraw_items)
		v.can_deposit_money = tobool(v.can_deposit_money)
		v.can_withdraw_money = tobool(v.can_withdraw_money)
		v.can_invite = tobool(v.can_invite)
		v.manage_faction = tobool(v.manage_faction)
		v.can_purchase_perks = tobool(v.can_purchase_perks)

		if (v.promote_default == "NULL") then
			v.promote_default = nil
		end

		local promoteDefault = {}
		if (v.promote_default and VoidFactions.Settings:IsStaticFactions()) then
			local promoteTbl = VoidLib.CSVToTable(v.promote_default)
			for k, id in ipairs(promoteTbl) do
				local faction = VoidFactions.Factions[tonumber(id)]
				if (!faction) then continue end

				promoteDefault[faction.id] = faction
			end
		end

		local rank = VoidFactions.Rank:InitRank(tonumber(v.rank_id), faction, v.rank_name, v.weight, v.tag, v.can_invite, v.can_promote, v.can_demote, v.can_purchase_perks, v.kick_members, v.manage_faction, jobs, tonumber(v.max_members), tonumber(v.minimum_level), v.can_withdraw_money, v.can_deposit_money, v.can_withdraw_items, v.can_deposit_items, v.autopromote_level, promoteDefault)
		VoidFactions.PrintDebug("Initialized rank name " .. rank.name .. "!")
		ranks[tonumber(rank.id)] = rank
	end

	VoidFactions.PrintDebug("Setting ranks to factions!")
	if (istable(faction)) then
		faction:SetRanks(ranks)
		hook.Run("VoidFactions.Faction.OnRanksLoaded", faction)
	end
	return ranks
end

function VoidFactions.SQL:UpdateDynamicFactionOffline(id, name, tag, color, logo, inviteRequired)
	local query = database:Update("voidfactions_factions")
		query:Update("name", name)
		query:Update("logo", logo)
		query:Update("color", string.FromColor(color))
		query:Update("tag", tag)
		query:Update("invite_required", inviteRequired)
		query:Where("id", id)
	query:Execute()
end

function VoidFactions.SQL:DeleteDynamicFactionOffline(id)
	local query = database:Delete("voidfactions_factions")
		query:Where("id", id)
	query:Execute()

	local query = database:Update("voidfactions_members")
		query:Where("faction_id", id)
		query:Update("faction_id", nil)
	query:Execute()
end

-- Saves only the faction info (name, parent_faction, logo, color)
function VoidFactions.SQL:SaveFactionInfo(faction)
	if (VoidFactions.Settings:IsStaticFactions()) then
		VoidFactions.SQL:InsertUsergroups(faction, faction.requiredUsergroups or {})
		VoidFactions.Settings:RefreshVoidCharFactions()
	end

	local query = database:Update("voidfactions_factions")
		query:Update("name", faction.name)
		query:Update("tag", faction.tag)
		query:Update("description", faction.description)
		query:Update("parent_faction", faction.parentFaction and faction.parentFaction.id or nil)
		query:Update("logo", faction.logo)
		query:Update("color", string.FromColor(faction.color))

		query:Update("max_members", faction.maxMembers)

		query:Update("is_default_faction", faction.isDefaultFaction)
		query:Update("invite_required", faction.inviteRequired)
		query:Update("can_capture_territory", faction.canCaptureTerritory)
		query:Update("show_board", faction.showBoard)

		query:Update("money", faction.money)

		query:Where("id", faction.id)
	query:Execute()

	hook.Run("VoidFactions.UpdateFactionInfo", faction)
end

-- Saves the XP and level (this will be done on a regular basis, so update only these to save performance)
function VoidFactions.SQL:SaveFactionXP(faction)
	local query = database:Update("voidfactions_factions")
		query:Update("faction_xp", faction.xp)
		query:Update("faction_level", faction.level)
		query:Where("id", faction.id)
	query:Execute()
end

-- Deletes the faction and everything associated with it
function VoidFactions.SQL:DeleteFaction(faction)
	local query = database:Update("voidfactions_members")
		query:Where("faction_id", faction.id)
		query:Update("faction_id", nil)
	query:Execute()

	local query = database:Update("voidfactions_factions")
		query:Where("parent_faction", faction.id)
		query:Update("parent_faction", nil)
	query:Execute()
	
	local query = database:Delete("voidfactions_factions")
		query:Where("id", faction.id)
	query:Execute()

	local query = database:Delete("voidfactions_ranks")
		query:Where("faction_id", faction.id)
	query:Execute()

	local query = database:Delete("voidfactions_transactionhistory")
		query:Where("faction_id", faction.id)
	query:Execute()

	local query = database:Delete("voidfactions_factionrewards")
		query:Where("faction_id", faction.id)
	query:Execute()

	local query = database:Delete("voidfactions_factionupgrades")
		query:Where("faction_id", faction.id)
	query:Execute()

	local query = database:Delete("voidfactions_rewardmodules")
		query:Where("faction_id", faction.id)
	query:Execute()

	local query = database:Delete("voidfactions_deposititems")
		query:Where("item_faction_id", faction.id)
	query:Execute()
end



function VoidFactions.SQL:DeleteAllFactions()
	local query = database:Delete("voidfactions_factions")
	query:Execute()

	local query = database:Delete("voidfactions_ranks")
	query:Execute()

	local query = database:Update("voidfactions_members")
		query:Update("faction_id", nil)
		query:Update("rank_id", nil)
	query:Execute()

	VoidFactions.Factions = {}
	for k, member in pairs(VoidFactions.Members) do
		member.faction = nil
		member.rank = nil

		if (IsValid(member.ply)) then
			member:NetworkToPlayer()
			VoidFactions.Faction:NetworkFactions(member.ply)
		end
	end
end

--[[---------------------------------------------------------
	Name: Ranks DB
-----------------------------------------------------------]]

function VoidFactions.SQL:CreateRank(faction, name, weight, tag, maxMembers, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, jobs, minLevel, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault, cb)
	
	local jobCmds = {}
	for k, v in pairs(jobs or {}) do
		local job = RPExtraTeams[v]
		if (job) then
			jobCmds[#jobCmds + 1] = job.command
		end
	end

	local factionIds = {}
	for k, v in pairs(promoteDefault or {}) do
		factionIds[#factionIds + 1] = v.id
	end

	local query = database:Insert("voidfactions_ranks")
		if (istable(faction)) then
			query:Insert("faction_id", faction.id)
		elseif (isstring(faction) and faction == "template") then
			query:Insert("is_template", true)
		end
		query:Insert("rank_name", name)
		query:Insert("weight", weight)
		query:Insert("tag", tag)
		query:Insert("max_members", tonumber(maxMembers))
	
		query:Insert("minimum_level", minLevel)

		query:Insert("can_invite", canInvite)
		query:Insert("can_promote", canPromote)
		query:Insert("can_demote", canDemote)
		query:Insert("can_purchase_perks", canPurchasePerks)
		query:Insert("kick_members", kickMembers)
		query:Insert("manage_faction", manageFaction)
		query:Insert("jobs", VoidLib.TableToCSV(jobCmds))

		query:Insert("can_withdraw_money", canWithdrawMoney)
		query:Insert("can_deposit_money", canDepositMoney)
		query:Insert("can_withdraw_items", canWithdrawItems)
		query:Insert("can_deposit_items", canDepositItems)

		query:Insert("autopromote_level", autoPromoteLevel)
		query:Update("promote_default", VoidLib.TableToCSV(factionIds))

		query:Callback(function (result, b, id)

			VoidFactions.PrintDebug("Inserted rank name " .. name .. "!")

			local rank = VoidFactions.Rank:InitRank(id, faction, name, weight, tag, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, jobs, maxMembers, minLevel, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault)
			if (istable(faction)) then
				if (!faction.ranks) then
					faction.ranks = {}
				end
				faction.ranks[rank.id] = rank

				VoidFactions.Faction:UpdateFactionRanks(faction)
			elseif (isstring(faction) and faction == "template") then
				-- add to templates
				VoidFactions.RankTemplates[rank.id] = rank
				VoidFactions.Rank:SendRankTemplates()
			end

			if (cb) then
				cb()
			end
			
		end)
	query:Execute()

end

function VoidFactions.SQL:DeleteRank(rank)
	local query = database:Delete("voidfactions_ranks")
		query:Where("rank_id", rank.id)
	query:Execute()

	-- ugly
	local intFactionId = rank.faction.id
	local intRankId = rank.id
	timer.Simple(3, function ()
		local query = database:Update("voidfactions_members")
			query:Where("faction_id", intFactionId)
			query:Where("rank_id", intRankId)
			query:Update("faction_id", nil)
			query:Update("rank_id", nil)
		query:Execute()
	end)

	local faction = rank.faction
	if (faction and faction != "template") then
		for k, v in pairs(rank.faction.ranks) do
			if (v.id == rank.id) then
				VoidFactions.PrintDebug("Removed rank from memory")
				rank.faction.ranks[k] = nil
			end
		end

		VoidFactions.Faction:UpdateFactionRanks(faction)
		VoidFactions.Faction:UpdateFactionMembers(faction)
	else
		VoidFactions.RankTemplates[rank.id] = nil
		VoidFactions.Rank:SendRankTemplates()
	end

end

function VoidFactions.SQL:SaveRank(rank)

	local jobCmds = {}
	for k, v in pairs(rank.jobs or {}) do
		local job = RPExtraTeams[v]
		if (job) then
			jobCmds[#jobCmds + 1] = job.command
		end
	end

	local factionIds = {}
	for k, v in pairs(rank.promoteDefault or {}) do
		factionIds[#factionIds + 1] = v.id
	end

	VoidFactions.Settings:RefreshVoidCharFactions()

	local query = database:Update("voidfactions_ranks")
		if (rank.faction != "template") then
			query:Update("faction_id", rank.faction.id)
		end
		query:Update("rank_name", rank.name)
		query:Update("weight", rank.weight)
		query:Update("tag", rank.tag)
		query:Update("max_members", rank.maxMembers)

		query:Update("minimum_level", rank.minLevel)

		query:Update("can_invite", rank.canInvite)
		query:Update("can_promote", rank.canPromote)
		query:Update("can_demote", rank.canDemote)
		query:Update("can_purchase_perks", rank.canPurchasePerks)
		query:Update("kick_members", rank.kickMembers)
		query:Update("manage_faction", rank.manageFaction)

		query:Update("can_withdraw_money", rank.canWithdrawMoney)
		query:Update("can_deposit_money", rank.canDepositMoney)
		query:Update("can_withdraw_items", rank.canWithdrawItems)
		query:Update("can_deposit_items", rank.canDepositItems)

		query:Update("jobs", VoidLib.TableToCSV(jobCmds))
		query:Update("promote_default", VoidLib.TableToCSV(factionIds))

		query:Update("autopromote_level", rank.autoPromoteLevel or 0)

		query:Where("rank_id", rank.id)
	query:Execute()

	hook.Run("VoidFactions.UpdateRankInfo", rank, rank.faction)
end

--[[---------------------------------------------------------
	Name: Member DB
-----------------------------------------------------------]]

-- This has nothing to do with static/dynamic factions!

-- Saves mostly static things (faction, lastPromotion, rank)
function VoidFactions.SQL:SaveMemberStatic(member)

	local job = nil
	if (member.job) then
		job = VoidFactions.Settings:IsStaticFactions() and RPExtraTeams[member.job].command or nil
	end

	local query = database:Update("voidfactions_members")
		query:Update("faction_id", member.faction and member.faction.id or nil)
		query:Update("last_promotion", member.lastPromotion)
		query:Update("rank_id", member.rank and member.rank.id or nil)
		query:Update("job", job)
		query:Update("default_faction_id", member.defaultFactionId)
		query:Update("autopromote_disabled", member.autoPromoteDisabled)
		query:Update("faction_joined", member.factionJoined)
		query:Where("sid", member.sid)
	query:Execute()
end

-- Saves dynamic things (things that change in a certain interval) (xp, level)
function VoidFactions.SQL:SaveMemberDynamic(member)
	local query = database:Update("voidfactions_members")
		query:Update("xp", member.xp)
		query:Update("level", member.level)
		query:Where("sid", member.sid)
	query:Execute()
end

--[[---------------------------------------------------------
	Name: Playtime DB
-----------------------------------------------------------]]

function VoidFactions.SQL:IncrementPlaytime(players)
	local query = database:Update("voidfactions_members")
		query:Update("playtime", "playtime + 1", true)
		local totalPlayers = 0
		for _, ply in ipairs(players) do
			local sid = ply:SteamID64()
			if (VoidChar) then
				if (!ply:GetCharacterID()) then continue end
				sid = sid .. "-" .. ply:GetCharacterID()
			end
			query:Where("sid", sid, true)
			totalPlayers = totalPlayers + 1
		end
	if (totalPlayers > 0) then
		query:Execute()
	end
end

--[[---------------------------------------------------------
	Name: Last Seen DB
-----------------------------------------------------------]]

function VoidFactions.SQL:UpdateLastSeen(players)
	local query = database:Update("voidfactions_members")
		query:Update("last_seen", os.time())
		local totalUpdated = 0
		for _, ply in ipairs(players) do
			local sid = ply:SteamID64()
			if (VoidChar) then
				if (!ply:GetCharacterID()) then continue end
				sid = sid .. "-" .. ply:GetCharacterID()
			end
			query:Where("sid", sid, true)
			totalUpdated = totalUpdated + 1
		end

	if (totalUpdated > 0) then
		query:Execute()
	end

end


--[[---------------------------------------------------------
	Name: Settings
-----------------------------------------------------------]]

function VoidFactions.SQL:GetSettings(callback)
	local query = database:Select("voidfactions_settings")
		query:Callback(function (result)
			local config = {}
			local configExists = {}
			for k, v in ipairs(result or {}) do
				local json = util.JSONToTable(v.value)
				if (!json) then
					json = {}
				end
				VoidFactions.PrintDebug("Getting key " .. v.setting_key .. "!")
				config[v.setting_key] = json[1]
				configExists[v.setting_key] = true
			end
			callback(config, configExists)
		end)
	query:Execute()
end

function VoidFactions.SQL:AddSetting(key, default)

	default = { default }
	default = util.TableToJSON(default)

	local query = database:Replace("voidfactions_settings")
		query:Insert("setting_key", key)
		query:Insert("value", default)
	query:Execute()
end

function VoidFactions.SQL:SetSetting(key, value)

	value = {value}
	value = util.TableToJSON(value)

	local query = database:Update("voidfactions_settings")
		query:Update("value", value)
		query:Where("setting_key", key)
	query:Execute()
end
