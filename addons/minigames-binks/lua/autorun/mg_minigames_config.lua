MG_MINIGAMES_CONFIG = {
    answer_time = 15, -- Temps en secondes pour répondre
    auto_start = true, -- Lancer automatiquement les mini-jeux
    auto_start_delay = 300, -- Intervalle entre les mini-jeux (en secondes)
    prefix = ":mg1::mg2::mg3::mg4::mg5::mg6: ", -- Préfixe personnalisable pour les messages dans le chat
    colors = {
        prefix = {255, 255, 255},  -- Or
        message = {255, 255, 255}, -- Blanc
        winner = {255, 255, 255},  -- Vert
        error = {255, 0, 0},       -- Rouge
        variables = {
            default = {255, 255, 255},  -- Couleur par défaut pour %s
            time = {255, 255, 255},     -- Couleur pour la variable de temps (%ss)
            word = {255, 255, 255},     -- Couleur pour les éléments du calcul
            player = {255, 255, 255}    -- Couleur pour les noms de joueurs
        }
    },
    messages = {
        calcul_start = "Résous ce calcul : %s %s %s",
        win_calcul = "Le joueur %s remporte le jeu en %ss !",
        no_winner = "Personne n'a trouvé la bonne réponse à temps !"
    },
    variable_types = {
        calcul_start = {"word", "word", "word"},
        win_calcul = {"player", "time", "word"},
        no_winner = {}
    }
}