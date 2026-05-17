-- Network strings for auto-loading profiles
util.AddNetworkString("BaseWars:PlayerChoseProfile")

--[[-------------------------------------------------------------------------
	Local Fcuntions
---------------------------------------------------------------------------]]
local clr = Color(255, 0, 0)
local function log(text)
	MsgC(clr, text, "\n")
end

local function sellAndDeletePlayerEntites(ply)
	if ply.oldBasewarsProfileID then
		local totalMoney = 0
		for k, v in ents.Iterator() do
			if not v:ValidToSell(ply) then continue end

			totalMoney = totalMoney + v:GetCurrentValue() * BaseWars.Config.BackMoney

			if v.IsPrinter or v.IsBank then
				totalMoney = totalMoney + v:GetMoney()
			end

			SafeRemoveEntity(v)
		end

		MySQLite.query(Format("UPDATE basewars_player SET money = CAST(money AS DECIMAL) + %s WHERE player_id64 = %s AND profile_id = %s", totalMoney, ply:SteamID64(), ply.oldBasewarsProfileID), function() end, BaseWarsSQLError)
	end
end

--[[-------------------------------------------------------------------------
	FUNCTIONS
---------------------------------------------------------------------------]]
function BaseWars:PlayerRequestProfilesData(ply)
	if not IsValid(ply) then return end

	MySQLite.query(Format([[
		SELECT level,
			money,
			time_played,
			xp,
			prestige,
			point,
			perks,
			basewars_player.profile_id,
			basewars_prestige.profile_id,
			basewars_player.player_id64,
			basewars_prestige.player_id64
		FROM basewars_player
			INNER JOIN basewars_prestige ON basewars_player.player_id64 = basewars_prestige.player_id64
			AND basewars_player.profile_id = basewars_prestige.profile_id
		WHERE basewars_player.player_id64 = %s
	]], ply:SteamID64()), function(result)
		if not IsValid(ply) then
			return
		end

		result = result or {}

		-- Auto-load the profile or create one if none exists
		if #result > 0 then
			-- Player has a profile, load it automatically
			local profileData = result[1] -- Always use the first (and only) profile
			
			-- Make XP and Money into numbers
			profileData.xp = profileData.xp == "inf" and math.huge or tonumber(profileData.xp)
			profileData.money = profileData.money == "inf" and math.huge or tonumber(profileData.money)

			-- Format prestige perks table
			local perksTable = {}
			for _, perkData in ipairs(string.Explode(";", profileData.perks)) do
				local perk = string.Explode(":", perkData)
				perksTable[perk[1]] = tonumber(perk[2])
			end
			profileData.perks = perksTable

			local profileId = profileData.profile_id

			sellAndDeletePlayerEntites(ply)

			ply.basewarsProfileID = profileId

			ply:SetMoney(profileData.money, true)
			ply:SetLevel(profileData.level, true)
			ply:SetXP(profileData.xp, true)
			ply:SetTimePlayed(profileData.time_played, true)

			ply:SetPrestige(profileData.prestige, true)
			ply:SetPrestigePoint(profileData.point, true)

			for k, v in pairs(profileData.perks) do
				ply:SetPrestigePerk(k, v)
			end

			hook.Run("BaseWars:PlayerChoseProfile", ply, profileId, profileData)

			-- Notify client
			net.Start("BaseWars:PlayerChoseProfile")
				net.WriteUInt(profileId, 31)
			net.Send(ply)

			local title, tit = "╔════════════════════[" .. ply:Name() .. "]════════════════════╗", 44 + string.len(ply:Name())
			local text = "Auto-loaded profile - ID » " .. profileId
			local half = math.floor((tit - #text) * .5)

			log(title)
			log("║" .. string.rep(" ", half % 2 == 0 and half - 1 or half) .. text .. string.rep(" ", half % 2 == 0 and half or half - 1) .. "║")
			log("╚" .. string.rep("═", tit - 2) .. "╝")
		else
			-- No profile exists, create one automatically
			BaseWars:CreatePlayerProfile(ply)
		end
	end, BaseWarsSQLError)
end

function BaseWars:CreatePlayerProfile(ply)
	if not IsValid(ply) then return end

	sellAndDeletePlayerEntites(ply)

	MySQLite.query(([[INSERT INTO basewars_player (player_id64, level, time_played, xp, money) VALUES (%s, %s, %s, %s, %s)]]):format(ply:SteamID64(), 0, 0, 0, BaseWars.Config.StartMoney), function()
		MySQLite.query("SELECT profile_id FROM basewars_player ORDER BY profile_id DESC LIMIT 1", function(profileIDResult)
			local IDResult = profileIDResult[1]["profile_id"]

			if not IDResult then
				ply:Kick("MySQL error! (profile id not found)")
				return
			end

			ply.basewarsProfileID = IDResult

			ply:SetMoney(BaseWars.Config.StartMoney, true)
			ply:SetLevel(1, true)
			ply:SetXP(0, true)
			ply:SetTimePlayed(0, true)

			local perks = ""
			for k, v in pairs(BaseWars:GetPrestigePerk()) do
				perks = perks .. k .. ":0;"
			end
			perks = string.sub(perks, 1, #perks - 1)

			MySQLite.query(([[INSERT INTO basewars_prestige (profile_id, player_id64, prestige, perks, point) VALUES (%s, %s, %s, %s, %s)]]):format(IDResult, ply:SteamID64(), 0, MySQLite.SQLStr(perks), 0), function()
				ply:SetPrestige(0, true)
				ply:SetPrestigePoint(0, true)

				for k, v in pairs(BaseWars:GetPrestigePerk()) do
					ply:SetPrestigePerk(k, 0)
				end

				hook.Run("BaseWars:PlayerCreateProfile", ply, IDResult)
				hook.Run("BaseWars:PlayerChoseProfile", ply, IDResult)

				-- Notify client
				net.Start("BaseWars:PlayerChoseProfile")
					net.WriteUInt(IDResult, 31)
				net.Send(ply)

				local title, tit = "╔════════════════════[" .. ply:Name() .. "]════════════════════╗", 44 + string.len(ply:Name())
				local text = "Auto-created profile - ID » " .. IDResult
				local half = math.floor((tit - #text) * .5)

				log(title)
				log("║" .. string.rep(" ", half % 2 == 0 and half - 1 or half) .. text .. string.rep(" ", half % 2 == 0 and half or half - 1) .. "║")
				log("╚" .. string.rep("═", tit - 2) .. "╝")
			end, BaseWarsSQLError)
		end, BaseWarsSQLError)
	end, BaseWarsSQLError)
end

--[[-------------------------------------------------------------------------
	HOOKS
---------------------------------------------------------------------------]]
hook.Add("BaseWars:PlayerChoseProfile", "BaseWars:ProfileSelector", function(ply, profileID, profileData)
	ply:StripAmmo()
	ply:StripWeapons()

	if not ply:InSafeZone() then
		ply:Spawn()
	else
		hook.Call("PlayerLoadout", GAMEMODE, ply)
	end

	if zrush then
		ply.zrush_INV_FuelBarrels = {}
	end

	if zcm then
		ply:SetNWInt("zcm_firework", 0)
	end

	if zrmine then
		ply:zrms_ResetMetalBars()
	end

	if zmlab then
		ply.zmlab_meth = 0
	end

	if ply.cfCigsAmount then
		ply.cfCigsAmount = 0
	end

	ply.profileChangeTime = CurTime() + 10

	local title, tit = "╔════════════════════[" .. ply:Name() .. "]════════════════════╗", 44 + string.len(ply:Name())
	local text = "Playing on profile - ID » " .. profileID
	local half = math.floor((tit - #text) * .5)

	log(title)
	log("║" .. string.rep(" ", half % 2 == 0 and half - 1 or half) .. text .. string.rep(" ", half % 2 == 0 and half or half - 1) .. "║")
	log("╚" .. string.rep("═", tit - 2) .. "╝")

	hook.Run("BaseWars:PostPlayerChoseProfile", ply, profileID, profileData)
end)

hook.Add("BaseWars:PlayerCreateProfile", "BaseWars:ProfilesSelection", function(ply, profileID)
	local title, tit = "╔════════════════════[" .. ply:Name() .. "]════════════════════╗", 44 + string.len(ply:Name())
	local text = "Created new profile - ID » " .. profileID
	local half = math.floor((tit - #text) * .5)

	log(title)
	log("║" .. string.rep(" ", half % 2 == 0 and half - 1 or half) .. text .. string.rep(" ", half % 2 == 0 and half or half - 1) .. "║")
	log("╚" .. string.rep("═", tit - 2) .. "╝")

	hook.Run("BaseWars:PostPlayerCreateProfile", ply, profileID)
end)

hook.Add("BaseWars:SendNetToClient", "BaseWars:ProfilesSelection", function(ply)
	BaseWars:PlayerRequestProfilesData(ply)
end)

--[[-------------------------------------------------------------------------
	NETS
---------------------------------------------------------------------------]]
-- Network receivers removed - profiles are now auto-loaded