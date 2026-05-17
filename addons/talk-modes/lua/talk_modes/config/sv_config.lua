--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
TalkModes.Server = TalkModes.Server || {}
TalkModes.Config = TalkModes.Config || {}
TalkModes.Config.Server = TalkModes.Config.Server || {}
TalkModes.Config.Server.Default = { -- Don't touch this, you can change settings in the in-game config.
	["General"] = {
		["Language"] = "English",
		["Selection Key"] = 18,
		["3D Voice"] = true,
		["Talking Dead"] = false,
		["Selection Menu Position"] = "Bottom Center",
		["Auto-Hide"] = false,
		["Mode Change Message"] = true
	},

	["Modes"] = {
		["Whisper"] = 100, 
		["Talk"] = 500, 
		["Yell"] = 750
	},

	["UI"] = {
		["White"] = Color(230, 230, 230),
		["Gray"] = Color(160, 160, 160),
		["Background"] = Color(30, 30, 30),
		["Foreground"] = Color(40, 40, 40),
		["Hover"] = Color(192, 57, 43)
	}
}

-- Create the necessary table in SQLite. 
-- We also apply the default settings from the table above. 
-- For some reason the Default table is returning nil ;c. 
function TalkModes.Server.Initialize()
	local tblDefault = { -- Don't touch this, you can change settings in the in-game config.
		["General"] = {
			["Language"] = "English",
			["Selection Key"] = 18,
			["3D Voice"] = true,
			["Talking Dead"] = false,
			["Selection Menu Position"] = "Bottom Center",
			["Auto-Hide"] = false, 
			["Mode Change Message"] = true,
		},

		["Modes"] = {
			["Whisper"] = 100, 
			["Talk"] = 500, 
			["Yell"] = 750
		},

		["UI"] = {
			["White"] = Color(230, 230, 230),
			["Gray"] = Color(160, 160, 160),
			["Background"] = Color(30, 30, 30),
			["Foreground"] = Color(40, 40, 40),
			["Hover"] = Color(192, 57, 43)
		}
	}

	if sql.TableExists("talkmodes_config") then 
		local tblData = sql.Query("SELECT * FROM talkmodes_config")
		local bUpdate = false
		
		for _, v in pairs(tblData) do 
			v.General = util.JSONToTable(v.General)
			v.Modes = util.JSONToTable(v.Modes)
			v.UI = util.JSONToTable(v.UI)
		end	

		-- We'll run some integrity checks to avoid SQL errors.
		for i, v in pairs(tblDefault["General"]) do 
			if tblData[1]["General"][i] == nil then 
				tblData[1]["General"][i] = v
				bUpdate = true
			end
		end

		for i, v in pairs(tblDefault["UI"]) do 
			if tblData[1]["UI"][i] == nil then 
				tblData[1]["UI"][i] = v
				bUpdate = true
			end
		end

		if bUpdate == true then 
			sql.Query("DROP TABLE talkmodes_config")
			sql.Query("CREATE TABLE talkmodes_config(General TEXT NOT NULL, Modes TEXT NOT NULL, UI TEXT NOT NULL);")
			sql.Query(string.format("INSERT INTO talkmodes_config VALUES('%s', '%s', '%s')", util.TableToJSON(tblData[1]["General"]), util.TableToJSON(tblData[1]["Modes"]), util.TableToJSON(tblData[1]["UI"])))
		end

		TalkModes.Config.Server = #tblData != 0 && tblData[1] || tblDefault
		return 
	end

	sql.Query("CREATE TABLE talkmodes_config(General TEXT NOT NULL, Modes TEXT NOT NULL, UI TEXT NOT NULL);")
	sql.Query(string.format("INSERT INTO talkmodes_config VALUES('%s', '%s', '%s')", util.TableToJSON(tblDefault["General"]), util.TableToJSON(tblDefault["Modes"]), util.TableToJSON(tblDefault["UI"])))
	TalkModes.Config.Server = tblDefault
end
hook.Add("InitPostEntity", "TalkModes.Config.Server:Initialize", TalkModes.Server.Initialize)

function TalkModes.Server:ResetSettings()	
	if !sql.TableExists("talkmodes_config") then return end

	sql.Query("DROP TABLE talkmodes_config")
	TalkModes.Server.Initialize()
end

function TalkModes.Server:UpdateSetting(strTable, strSetting, Value)
	if !sql.TableExists("talkmodes_config") then return end

	local tblUpdated = table.Copy(TalkModes.Config.Server)
	tblUpdated[strTable][strSetting] = Value

	sql.Query(string.format("UPDATE talkmodes_config SET %s = '%s'", strTable, util.TableToJSON(tblUpdated[strTable])))
	TalkModes.Config.Server = tblUpdated
end

TalkModes.Server.Initialize()
