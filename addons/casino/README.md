# Blackjack DHTML pour Gmod

Un addon complet de Blackjack pour Garry's Mod utilisant la technologie DHTML pour une interface web moderne et interactive.

## Fonctionnalités

### 🎮 Gameplay
- **Blackjack authentique** avec règles standard du casino
- **Mises flexibles** de 100 à 10,000 (configurable)
- **Double Down** pour doubler votre mise
- **Blackjack naturel** avec paiement 3:2
- **Interface intuitive** avec cartes animées

### 💰 Système de monnaie
- **Compatibilité multi-systèmes** :
  - Basewars
  - DarkRP
  - PointShop 1 & 2
  - XeninCoinflip
  - Système par défaut
- **Sécurité** des transactions
- **Logging** des paris et gains

### 🎨 Interface DHTML
- **Design moderne** avec animations fluides
- **Table de casino réaliste**
- **Cartes stylées** avec couleurs rouges/noires
- **Jetons interactifs** pour les paris
- **Messages animés** pour les résultats

### 🔧 Administration
- **Statistiques des joueurs** détaillées
- **Détection d'activités suspectes**
- **Configuration flexible** via Lua
- **Commandes admin** intégrées

## Installation

1. Téléchargez l'addon et placez-le dans :
   ```
   garrysmod/addons/blackjack_dhtml/
   ```

2. Redémarrez votre serveur ou rechargez les addons

3. L'addon est prêt à être utilisé !

## Utilisation

### Pour les joueurs
1. Ouvrez la console et tapez :
   ```
   slots
   ```
   ou
   ```
   blackjack_open
   ```

2. L'interface du blackjack s'ouvrira

3. Placez votre mise en cliquant sur les jetons

4. Jouez au blackjack !

### Pour les administrateurs
- **Voir les statistiques d'un joueur** :
  ```
   blackjack_stats <nom_du_joueur>
  ```

- **Configuration** : Modifiez les valeurs dans `lua/blackjack/config.lua`

## Configuration

### Paramètres de jeu
```lua
Game = {
    MinBet = 100,           -- Mise minimale
    MaxBet = 10000,         -- Mise maximale
    BlackjackPayout = 2.5,  -- Payout blackjack (3:2)
    NormalPayout = 2.0,     -- Payout normal (1:1)
    DealerStandOn = 17,     -- Croupier s'arrête à 17
    AllowDoubleDown = true, -- Autoriser double
    AllowSplit = true,      -- Autoriser split
    AllowInsurance = true   -- Autoriser assurance
}
```

### Paramètres d'interface
```lua
UI = {
    WindowWidth = 900,      -- Largeur fenêtre
    WindowHeight = 650,     -- Hauteur fenêtre
    CardWidth = 71,         -- Largeur carte
    CardHeight = 96,        -- Hauteur carte
    AnimationSpeed = 0.3    -- Vitesse animations
}
```

### Sécurité
```lua
Security = {
    MaxGamesPerMinute = 10, -- Parties max/minute
    AntiSpamDelay = 1,      -- Délai anti-spam
    LogTransactions = true, -- Logger transactions
    MinPlayTime = 30        -- Temps min entre parties
}
```

## Structure des fichiers

```
blackjack_dhtml/
├── lua/
│   ├── autorun/
│   │   └── blackjack_load.lua    # Chargement principal
│   └── blackjack/
│       ├── config.lua            # Configuration
│       ├── currency.lua          # Gestion monnaie
│       ├── client.lua            # Interface client
│       ├── server.lua            # Logique serveur
│       ├── ui.lua                # Mises à jour UI
│       └── game_logic.lua        # Logique avancée
├── materials/
│   └── blackjack/                # Ressources graphiques
├── sound/
│   └── blackjack/                # Sons du jeu
└── README.md                     # Documentation
```

## Communication JavaScript ↔ Lua

### Du JavaScript vers Lua
```javascript
// Placer une mise
luaPlaceBet(amount);

// Tirer une carte
luaHit();

// Rester
luaStand();

// Double down
luaDoubleDown();

// Nouvelle partie
luaNewGame();
```

### De Lua vers JavaScript
```lua
-- Mettre à jour les cartes
HTML:Call("updatePlayerCards('" .. cardsJson .. "')");

-- Afficher un message
HTML:Call("showMessage('" .. message .. "', '" .. type .. "')");

-- Fin de partie
HTML:Call("gameOver('" .. result .. "', '" .. message .. "')");
```

## Sécurité

### Protection contre les abus
- **Anti-spam** avec délais entre actions
- **Limitation de parties** par minute
- **Validation des mises** côté serveur
- **Détection de comportements suspects**
- **Logging complet** des transactions

### Détection d'anomalies
- Taux de victoire anormal (>70%)
- Gains très élevés
- Comportement de jeu suspect
- Alertes automatiques aux admins

## Statistiques des joueurs

L'addon suit automatiquement :
- Nombre de parties jouées
- Victoires/Défaites/Nuls
- Blackjacks obtenus
- Busts (dépassements)
- Total misé et gagné
- Plus gros gains/pertes
- Taux de victoire

## Personnalisation

### Thèmes couleurs
Modifiez les couleurs dans `config.lua` :
```lua
Theme = {
    Background = "#0d5f0d",     -- Vert foncé
    Table = "#1a7a1a",          -- Vert table
    CardBack = "#8b0000",       -- Rouge dos carte
    WinColor = "#4CAF50",       -- Vert victoire
    LoseColor = "#f44336"       -- Rouge défaite
}
```

### Messages personnalisés
```lua
Messages = {
    Welcome = "Bienvenue au Blackjack!",
    Win = "Vous avez gagné!",
    Lose = "Vous avez perdu!",
    Push = "Match nul!",
    Blackjack = "Blackjack!"
}
```

## Dépannage

### Problèmes courants

**Q: La commande "slots" ne fonctionne pas**
R: Vérifiez que l'addon est bien installé et que le serveur a redémarré

**Q: L'interface ne s'ouvre pas**
R: Vérifiez que vous avez les droits nécessaires et que le DHTML est activé

**Q: La monnaie ne s'actualise pas**
R: Vérifiez la compatibilité avec votre système de monnaie dans `currency.lua`

**Q: Messages d'erreur dans la console**
R: Vérifiez que tous les fichiers sont présents et que les permissions sont correctes

### Support
Pour toute question ou problème, vérifiez :
1. La console serveur pour les erreurs
2. La configuration de votre système de monnaie
3. Les permissions des fichiers

## Mises à jour

Cet addon est conçu pour être :
- **Modulaire** : Chaque fonction est dans un fichier séparé
- **Extensible** : Facile à ajouter de nouvelles fonctionnalités
- **Compatible** : Fonctionne avec la plupart des systèmes de monnaie
- **Sécurisé** : Protection contre les abus et les triches

## Licence

Cet addon est open-source et peut être modifié selon vos besoins.

---

**Profitez bien de votre Blackjack !** 🎰🃏
