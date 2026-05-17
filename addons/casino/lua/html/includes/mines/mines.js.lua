// État du jeu Mines
let gameState = {
	grid: [],
	bet: 0,
	bombCount: 3,
	revealedCount: 0,
	currentMultiplier: 1.0,
	potentialWin: 0,
	playerBalance: 0,
	gameActive: false
};

// Initialisation
function init() {
	//console.log('Mines game initializing...');
	initializeGrid();
	setupEventListeners();
	updateDisplay();
	//console.log('Mines game initialized!');
}

// Lancer l'initialisation
document.addEventListener('DOMContentLoaded', init);
// Essayer aussi sans attendre DOMContentLoaded au cas où
setTimeout(function() {
	const grid = document.getElementById('grid');
	if (grid && grid.children.length === 0) {
		//console.log('Fallback initialization triggered');
		init();
	}
}, 100);

// Créer la grille 5x5
	function initializeGrid() {
		const grid = document.getElementById('grid');
		if (!grid) {
			console.error('Grid element not found!');
			return;
		}
		
		//console.log('Initializing grid...');
		grid.innerHTML = '';
		
		for (let i = 0; i < 25; i++) {
			const tile = document.createElement('div');
			tile.className = 'mine-tile disabled';
			tile.dataset.index = i;
			tile.addEventListener('click', () => handleTileClick(i));
			grid.appendChild(tile);
		}
		
		//console.log('Grid initialized with', grid.children.length, 'tiles');
	}

// Configuration des événements
function setupEventListeners() {
	// Bouton retour
	document.getElementById('backBtn').addEventListener('click', function() {
		if (typeof mines !== 'undefined' && mines.returnToMenu) {
			mines.returnToMenu();
		}
	});
	
	// Slider de bombes
	const bombSlider = document.getElementById('bombCountSlider');
	bombSlider.addEventListener('input', function() {
		const count = parseInt(this.value);
		document.getElementById('bombCountDisplay').textContent = count;
		gameState.bombCount = count;
		updateRiskLevel(count);
	});
	
	// Mises rapides
	document.querySelectorAll('.quick-bets .btn').forEach(btn => {
		btn.addEventListener('click', function() {
			document.getElementById('betInput').value = this.dataset.bet;
		});
	});
	
	// Bouton commencer
	document.getElementById('startBtn').addEventListener('click', startGame);
	
	// Bouton encaisser
	document.getElementById('cashOutBtn').addEventListener('click', cashOut);
	
	// Bouton nouvelle partie
	document.getElementById('newGameBtn').addEventListener('click', resetGame);
}

// Mettre à jour le niveau de risque
function updateRiskLevel(bombCount) {
	const riskLevel = document.getElementById('riskLevel');
	
	if (bombCount <= 3) {
		riskLevel.textContent = 'Faible';
		riskLevel.className = '';
	} else if (bombCount <= 10) {
		riskLevel.textContent = 'Moyen';
		riskLevel.className = 'medium';
	} else {
		riskLevel.textContent = 'Élevé';
		riskLevel.className = 'high';
	}
}

// Commencer une partie
function startGame() {
	const betInput = document.getElementById('betInput');
	const betAmount = parseInt(betInput.value);
	
	if (isNaN(betAmount) || betAmount < 1) {
		showNotification('Veuillez entrer un montant valide!', 'error');
		betInput.focus();
		return;
	}
	
	if (betAmount < 1 || betAmount > 10000) {
		showNotification('Mise invalide! (1💎 - 10000💎)', 'error');
		betInput.focus();
		return;
	}
	
	if (betAmount > gameState.playerBalance) {
		showNotification('Solde insuffisant!', 'error');
		betInput.focus();
		return;
	}
	
	const bombCount = parseInt(document.getElementById('bombCountSlider').value);
	
	if (typeof mines !== 'undefined' && mines.placeBet) {
		mines.placeBet(betAmount, bombCount);
	}
}

// Cliquer sur une case
function handleTileClick(index) {
	if (!gameState.gameActive) return;
	
	const tile = document.querySelector(`[data-index="${index}"]`);
	if (tile.classList.contains('revealed') || tile.classList.contains('disabled')) {
		return;
	}
	
	if (typeof mines !== 'undefined' && mines.revealTile) {
		mines.revealTile(index);
	}
}

// Encaisser les gains
function cashOut() {
	if (!gameState.gameActive) return;
	
	if (typeof mines !== 'undefined' && mines.cashOut) {
		mines.cashOut();
	}
}

// Réinitialiser pour une nouvelle partie
function resetGame() {
	gameState.gameActive = false;
	gameState.revealedCount = 0;
	gameState.currentMultiplier = 1.0;
	gameState.potentialWin = 0;
	
	// Réinitialiser la grille
	document.querySelectorAll('.mine-tile').forEach(tile => {
		tile.className = 'mine-tile disabled';
		tile.textContent = '';
	});
	
	// Afficher le panneau de config, cacher les boutons
	document.getElementById('configPanel').style.display = 'block';
	document.getElementById('cashOutBtn').style.display = 'none';
	document.getElementById('newGameBtn').style.display = 'none';
	
	updateDisplay();
}

// Recevoir l'état du jeu depuis le serveur
function receiveGameState(state) {
	gameState.grid = state.grid;
	gameState.bet = state.bet;
	gameState.bombCount = state.bombCount;
	gameState.revealedCount = state.revealedCount;
	gameState.currentMultiplier = state.currentMultiplier;
	gameState.potentialWin = state.potentialWin;
	gameState.gameActive = true;
	
	// Masquer le panneau de config
	document.getElementById('configPanel').style.display = 'none';
	
	// Activer la grille
	document.querySelectorAll('.mine-tile').forEach(tile => {
		tile.classList.remove('disabled');
	});
	
	// Mettre à jour l'affichage de la grille
	state.grid.forEach((tile, index) => {
		// Les data-index et les indices du tableau state.grid correspondent tous deux de 0 à 24
		const tileElement = document.querySelector(`[data-index="${index}"]`);
		
		if (!tileElement) {
			console.error('Tile not found for index:', index);
			return;
		}
		
		if (tile.revealed) {
			tileElement.classList.add('revealed');
			tileElement.classList.remove('disabled');
			
			if (tile.isBomb) {
				tileElement.classList.add('bomb');
				tileElement.textContent = '💣';
			} else {
				tileElement.classList.add('safe');
				tileElement.textContent = '💎';
			}
		}
	});
	
	// Afficher le bouton encaisser si au moins une case révélée
	if (gameState.revealedCount > 0 && gameState.gameActive) {
		document.getElementById('cashOutBtn').style.display = 'inline-block';
	}
	
	updateDisplay();
}

// Afficher le résultat final
function showGameResult(result, message, winAmount) {
	gameState.gameActive = false;
	
	let notifType = result;
	let notifMessage = message;
	
	if (result === 'win') {
		notifMessage = `✓ ${message} +${winAmount}💎`;
	} else if (result === 'lose') {
		notifMessage = `✗ ${message}`;
	} else if (result === 'push') {
		notifMessage = `↔ ${message}`;
	}
	
	showNotification(notifMessage, notifType);
	
	// Désactiver toutes les cases
	document.querySelectorAll('.mine-tile').forEach(tile => {
		tile.classList.add('disabled');
	});
	
	// Cacher le bouton encaisser, afficher nouvelle partie
	document.getElementById('cashOutBtn').style.display = 'none';
	
	setTimeout(() => {
		document.getElementById('newGameBtn').style.display = 'inline-block';
	}, 2000);
}

// Mettre à jour l'affichage
function updateDisplay() {
	document.getElementById('balance').textContent = gameState.playerBalance.toLocaleString();
	document.getElementById('revealedCount').textContent = gameState.revealedCount;
	document.getElementById('multiplier').textContent = gameState.currentMultiplier.toFixed(2) + 'x';
	document.getElementById('potentialWin').textContent = gameState.potentialWin.toLocaleString() + '💎';
}

// Mettre à jour les infos du joueur
function updatePlayerInfo(balance) {
	gameState.playerBalance = balance;
	updateDisplay();
}

// Notification minimaliste
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
window.receiveGameState = receiveGameState;
window.showGameResult = showGameResult;
