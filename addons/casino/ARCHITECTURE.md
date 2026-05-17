# 📊 Architecture du Casino Addon

## 🏗️ Vue d'ensemble

```
┌─────────────────────────────────────────┐
│         Casino Addon v2.0               │
│  Architecture Modulaire & Scalable      │
└─────────────────────────────────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Autorun    │────▶│    Casino    │────▶│    Games     │
│  casino_init │     │   Modules    │     │  (Blackjack) │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
      ┌─────▼────┐    ┌────▼─────┐   ┌────▼─────┐
      │  Config  │    │ Currency │   │HTML Loader│
      └──────────┘    └──────────┘   └──────────┘
```

## 📁 Structure détaillée

### 1. Point d'entrée (`autorun/casino_init.lua`)
```lua
Casino = {}
- Version
- Games Registry
- LoadCasinoFile()
- LoadSharedFile()
- LoadServerFile()
- LoadClientFile()
- RegisterGame()
```

**Responsabilités:**
- Initialiser la table globale Casino
- Charger tous les modules dans le bon ordre
- Gérer le chargement des jeux
- Enregistrer les commandes console

### 2. Modules de base (`casino/`)

#### `config.lua`
```lua
Casino.Config = {
    Security: {...}
    UI: {...}
    Currency: {...}
}
- GetConfig(key)
- SetConfig(key, value)
```

#### `currency.lua`
```lua
Casino.Currency = {
    System: "basewars"|"darkrp"|"default"
}
- DetectCurrencySystem()
- GetMoney(ply)
- AddMoney(ply, amount)
- TakeMoney(ply, amount)
- CanAfford(ply, amount)
```

#### `html_loader.lua`
```lua
Serveur:
- compileHTMLFile(path)
- Remplace <script src="...">
- Remplace <link href="...">
- Cache les fichiers compilés

Client:
- Casino.LoadHTML(fileName, callback)
- DHTML:LoadCasinoFile(fileName)
```

#### `ui_manager.lua` (Client uniquement)
```lua
Casino.UI = {
    Frame, HTML, IsOpen, CurrentGame
}
- Open()
- Close()
- Toggle()
- SetupMainMenuFunctions()
- UpdatePlayerInfo()
- OpenGame(name)
- ReturnToMenu()
- ShowMessage(msg, type)
- AddHistory(game, result, amount)
```

#### `statistics.lua` (Serveur uniquement)
```lua
Casino.Stats = {
    PlayerData: {}
}
- InitPlayer(ply)
- RecordGame(ply, game, bet, result, winAmount)
- GetPlayerStats(ply)
```

### 3. Structure des jeux (`casino/games/`)

Chaque jeu suit cette structure:

```
game_name/
├── init.lua          # Enregistrement et config
├── server.lua        # Logique serveur
└── client.lua        # Logique client
```

#### `init.lua`
```lua
Casino.RegisterGame("game_name", {
    name: "game_name"
    displayName: "Nom affiché"
    description: "Description"
    icon: "🎮"
    minBet: 100
    maxBet: 10000
    htmlFile: "game_name/game_name.html"
    setupFunctions: function(html)
})
```

#### `server.lua`
```lua
- Network strings
- Sécurité anti-spam
- Validation des mises
- Gestion des transactions
- Stats recording
```

#### `client.lua`
```lua
- Receive network messages
- Update UI
- Handle transactions
```

### 4. Interface HTML (`html/includes/`)

```
includes/
├── shared/           # Ressources partagées
│   └── base.css.lua  # Variables CSS, boutons, cards
│
├── main/             # Menu principal
│   ├── main.html.lua
│   ├── main.css.lua
│   └── main.js.lua
│
└── [game]/           # Interface de chaque jeu
    ├── [game].html.lua
    ├── [game].css.lua
    └── [game].js.lua
```

#### HTML Structure
```html
<link rel="stylesheet" href="shared/base.css">
<link rel="stylesheet" href="game/game.css">
<script src="game/game.js"></script>
```

#### Communication JS ↔ Lua

**Lua → JS:**
```lua
html:Call("functionName(arg1, arg2)")
```

**JS → Lua:**
```javascript
if (typeof casino !== 'undefined' && casino.function) {
    casino.function(arg);
}
```

## 🔄 Flux de données

### Ouverture du menu

```
Joueur tape "casino"
    │
    ▼
Casino.UI:Open()
    │
    ├─▶ Créer DFrame
    ├─▶ Créer DHTML
    ├─▶ LoadCasinoFile("main/main.html")
    │
    ▼
Serveur: net.Receive("Casino_LoadHTML")
    │
    ├─▶ Lire fichier HTML
    ├─▶ Compiler (remplacer CSS/JS)
    ├─▶ Mettre en cache
    │
    ▼
Client: net.Receive("Casino_LoadHTML")
    │
    ├─▶ Recevoir HTML compilé
    ├─▶ html:SetHTML(content)
    ├─▶ SetupMainMenuFunctions()
    │
    ▼
JS: window.onload
    │
    ├─▶ initNavigation()
    ├─▶ loadPlayerInfo()
    └─▶ Afficher l'interface
```

### Jouer à un jeu (Blackjack)

```
Clic sur "Jouer" (menu)
    │
    ▼
JS: openGame("blackjack")
    │
    ▼
Lua: casino.openGame("blackjack")
    │
    ▼
Casino.UI:OpenGame("blackjack")
    │
    ├─▶ LoadCasinoFile("blackjack/blackjack.html")
    ├─▶ SetupGameFunctions("blackjack")
    │
    ▼
JS: Blackjack loaded
    │
    ├─▶ loadPlayerInfo()
    ├─▶ Afficher zone de mise
    │
    ▼
Joueur place une mise
    │
    ▼
JS: placeBet()
    │
    ▼
Lua: blackjack.placeBet(amount)
    │
    ▼
net.Start("Casino_Blackjack_PlaceBet")
    │
    ▼
Serveur: Validation
    │
    ├─▶ CheckSecurity()
    ├─▶ Valider montant
    ├─▶ TakeMoney()
    ├─▶ Enregistrer stats
    │
    ▼
net.Start("Casino_Blackjack_Result")
    │
    ▼
Client: luaTransactionComplete()
    │
    ├─▶ Mettre à jour solde
    ├─▶ startGame()
    │
    ▼
Jeu commence (côté client)
    │
    ├─▶ Distribution cartes
    ├─▶ Tour du joueur
    ├─▶ Tour du croupier
    ├─▶ Déterminer gagnant
    └─▶ Afficher résultat
```

## 🔐 Sécurité

### Serveur
- ✅ Validation de toutes les transactions
- ✅ Anti-spam (délai entre actions)
- ✅ Vérification des montants
- ✅ Logging des transactions
- ✅ Protection contre valeurs négatives

### Client
- ✅ Logique de jeu locale (pas de triche possible)
- ✅ UI responsive aux actions serveur
- ✅ Validation des inputs utilisateur

## 📊 Système de stats

```lua
PlayerData[steamid] = {
    totalWins: 0
    totalLosses: 0
    totalGames: 0
    biggestWin: 0
    biggestLoss: 0
    totalWagered: 0
    totalProfit: 0
    winRate: 0
    history: [{game, bet, result, winAmount, timestamp}]
    lastPlayed: timestamp
}
```

## 🎯 Ajouter un nouveau jeu

1. Créer la structure de fichiers
2. Enregistrer le jeu dans `init.lua`
3. Coder la logique serveur
4. Coder la logique client
5. Créer l'interface HTML/CSS/JS
6. Tester !

## 🔧 Dépendances

**Côté serveur:**
- `util` - Network strings
- `file` - Lecture fichiers HTML
- `net` - Communication réseau

**Côté client:**
- `vgui` - Création DFrame/DHTML
- `net` - Communication réseau
- `timer` - Délais et animations

**Optionnel:**
- Basewars API
- DarkRP API
- PointShop API

## 📝 Conventions de code

### Nommage
- **Modules:** PascalCase (`Casino.UI`, `Casino.Stats`)
- **Fonctions:** camelCase (`GetMoney`, `PlaceBet`)
- **Variables locales:** camelCase
- **Constantes:** UPPER_SNAKE_CASE

### Network strings
Format: `Casino_[Game]_[Action]`
```lua
"Casino_Blackjack_PlaceBet"
"Casino_Blackjack_Result"
"Casino_LoadHTML"
```

### Fichiers HTML
Extension: `.lua` pour compatibilité workshop
```
fichier.html.lua
fichier.css.lua
fichier.js.lua
```

## 🚀 Performance

### Cache
- ✅ HTML compilés mis en cache
- ✅ Réutilisation entre joueurs
- ✅ Commande pour vider le cache

### Optimisations
- Logique de jeu côté client (pas de lag serveur)
- Network minimal (seulement transactions)
- Animations CSS (GPU accelerated)
- Pas de SetInterval/SetTimeout intensif

---

**Cette architecture permet d'ajouter facilement de nouveaux jeux sans modifier le code existant ! 🎰**
