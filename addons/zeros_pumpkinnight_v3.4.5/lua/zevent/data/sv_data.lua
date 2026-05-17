/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.data = zpn.data or {}

function zpn.data.DataChanged(ply)
    if not ply.zpn_DataChanged then
        ply.zpn_DataChanged = true
    end

	hook.Run("zpn_OnDataChanged",ply)
end

function zpn.data.PlayerDisconnect(ply)
    zclib.Debug("zpn.data.PlayerDisconnect")

    if ply.zpn_DataChanged then
        zpn.data.Save(ply)
    end
end

zclib.Hook.Add("PlayerDisconnected", "zpn_Data", zpn.data.PlayerDisconnect)

function zpn.data.Init(ply)
    zclib.Debug("zpn.data.Init: " .. ply:Nick())

    if not file.Exists("zpn", "DATA") then
        file.CreateDir("zpn")
    end

    if not file.Exists("zpn/data/", "DATA") then
        file.CreateDir("zpn/data/")
    end

    local plyID = ply:SteamID64()

    if file.Exists("zpn/data/" .. plyID .. ".txt", "DATA") then
        local data = file.Read("zpn/data/" .. plyID .. ".txt", "DATA")
        data = util.JSONToTable(data)
        zclib.Debug("Data loaded for " .. ply:Nick())
        zpn.Candy.SetPoints(ply, data.Points)
        zpn.Score.SetPoints(ply, data.Score)
        ply.zpn_OwnedItems = data.OwnedItems
    else
        zpn.Candy.SetPoints(ply, 0)
        zpn.Score.SetPoints(ply, 0)
        ply.zpn_OwnedItems = {}
        zclib.Debug("Data created for " .. ply:Nick())
    end

    zpn.data.DataChanged(ply)
end

function zpn.data.Save(ply)
    if zpn.config.Data.Save == false then return end
    if zpn.config.Data.Whitelist and table.Count(zpn.config.Data.Whitelist) > 0 and zpn.config.Data.Whitelist[zclib.Player.GetRank(ply)] == nil then return end
    zclib.Debug("zpn.data.Save")
    local plyID = ply:SteamID64()

    local data = {
        Points = zpn.Candy.ReturnPoints(ply),
        Score = zpn.Score.ReturnPoints(ply),
        OwnedItems = ply.zpn_OwnedItems or {},
    }

    local path = "zpn/data/" .. tostring(plyID) .. ".txt"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    if data and (data.Points > 0 or data.Score > 0 or table.Count(data.OwnedItems) > 0) then
        file.Write(path, util.TableToJSON(data))
    else
        if file.Exists(path, "DATA") then
            file.Delete(path)
        end
    end
end

concommand.Add( "zpn_data_resetscore", function( ply, cmd, args )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

    if zclib.Player.IsAdmin(ply) then

		-- Create the directory path
		local directory = "zpn/data/"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

		-- Define the function to reset the score
		local function resetScore(filePath)

			local data = file.Read(filePath, "DATA")

		    if not data then
		        print("Failed to open file: " .. filePath)
		        return
		    end

			data = util.JSONToTable(data)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

			data.Score = 0

			file.Write(filePath, util.TableToJSON(data,true))

		    print("Reset score for " .. filePath)
		end

		-- Loop through files in the directory
		local afiles, _ = file.Find(directory .. "*.txt", "DATA")

		for _, fileName in ipairs(afiles) do
		    local filePath = directory .. fileName
		    resetScore(filePath)
		end
    end
end )


function zpn.data.Save_All()
    for k, v in pairs(zclib.Player.List) do
        if (v.zpn_DataChanged) then
            zpn.data.Save(v)
        end
    end
end

local function Check_DataSaver_TimerExist()
    if zpn.config.Data.Save == false then return end
    if zpn.config.Data.Save_Interval == -1 then return end

    if timer.Exists("zpn_DataSaver_timer") then
        timer.Remove("zpn_DataSaver_timer")
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    timer.Create("zpn_DataSaver_timer", zpn.config.Data.Save_Interval, 0, zpn.data.Save_All)
end

timer.Simple(1,function()
    Check_DataSaver_TimerExist()
end)
