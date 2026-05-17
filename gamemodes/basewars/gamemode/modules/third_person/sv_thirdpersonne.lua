util.AddNetworkString("BaseWars:ThirdPerson")

function GM:ShowTeam(ply)
    net.Start("BaseWars:ThirdPerson")
    net.Send(ply)
end