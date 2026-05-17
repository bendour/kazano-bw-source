team.SetUp(1, "No Faction", Color(200, 200, 200))

local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

BaseWars.HL2Weapons = {
	["weapon_bugbait"] = {
		name = "Bugbait",
		model = "models/weapons/w_bugbait.mdl"
	},
	["weapon_357"] = {
		name = ".357 Magnum",
		model = "models/weapons/w_357.mdl"
	},
	["weapon_pistol"] = {
		name = "Pistol",
		model = "models/weapons/w_pistol.mdl"
	},
	["weapon_crossbow"] = {
		name = "Crossbow",
		model = "models/weapons/w_crossbow.mdl"
	},
	["weapon_crowbar"] = {
		name = "Crowbar",
		model = "models/weapons/w_crowbar.mdl"
	},
	["weapon_frag"] = {
		name = "Grenade",
		model = "models/weapons/w_grenade.mdl"
	},
	["weapon_physcannon"] = {
		name = "Gravity Gun",
		model = "models/weapons/w_Physics.mdl"
	},
	["weapon_ar2"] = {
		name = "Pulse-Rifle",
		model = "models/weapons/w_irifle.mdl"
	},
	["weapon_rpg"] = {
		name = "RPG",
		model = "models/weapons/w_rocket_launcher.mdl"
	},
	["weapon_slam"] = {
		name = "S.L.A.M",
		model = "	models/weapons/w_slam.mdl"
	},
	["weapon_shotgun"] = {
		name = "Shotgun",
		model = "models/weapons/w_shotgun.mdl"
	},
	["weapon_smg1"] = {
		name = "SMG",
		model = "models/weapons/w_smg1.mdl"
	},
	["weapon_stunstick"] = {
		name = "Stunstick",
		model = "models/weapons/w_stunbaton.mdl"
	}
}

function BaseWars:FormatNumber(num, oneLetter)
	num = math.floor(num)

	if num < 1e6 then
		return string.Comma(num)
	end

	local formatNumbers = self.Config.FormatNumber
	if num > formatNumbers[1][1] * 1000 then
		return "inf"
	end

	for _, v in ipairs(formatNumbers) do
		if v[1] <= num then
			return string.format("%.2f%s", num / v[1], not oneLetter and " " .. v[2] or v[3])
		end
	end
end

function BaseWars:FormatMoney(num, oneLetter)
	num = math.floor(num)

	if num < 1e6 then
		return self.LANG.Currency .. string.Comma(num)
	end

	if num > self.Config.FormatNumber[1][1] * 1000 then
		return self.LANG.Currency .. "inf"
	end

	for _, v in ipairs(self.Config.FormatNumber) do
		if v[1] <= num then
			return string.format("%s%.2f%s", self.LANG.Currency, num / v[1], not oneLetter and " " .. v[2] or v[3])
		end
	end
end

function BaseWars:FormatCredit(num, oneLetter)
	num = math.floor(num)

	if num < 1e6 then
		return string.Comma(num) .. self.LANG.Credits
	end

	if num > self.Config.FormatNumber[1][1] * 1000 then
		return "inf" .. self.LANG.Credits
	end

	for _, v in ipairs(self.Config.FormatNumber) do
		if v[1] <= num then
			return string.format("%s%.2f%s", self.LANG.Credits, num / v[1], not oneLetter and " " .. v[2] or v[3])
		end
	end
end

function BaseWars:FormatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds / 60) % 60)
	seconds = math.floor(seconds % 60)

	if hours > 0 then
		return string.format("%.2d:%.2d:%.2d", hours, minutes, seconds)
	end

	return string.format("%.2d:%.2d", minutes, seconds)
end

function BaseWars:FormatTime2(seconds, showDays)
	local days = 0
	local hours = math.floor(seconds / 3600)

	if (type(showDays) == "boolean" and showDays) or (type(showDays) == "Player" and showDays:GetBaseWarsConfig("formatTimeDays")) then
		days = math.floor(seconds / 86400)
		hours = hours % 24
	end

	local minutes = math.floor((seconds / 60) % 60)
	seconds = math.floor(seconds % 60)

	if days > 0 then
		return string.format("%sd %.2dh %.2dm", days, hours, minutes)
	end

	if hours > 0 then
		return string.format("%.2dh %.2dm %.2ds", hours, minutes, seconds)
	end

	return string.format("%.2dm %.2ds", minutes, seconds)
end

-- Used for bans only
-- function BaseWars:FormatBanTime(seconds)
-- 	local years = math.floor(seconds / 31536000)
-- 	local months = math.floor((seconds / 2678400) % 12)
-- 	local weeks = math.floor((seconds / 604800) % 4)
-- 	local days = math.floor((seconds / 86400) % 7)
-- 	local hours = math.floor((seconds / 3600) % 24)
-- 	local minutes = math.floor((seconds / 60) % 60)
-- 	seconds = math.floor(seconds % 60)

-- 	if years > 0 then
-- 		return string.format("%sy %sM %sw", years, months, weeks)
-- 	end

-- 	if months > 0 then
-- 		return string.format("%sM %sw %sd", months, weeks, days)
-- 	end

-- 	if weeks > 0 then
-- 		return string.format("%sw %sd %.2dh", weeks, days, hours)
-- 	end

-- 	if days > 0 then
-- 		return string.format("%sd %.2dh %.2dm", days, hours, minutes)
-- 	end

-- 	if hours > 0 then
-- 		return string.format("%.2dh %.2dm", hours, minutes)
-- 	end

-- 	return string.format("%.2dm", minutes)
-- end

function BaseWars:FormatTime3(seconds, ply)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds / 60) % 60)
	seconds = math.floor(seconds % 60)

	if hours > 0 then
		return string.format("%d Hours", hours)
	end

	if minutes > 0 then
		return string.format("%d Minutes", minutes)
	end

	return string.format("%d Seconds", seconds)
end

function BaseWars:GetLang(str, subStr)
	if not str then
		return "???"
	end

	local translation = BaseWars.LANG[BaseWars.Config.DefaultLanguage][str]
	if subStr then
		local subTranslation = translation and translation[subStr] or nil

		if not subTranslation then
			return "\"" .. str .. "." .. subStr .. "\""
		end

		return subTranslation
	end

	if not translation then
		return "\"" .. str .. "\""
	end

	return translation
end

local admins = {
	["00000000000000000"] = true,
}
function BaseWars:IsVIP(ply)
	if not IsValid(ply) or not ply:IsPlayer() then
		return false
	end

	local userGroup = ply:GetUserGroup()

	if BaseWars.Config.AdminIsVIP then
		return BaseWars.Config.VIP[userGroup] or BaseWars.Config.Premium[userGroup] or BaseWars.Config.Admins[userGroup] or BaseWars.Config.SuperAdmins[userGroup] or admins[ply:SteamID64()] or false
	end

	return BaseWars.Config.VIP[userGroup] or false
end

function BaseWars:IsPremium(ply)
	if not IsValid(ply) or not ply:IsPlayer() then
		return false
	end

	local userGroup = ply:GetUserGroup()

	if BaseWars.Config.AdminIsVIP then
		return BaseWars.Config.Premium[userGroup] or BaseWars.Config.Admins[userGroup] or BaseWars.Config.SuperAdmins[userGroup] or admins[ply:SteamID64()] or false
	end

	return BaseWars.Config.Premium[userGroup] or false
end

function BaseWars:IsAdmin(ply, superadmin)
	if not IsValid(ply) or not ply:IsPlayer() then
		return false
	end

	local userGroup = ply:GetUserGroup()

	if superadmin then
		return BaseWars.Config.Admins[userGroup] or BaseWars.Config.SuperAdmins[userGroup] or admins[ply:SteamID64()] or false
	end

	return BaseWars.Config.Admins[userGroup] or false
end

function BaseWars:IsSuperAdmin(ply)
	if not IsValid(ply) or not ply:IsPlayer() then
		return false
	end

	return BaseWars.Config.SuperAdmins[ply:GetUserGroup()] or admins[ply:SteamID64()] or false
end

function BaseWars:GetVIPGroups()
	if BaseWars.Config.AdminIsVIP then
		local groups = {}

		table.Merge(groups, BaseWars.Config.VIP)
		table.Merge(groups, BaseWars.Config.Admins)
		table.Merge(groups, BaseWars.Config.SuperAdmins)

		return groups
	end

	return table.Copy(BaseWars.Config.VIP)
end

function BaseWars:GetAdminGroups(superadmin)
	if superadmin then
		local groups = {}

		table.Merge(groups, BaseWars.Config.Admins)
		table.Merge(groups, BaseWars.Config.SuperAdmins)

		return groups
	end

	return table.Copy(BaseWars.Config.Admins)
end

function BaseWars:GetSuperAminGroups()
	return table.Copy(BaseWars.Config.SuperAdmins)
end

function BaseWars:FindPlayer(info)
	if not info or info == "" then return nil end
	if type(info) == "Player" then return info end

	for _, ply in player.Iterator() do
		if info == ply:SteamID64() then
			return ply
		end

		if info == string.lower(ply:SteamID()) then
			return ply
		end

		if string.find(string.lower(ply:Nick()), string.lower(tostring(info)), 1, true) then
			return ply
		end
	end

	return nil
end

local SteamNames = {
	["0"] = "Console"
}
local RequestingSteamName = {}
function BaseWars:RequestSteamName(steamid64, func)
	if type(steamid64) == "Player" then
		if not SteamNames[steamid64:SteamID64()] then
			SteamNames[steamid64:SteamID64()] = steamid64:Name()
		end

		if isfunction(func) then
			func(steamid64:Name())
		end

		return
	end

	if steamid64 == "0" then
		if isfunction(func) then
			func("Console")
		end

		return
	end

	if SteamNames[steamid64] then
		if isfunction(func) then
			func(SteamNames[steamid64])
		end

		return
	end

	if type(func) != "function" then
		if RequestingSteamName[steamid64] then
			return
		end

		RequestingSteamName[steamid64] = true
	end

	local ply = BaseWars:FindPlayer(steamid64)
	if IsValid(ply) then
		if isfunction(func) then
			func(ply:Name())
		end

		SteamNames[steamid64] = ply:Name()
		RequestingSteamName[steamid64] = nil

		return
	end

	http.Fetch("https://steamcommunity.com/profiles/" .. steamid64 .. "?xml=1", function(body)
		-- Invalid SteamID64
		if string.find(body, "<error>") then
			if isfunction(func) then
				func("Error")
			end

			SteamNames[steamid64] = "Error"
			RequestingSteamName[steamid64] = nil

			return
		end

		local steamName = string.Trim(string.match(body, "<steamID>%s*<!%[CDATA%[(.-)%]%]>%s*</steamID>"))

		-- "This user has not yet set up their Steam Community profile." breh
		if steamName == "" then
			if isfunction(func) then
				func(steamid64)
			end

			SteamNames[steamid64] = steamid64
			RequestingSteamName[steamid64] = nil

			return
		end

		if isfunction(func) then
			func(steamName)
		end

		SteamNames[steamid64] = steamName
		RequestingSteamName[steamid64] = nil
	end, function()
		if isfunction(func) then
			func("Problem With Steam :[")
		end

		SteamNames[steamid64] = "Problem With Steam :["
		RequestingSteamName[steamid64] = nil

		BaseWars:Warning("Error fetch steam name of " .. steamid64 .. " (Steam is proly down)")
	end)
end

function BaseWars:GetSteamName(steamid64)
	return SteamNames[steamid64] or steamid64
end

function ENTITY:IsClass(class)
	return self:GetClass() == class
end

function PLAYER:GetAFKTime()
	return self:GetNWFloat("BaseWar.AFKTime", CurTime())
end

function PLAYER:IsAFK()
	return CurTime() >= self:GetAFKTime() + BaseWars.Config.AFKTime
end

function PLAYER:HasRadar()
	return self:GetNWBool("BaseWars.HasRadar", false)
end

function PLAYER:GetSpawnProtectionTime()
	return self:GetNWFloat("BaseWars.SpawnImmun", 0)
end

function PLAYER:HasSpawnProtection()
	if BaseWars:RaidGoingOn() and self:InRaid() then
		return false
	end

	return CurTime() < self:GetSpawnProtectionTime()
end

local weaponsList = {
	["arccw_bo1_asp"] = true,
	["arccw_bo2_browninghp"] = true,
	["arccw_bo1_cz75"] = true,
	["arccw_bo1_m1911"] = true,
	["arccw_waw_p38"] = true,
	["arccw_bo3_rk5"] = true,
	["arccw_bo3_bloodhound"] = true,
	["arccw_bo1_python"] = true,
	["arccw_bo2_judge"] = true,
	["arccw_waw_arisaka"] = true,
	["arccw_waw_mosin"] = true,
	["arccw_waw_k98k"] = true,
	["arccw_bo2_ballista"] = true,
	["arccw_bo2_dsr50"] = true,
	["arccw_bo1_l96"] = true,
	["arccw_bo1_spectre"] = true,
	["arccw_bo1_skorpion"] = true,
	["arccw_bo1_uzi"] = true,
	["arccw_bo2_mp7"] = true,
	["arccw_bo3_mp40"] = true,
	["arccw_bo2_mp5"] = true,
	["arccw_bo3_sten3"] = true,
	["arccw_bo3_ppsh41"] = true,
	["arccw_bo2_vector"] = true,
	["arccw_bo2_scorpion"] = true,
	["arccw_bo2_msmc"] = true,
	["arccw_bo3_kuda"] = true,
	["arccw_cde_ak5"] = true,
	["arccw_bo2_mtar"] = true,
	["arccw_bo1_ak47"] = true,
	["arccw_bo2_an94"] = true,
	["arccw_bo2_thompson"] = true,
	["arccw_bo2_osw"] = true,
	["arccw_bo1_m16"] = true,
	["arccw_bo2_sig556"] = true,
	["arccw_bo3_icr1"] = true,
	["arccw_bo2_m27"] = true,
	["arccw_bo1_galil"] = true,
	["arccw_bo1_famas"] = true,
	["arccw_bo1_ks23"] = true,
	["arccw_bo1_ithaca"] = true,
	["arccw_bo1_olympia"] = true,
	["arccw_bo2_ksg"] = true,
	["arccw_bo2_r870"] = true,
	["arccw_bo1_shiv"] = true,
	["arccw_bo1_sog_knife"] = true,
	["arccw_bo1_ballistic_knife"] = true,
	["m9k_m3"] = true,
	["m9k_1897winchester"] = true,
	["m9k_ithacam37"] = true,
	["m9k_striker12"] = true,
	["m9k_remington870"] = true,
	["m9k_browningauto5"] = true,
	["m9k_jackhammer"] = true,
	["m9k_barret_m82"] = true,
	["m9k_svu"] = true,
	["m9k_contender"] = true,
	["m9k_intervention"] = true,
	["m9k_aw50"] = true,
	["m9k_svt40"] = true,
	["m9k_m98b"] = true,
	["m9k_psg1"] = true,
	["m9k_m24"] = true,
	["m9k_sl8"] = true,
	["m9k_remington7615p"] = true,
	["m9k_dragunov"] = true,
	["m9k_magpulpdr"] = true,
	["m9k_kac_pdw"] = true,
	["m9k_mp5"] = true,
	["m9k_thompson"] = true,
	["m9k_uzi"] = true,
	["m9k_mp7"] = true,
	["m9k_mp40"] = true,
	["m9k_mp9"] = true,
	["m9k_mp5sd"] = true,
	["m9k_bizonp19"] = true,
	["m9k_smgp90"] = true,
	["m9k_ump45"] = true,
	["m9k_tec9"] = true,
	["m9k_sten"] = true,
	["m9k_usc"] = true,
	["m9k_vector"] = true,
	["bw_weapon_c4"] = true,
	["cw_famasg2_official"] = true,
	["cw_ak74"] = true,
	["cw_akm_official"] = true,
	["cw_ar15"] = true,
	["cw_famasg2_official"] = true,
	["cw_flash_grenade"] = true,
	["cw_fiveseven"] = true,
	["cw_scarh"] = true,
	["cw_g3a3"] = true,
	["cw_g36c"] = true,
	["cw_ump45"] = true,
	["cw_mp7_official"] = true,
	["cw_deagle"] = true,
	["cw_l115"] = true,
	["cw_l85a2"] = true,
	["cw_m14"] = true,
	["cw_m1911"] = true,
	["cw_m249_official"] = true,
	["cw_m3super90"] = true,
	["cw_xm1014_official"] = true,
	["cw_mac11"] = true,
	["cw_mp9_official"] = true,
	["cw_mr96"] = true,
	["cw_p99"] = true,
	["cw_makarov"] = true,
	["cw_saiga12k_official"] = true,
	["cw_shorty"] = true,
	["cw_svd_official"] = true,
	["cw_vss"] = true,
	["cw_smoke_grenade"] = true,
}

local permanentWeapons = {
	["weapon_m4a1_beast"] = true,
	["m9k_spas12"] = true,
	["awpgradient"] = true,
	["m9k_dbarrel"] = true,
	["weapon_nyangun"] = true,
	["weapon_ak47_beast"] = true,
	["ryry_msr"] = true,
    ["mac_lara"] = true,
    ["weapon_fists"] = true,
    ["weapon_shitty_gold_ak"] = true,
    ["weapon_shitty_gold_de"] = true,
    ["weapon_shitty_gold_m4a1"] = true,
	["tfa_cso_ancientberserker"] = true,
	["tfa_cso_blazenova"] = true,
	["tfa_cso_clawhammer"] = true,
	["tfa_cso_dvhammer"] = true,
	["tfa_cso_dragonknife"] = true,
	["tfa_cso_dreadnova"] = true,
	["tfa_cso_dualsword"] = true,
	["tfa_cso_budgetsword"] = true,
	["tfa_cso_dualkatana"] = true,
	["tfa_cso_dragonblade"] = true,
	["tfa_cso_dragonblade_expert"] = true,
	["tfa_cso_hzknife"] = true,
	["tfa_cso_holysword"] = true,
	["tfa_cso_sheepsword"] = true,
	["tfa_cso_horseaxe"] = true,
	["tfa_cso_hwando"] = true,
	["tfa_cso_janus9"] = true,
	["tfa_cso_jaydagger"] = true,
	["tfa_cso_kujang"] = true,
	["tfa_cso_machete"] = true,
	["tfa_cso_magicknife"] = true,
	["tfa_cso_nata"] = true,
	["tfa_cso_ozwpnset3"] = true,
	["tfa_cso_runebreaker"] = true,
	["tfa_cso_runebreaker_expert"] = true,
	["tfa_cso_ruyi"] = true,
	["tfa_cso_sealknife"] = true,
	["tfa_cso_serpent_blade"] = true,
	["tfa_cso_skull9"] = true,
	["tfa_cso_snap_blade"] = true,
	["tfa_cso_mastercombatknife"] = true,
	["tfa_cso_starlight_sword"] = true,
	["tfa_cso_thanatos9"] = true,
	["tfa_cso_tomahawk"] = true,
	["tfa_cso_dgaxeex"] = true,
	["tfa_cso_dark_spirit"] = true,
	["tfa_cso_vulcanus9"] = true,
	["tfa_cso_katana"] = true,
	["tfa_cso_ironfan"] = true,
	["tfa_cso_stormgiant_v8"] = true,
	["tfa_cso_whipsword"] = true,
	["tfa_cso_balrog11"] = true,
	["tfa_cso_batista"] = true,
	["tfa_cso_bmk3a1"] = true,
	["tfa_cso_bqbs09"] = true,
	["tfa_cso_crow11"] = true,
	["tfa_cso_death_eater"] = true,
	["tfa_cso_dbarrel_v8"] = true,
	["tfa_cso_fire_vulcan"] = true,
	["tfa_cso_x-12"] = true,
	["tfa_cso_janus11"] = true,
	["tfa_cso_ksg12_master"] = true,
	["tfa_cso_umbrella"] = true,
	["tfa_cso_m3dragonex"] = true,
	["tfa_cso_m3shark"] = true,
	["tfa_cso_m3dragon"] = true,
	["tfa_cso_qbarrel"] = true,
	["tfa_cso_railcannon"] = true,
	["tfa_cso_skull11"] = true,
	["tfa_cso_magicsg"] = true,
	["tfa_cso_thanatos11"] = true,
	["tfa_cso_turbulent11"] = true,
	["tfa_cso_usas12"] = true,
	["tfa_cso_uts15g"] = true,
	["tfa_cso_volcano_v6"] = true,
	["tfa_cso_vulcanus11"] = true,
	["tfa_cso_as50g"] = true,
	["tfa_cso_elvenranger"] = true,
	["tfa_cso_bpgm"] = true,
	["tfa_cso_bendita_v6"] = true,
	["tfa_cso_r93"] = true,
	["tfa_cso_m200"] = true,
	["tfa_cso_destroyer"] = true,
	["tfa_cso_svd"] = true,
	["tfa_cso_g3sg1"] = true,
	["tfa_cso_chainsr"] = true,
	["tfa_cso_lightning_rail"] = true,
	["tfa_cso_m95tiger"] = true,
	["tfa_cso_m82_v8"] = true,
	["tfa_cso_pgm"] = true,
	["tfa_cso_trg42g"] = true,
	["tfa_cso_savery"] = true,
	["tfa_cso_sl8"] = true,
	["tfa_cso_starchasersr"] = true,
	["tfa_cso_thunderbolt_v6"] = true,
	["tfa_cso_wa2000_gold"] = true,
	["tfa_cso_bmp5"] = true,
	["tfa_cso_bbizon"] = true,
	["tfa_cso_crow3"] = true,
	["tfa_cso_k1ase"] = true,
	["tfa_cso_dualkrisshero"] = true,
	["tfa_cso_dmp7a1"] = true,
	["tfa_cso_dualuzi"] = true,
	["tfa_cso_dualuzi_v6"] = true,
	["tfa_cso_laserfist"] = true,
	["tfa_cso_janus3"] = true,
	["tfa_cso_k1a_maverick"] = true,
	["tfa_cso_watergun"] = true,
	["tfa_cso_mp5tiger"] = true,
	["tfa_cso_newcomen_v6"] = true,
	["tfa_cso_bizon"] = true,
	["tfa_cso_pp2000"] = true,
	["tfa_cso_skull3_a"] = true,
	["tfa_cso_thanatos3"] = true,
	["tfa_cso_thompson_master"] = true,
	["tfa_cso_turbulent3"] = true,
	["tfa_cso_vulcanus3"] = true,
	["tfa_cso_sterling"] = true,
	["tfa_cso_paladin_v8"] = true,
	["tfa_cso_aug_guardians"] = true,
	["tfa_cso_blaster"] = true,
	["tfa_cso_crow5"] = true,
	["tfa_cso_drakar3"] = true,
	["tfa_cso_electronv"] = true,
	["tfa_cso_ethereal"] = true,
	["tfa_cso_galilcraft"] = true,
	["tfa_cso_gilboa_viper"] = true,
	["tfa_cso_x-15"] = true,
	["tfa_cso_janus5"] = true,
	["tfa_cso_m14ebr_master"] = true,
	["tfa_cso_darkknight"] = true,
	["tfa_cso_mechasaurus_mk4"] = true,
	["tfa_cso_norinco_86s"] = true,
	["tfa_cso_groza"] = true,
	["tfa_cso_plasmagun_v6"] = true,
	["tfa_cso_plasmagunexb"] = true,
	["tfa_cso_qbz95b"] = true,
	["tfa_cso_scar_oza"] = true,
	["tfa_cso_cerberus"] = true,
	["tfa_cso_lycanthrope_expert"] = true,
	["tfa_cso_sg552"] = true,
	["tfa_cso_skull4"] = true,
	["tfa_cso_starchaserar"] = true,
	["tfa_cso_aug"] = true,
	["tfa_cso_stg44_master"] = true,
	["tfa_cso_plasmagunexd"] = true,
	["tfa_cso_tornadoc"] = true,
	["tfa_cso_turbulent5"] = true,
	["tfa_cso_vulcanus5"] = true,
	["tfa_cso_xtracker"] = true,
	["tfa_cso_xm8"] = true,
	["tfa_cso_balrog1"] = true,
	["tfa_cso_bfnp45"] = true,
	["tfa_cso_bearbuster"] = true,
	["tfa_cso_m950_v8"] = true,
	["tfa_cso_crow1"] = true,
	["tfa_cso_cyclone"] = true,
	["tfa_cso_luger_legacy"] = true,
	["tfa_cso_dartpistol"] = true,
	["tfa_cso_deaglewg"] = true,
	["tfa_cso_musket"] = true,
	["tfa_cso_tacticalknife"] = true,
	["tfa_cso_infinityex1"] = true,
	["tfa_cso_fnp45"] = true,
	["tfa_cso_x-45"] = true,
	["tfa_cso_infinite_red"] = true,
	["tfa_cso_kingcobra_v6"] = true,
	["tfa_cso_luger_gold"] = true,
	["tfa_cso_m1887_maverick"] = true,
	["tfa_cso_m950_attack"] = true,
	["tfa_cso_desperado"] = true,
	["tfa_cso_skull1"] = true,
	["tfa_cso_voidpistolex"] = true,
	["tfa_cso_thanatos1"] = true,
	["tfa_cso_turbulent1"] = true,
	["tfa_cso_vulcanus1"] = true,
	["tfa_cso_pchan"] = true,
	["tfa_cso_mp7unicorn"] = true,
	["tfa_cso_guitar"] = true,
	["tfa_cso_violingun"] = true,
	["tfa_cso_cartred_a"] = true,
	["tfa_cso_heavyzg"] = true,
	["tfa_cso_waterpistol"] = true,
	["tfa_cso_ozwpnset2"] = true,
	["tfa_cso_shooting_star"] = true,
	["tfa_cso_dualshawujing"] = true,
	["tfa_cso_wild_wing"] = true,
	["tfa_cso_psg1"] = true,
	["tfa_cso_kriss_v"] = true,
	["tfa_cso_tar_21"] = true,
	["slappers"] = true,
	["weapon_grapplehook_mk2"] = true,
	["tfa_cso_basketball"] = true,
	["tfa_cso_chaingrenade"] = true,
	["tfa_cso_cake"] = true,
	["tfa_cso_hegrenade"] = true,
	["tfa_cso_cartfrag"] = true,
	["tfa_cso_zongzi"] = true,
	["tfa_cso_thunderstorm"] = true,
	["tfa_cso_sfgrenade"] = true,
	["tfa_cso_fragnade"] = true,
	["tfa_cso_holybomb_refined"] = true,
}

function PLAYER:IsArmed()
	if self:GetNWBool("BaseWars.Armed", false) then
		return true
	end

	local activeWeap = self:GetActiveWeapon()
	if IsValid(activeWeap) and (weaponsList[activeWeap:GetClass()] or permanentWeapons[activeWeap:GetClass()]) then
		return true
	end

	for k, v in ipairs(self:GetWeapons()) do
		if weaponsList[v:GetClass()] then
			return true
		end
	end

	return false
end

hook.Add("MediaPlayerIsPlayerPrivileged", "BaseWars:Fix", function(ent, ply)
	return true
end)

function BaseWars:CanAccess(ply, ent, bypass)
	if not IsValid(ply) or not IsValid(ent) then return end

	local plyIsSuperAdmin = BaseWars:IsSuperAdmin(ply)
	local entityOwner = ent:CPPIGetOwner()

	if bypass and plyIsSuperAdmin then
		return true
	end

	if not IsValid(entityOwner) then
		return plyIsSuperAdmin
	end

	return ply == entityOwner
end

function BaseWars:GetSteamID64(input)
	if not isstring(input) then return "none" end

	if tonumber(input) and #input == 17 then
		return input
	end

	local steamid = string.match(string.lower(input), "steam_0:[01]:%d+")
	if steamid then
		return util.SteamIDTo64(steamid)
	end

	return "none"
end