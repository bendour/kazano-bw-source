-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/*
	This file is used to check if Anti-Crash is using the latest version
*/

local gmodstoreLink = "https://www.gmodstore.com/api/v3/products/%s/versions"
local apiKey = "bb7fc6fd-d28c-4bcb-b864-db6a409fa50f|l4OpPCggdfo0jd1xBBtEiLcl3SGoWLP4tNjXDwjZ"
local hadezID = "034d6cbd-7b56-41c3-be94-cedd264df548"
local hadezVersion = "1.1.8"
local updateMsg = "[Hadez] New version %s available! (curr: %s)"

local function VersionCheck()

	SH_HADEZ.VAR.VERSION = hadezVersion

	-- Retrieve versions from gmodstore
	http.Fetch( string.format(gmodstoreLink,hadezID),
		function( body, len, headers, code )
				
			local response = util.JSONToTable(body)

			-- Gmodstore api problem -> do nothing
			if response == nil then return end
			
			local data = response.data

			if data and istable(data) and #data > 0 then
			
				local latestVersion = data[1].name
				local latestVersionNum = SH_HADEZ:ParseVersionStr(latestVersion) 
				local installedVersionNum = SH_HADEZ:ParseVersionStr(hadezVersion)
				
				if installedVersionNum < latestVersionNum then
					
					local updateMsg = string.format(updateMsg,latestVersion,hadezVersion)
					
					if SERVER then
						print(updateMsg)
					end
					
					SH_HADEZ.VAR.LATESTVERSION = false
					SH_HADEZ.VAR.LATESTVERSIONMSG = updateMsg
					
				end
				
			end

		end,
		function( error )
			-- Do nothing
		end,
		{
			["Authorization"] = "Bearer "..apiKey
		}
	)
	
end
timer.Simple(0, VersionCheck)