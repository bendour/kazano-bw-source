ashop.RegisterPremade("DarkRP Money", {
    objectTypes = {
        {
            "Commandes",
        }
    },

    items = {
        {
            name = "1000 DarkRP Money",
            rendering = 1,
            metadata = {
                [2] = 3,
                [3] = 'player.GetBySteamID({PLAYER_STEAMID}):addMoney(1000)',
            },
        },
    },
})