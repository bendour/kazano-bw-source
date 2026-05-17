// Machine à Sous Classique 5x5 JavaScript

// État du jeu
let gameState = {
	balance: 0,
	bet: 10,
	isSpinning: false,
	spinsCount: 0,
	totalWins: 0,
	biggestWin: 0,
	currentWin: 0,
	lastSpinTime: 0,
	cooldownDuration: 1000 // 1 seconde de cooldown
};

// Symboles et leurs emojis
const SYMBOLS = {
	wild: "🦝",
	revolver: "🔫",
	chapeau: "🤠",
	horseshoe: "🐴",
	ace: "🂡",
	king: "♔",
	queen: "♕",
	jack: "🃏",
	ten: "🔟"
};

// Initialisation
function init() {
	//console.log('Slot Machine 5x5 initializing...');
	initializeReels();
	setupEventListeners();
	updateDisplay();
	
	// Demander le solde au serveur
	if (typeof slots !== 'undefined' && slots.getPlayerInfo) {
		slots.getPlayerInfo();
	}
	
	//console.log('Slot Machine 5x5 initialized!');
}

// Initialiser la grille 5x5
function initializeReels() {
	const grid = document.getElementById('reelsGrid');
	if (!grid) {
		console.error('Reels grid not found!');
		return;
	}
	
	grid.innerHTML = '';
	
	// Créer 25 cellules (5 colonnes x 5 lignes)
	for (let i = 0; i < 25; i++) {
		const cell = document.createElement('div');
		cell.className = 'reel-cell';
		cell.dataset.index = i;
		cell.textContent = '🎰';
		grid.appendChild(cell);
	}
	
	//console.log('Reels grid initialized with 25 cells (5x5)');
}

// Configuration des event listeners
function setupEventListeners() {
	// Bouton retour
	const backBtn = document.getElementById('backBtn');
	if (backBtn) {
		backBtn.addEventListener('click', () => {
			if (typeof slots !== 'undefined' && slots.returnToMenu) {
				slots.returnToMenu();
			}
		});
	}
	
	// Bouton spin
	const spinBtn = document.getElementById('spinBtn');
	if (spinBtn) {
		spinBtn.addEventListener('click', startSpin);
	}
	
	// Contrôles de mise
	const decreaseBtn = document.getElementById('decreaseBet');
	const increaseBtn = document.getElementById('increaseBet');
	const betInput = document.getElementById('betInput');
	
	if (decreaseBtn) {
		decreaseBtn.addEventListener('click', () => {
			const current = parseInt(betInput.value) || 1;
			betInput.value = Math.max(1, current - 10);
			gameState.bet = parseInt(betInput.value);
		});
	}
	
	if (increaseBtn) {
		increaseBtn.addEventListener('click', () => {
			const current = parseInt(betInput.value) || 1;
			betInput.value = Math.min(10000, current + 10);
			gameState.bet = parseInt(betInput.value);
		});
	}
	
	if (betInput) {
		betInput.addEventListener('change', (e) => {
			let value = parseInt(e.target.value) || 1;
			value = Math.max(1, Math.min(10000, value));
			e.target.value = value;
			gameState.bet = value;
		});
	}
	
	// Boutons de mise rapide
	const quickBets = document.querySelectorAll('.quick-bets .btn[data-bet]');
	quickBets.forEach(btn => {
		btn.addEventListener('click', () => {
			const bet = parseInt(btn.dataset.bet);
			betInput.value = bet;
			gameState.bet = bet;
		});
	});
	
	// Bouton MAX
	const maxBetBtn = document.getElementById('maxBet');
	if (maxBetBtn) {
		maxBetBtn.addEventListener('click', () => {
			const maxBet = Math.min(10000, gameState.balance);
			betInput.value = maxBet;
			gameState.bet = maxBet;
		});
	}
}

// Lancer un spin
function startSpin() {
	// Vérifier le cooldown
	const now = Date.now();
	const timeSinceLastSpin = now - gameState.lastSpinTime;
	
	if (timeSinceLastSpin < gameState.cooldownDuration) {
		const remainingTime = Math.ceil((gameState.cooldownDuration - timeSinceLastSpin) / 1000);
		showNotification(`Veuillez attendre ${remainingTime}s avant de relancer`, 'error');
		return;
	}
	
	if (gameState.isSpinning) return;
	
	const bet = parseInt(document.getElementById('betInput').value) || 0;
	
	// Validations
	if (bet < 1 || bet > 10000) {
		showNotification('Mise invalide (1-10000💎)', 'error');
		return;
	}
	
	if (bet > gameState.balance) {
		showNotification('Solde insuffisant', 'error');
		return;
	}
	
	gameState.isSpinning = true;
	gameState.bet = bet;
	gameState.lastSpinTime = now;
	
	// Désactiver le bouton
	const spinBtn = document.getElementById('spinBtn');
	spinBtn.disabled = true;
	spinBtn.classList.add('spinning');
	
	// Animation de spin
	animateSpin();
	
	// Appeler Lua
	if (typeof slots !== 'undefined' && slots.spin) {
		slots.spin(bet);
	}
}

// Animation de spin
function animateSpin() {
	const cells = document.querySelectorAll('.reel-cell');
	cells.forEach(cell => cell.classList.add('spinning'));
	
	// Symboles aléatoires pendant le spin
	const spinInterval = setInterval(() => {
		cells.forEach(cell => {
			const symbolKeys = Object.keys(SYMBOLS);
			const randomSymbol = symbolKeys[Math.floor(Math.random() * symbolKeys.length)];
			cell.textContent = SYMBOLS[randomSymbol];
		});
	}, 50);
	
	// Stocker l'intervalle pour l'arrêter plus tard
	gameState.spinInterval = spinInterval;
}

// Recevoir le résultat du spin
function receiveSpinResult(result) {
	//console.log('Spin result received:', result);
	
	// Arrêter l'animation
	if (gameState.spinInterval) {
		clearInterval(gameState.spinInterval);
	}
	
	// Attendre un peu avant d'afficher le résultat
	setTimeout(() => {
		displayResult(result);
	}, 500);
}

// Afficher le résultat
function displayResult(result) {
	const cells = document.querySelectorAll('.reel-cell');
	const grid = result.grid;
	
	//console.log('Grid received:', grid);
	
	// Afficher la grille finale 5x5
	let index = 0;
	for (let row = 1; row <= 5; row++) {
		for (let col = 1; col <= 5; col++) {
			const rowKey = 'row' + row;
			const colKey = 'col' + col;
			
			// Vérifier que la ligne et la colonne existent
			if (grid && grid[rowKey] && grid[rowKey][colKey]) {
				const symbolId = grid[rowKey][colKey];
				const emoji = SYMBOLS[symbolId] || '❓';
				cells[index].textContent = emoji;
			} else {
				console.error('Grid cell not found:', rowKey, colKey);
				cells[index].textContent = '❓';
			}
			cells[index].classList.remove('spinning');
			index++;
		}
	}
	
	// Mettre à jour les stats
	gameState.spinsCount++;
	gameState.currentWin = result.totalWin;
	gameState.totalWins += result.totalWin;
	
	if (result.totalWin > gameState.biggestWin) {
		gameState.biggestWin = result.totalWin;
	}
	
	updateDisplay();
	
	// Afficher les animations de gain
	if (result.totalWin > 0) {
		setTimeout(() => {
			animateWin(result);
		}, 300);
	} else {
		finishSpin();
	}
}

// Animation de gain
function animateWin(result) {
	// Activer l'overlay
	const overlay = document.getElementById('winOverlay');
	overlay.classList.add('active');
	
	// Animer les cellules gagnantes
	if (result.winningLines && result.winningLines.length > 0) {
		result.winningLines.forEach((line, i) => {
			setTimeout(() => {
				highlightWinningLine(line);
			}, i * 500);
		});
	}
	
	// Notification de gain
	let multiplier = result.totalWin / result.bet;
	let message = `Gain: ${result.totalWin}💎`;
	
	if (multiplier >= 100) {
		message = `🎉 ÉNORME GAIN! ${result.totalWin}💎 (${multiplier.toFixed(0)}x)`;
	} else if (multiplier >= 50) {
		message = `✨ GROS GAIN! ${result.totalWin}💎 (${multiplier.toFixed(0)}x)`;
	} else if (multiplier >= 20) {
		message = `🌟 Super gain! ${result.totalWin}💎 (${multiplier.toFixed(1)}x)`;
	}
	
	setTimeout(() => {
		showNotification(message, 'win');
		overlay.classList.remove('active');
		finishSpin();
	}, result.winningLines.length * 500 + 1000);
}

// Surligner une ligne gagnante
function highlightWinningLine(lineData) {
	const cells = document.querySelectorAll('.reel-cell');
	const positions = lineData.positions;
	
	if (!positions) return;
	
	// Surligner les cellules de cette ligne (seulement les symboles gagnants)
	for (let col = 0; col < lineData.count; col++) {
		const row = positions[col];
		// Index dans la grille 5x5: (row-1) * 5 + col
		const index = (row - 1) * 5 + col;
		
		if (cells[index]) {
			cells[index].classList.add('winning');
			setTimeout(() => {
				cells[index].classList.remove('winning');
			}, 1500);
		}
	}
}

// Terminer le spin
function finishSpin() {
	gameState.isSpinning = false;
	
	const spinBtn = document.getElementById('spinBtn');
	
	// Vérifier si le cooldown est toujours actif
	const now = Date.now();
	const timeSinceLastSpin = now - gameState.lastSpinTime;
	const remainingCooldown = gameState.cooldownDuration - timeSinceLastSpin;
	
	if (remainingCooldown > 0) {
		// Garder le bouton désactivé pendant le cooldown restant
		spinBtn.disabled = true;
		spinBtn.textContent = `Cooldown (${Math.ceil(remainingCooldown / 1000)}s)`;
		
		setTimeout(() => {
			spinBtn.disabled = false;
			spinBtn.classList.remove('spinning');
			spinBtn.textContent = '🎰 SPIN';
		}, remainingCooldown);
	} else {
		// Cooldown déjà terminé
		spinBtn.disabled = false;
		spinBtn.classList.remove('spinning');
		spinBtn.textContent = '🎰 SPIN';
	}
	
	// Réinitialiser l'affichage de gain après 3 secondes
	setTimeout(() => {
		gameState.currentWin = 0;
		updateDisplay();
	}, 3000);
}

// Mettre à jour l'affichage
function updateDisplay() {
	document.getElementById('balance').textContent = gameState.balance.toLocaleString();
	document.getElementById('winAmount').textContent = gameState.currentWin.toLocaleString() + '💎';
	document.getElementById('spinsCount').textContent = gameState.spinsCount;
	document.getElementById('totalWins').textContent = gameState.totalWins.toLocaleString() + '💎';
	document.getElementById('biggestWin').textContent = gameState.biggestWin.toLocaleString() + '💎';
}

// Mettre à jour les infos du joueur
function updatePlayerInfo(balance) {
	gameState.balance = balance;
	updateDisplay();
}

// Notification
function showNotification(text, type) {
	const notif = document.getElementById('notification');
	notif.textContent = text;
	notif.className = 'notification show ' + type;
	
	setTimeout(() => {
		notif.className = 'notification ' + type;
	}, 4000);
}

// Exposer les fonctions pour Lua
window.updatePlayerInfo = updatePlayerInfo;
window.receiveSpinResult = receiveSpinResult;
window.showNotification = showNotification;

// Initialisation
document.addEventListener('DOMContentLoaded', init);

// Fallback
setTimeout(function() {
	const grid = document.getElementById('reelsGrid');
	if (grid && grid.children.length === 0) {
		//console.log('Fallback initialization triggered');
		init();
	}
}, 100);

