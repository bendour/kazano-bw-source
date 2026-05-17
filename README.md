# Kazano BaseWars

Gamemode Garry's Mod **BaseWars** complet avec addons et configuration serveur.

## Installation

### 1. Workshop Collection (obligatoire)

Le serveur nécessite cette collection Steam Workshop pour fonctionner correctement (modèles, contenus) :

**👉 [Collection Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3355620511)**

Abonne-toi à toute la collection avant de lancer le serveur, ou configure-la sur ton serveur dédié via la `collection_id` dans ton fichier de démarrage.

### 2. Déploiement du gamemode

Place le contenu de ce dépôt dans ton dossier `garrysmod/` :

```
garrysmod/
├── addons/        ← addons du dépôt
├── cfg/           ← configs serveur
├── gamemodes/     ← gamemode basewars + base/sandbox/darkrp/terrortown
└── lua/           ← scripts autorun et utilitaires
```

### 3. Configuration serveur

- Édite `cfg/server.cfg` :
  - `hostname` : nom de ton serveur
  - `rcon_password` : ton mot de passe RCON (laissé vide par défaut)
  - `sv_downloadurl` : URL fast-download si tu en utilises une
- Lance le serveur avec `+gamemode basewars +map <map_de_la_collection>`

## Structure

| Dossier | Contenu |
|---------|---------|
| `gamemodes/basewars` | Gamemode principal BaseWars (modules f4, raid, shop, prestige, etc.) |
| `gamemodes/darkrp` | Variante DarkRP custom |
| `gamemodes/sandbox` / `base` / `terrortown` | Gamemodes de base GMod |
| `addons/` | ~30 addons (SAM, ashop, eChat, eProtect, voidfactions, bitminers, etc.) |
| `lua/autorun/` | Scripts de démarrage et utilitaires |
| `cfg/` | Configuration serveur Source |

## Notes

- **Printers** : les printers de ce dépôt n'utilisent pas le modèle récent. Le modèle à jour est disponible dans la [collection Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3355620511) — il faut juste réadapter les `3d2d` (overlays texte/UI) sur le nouveau mesh.

## Auteur

JL
