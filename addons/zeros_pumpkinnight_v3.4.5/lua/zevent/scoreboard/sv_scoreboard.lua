/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Scoreboard = zpn.Scoreboard or {}
zpn.Score = zpn.Score or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd


////////////////////////////////////////////
////////////////// ENTITY //////////////////
////////////////////////////////////////////
function zpn.Scoreboard.Initialize(Scoreboard)
    zclib.Debug("zpn.Scoreboard.Initialize")

    Scoreboard:SetModel(zpn.Theme.Scoreboard.model)
    Scoreboard:PhysicsInit(SOLID_VPHYSICS)
    Scoreboard:SetSolid(SOLID_VPHYSICS)
    Scoreboard:SetMoveType(MOVETYPE_VPHYSICS)

    local phys = Scoreboard:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    Scoreboard:DrawShadow(false)

    zclib.EntityTracker.Add(Scoreboard)
end
////////////////////////////////////////////
////////////////////////////////////////////


////////////////////////////////////////////
/////////////// SCORELIST //////////////////
////////////////////////////////////////////
// The Top 10 List we send the clients
zpn.ScoreList = zpn.ScoreList or {}

// The global scorelist which gets loaded from the save file
zpn.GlobalScoreList = zpn.GlobalScoreList or {}

// Does the scorelist needs to be updated?
zpn.ScoreList_Update = false

// Gets called when the score changes
function zpn.Scoreboard.ScoreChanged()
    zclib.Debug("zpn.Scoreboard.ScoreChanged")
    zpn.ScoreList_Update = true
end

// Creates a updated version of the scorelist
function zpn.Scoreboard.CreateScoreList()
    zclib.Debug("zpn.Scoreboard.CreateScoreList")

    local tbl = {}
	local function AddItem(name,points,steamid,rank)

		// Check if the player is allowed to be on the scoreboard
		if zpn.config.Scoreboard.RankBlackList[rank] then return end

		if string.len(name) > 15 then
			name = string.gsub( name, "[^%w_]", "" )
			name = string.sub(name, 1, 15)
		end

		table.insert(tbl, {
			name = name,
			val = points,
			id = steamid
		})
	end

    if zpn.config.Scoreboard.ShowGlobal then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

        //Saves the Global scorelist
        zclib.STM.Save("zpn_score")

        for k, v in pairs(zpn.GlobalScoreList) do
            if v and v.points > 0 then
				AddItem(v.name,v.points,k,v.rank)
            end
        end
    else
		for k, v in pairs(zpn.PumpkinScore) do
			local ply = player.GetBySteamID(k)
			if not IsValid(ply) then continue end

			if v and v > 0 then
				AddItem(ply:Nick(), v, k, zclib.Player.GetRank(ply))
			end
		end
    end

    table.sort( tbl, function( a, b ) return a.val > b.val end )

    zpn.ScoreList = {}
    for i = 0, 10 do
        if tbl[i] then
            zpn.ScoreList[i] = tbl[i]
        end
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    zpn.Scoreboard.Update()
end

// Sends the scorelist to all players
util.AddNetworkString("zpn_scoreboard_send")
function zpn.Scoreboard.Update()
    zclib.Debug("zpn.Scoreboard.Update")

	local scoreString = util.TableToJSON(zpn.ScoreList)
	local scoreCompressed = util.Compress(scoreString)

    for k,v in pairs(zclib.Player.List) do
		if not IsValid(v) then continue end

		local YourScore = 0
		if zpn.config.Scoreboard.ShowGlobal then
			if zpn.GlobalScoreList[v:SteamID()] and zpn.GlobalScoreList[v:SteamID()].points then
				YourScore = zpn.GlobalScoreList[v:SteamID()].points or 0
			end
		else
			YourScore = zpn.PumpkinScore[v:SteamID()] or 0
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

	    net.Start("zpn_scoreboard_send")
	    net.WriteUInt(#scoreCompressed, 16)
	    net.WriteData(scoreCompressed, #scoreCompressed)
		net.WriteUInt(YourScore,32)
	    net.Send(v)
    end
end
////////////////////////////////////////////
////////////////////////////////////////////


////////////////////////////////////////////
////////// Smashed Pumpkins Score //////////
////////////////////////////////////////////
// This System keeps track on how many Candy Points the player has collected no matter if he uses the points or not
zpn.PumpkinScore = zpn.PumpkinScore or {}
function zpn.Score.AddPoints(ply, points)
    //zclib.Debug("zpn.Score.AddPoints: " .. points .. " to " .. ply:Nick())
    if not IsValid(ply) then return end
    local plyID = zclib.Player.GetID(ply)
    zpn.PumpkinScore[plyID] = (zpn.PumpkinScore[plyID] or 0) + points

    if zpn.config.Scoreboard.ShowGlobal then
        zpn.Score.UpdateScorelist(plyID,ply:Nick(),zpn.PumpkinScore[plyID],zclib.Player.GetRank(ply))
    end

    // Tell the scoreboard that the score changed
    zpn.Scoreboard.ScoreChanged()

    zpn.data.DataChanged(ply)
end

function zpn.Score.SetPoints(ply, points)
    if not IsValid(ply) then return end
    zclib.Debug("zpn.Score.SetPoints: " .. points .. " for " .. ply:Nick())

    local plyID = zclib.Player.GetID(ply)
    zpn.PumpkinScore[plyID] = points

    if zpn.config.Scoreboard.ShowGlobal then
        zpn.Score.UpdateScorelist(plyID,ply:Nick(),zpn.PumpkinScore[plyID],zclib.Player.GetRank(ply))
    end

    // Tell the scoreboard that the score changed
    zpn.Scoreboard.ScoreChanged()

    zpn.data.DataChanged(ply)
end

// Returns the players Candy Score
function zpn.Score.ReturnPoints(ply)
    return zpn.PumpkinScore[zclib.Player.GetID(ply)] or 0
end

// Everytime a Players zpn.PumpkinScore changes we update the Global list
function zpn.Score.UpdateScorelist(id,name,points,rank)
    zclib.Debug("zpn.Score.SetupData")

    if points == nil or points <= 0 then
        zpn.GlobalScoreList[id] = nil
    else
        zpn.GlobalScoreList[id] = {
            name = name,
            points = points,
            rank = rank
        }
    end

    // 1235078258
    // Tell the scoreboard that the score changed
    zpn.Scoreboard.ScoreChanged()
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
////// Smashed Pumpkins Global Score ///////
////////////////////////////////////////////
// Sets up the saving / loading and removing of the data for the map
zclib.STM.Setup("zpn_score","zpn/global_score.txt",function()
    return zpn.GlobalScoreList
end,function(data)

    for k, v in pairs(data) do
        if v and k then
            zpn.Score.UpdateScorelist(k,v.name,v.points,v.rank)
        end
    end

    zpn.Print("Finished loading Global Scorelist.")
end,function()
end)
////////////////////////////////////////////
////////////////////////////////////////////


// Sets up the saving / loading and removing of the entity for the map
zclib.STM.Setup("zpn_scoreboard","zpn/" .. string.lower(game.GetMap()) .. "_scoreboard" .. ".txt",function()
    local data = {}

    for u, j in pairs(ents.FindByClass("zpn_scoreboard")) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    return data
end,function(data)

    // This handles the updateting of the scorelist if it changed
    local timerid = "zpn_scorelist_updater"
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid, zpn.config.Scoreboard.UpdateInterval, 0, function()

        if zpn.ScoreList_Update then
            zpn.ScoreList_Update = false

            zpn.Scoreboard.CreateScoreList()
        end
    end)

    for k, v in pairs(data) do
        local ent = ents.Create("zpn_scoreboard")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end

    //Loads the Global scorelist
    if zpn.config.Scoreboard.ShowGlobal then
        zclib.STM.Load("zpn_score")
    end

	timer.Simple(3, function()
		if zpn.ScoreList_Update then
			zpn.ScoreList_Update = false
			zpn.Scoreboard.CreateScoreList()
		end
	end)

    zpn.Print("Finished loading Scoreboard Entities.")
end,function()
    for k, v in pairs(ents.FindByClass("zpn_scoreboard")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

// Save functions
concommand.Add("zpn_save_scoreboard", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) and zclib.STM.Save("zpn_scoreboard") then
        zclib.Notify(ply, "Scoreboard entities have been saved for the map " .. game.GetMap() .. "!", 0)
    end
end)

concommand.Add("zpn_remove_scoreboard", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Scoreboard entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("zpn_scoreboard")
    end
end)

zclib.Hook.Add("ShutDown", "zpn_SaveGlobalList", function()

    if zpn.config.Scoreboard.ShowGlobal then

        zclib.Debug("Server Shutdown, Saving GlobalScoreList")

        // Saves the Global scorelist
        zclib.STM.Save("zpn_score")
    end
end)
