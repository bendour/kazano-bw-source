# 🎰 Vote Rewards System

Système complet de récompenses pour les votes avec wheelspin HTML5, classement mensuel et intégration Discord.

## 📋 Fonctionnalités

- ✅ **Intégration Top-Serveurs** : Vérification automatique des votes via API
- ✅ **Wheelspin HTML5** : Roue de la fortune interactive avec animations
- ✅ **Récompenses variées** : Crédits, armes permanentes, skins Pointshop
- ✅ **Système de probabilités** : Taux de drop configurables
- ✅ **Classement mensuel** : Top 3 des voteurs
- ✅ **Webhook Discord** : Envoi automatique du classement
- ✅ **Reset automatique** : Chaque 1er du mois
- ✅ **Commandes admin** : Gestion complète des wheelspins

## 🔧 Installation

1. Placez le dossier `vote_rewards` dans `garrysmod/addons/`
2. Configurez l'addon dans `lua/vote_rewards/config.lua`
3. Redémarrez le serveur

## ⚙️ Configuration

### Discord Webhook
```lua
DiscordWebhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE"
```

### API Top-Serveurs
```lua
TopServeurAPIKey = "YOUR_API_KEY_HERE"
TopServeurServerID = "YOUR_SERVER_ID_HERE"
```

### Récompenses de la Roue
```lua
WheelRewards = {
	{ name = "500 Crédits", type = "credits", value = 500, chance = 30, color = Color(52, 152, 219) },
	{ name = "Arme Permanente", type = "weapon", value = "random", chance = 10, color = Color(231, 76, 60) },
	-- ... etc
}
```

### Pool d'Armes et Skins
```lua
WeaponPool = { "m9k_ak47", "m9k_m4a1", ... }
SkinPool = { 1, 2, 3, 4, ... }
```

## 🎮 Commandes Joueurs

- `/wheelspin` ou `!wheelspin` - Ouvrir la roue
- `/votes` ou `!votes` - Voir le classement

## 🛠️ Commandes Admin

- `vote_give_wheelspin <steamid64> <amount>` - Donner des wheelspins
- `vote_send_leaderboard` - Envoyer le classement sur Discord
- `vote_reset_monthly` - Forcer le reset mensuel
- `vote_reload_html` - Recharger le cache HTML (dev)

## 📊 Base de Données

### Table `vote_rewards_players`
- `steam_id` - SteamID64 du joueur
- `player_name` - Nom du joueur
- `total_votes` - Votes totaux
- `monthly_votes` - Votes du mois
- `wheelspins` - Wheelspins disponibles
- `last_vote_time` - Timestamp du dernier vote
- `last_reset_month` - Mois du dernier reset

### Table `vote_rewards_history`
- `id` - ID auto-incrémenté
- `steam_id` - SteamID64
- `player_name` - Nom
- `reward_type` - Type de récompense
- `reward_value` - Valeur
- `timestamp` - Date

## 🔗 Intégration

### BaseWars
- Crédits via `ply:GiveCredit(amount)`
- Armes permanentes via `BaseWars.PW:AddWeapon()`
- Skins via `BaseWars.PS:GiveSkinToPlayer()`

### Top-Serveurs
Configurez le webhook dans votre panel Top-Serveurs :
```
URL: http://votre_ip:27015/vote_webhook
```

## 🎨 Personnalisation

### Modifier les couleurs de la roue
Dans `config.lua`, modifiez les `color` de chaque récompense :
```lua
color = Color(R, G, B)
```

### Modifier la durée du spin
```lua
WheelSpinDuration = 5 -- secondes
```

### Modifier le jour de reset
```lua
ResetDay = 1 -- 1 = 1er du mois
```

## 📝 Notes

- Le système utilise MySQLite (compatible MySQL et SQLite)
- Les wheelspins sont persistants en base de données
- Le classement est envoyé automatiquement sur Discord le jour du reset
- Les récompenses sont distribuées via les systèmes BaseWars existants

## 🐛 Dépannage

### La roue ne s'affiche pas
```
vote_reload_html
```

### Les votes ne sont pas détectés
Vérifiez :
- L'API Key Top-Serveurs
- Le Server ID
- Le webhook configuré dans Top-Serveurs

### Le webhook Discord ne fonctionne pas
Vérifiez l'URL du webhook dans `config.lua`

## 📜 Licence

Créé pour Kazano BaseWars - 2025
