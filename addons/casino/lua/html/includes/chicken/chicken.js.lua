// Chicken Road JavaScript

// État du jeu
let gameState = {
	balance: 0,
	betAmount: 10,
	difficulty: 'facile',
	isPlaying: false,
	grid: [],
	revealedCount: 0,
	currentMultiplier: 1,
	potentialWin: 0
};

// Initialisation
document.addEventListener('DOMContentLoaded', function() {
	initializeGrid();
	setupControls();
	setupDifficulty();
	updateDisplay();
	
	// Demander le solde
	if (typeof chicken !== 'undefined' && chicken.getBalance) {
		chicken.getBalance();
	}
	
	// Bouton retour
	document.getElementById('backBtn').addEventListener('click', function() {
		if (typeof chicken !== 'undefined' && chicken.returnToMenu) {
			chicken.returnToMenu();
		}
	});
});

// Initialiser la grille
function initializeGrid() {
	const container = document.getElementById('gridContainer');
	container.innerHTML = '';
	
	gameState.grid = [];
	
	for (let i = 0; i < 25; i++) {
		const tile = document.createElement('div');
		tile.className = 'tile';
		tile.dataset.index = i + 1;
		
		tile.addEventListener('click', function() {
			if (!gameState.isPlaying || this.classList.contains('revealed')) return;
			pickTile(parseInt(this.dataset.index));
		});
		
		container.appendChild(tile);
		gameState.grid.push({
			element: tile,
			revealed: false,
			hasBone: false
		});
	}
}

// Configuration des contrôles
function setupControls() {
	const betInput = document.getElementById('betAmount');
	const decreaseBtn = document.getElementById('decreaseBet');
	const increaseBtn = document.getElementById('increaseBet');
	const quickBets = document.querySelectorAll('.quick-bets .btn');
	const startBtn = document.getElementById('startBtn');
	const cashOutBtn = document.getElementById('cashOutBtn');
	
	// Contrôle de mise
	decreaseBtn.addEventListener('click', () => {
		let value = parseInt(betInput.value) || 10;
		betInput.value = Math.max(1, value - 10);
		gameState.betAmount = parseInt(betInput.value);
	});
	
	increaseBtn.addEventListener('click', () => {
		let value = parseInt(betInput.value) || 10;
		betInput.value = Math.min(100000, value + 10);
		gameState.betAmount = parseInt(betInput.value);
	});
	
	betInput.addEventListener('change', function() {
		let value = parseInt(this.value) || 1;
		value = Math.max(1, Math.min(100000, value));
		this.value = value;
		gameState.betAmount = value;
	});
	
	// Mises rapides
	quickBets.forEach(btn => {
		btn.addEventListener('click', function() {
			const amount = parseInt(this.dataset.amount);
			betInput.value = amount;
			gameState.betAmount = amount;
		});
	});
	
	// Démarrer
	startBtn.addEventListener('click', startGame);
	
	// Retirer
	cashOutBtn.addEventListener('click', cashOut);
}

// Configuration de la difficulté
function setupDifficulty() {
	const diffButtons = document.querySelectorAll('.difficulty-btn');
	
	diffButtons.forEach(btn => {
		btn.addEventListener('click', function() {
			if (gameState.isPlaying) return;
			
			diffButtons.forEach(b => b.classList.remove('active'));
			this.classList.add('active');
			gameState.difficulty = this.dataset.difficulty;
		});
	});
}

// Démarrer une partie
function startGame() {
	if (gameState.isPlaying) return;
	
	if (typeof chicken !== 'undefined' && chicken.startGame) {
		chicken.startGame(gameState.betAmount, gameState.difficulty);
		
		// Réinitialiser la grille
		initializeGrid();
		gameState.isPlaying = true;
		gameState.revealedCount = 0;
		gameState.currentMultiplier = 1;
		gameState.potentialWin = 0;
		
		updateDisplay();
		updateButtonStates();
	}
}

// Choisir une case
function pickTile(index) {
	if (!gameState.isPlaying) return;
	
	if (typeof chicken !== 'undefined' && chicken.pickTile) {
		// Marquer la case comme cliquée (désactiver temporairement)
		const tile = gameState.grid[index - 1];
		tile.element.classList.add('disabled');
		
		chicken.pickTile(index);
	}
}

// Retirer les gains
function cashOut() {
	if (!gameState.isPlaying) return;
	
	if (typeof chicken !== 'undefined' && chicken.cashOut) {
		chicken.cashOut();
	}
}

// Mettre à jour l'état du jeu (appelé par le serveur)
function updateGameState(state) {
	if (!state || !state.grid) return;
	
	gameState.revealedCount = state.revealedCount || 0;
	gameState.currentMultiplier = state.currentMultiplier || 1;
	gameState.potentialWin = state.potentialWin || 0;
	
	// Mettre à jour la grille
	state.grid.forEach((tile, index) => {
		const localTile = gameState.grid[index];
		if (!localTile) return;
		
		if (tile.revealed && !localTile.revealed) {
			localTile.revealed = true;
			localTile.hasBone = tile.hasBone;
			localTile.element.classList.add('revealed');
			localTile.element.classList.remove('disabled');
			
			if (tile.hasBone) {
				localTile.element.classList.add('bone');
				localTile.element.textContent = '🦴';
			} else {
				localTile.element.classList.add('safe');
				localTile.element.textContent = '🐔';
			}
		}
	});
	
	updateDisplay();
}

// Résultat de la partie (appelé par le serveur)
function gameResult(status, message, amount) {
	showNotification(message, status);
	
	if (status === 'lose' || status === 'cashout' || status === 'perfect' || status === 'refund') {
		gameState.isPlaying = false;
		updateButtonStates();
	}
}

// Mettre à jour le solde (appelé par le serveur)
function updateBalance(balance) {
	gameState.balance = balance;
	updateDisplay();
}

// Mettre à jour l'affichage
function updateDisplay() {
	document.getElementById('balance').textContent = formatNumber(gameState.balance);
	document.getElementById('revealedCount').textContent = gameState.revealedCount;
	document.getElementById('multiplier').textContent = 'x' + gameState.currentMultiplier.toFixed(2);
	document.getElementById('potentialWin').textContent = formatNumber(gameState.potentialWin) + ' 💎';
}

// Mettre à jour les boutons
function updateButtonStates() {
	const startBtn = document.getElementById('startBtn');
	const cashOutBtn = document.getElementById('cashOutBtn');
	const betInput = document.getElementById('betAmount');
	const diffButtons = document.querySelectorAll('.difficulty-btn');
	
	if (gameState.isPlaying) {
		startBtn.style.display = 'none';
		cashOutBtn.style.display = 'block';
		betInput.disabled = true;
		diffButtons.forEach(btn => btn.style.pointerEvents = 'none');
	} else {
		startBtn.style.display = 'block';
		cashOutBtn.style.display = 'none';
		betInput.disabled = false;
		diffButtons.forEach(btn => btn.style.pointerEvents = 'auto');
	}
}

// Afficher une notification
function showNotification(message, type = 'info') {
	const notification = document.getElementById('notification');
	notification.textContent = message;
	notification.className = 'notification show ' + type;
	
	setTimeout(() => {
		notification.classList.remove('show');
	}, 4000);
}

// Formater un nombre
function formatNumber(num) {
	return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

// Exposer les fonctions pour Lua
window.updateGameState = updateGameState;
window.gameResult = gameResult;
window.updateBalance = updateBalance;
