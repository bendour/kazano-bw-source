-- // JavaScript moderne pour le Blackjack

-- // État du jeu
-- const gameState = {
-- 	deck: [],
-- 	playerHand: [],
-- 	dealerHand: [],
-- 	currentBet: 0,
-- 	playerBalance: 0,
-- 	gameActive: false,
-- 	playerTurn: true,
-- 	dealerHiddenCard: null
-- };

-- // Configuration
-- const CONFIG = {
-- 	BLACKJACK_PAYOUT: 2.5, // 3:2
-- 	REGULAR_PAYOUT: 2, // 1:1
-- 	DEALER_STANDS_ON: 17,
-- 	MIN_BET: 1,
-- 	MAX_BET: 10000
-- };

-- // Initialisation
-- document.addEventListener('DOMContentLoaded', init);

-- function init() {
-- 	setupEventListeners();
-- 	loadPlayerInfo();
	
-- 	// Focus sur le champ de mise
-- 	setTimeout(() => {
-- 		document.getElementById('betInput').focus();
-- 	}, 100);
-- }

-- // Configuration des event listeners
-- function setupEventListeners() {
-- 	// Bouton retour
-- 	document.getElementById('backBtn').addEventListener('click', returnToMenu);
	
-- 	// Input de mise avec validation
-- 	const betInput = document.getElementById('betInput');
-- 	betInput.addEventListener('input', () => {
-- 		let value = parseInt(betInput.value);
-- 		if (isNaN(value) || value < 1) {
-- 			betInput.value = '';
-- 		} else if (value > 10000) {
-- 			betInput.value = 10000;
-- 		}
-- 	});
	
-- 	// Validation avec la touche Entrée
-- 	betInput.addEventListener('keypress', (e) => {
-- 		if (e.key === 'Enter') {
-- 			placeBet();
-- 		}
-- 	});
	
-- 	// Action de mise
-- 	document.getElementById('betBtn').addEventListener('click', placeBet);
	
-- 	// Contrôles de jeu
-- 	document.getElementById('hitBtn').addEventListener('click', hit);
-- 	document.getElementById('standBtn').addEventListener('click', stand);
-- 	document.getElementById('doubleBtn').addEventListener('click', doubleDown);
-- 	document.getElementById('newGameBtn').addEventListener('click', newGame);
-- }

-- // Communication avec Lua
-- function loadPlayerInfo() {
-- 	if (typeof blackjack !== 'undefined' && blackjack.getPlayerInfo) {
-- 		blackjack.getPlayerInfo();
-- 	}
-- }

-- function returnToMenu() {
-- 	if (typeof blackjack !== 'undefined' && blackjack.returnToMenu) {
-- 		blackjack.returnToMenu();
-- 	}
-- }

-- function luaPlaceBet(amount) {
-- 	if (typeof blackjack !== 'undefined' && blackjack.placeBet) {
-- 		blackjack.placeBet(amount);
-- 	}
-- }

-- // Appelé depuis Lua pour mettre à jour les infos
-- function updatePlayerInfo(balance) {
-- 	gameState.playerBalance = balance;
-- 	updateDisplay();
-- }

-- // Appelé depuis Lua après une transaction
-- function luaTransactionComplete(success, newBalance, message) {
-- 	gameState.playerBalance = newBalance;
	
-- 	if (success) {
-- 		updateDisplay();
-- 		if (gameState.currentBet > 0) {
-- 			setTimeout(() => startGame(), 300);
-- 		}
-- 	} else {
-- 		showMessage(message || "Erreur de transaction", "lose");
-- 	}
-- }

-- // Gestion des mises
-- function placeBet() {
-- 	if (gameState.gameActive) return;
	
-- 	const betInput = document.getElementById('betInput');
-- 	const betAmount = parseInt(betInput.value);
	
-- 	// Validation de la mise
-- 	if (isNaN(betAmount) || betAmount < 1) {
-- 		showMessage("Veuillez entrer un montant valide!", "lose");
-- 		betInput.focus();
-- 		return;
-- 	}
	
-- 	if (betAmount < CONFIG.MIN_BET || betAmount > CONFIG.MAX_BET) {
-- 		showMessage(`Mise invalide! (${CONFIG.MIN_BET}$ - ${CONFIG.MAX_BET}$)`, "lose");
-- 		betInput.focus();
-- 		return;
-- 	}
	
-- 	if (betAmount > gameState.playerBalance) {
-- 		showMessage("Solde insuffisant!", "lose");
-- 		betInput.focus();
-- 		return;
-- 	}
	
-- 	gameState.currentBet = betAmount;
-- 	luaPlaceBet(gameState.currentBet);
-- }

-- // Démarrer la partie
-- function startGame() {
-- 	// Masquer la zone de mise
-- 	document.getElementById('bettingArea').style.display = 'none';
	
-- 	// Initialiser le deck
-- 	initializeDeck();
-- 	shuffleDeck();
	
-- 	// Distribuer les cartes
-- 	gameState.playerHand = [drawCard(), drawCard()];
-- 	gameState.dealerHand = [drawCard(), drawCard()];
-- 	gameState.dealerHiddenCard = gameState.dealerHand[1];
	
-- 	gameState.gameActive = true;
-- 	gameState.playerTurn = true;
	
-- 	// Afficher les cartes
-- 	updateCards();
	
-- 	// Activer les contrôles
-- 	enableControls(true);
	
-- 	// Vérifier blackjack initial
-- 	setTimeout(() => checkInitialBlackjack(), 1000);
-- }

-- // Gestion du deck
-- function initializeDeck() {
-- 	gameState.deck = [];
-- 	const suits = ['♠', '♥', '♦', '♣'];
-- 	const ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
	
-- 	for (let suit of suits) {
-- 		for (let rank of ranks) {
-- 			gameState.deck.push({
-- 				rank: rank,
-- 				suit: suit,
-- 				value: getCardValue(rank)
-- 			});
-- 		}
-- 	}
-- }

-- function shuffleDeck() {
-- 	for (let i = gameState.deck.length - 1; i > 0; i--) {
-- 		const j = Math.floor(Math.random() * (i + 1));
-- 		[gameState.deck[i], gameState.deck[j]] = [gameState.deck[j], gameState.deck[i]];
-- 	}
-- }

-- function drawCard() {
-- 	return gameState.deck.pop();
-- }

-- function getCardValue(rank) {
-- 	if (rank === 'A') return 11;
-- 	if (['J', 'Q', 'K'].includes(rank)) return 10;
-- 	return parseInt(rank);
-- }

-- function calculateHandValue(hand) {
-- 	let value = 0;
-- 	let aces = 0;
	
-- 	for (let card of hand) {
-- 		value += card.value;
-- 		if (card.rank === 'A') aces++;
-- 	}
	
-- 	while (value > 21 && aces > 0) {
-- 		value -= 10;
-- 		aces--;
-- 	}
	
-- 	return value;
-- }

-- // Affichage des cartes
-- function updateCards() {
-- 	// Cartes du joueur
-- 	const playerContainer = document.getElementById('playerCards');
-- 	playerContainer.innerHTML = '';
	
-- 	gameState.playerHand.forEach((card, index) => {
-- 		setTimeout(() => {
-- 			const cardEl = createCardElement(card);
-- 			playerContainer.appendChild(cardEl);
-- 		}, index * 200);
-- 	});
	
-- 	// Cartes du croupier
-- 	const dealerContainer = document.getElementById('dealerCards');
-- 	dealerContainer.innerHTML = '';
	
-- 	gameState.dealerHand.forEach((card, index) => {
-- 		setTimeout(() => {
-- 			let cardEl;
-- 			if (index === 1 && gameState.playerTurn && gameState.gameActive) {
-- 				cardEl = createCardElement(null, true);
-- 			} else {
-- 				cardEl = createCardElement(card);
-- 			}
-- 			dealerContainer.appendChild(cardEl);
-- 		}, index * 200);
-- 	});
	
-- 	// Scores
-- 	updateScores();
-- }

-- function createCardElement(card, isHidden = false) {
-- 	const cardEl = document.createElement('div');
-- 	cardEl.className = 'card';
	
-- 	if (isHidden) {
-- 		cardEl.classList.add('back');
-- 	} else {
-- 		cardEl.classList.add(card.suit === '♥' || card.suit === '♦' ? 'red' : 'black');
-- 		cardEl.textContent = card.rank + card.suit;
-- 	}
	
-- 	return cardEl;
-- }

-- function updateScores() {
-- 	const playerScore = calculateHandValue(gameState.playerHand);
-- 	document.getElementById('playerScore').textContent = `Score: ${playerScore}`;
	
-- 	if (gameState.playerTurn && gameState.gameActive) {
-- 		const visibleScore = calculateHandValue([gameState.dealerHand[0]]);
-- 		document.getElementById('dealerScore').textContent = `Score: ${visibleScore}`;
-- 	} else {
-- 		const dealerScore = calculateHandValue(gameState.dealerHand);
-- 		document.getElementById('dealerScore').textContent = `Score: ${dealerScore}`;
-- 	}
-- }

-- // Actions du joueur
-- function hit() {
-- 	if (!gameState.gameActive || !gameState.playerTurn) return;
	
-- 	gameState.playerHand.push(drawCard());
-- 	updateCards();
	
-- 	setTimeout(() => {
-- 		const playerScore = calculateHandValue(gameState.playerHand);
-- 		if (playerScore > 21) {
-- 			endGame('bust', "Bust! Vous perdez!");
-- 		} else if (playerScore === 21) {
-- 			stand();
-- 		}
		
-- 		document.getElementById('doubleBtn').disabled = true;
-- 	}, 300);
-- }

-- function stand() {
-- 	if (!gameState.gameActive || !gameState.playerTurn) return;
	
-- 	gameState.playerTurn = false;
-- 	enableControls(false);
	
-- 	setTimeout(() => {
-- 		updateCards();
-- 		dealerPlay();
-- 	}, 500);
-- }

-- function doubleDown() {
-- 	if (!gameState.gameActive || !gameState.playerTurn) return;
-- 	if (gameState.playerBalance < gameState.currentBet) {
-- 		showMessage("Solde insuffisant pour doubler!", "lose");
-- 		return;
-- 	}
	
-- 	gameState.currentBet *= 2;
-- 	gameState.playerHand.push(drawCard());
-- 	updateCards();
	
-- 	setTimeout(() => {
-- 		const playerScore = calculateHandValue(gameState.playerHand);
-- 		if (playerScore > 21) {
-- 			endGame('bust', "Bust! Vous perdez!");
-- 		} else {
-- 			stand();
-- 		}
-- 	}, 300);
-- }

-- // Tour du croupier
-- function dealerPlay() {
-- 	const dealerScore = calculateHandValue(gameState.dealerHand);
	
-- 	if (dealerScore < CONFIG.DEALER_STANDS_ON) {
-- 		setTimeout(() => {
-- 			gameState.dealerHand.push(drawCard());
-- 			updateCards();
-- 			setTimeout(() => dealerPlay(), 800);
-- 		}, 1000);
-- 	} else {
-- 		setTimeout(() => determineWinner(), 1000);
-- 	}
-- }

-- // Déterminer le gagnant
-- function determineWinner() {
-- 	const playerScore = calculateHandValue(gameState.playerHand);
-- 	const dealerScore = calculateHandValue(gameState.dealerHand);
	
-- 	if (dealerScore > 21) {
-- 		endGame('win', "Croupier bust! Vous gagnez!");
-- 	} else if (playerScore > dealerScore) {
-- 		endGame('win', "Vous gagnez!");
-- 	} else if (dealerScore > playerScore) {
-- 		endGame('lose', "Vous perdez!");
-- 	} else {
-- 		endGame('push', "Égalité!");
-- 	}
-- }

-- // Vérifier blackjack initial
-- function checkInitialBlackjack() {
-- 	const playerScore = calculateHandValue(gameState.playerHand);
-- 	const dealerScore = calculateHandValue(gameState.dealerHand);
	
-- 	if (playerScore === 21 && dealerScore === 21) {
-- 		endGame('push', "Double Blackjack! Égalité!");
-- 	} else if (playerScore === 21) {
-- 		endGame('blackjack', "Blackjack! Vous gagnez!");
-- 	} else if (dealerScore === 21) {
-- 		updateCards();
-- 		setTimeout(() => endGame('lose', "Croupier a Blackjack!"), 1000);
-- 	}
-- }

-- // Fin de partie
-- function endGame(result, message) {
-- 	gameState.gameActive = false;
-- 	gameState.playerTurn = false;
	
-- 	enableControls(false);
-- 	updateCards();
-- 	showMessage(message, result);
	
-- 	// Envoyer le résultat au serveur pour gérer les gains
-- 	if (typeof blackjack !== 'undefined' && blackjack.gameResult) {
-- 		blackjack.gameResult(result);
-- 	}
	
-- 	// Note: Le solde sera mis à jour par le serveur via updatePlayerInfo()
-- 	// On ne calcule plus les gains côté client pour éviter la désynchronisation
	
-- 	// Afficher le bouton nouvelle partie
-- 	setTimeout(() => {
-- 		document.getElementById('newGameBtn').style.display = 'inline-block';
-- 	}, 3000);
-- }

-- // Nouvelle partie
-- function newGame() {
-- 	// Réinitialiser l'état
-- 	gameState.gameActive = false;
-- 	gameState.playerTurn = true;
-- 	gameState.currentBet = 0;
-- 	gameState.playerHand = [];
-- 	gameState.dealerHand = [];
-- 	gameState.dealerHiddenCard = null;
	
-- 	// Nettoyer l'affichage
-- 	document.getElementById('playerCards').innerHTML = '';
-- 	document.getElementById('dealerCards').innerHTML = '';
-- 	document.getElementById('playerScore').textContent = '';
-- 	document.getElementById('dealerScore').textContent = '';
-- 	document.getElementById('newGameBtn').style.display = 'none';
	
-- 	// Réinitialiser le champ de mise
-- 	document.getElementById('betInput').value = '';
-- 	document.getElementById('betInput').focus();
	
-- 	// Réafficher la zone de mise
-- 	document.getElementById('bettingArea').style.display = 'block';
	
-- 	updateDisplay();
-- }

-- // Gestion de l'interface
-- function enableControls(enabled) {
-- 	document.getElementById('hitBtn').disabled = !enabled;
-- 	document.getElementById('standBtn').disabled = !enabled;
-- 	document.getElementById('doubleBtn').disabled = !enabled || gameState.playerBalance < gameState.currentBet;
-- }

-- function updateDisplay() {
-- 	const balanceEl = document.getElementById('balance');
-- 	animateNumber(balanceEl, gameState.playerBalance);
-- }

-- function animateNumber(element, targetValue) {
-- 	const startValue = parseInt(element.textContent.replace(/\s/g, '')) || 0;
-- 	const duration = 500;
-- 	const startTime = Date.now();
	
-- 	function update() {
-- 		const elapsed = Date.now() - startTime;
-- 		const progress = Math.min(elapsed / duration, 1);
		
-- 		const currentValue = Math.floor(startValue + (targetValue - startValue) * progress);
-- 		element.textContent = formatNumber(currentValue);
		
-- 		if (progress < 1) {
-- 			requestAnimationFrame(update);
-- 		}
-- 	}
	
-- 	update();
-- }

-- function formatNumber(num) {
-- 	return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
-- }

-- function showMessage(text, type) {
-- 	const messageEl = document.getElementById('message');
-- 	messageEl.textContent = text;
-- 	messageEl.className = `game-message ${type}`;
	
-- 	setTimeout(() => {
-- 		messageEl.classList.add('show');
-- 	}, 10);
	
-- 	setTimeout(() => {
-- 		messageEl.classList.remove('show');
-- 	}, 2500);
-- }

-- // Exposer les fonctions pour Lua
-- window.updatePlayerInfo = updatePlayerInfo;
-- window.luaTransactionComplete = luaTransactionComplete;

