// JavaScript sécurisé pour le Blackjack
// Toute la logique du jeu est côté serveur

// État du jeu
let gameState = {
	playerHand: [],
	dealerHand: [],
	playerScore: 0,
	dealerScore: 0,
	playerBalance: 0,
	currentBet: 0,
	gameActive: false,
	hideDealer: true,
	canDouble: false
};

// Initialisation
document.addEventListener('DOMContentLoaded', init);

function init() {
	setupEventListeners();
	loadPlayerInfo();
	
	setTimeout(() => {
		document.getElementById('betInput').focus();
	}, 100);
}

// Configuration des event listeners
function setupEventListeners() {
	document.getElementById('backBtn').addEventListener('click', returnToMenu);
	
	const betInput = document.getElementById('betInput');
	betInput.addEventListener('input', () => {
		let value = parseInt(betInput.value);
		if (isNaN(value) || value < 1) {
			betInput.value = '';
		} else if (value > 10000) {
			betInput.value = 10000;
		}
	});
	
	betInput.addEventListener('keypress', (e) => {
		if (e.key === 'Enter') {
			placeBet();
		}
	});
	
	document.getElementById('betBtn').addEventListener('click', placeBet);
	document.getElementById('hitBtn').addEventListener('click', hit);
	document.getElementById('standBtn').addEventListener('click', stand);
	document.getElementById('doubleBtn').addEventListener('click', doubleDown);
	document.getElementById('newGameBtn').addEventListener('click', newGame);
}

// Communication avec Lua
function loadPlayerInfo() {
	if (typeof blackjack !== 'undefined' && blackjack.getPlayerInfo) {
		blackjack.getPlayerInfo();
	}
}

function returnToMenu() {
	if (typeof blackjack !== 'undefined' && blackjack.returnToMenu) {
		blackjack.returnToMenu();
	}
}

// Appelé depuis Lua pour mettre à jour les infos
function updatePlayerInfo(balance) {
	gameState.playerBalance = balance;
	updateDisplay();
}

// Appelé depuis Lua après une transaction
function luaTransactionComplete(success, newBalance, message) {
	gameState.playerBalance = newBalance;
	
	if (success) {
		updateDisplay();
		// Le serveur enverra l'état du jeu via receiveGameState
	} else {
		showMessage(message || "Erreur de transaction", "lose");
	}
}

// NOUVELLE FONCTION: Recevoir l'état du jeu depuis le serveur
function receiveGameState(stateJSON) {
	let state;
	
	// Si c'est déjà un objet, l'utiliser directement
	if (typeof stateJSON === 'object') {
		state = stateJSON;
	} else {
		// Sinon, parser le JSON
		try {
			state = JSON.parse(stateJSON);
		} catch(e) {
			console.error('Erreur parsing JSON:', e, stateJSON);
			return;
		}
	}
	
	gameState.playerHand = state.playerHand || [];
	gameState.dealerHand = state.dealerHand || [];
	gameState.playerScore = state.playerScore || 0;
	gameState.dealerScore = state.dealerScore || 0;
	gameState.currentBet = state.bet || 0;
	gameState.canDouble = state.canDouble || false;
	gameState.hideDealer = state.hideDealer !== false;
	gameState.gameActive = true;
	
	// Masquer la zone de mise
	document.getElementById('bettingArea').style.display = 'none';
	
	// Afficher les cartes avec animations
	updateCards();
	
	// Activer les contrôles
	enableControls(true);
}

// NOUVELLE FONCTION: Afficher le résultat final
function showGameResult(result, winAmount) {
	gameState.gameActive = false;
	enableControls(false);
	
	let message = '';
	let type = result;
	
	if (result === 'blackjack') {
		message = '🎉 BLACKJACK! +' + winAmount + '💎';
	} else if (result === 'win') {
		message = '✓ Victoire! +' + winAmount + '💎';
	} else if (result === 'push') {
		message = '↔ Égalité - Mise rendue';
	} else {
		message = '✗ Défaite -' + gameState.currentBet + '💎';
	}
	
	showNotification(message, type);
	
	// Afficher le bouton nouvelle partie après 2 secondes
	setTimeout(() => {
		document.getElementById('newGameBtn').style.display = 'inline-block';
	}, 2000);
}

// Gestion des mises
function placeBet() {
	if (gameState.gameActive) return;
	
	const betInput = document.getElementById('betInput');
	const betAmount = parseInt(betInput.value);
	
	if (isNaN(betAmount) || betAmount < 1) {
		showMessage("Veuillez entrer un montant valide!", "lose");
		betInput.focus();
		return;
	}
	
	if (betAmount < 1 || betAmount > 10000) {
		showMessage(`Mise invalide! (1💎 - 10000💎)`, "lose");
		betInput.focus();
		return;
	}
	
	if (betAmount > gameState.playerBalance) {
		showMessage("Solde insuffisant!", "lose");
		betInput.focus();
		return;
	}
	
	gameState.currentBet = betAmount;
	
	// Envoyer au serveur - le serveur gèrera tout le reste
	if (typeof blackjack !== 'undefined' && blackjack.placeBet) {
		blackjack.placeBet(betAmount);
	}
}

// Actions de jeu - communiquent avec le serveur
function hit() {
	if (!gameState.gameActive) return;
	
	if (typeof blackjack !== 'undefined' && blackjack.hit) {
		blackjack.hit();
	}
}

function stand() {
	if (!gameState.gameActive) return;
	
	if (typeof blackjack !== 'undefined' && blackjack.stand) {
		blackjack.stand();
	}
}

function doubleDown() {
	if (!gameState.gameActive || !gameState.canDouble) return;
	
	if (gameState.currentBet > gameState.playerBalance) {
		showMessage("Solde insuffisant pour doubler!", "lose");
		return;
	}
	
	if (typeof blackjack !== 'undefined' && blackjack.double) {
		blackjack.double();
	}
}

function newGame() {
	// Réinitialiser l'interface
	gameState.playerHand = [];
	gameState.dealerHand = [];
	gameState.currentBet = 0;
	gameState.gameActive = false;
	gameState.hideDealer = true;
	
	document.getElementById('playerCards').innerHTML = '';
	document.getElementById('dealerCards').innerHTML = '';
	document.getElementById('bettingArea').style.display = 'flex';
	document.getElementById('betInput').value = '';
	document.getElementById('betInput').focus();
	document.getElementById('newGameBtn').style.display = 'none';
	
	hideMessage();
	enableControls(false);
	updateScores();
	updateDisplay();
}

// Affichage des cartes avec animations améliorées
function updateCards() {
	const playerContainer = document.getElementById('playerCards');
	const dealerContainer = document.getElementById('dealerCards');
	
	// Nombre de cartes actuellement affichées
	const currentPlayerCards = playerContainer.children.length;
	const currentDealerCards = dealerContainer.children.length;
	
	// Ajouter seulement les nouvelles cartes du joueur
	for (let i = currentPlayerCards; i < gameState.playerHand.length; i++) {
		const card = gameState.playerHand[i];
		setTimeout(() => {
			const cardEl = createCardElement(card);
			cardEl.style.animation = 'dealCard 0.5s ease-out';
			playerContainer.appendChild(cardEl);
		}, (i - currentPlayerCards) * 300);
	}
	
	// Gérer les cartes du croupier (le serveur envoie déjà progressivement)
	const targetDealerCards = gameState.dealerHand.length;
	
	// Mettre à jour ou ajouter les cartes du croupier
	for (let i = 0; i < targetDealerCards; i++) {
		const card = gameState.dealerHand[i];
		const existingCard = dealerContainer.children[i];
		
		if (existingCard) {
			// La carte existe déjà
			if (i === 1 && gameState.hideDealer) {
				// Carte doit rester cachée
				if (!existingCard.classList.contains('hidden')) {
					existingCard.className = 'card hidden';
					existingCard.innerHTML = '<div class="card-back">?</div>';
				}
			} else {
				// Révéler la carte si elle était cachée
				if (existingCard.classList.contains('hidden')) {
					existingCard.style.animation = 'flipCard 0.6s ease-out';
					setTimeout(() => {
						const isRed = card.suit === '♥' || card.suit === '♦';
						existingCard.className = 'card ' + (isRed ? 'red' : 'black');
						existingCard.innerHTML = `${card.rank}<br>${card.suit}`;
					}, 300);
				}
			}
		} else {
			// Ajouter une nouvelle carte avec animation
			let cardEl;
			if (i === 1 && gameState.hideDealer) {
				cardEl = createCardElement(null, true);
			} else {
				cardEl = createCardElement(card);
			}
			cardEl.style.animation = 'dealCard 0.5s ease-out';
			dealerContainer.appendChild(cardEl);
		}
	}
	
	// Mettre à jour les scores immédiatement
	setTimeout(() => {
		updateScores();
	}, 100);
}

function createCardElement(card, isHidden = false) {
	const cardEl = document.createElement('div');
	cardEl.className = 'card';
	
	if (isHidden) {
		cardEl.classList.add('hidden');
		cardEl.innerHTML = '<div class="card-back">?</div>';
	} else {
		const isRed = card.suit === '♥' || card.suit === '♦';
		cardEl.classList.add(isRed ? 'red' : 'black');
		cardEl.innerHTML = `${card.rank}<br>${card.suit}`;
	}
	
	return cardEl;
}

function updateScores() {
	document.getElementById('playerScore').textContent = gameState.playerScore;
	document.getElementById('dealerScore').textContent = gameState.hideDealer ? '?' : gameState.dealerScore;
}

// Affichage
function updateDisplay() {
	document.getElementById('balance').textContent = gameState.playerBalance.toLocaleString();
}

function enableControls(enabled) {
	document.getElementById('hitBtn').disabled = !enabled;
	document.getElementById('standBtn').disabled = !enabled;
	document.getElementById('doubleBtn').disabled = !enabled || !gameState.canDouble;
}

function showMessage(text, type) {
	const messageEl = document.getElementById('message');
	messageEl.textContent = text;
	messageEl.className = 'game-message show ' + type;
}

function hideMessage() {
	const messageEl = document.getElementById('message');
	messageEl.className = 'game-message';
}

// Notification minimaliste en haut à droite
function showNotification(text, type) {
	const notif = document.getElementById('notification');
	notif.textContent = text;
	notif.className = 'notification show ' + type;
	
	// Masquer après 4 secondes
	setTimeout(() => {
		notif.className = 'notification ' + type;
	}, 4000);
}

// Exposer les fonctions pour que Lua puisse les appeler
window.updatePlayerInfo = updatePlayerInfo;
window.luaTransactionComplete = luaTransactionComplete;
window.receiveGameState = receiveGameState;
window.showGameResult = showGameResult;
