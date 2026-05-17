# 🎰 Guide d'utilisation - Casino Addon

## 🎮 Comment jouer

### 1. Ouvrir le casino
Tapez `casino` dans la console ou utilisez un bouton/commande personnalisé

### 2. Menu principal

Vous arriverez sur un menu moderne avec 4 sections :

#### 🎮 Jeux
- Sélectionnez le jeu auquel vous voulez jouer
- Cliquez sur "Jouer maintenant" ou sur la carte du jeu
- Actuellement disponible : **Blackjack** 🃏

#### 📊 Statistiques
Consultez vos performances :
- **Gains totaux** - Combien vous avez gagné
- **Parties jouées** - Nombre total de parties
- **Taux de victoire** - Votre pourcentage de victoires
- **Plus gros gain** - Votre meilleur coup !

#### 📜 Historique
Revoyez vos dernières parties avec :
- Le jeu joué
- Le résultat (victoire/défaite)
- Le montant gagné/perdu
- La date et l'heure

#### ⚙️ Paramètres
Personnalisez votre expérience :
- **Sons** - Activer/désactiver les effets sonores
- **Animations** - Activer/désactiver les animations
- **Notifications** - Recevoir des notifications de gains

---

## 🃏 Comment jouer au Blackjack

### Objectif
Battre le croupier en obtenant un score plus proche de 21 sans le dépasser !

### Étapes

1. **Placer une mise**
   - Cliquez sur les jetons pour ajouter à votre mise
   - Mise minimum : 100$
   - Mise maximum : 10,000$
   - Cliquez sur "Effacer" pour recommencer
   - Cliquez sur "Miser" pour valider

2. **Recevoir vos cartes**
   - Vous recevez 2 cartes visibles
   - Le croupier reçoit 2 cartes (1 visible, 1 cachée)

3. **Prendre votre décision**
   - **🃏 Tirer** - Prendre une carte supplémentaire
   - **✋ Rester** - Garder votre main actuelle
   - **💰 Doubler** - Doubler votre mise et tirer une dernière carte

4. **Résultat**
   - Si vous dépassez 21 : **Bust** (défaite)
   - Si le croupier dépasse 21 : **Vous gagnez**
   - Si votre score > croupier : **Vous gagnez**
   - Si le croupier > votre score : **Vous perdez**
   - Si égalité : **Push** (remboursement)
   - Si vous obtenez 21 avec 2 cartes : **Blackjack !** (gain x2.5)

### Valeurs des cartes
- **As (A)** : 1 ou 11 points (automatique)
- **Figures (J, Q, K)** : 10 points
- **Chiffres (2-10)** : Valeur nominale

### Conseils
- Le croupier tire jusqu'à 17 minimum
- Blackjack paye 2.5x votre mise (3:2)
- Victoire normale paye 2x votre mise (1:1)
- Ne doublez que si vous êtes confiant !

---

## 💡 Astuces

### Gestion de l'argent
- Commencez avec de petites mises pour apprendre
- Ne misez jamais plus que ce que vous pouvez vous permettre
- Fixez-vous une limite et respectez-la

### Stratégie de base (Blackjack)
- **17-21** : Toujours rester
- **12-16** : Dépend de la carte du croupier
- **11 ou moins** : Toujours tirer
- **Doublez sur 10-11** si le croupier a 9 ou moins

### Interface
- Utilisez **← Retour au menu** pour changer de jeu
- Vos gains sont instantanément ajoutés à votre solde
- L'historique est sauvegardé automatiquement

---

## ❓ Questions fréquentes

**Q : Comment obtenir plus d'argent ?**  
A : L'argent vient de votre gamemode (Basewars, DarkRP, etc.)

**Q : Mes gains sont-ils sauvegardés ?**  
A : Oui, votre solde est synchronisé avec votre gamemode

**Q : Puis-je jouer avec des amis ?**  
A : Chaque joueur joue individuellement contre le croupier

**Q : Qu'arrive-t-il si je déconnecte pendant une partie ?**  
A : Votre mise est perdue si vous déconnectez pendant une partie active

**Q : Les jeux sont-ils équitables ?**  
A : Oui, tout est aléatoire et les règles sont standard

---

## 🔧 Problèmes courants

**Le menu ne s'ouvre pas**
- Tapez `lua_refresh` dans la console
- Vérifiez que l'addon est bien installé

**Impossible de miser**
- Vérifiez votre solde
- Attendez 1 seconde entre chaque mise (anti-spam)
- Assurez-vous que la mise est entre 100$ et 10,000$

**Les boutons sont grisés**
- Attendez que le jeu soit terminé
- Cliquez sur "Nouvelle partie" pour recommencer

---

## 🎯 Prochainement

D'autres jeux seront bientôt disponibles :
- 🎰 **Machine à sous** - Jackpots progressifs
- 🎡 **Roulette** - Rouge ou noir ?
- ♠️ **Poker** - Bluffez vos adversaires

---

**Amusez-vous bien et jouez responsable ! 🎰✨**
