/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.MiniGame = zmlab2.MiniGame or {}
zmlab2.MiniGame.List = zmlab2.MiniGame.List or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

/*
	Registers a new minigame
*/
function zmlab2.MiniGame.Register(id,data)
	data.GameID = id
	zmlab2.MiniGame.List[id] = data
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function zmlab2.MiniGame.GetPenalty(Machine)
    return math.Round(zmlab2.config.MiniGame.Quality_Penalty)
end

function zmlab2.MiniGame.GetReward(Machine)
    return math.Round(zmlab2.config.MiniGame.Quality_Reward)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
