# 🎰 Casino Addon pour Garry's Mod - v2.0

Addon de casino moderne et modulaire pour Garry's Mod avec interface DHTML épurée.

## 🎮 Fonctionnalités

### Jeux disponibles
- **Blackjack** ✅ - Le classique du casino avec interface moderne
- **Machine à sous** 🚧 - À venir
- **Roulette** 🚧 - À venir  
- **Poker** 🚧 - À venir

### Caractéristiques
- ✨ Interface moderne et épurée avec design glassmorphism
- 📊 Système de statistiques complet
- 💰 Support multi-devises (Basewars, DarkRP, PointShop, etc.)
- 🔒 Système anti-triche et anti-spam
- 📜 Historique des parties
- ⚙️ Paramètres personnalisables
- 🎨 Animations fluides et effets visuels
- 📱 Interface responsive

## 📁 Structure du projet

```
blackjack_dhtml/
├── lua/
│   ├── autorun/
│   │   └── casino_init.lua                 # Point d'entrée principal
│   │
│   ├── casino/                              # Modules principaux
│   │   ├── config.lua                       # Configuration globale
│   │   ├── currency.lua                     # Système de monnaie
│   │   ├── html_loader.lua                  # Chargeur HTML/CSS/JS
│   │   ├── ui_manager.lua                   # Gestionnaire d'interface
│   │   ├── client.lua                       # Module client
│   │   ├── server.lua                       # Module serveur
│   │   ├── statistics.lua                   # Système de stats
│   │   │
│   │   └── games/                           # Dossier des jeux
│   │       └── blackjack/
│   │           ├── init.lua                 # Initialisation du jeu
│   │           ├── client.lua               # Code client
│   │           └── server.lua               # Code serveur
│   │
│   └── html/                                # Fichiers HTML/CSS/JS
│       └── includes/
│           ├── shared/                      # Ressources partagées
│           │   └── base.css.lua             # CSS de base
│           │
│           ├── main/                        # Menu principal
│           │   ├── main.html.lua            # HTML du menu
│           │   ├── main.css.lua             # Styles du menu
│           │   └── main.js.lua              # JavaScript du menu
│           │
│           └── blackjack/                   # Interface Blackjack
│               ├── blackjack.html.lua       # HTML du jeu
│               ├── blackjack.css.lua        # Styles du jeu
│               └── blackjack.js.lua         # Logique du jeu
│
├── materials/blackjack/                     # Textures et images
├── sound/blackjack/                         # Sons du jeu
└── addon.json                               # Métadonnées de l'addon
```

## 🚀 Installation

1. Téléchargez l'addon
2. Placez le dossier `blackjack_dhtml` dans `garrysmod/addons/`
3. Redémarrez votre serveur ou tapez `lua_refresh` dans la console

## 💻 Utilisation

### Commandes console
- `casino` - Ouvrir/fermer le menu du casino
- `casino_open` - Ouvrir le menu du casino
- `casino_close` - Fermer le menu du casino
- `casino_clearcache` - Vider le cache HTML (admin uniquement)

### Pour les joueurs
1. Ouvrez le menu avec la commande `casino`
2. Sélectionnez un jeu dans le menu principal
3. Placez votre mise et jouez !
4. Consultez vos statistiques dans l'onglet "Statistiques"

## 🔧 Configuration

Modifiez `/lua/casino/config.lua` pour personnaliser :

```lua
Casino.Config = {
	Security = {
		AntiSpamDelay = 1,              -- Délai anti-spam (secondes)
		MaxBetsPerSession = 1000,       -- Nombre max de paris
		LogTransactions = true          -- Logger les transactions
	},
	UI = {
		Theme = "dark",                 -- Thème (dark/light)
		Language = "fr",                -- Langue (fr/en)
		EnableAnimations = true,        -- Activer les animations
		EnableSounds = true             -- Activer les sons
	}
}
```

### Configuration des jeux

Chaque jeu peut être configuré dans son fichier `init.lua` :

```lua
Casino.RegisterGame("blackjack", {
	name = "blackjack",
	displayName = "Blackjack",
	icon = "🃏",
	minBet = 100,                       -- Mise minimum
	maxBet = 10000,                     -- Mise maximum
	htmlFile = "blackjack/blackjack.html"
})
```

## 🎨 Personnalisation de l'interface

### Modifier les couleurs

Éditez `/lua/html/includes/shared/base.css.lua` :

```css
:root {
	--primary-color: #2196F3;
	--accent-color: #FFC107;
	--success-color: #4CAF50;
	--error-color: #f44336;
	/* ... */
}
```

### Ajouter un nouveau jeu

1. Créez un dossier dans `/lua/casino/games/votre_jeu/`
2. Créez les fichiers :
   - `init.lua` - Enregistrement du jeu
   - `server.lua` - Logique serveur
   - `client.lua` - Logique client

3. Créez l'interface dans `/lua/html/includes/votre_jeu/`
   - `votre_jeu.html.lua` - Structure HTML
   - `votre_jeu.css.lua` - Styles CSS
   - `votre_jeu.js.lua` - Logique JavaScript

4. Enregistrez le jeu dans `init.lua` :

```lua
Casino.RegisterGame("votre_jeu", {
	name = "votre_jeu",
	displayName = "Votre Jeu",
	description = "Description du jeu",
	icon = "🎲",
	minBet = 50,
	maxBet = 5000,
	htmlFile = "votre_jeu/votre_jeu.html",
	setupFunctions = function(html)
		-- Configuration des fonctions JS/Lua
	end
})
```

## 📡 Système de monnaie

L'addon supporte automatiquement :
- **Basewars** - Détection automatique
- **DarkRP** - Détection automatique
- **PointShop 1 & 2** - Détection automatique
- **XeninCoinflip** - Détection automatique
- **Système par défaut** - 10,000$ de départ

Le système de monnaie est détecté automatiquement au chargement.

## 🔐 Sécurité

- Anti-spam intégré (délai entre les actions)
- Validation côté serveur de toutes les transactions
- Limite de paris par session
- Logging des transactions
- Protection contre les montants négatifs

## 📊 Statistiques

Le système enregistre automatiquement :
- Nombre de victoires/défaites
- Total misé
- Plus gros gain
- Taux de victoire
- Historique des 50 dernières parties

## 🐛 Dépannage

### Le menu ne s'ouvre pas
- Vérifiez la console pour les erreurs
- Tapez `lua_refresh` pour recharger
- Vérifiez que l'addon est bien chargé

### Les transactions ne fonctionnent pas
- Vérifiez le système de monnaie détecté dans la console
- Assurez-vous d'avoir assez d'argent
- Vérifiez les logs serveur

### Le HTML ne se charge pas
- Tapez `casino_clearcache` pour vider le cache
- Vérifiez que les fichiers HTML existent
- Regardez la console pour les erreurs

## 📝 Changelog

### v2.0 (2025-10-22)
- ✨ Refonte complète de l'interface
- 🎨 Design moderne avec glassmorphism
- 📁 Architecture modulaire
- 🎮 Menu principal avec sélection de jeux
- 📊 Système de statistiques
- 📜 Historique des parties
- ⚙️ Paramètres personnalisables
- 🔧 Séparation HTML/CSS/JS
- 📱 Interface responsive

### v1.0
- 🃏 Blackjack de base

## 👨‍💻 Développement

### Inspiration
Architecture inspirée de [gm_html_loader](https://github.com/Periapsises/gm_html_loader) par Periapsises

### Contribuer
Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer de nouvelles fonctionnalités
- Créer de nouveaux jeux
- Améliorer l'interface

## 📄 Licence

Ce projet est libre d'utilisation. Crédits appréciés mais non obligatoires.

## 🎯 Roadmap

- [ ] Machine à sous
- [ ] Roulette  
- [ ] Poker
- [ ] Système de jackpot progressif
- [ ] Tournois
- [ ] Classement des joueurs
- [ ] Succès/Achievements
- [ ] Support MySQL pour les stats
- [ ] API pour développeurs

---

**Bon jeu ! 🎰✨**
