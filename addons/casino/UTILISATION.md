# 🎰 Blackjack DHTML - Guide d'Utilisation

## 🚀 Comment Démarrer

### 1. Installation
L'addon est déjà installé dans : `garrysmod/addons/blackjack_dhtml/`

### 2. Ouvrir le Blackjack
Dans la console du jeu (touche `~` par défaut), tapez :
```
slots
```

**Commandes disponibles :**
- `slots` - Commande principale pour ouvrir le blackjack
- `blackjack` - Alias alternatif
- `blackjack_open` - Alias alternatif

## 💰 Comment Jouer et Miser

### Étape 1 : Ouvrir l'interface
1. Appuyez sur `~` pour ouvrir la console
2. Tapez `slots` et appuyez sur Entrée
3. La fenêtre du blackjack s'ouvre automatiquement

### Étape 2 : Placer votre mise
1. Votre solde actuel s'affiche en haut à gauche
2. Cliquez sur les jetons pour ajouter à votre mise :
   - **Blanc** : 100
   - **Rouge** : 250
   - **Bleu** : 500
   - **Noir** : 1,000
   - **Violet** : 2,500
   - **Orange** : 5,000

3. Cliquez sur **"Miser"** pour commencer la partie
4. Ou cliquez sur **"Effacer"** pour recommencer votre mise

### Étape 3 : Jouer
Une fois la mise placée, les boutons de jeu s'activent :

- **Tirer** : Prendre une carte supplémentaire
- **Rester** : Garder votre main et passer au tour du croupier
- **Double** : Doubler votre mise et prendre une seule carte

## 🎯 Règles du Blackjack

### Objectif
Obtenir une main avec une valeur totale proche de 21 sans dépasser.

### Valeurs des cartes
- **2-10** : Valeur nominale
- **J, Q, K** : 10 points
- **As** : 1 ou 11 points (automatiquement ajusté)

### Déroulement du jeu
1. **Distribution initiale** : Vous et le croupier recevez 2 cartes
2. **Votre tour** : Choisissez Tirer ou Rester
3. **Tour du croupier** : Le croupier tire jusqu'à atteindre 17 minimum
4. **Comparaison** : La main la plus proche de 21 gagne

### Cas spéciaux
- **Blackjack** : Main de 2 cartes valant 21 (As + 10) → Paiement 3:2
- **Bust** : Dépasser 21 → Perte automatique
- **Égalité** : Même score que le croupier → Remboursement de la mise

## 💡 Conseils de Jeu

### Gestion de votre bankroll
- **Mise minimale** : 100
- **Mise maximale** : 10,000
- Ne misez jamais plus que ce que vous pouvez vous permettre de perdre

### Stratégie de base
- **16 ou moins** : Toujours tirer
- **17-21** : Toujours rester
- **As + 6 ou moins** : Tirer
- **As + 7 ou plus** : Rester

### Double Down recommandé
- **Main totale 11** : Toujours doubler
- **Main totale 10** : Doubler si le croupier montre 2-9
- **Main totale 9** : Doubler si le croupier montre 3-6

## 🔧 Système de Monnaie

Le blackjack est compatible avec :
- **xenin_coinflip** : Si installé sur le serveur
- **Basewars** : Argent du serveur Basewars
- **DarkRP** : Argent du serveur DarkRP
- **Système par défaut** : Points virtuels si aucun système détecté

## 🛡️ Sécurité et Limites

### Protections intégrées
- **Anti-spam** : Délai entre chaque action
- **Limite de mises** : 100-10,000 par partie
- **Validation serveur** : Toutes les transactions sont vérifiées

### En cas de problème
1. Fermez et rouvrez l'interface avec `slots`
2. Vérifiez votre solde dans le jeu
3. Contactez un administrateur si le problème persiste

## 📞 Support

Si vous rencontrez des problèmes :
- Vérifiez que l'addon est bien installé
- Assurez-vous d'avoir les permissions nécessaires
- Contactez un administrateur du serveur

---

**Bon jeu et bonne chance ! 🎰**
