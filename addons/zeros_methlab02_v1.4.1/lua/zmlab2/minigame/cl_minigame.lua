/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if not CLIENT then return end
zmlab2 = zmlab2 or {}
zmlab2.MiniGame = zmlab2.MiniGame or {}

/*
	Called from the SERVER to tell the Client about the minigame id
*/
net.Receive("zmlab2.MiniGame.GameID", function(len)
    zclib.Debug_Net("zmlab2.MiniGame.GameID",len)

	local MiniGame_Ent = net.ReadEntity()
	local GameID = net.ReadString()
	if MiniGame_Ent and IsValid(MiniGame_Ent) and MiniGame_Ent:IsValid() and GameID then
		MiniGame_Ent.GameID = GameID
	end
end)

/*
	Called from the SERVER to start a minigame
*/
net.Receive("zmlab2_MiniGame", function(len)
    zclib.Debug_Net("zmlab2_MiniGame",len)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	local GameID = net.ReadString()
    local MiniGame_Ent = net.ReadEntity()

	zmlab2.MiniGame.List[GameID]:OnStart(MiniGame_Ent,ply)

	zmlab2.MiniGame.List[GameID]:Interface(MiniGame_Ent,ply)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

/*
	Called from the MiniGame to send the game result to the SERVER
*/
function zmlab2.MiniGame.Finish(GameID,Machine,Result)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	zmlab2.MiniGame.List[ GameID ]:OnFinish(Machine, LocalPlayer(), Result)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

	net.Start("zmlab2_MiniGame")
	net.WriteString(GameID)
	net.WriteEntity(Machine)
	net.WriteBool(Result)
	net.SendToServer()
end
