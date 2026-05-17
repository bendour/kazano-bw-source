// Roulette Européenne JavaScript

// État du jeu
let gameState = {
	balance: 0,
	currentBets: [],
	totalBet: 0,
	timeRemaining: 15,
	isSpinning: false,
	history: [],
	wheelRotation: 0,
	ballAngle: 0,
	animationFrame: null,
	lastBetTime: 0,
	betCooldown: 200 // 0.2 seconde de cooldown entre les paris
};

// Limites de paris (synchronisé avec le serveur)
const MAX_BETS_PER_PLAYER = 20;
const MAX_TOTAL_BET_PER_PLAYER = 50000;

// Configuration des numéros de la roulette (ordre européen)
const ROULETTE_LAYOUT = [
	{num: 0, color: 'green'},
	{num: 32, color: 'red'}, {num: 15, color: 'black'}, {num: 19, color: 'red'},
	{num: 4, color: 'black'}, {num: 21, color: 'red'}, {num: 2, color: 'black'},
	{num: 25, color: 'red'}, {num: 17, color: 'black'}, {num: 34, color: 'red'},
	{num: 6, color: 'black'}, {num: 27, color: 'red'}, {num: 13, color: 'black'},
	{num: 36, color: 'red'}, {num: 11, color: 'black'}, {num: 30, color: 'red'},
	{num: 8, color: 'black'}, {num: 23, color: 'red'}, {num: 10, color: 'black'},
	{num: 5, color: 'red'}, {num: 24, color: 'black'}, {num: 16, color: 'red'},
	{num: 33, color: 'black'}, {num: 1, color: 'red'}, {num: 20, color: 'black'},
	{num: 14, color: 'red'}, {num: 31, color: 'black'}, {num: 9, color: 'red'},
	{num: 22, color: 'black'}, {num: 18, color: 'red'}, {num: 29, color: 'black'},
	{num: 7, color: 'red'}, {num: 28, color: 'black'}, {num: 12, color: 'red'},
	{num: 35, color: 'black'}, {num: 3, color: 'red'}, {num: 26, color: 'black'}
];

// Noms des types de paris
const BET_NAMES = {
	straight: 'Numéro',
	red: 'Rouge',
	black: 'Noir',
	even: 'Pair',
	odd: 'Impair',
	low: '1-18',
	high: '19-36',
	dozen1: '1ère Douzaine',
	dozen2: '2ème Douzaine',
	dozen3: '3ème Douzaine',
	column1: '1ère Colonne',
	column2: '2ème Colonne',
	column3: '3ème Colonne'
};

// Canvas pour la roue
let canvas, ctx;

// Initialisation
function init() {
	canvas = document.getElementById('rouletteCanvas');
	if (canvas) {
		ctx = canvas.getContext('2d');
		drawRouletteWheel();
	}
	
	generateNumbersGrid();
	setupEventListeners();
	updateDisplay();
	
	// Demander le solde au serveur
	if (typeof roulette !== 'undefined' && roulette.getPlayerInfo) {
		roulette.getPlayerInfo();
	}
}

// Dessiner la roue de roulette avec les numéros
function drawRouletteWheel() {
	drawRouletteWheelStatic();
}

// Dessiner la roue (version statique, rotation gérée par transform CSS)
function drawRouletteWheelStatic() {
	if (!canvas || !ctx) return;
	
	const centerX = canvas.width / 2;
	const centerY = canvas.height / 2;
	const radius = canvas.width / 2;
	const innerRadius = 60; // Rayon du centre
	
	const segmentAngle = (Math.PI * 2) / ROULETTE_LAYOUT.length;
	
	// Effacer le canvas
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	
	// Dessiner chaque segment
	ROULETTE_LAYOUT.forEach((segment, index) => {
		const startAngle = index * segmentAngle - Math.PI / 2;
		const endAngle = startAngle + segmentAngle;
		
		// Couleur du segment
		ctx.fillStyle = segment.color === 'green' ? '#4CAF50' : 
		                segment.color === 'red' ? '#ff0000' : '#000000';
		
		// Dessiner le segment
		ctx.beginPath();
		ctx.arc(centerX, centerY, radius, startAngle, endAngle);
		ctx.arc(centerX, centerY, innerRadius, endAngle, startAngle, true);
		ctx.closePath();
		ctx.fill();
		
		// Bordure dorée entre les segments
		ctx.strokeStyle = '#FFD700';
		ctx.lineWidth = 2;
		ctx.stroke();
		
		// Dessiner le numéro
		const textAngle = startAngle + segmentAngle / 2;
		const textRadius = radius - 25;
		const textX = centerX + Math.cos(textAngle) * textRadius;
		const textY = centerY + Math.sin(textAngle) * textRadius;
		
		ctx.save();
		ctx.translate(textX, textY);
		ctx.rotate(textAngle + Math.PI / 2);
		ctx.fillStyle = 'white';
		ctx.font = 'bold 14px Arial';
		ctx.textAlign = 'center';
		ctx.textBaseline = 'middle';
		ctx.fillText(segment.num.toString(), 0, 0);
		ctx.restore();
	});
}

// Générer la grille de numéros
function generateNumbersGrid() {
	const grid = document.getElementById('numbersGrid');
	if (!grid) return;
	
	// Garder le zéro qui est déjà dans le HTML
	// Ajouter les numéros 1-36 en grille 3x12
	for (let i = 1; i <= 36; i++) {
		const numData = ROULETTE_LAYOUT.find(n => n.num === i);
		const btn = document.createElement('button');
		btn.className = `bet-btn number-cell bet-${numData.color}`;
		btn.dataset.type = 'straight';
		btn.dataset.value = i;
		btn.textContent = i;
		grid.appendChild(btn);
	}
}

// Configuration des event listeners
function setupEventListeners() {
	// Bouton retour
	const backBtn = document.getElementById('backBtn');
	if (backBtn) {
		backBtn.addEventListener('click', () => {
			if (typeof roulette !== 'undefined' && roulette.returnToMenu) {
				roulette.returnToMenu();
			}
		});
	}
	
	// Contrôles de mise
	const decreaseBtn = document.getElementById('decreaseBet');
	const increaseBtn = document.getElementById('increaseBet');
	const betAmount = document.getElementById('betAmount');
	
	if (decreaseBtn) {
		decreaseBtn.addEventListener('click', () => {
			const current = parseInt(betAmount.value) || 1;
			betAmount.value = Math.max(1, current - 10);
		});
	}
	
	if (increaseBtn) {
		increaseBtn.addEventListener('click', () => {
			const current = parseInt(betAmount.value) || 1;
			betAmount.value = Math.min(10000, current + 10);
		});
	}
	
	if (betAmount) {
		betAmount.addEventListener('change', (e) => {
			let value = parseInt(e.target.value) || 1;
			value = Math.max(1, Math.min(10000, value));
			e.target.value = value;
		});
	}
	
	// Boutons de mise rapide
	const quickBets = document.querySelectorAll('.quick-bets .btn[data-amount]');
	quickBets.forEach(btn => {
		btn.addEventListener('click', () => {
			const amount = parseInt(btn.dataset.amount);
			betAmount.value = amount;
		});
	});
	
	// Boutons de paris
	document.addEventListener('click', (e) => {
		const betBtn = e.target.closest('.bet-btn');
		if (betBtn && betBtn.dataset.type) {
			placeBet(betBtn.dataset.type, betBtn.dataset.value);
		}
	});
	
	// Bouton supprimer tous les paris
	const clearAllBtn = document.getElementById('clearAllBets');
	if (clearAllBtn) {
		clearAllBtn.addEventListener('click', clearAllBets);
	}
}

// Placer un pari
function placeBet(betType, betValue) {
	// Vérifier le cooldown
	const now = Date.now();
	if (now - gameState.lastBetTime < gameState.betCooldown) {
		return; // Silencieusement ignorer les paris trop rapides
	}
	
	if (gameState.isSpinning) {
		showNotification('Le spin est en cours, attendez le prochain tour', 'error');
		return;
	}
	
	const amount = parseInt(document.getElementById('betAmount').value) || 0;
	
	if (amount < 1 || amount > 10000) {
		showNotification('Mise invalide (1-10000💎)', 'error');
		return;
	}
	
	if (amount > gameState.balance) {
		showNotification('Solde insuffisant', 'error');
		return;
	}
	
	// SÉCURITÉ: Vérifier le nombre de paris
	if (gameState.currentBets.length >= MAX_BETS_PER_PLAYER) {
		showNotification(`Maximum ${MAX_BETS_PER_PLAYER} paris par tour`, 'error');
		return;
	}
	
	// SÉCURITÉ: Vérifier la mise totale
	if (gameState.totalBet + amount > MAX_TOTAL_BET_PER_PLAYER) {
		showNotification(`Mise totale maximum: ${MAX_TOTAL_BET_PER_PLAYER}💎 par tour`, 'error');
		return;
	}
	
	// Mettre à jour le timestamp
	gameState.lastBetTime = now;
	
	// Ajouter le pari localement
	const betId = Date.now() + Math.random(); // ID unique pour le pari
	gameState.currentBets.push({
		id: betId,
		type: betType,
		value: betValue,
		amount: amount
	});
	gameState.totalBet += amount;
	
	// Envoyer au serveur
	if (typeof roulette !== 'undefined' && roulette.placeBet) {
		roulette.placeBet(betType, betValue, amount);
	}
	
	// Ajouter l'indicateur visuel sur le bouton
	addVisualChip(betType, betValue, amount);
	
	updateActiveBets();
}

// Ajouter un jeton visuel sur le bouton de pari
function addVisualChip(betType, betValue, amount) {
	// Trouver le bouton correspondant
	const selector = `[data-type="${betType}"]${betValue ? `[data-value="${betValue}"]` : ''}`;
	const button = document.querySelector(selector);
	
	if (!button) return;
	
	// Vérifier si un jeton existe déjà
	let chip = button.querySelector('.bet-chip');
	
	if (chip) {
		// Mettre à jour le montant existant
		const oldAmount = parseInt(chip.textContent.replace('💎', '')) || 0;
		const newAmount = oldAmount + amount;
		chip.textContent = newAmount + '💎';
	} else {
		// Créer un nouveau jeton
		chip = document.createElement('div');
		chip.className = 'bet-chip';
		chip.textContent = amount + '💎';
		button.appendChild(chip);
	}
}

// Supprimer un pari spécifique
function removeBet(betId) {
	const betIndex = gameState.currentBets.findIndex(bet => bet.id === betId);
	if (betIndex === -1) return;
	
	const bet = gameState.currentBets[betIndex];
	gameState.totalBet -= bet.amount;
	gameState.currentBets.splice(betIndex, 1);
	
	// Mettre à jour le jeton visuel
	updateVisualChip(bet.type, bet.value);
	
	// Informer le serveur
	if (typeof roulette !== 'undefined' && roulette.removeBet) {
		roulette.removeBet(bet.type, bet.value, bet.amount);
	}
	
	updateActiveBets();
}

// Supprimer tous les paris
function clearAllBets() {
	if (gameState.isSpinning) {
		showNotification('Impossible de supprimer les paris pendant le spin', 'error');
		return;
	}
	
	// Supprimer tous les jetons visuels
	document.querySelectorAll('.bet-chip').forEach(chip => chip.remove());
	
	// Réinitialiser l'état
	gameState.currentBets = [];
	gameState.totalBet = 0;
	
	// Informer le serveur
	if (typeof roulette !== 'undefined' && roulette.clearAllBets) {
		roulette.clearAllBets();
	}
	
	updateActiveBets();
	showNotification('Tous les paris ont été supprimés', 'success');
}

// Mettre à jour le jeton visuel après suppression
function updateVisualChip(betType, betValue) {
	const selector = `[data-type="${betType}"]${betValue ? `[data-value="${betValue}"]` : ''}`;
	const button = document.querySelector(selector);
	
	if (!button) return;
	
	// Calculer le montant total restant pour ce type de pari
	const remainingAmount = gameState.currentBets
		.filter(bet => bet.type === betType && bet.value === betValue)
		.reduce((sum, bet) => sum + bet.amount, 0);
	
	// Supprimer l'ancien jeton
	const oldChip = button.querySelector('.bet-chip');
	if (oldChip) oldChip.remove();
	
	// Ajouter le nouveau si montant > 0
	if (remainingAmount > 0) {
		const chip = document.createElement('div');
		chip.className = 'bet-chip';
		chip.textContent = remainingAmount + '💎';
		button.appendChild(chip);
	}
}

// Mettre à jour l'affichage des paris actifs
function updateActiveBets() {
	const list = document.getElementById('activeBetsList');
	const totalBet = document.getElementById('totalBet');
	
	if (gameState.currentBets.length === 0) {
		list.innerHTML = '<p class="no-bets">Aucun pari placé</p>';
	} else {
		list.innerHTML = '';
		gameState.currentBets.forEach((bet, index) => {
			const item = document.createElement('div');
			item.className = 'bet-item';
			
			let betName = BET_NAMES[bet.type] || bet.type;
			if (bet.type === 'straight') {
				betName += ' ' + bet.value;
			}
			
			const info = document.createElement('div');
			info.className = 'bet-item-info';
			info.innerHTML = `
				<span class="bet-item-name">${betName}</span>
				<span class="bet-item-amount">${bet.amount}💎</span>
			`;
			
			const removeBtn = document.createElement('button');
			removeBtn.className = 'bet-item-remove';
			removeBtn.textContent = '✕';
			removeBtn.onclick = () => removeBet(bet.id);
			
			item.appendChild(info);
			item.appendChild(removeBtn);
			list.appendChild(item);
		});
	}
	
	totalBet.textContent = gameState.totalBet + '💎';
}

// Démarrer un spin (appelé par le serveur)
function startSpin(winningNumber, winningColor) {
	gameState.isSpinning = true;
	
	// Cacher le numéro gagnant précédent au début du spin
	const winningNumberDisplay = document.getElementById('winningNumber');
	winningNumberDisplay.textContent = '';
	winningNumberDisplay.style.display = 'none';
	
	// Mettre à jour le statut
	document.getElementById('timerStatus').textContent = 'La roue tourne...';
	document.getElementById('timerValue').classList.add('spinning');
	
	// Trouver l'index du numéro gagnant dans le layout
	const winningIndex = ROULETTE_LAYOUT.findIndex(seg => seg.num === parseInt(winningNumber));
	if (winningIndex === -1) {
		return;
	}
	
	// Calculer l'angle pour que le numéro gagnant soit sous la flèche (en haut)
	const segmentAngle = 360 / ROULETTE_LAYOUT.length; // ~9.73 degrés par segment
	
	// Le canvas dessine le segment à l'index 0 en haut (à -90° = 270° = en haut)
	// Pour mettre un autre segment en haut, il faut tourner de -(index * segmentAngle)
	// MAIS on ajoute un demi-segment pour centrer exactement sur le numéro
	const targetAngle = -(winningIndex * segmentAngle) - (segmentAngle / 2);
	
	// Animation parameters
	const duration = 6000; // 6 secondes
	const startTime = Date.now();
	const startRotation = gameState.wheelRotation;
	
	// Calculer la rotation totale : 5 tours complets (1800°) + angle pour atteindre le numéro
	let finalRotation = 1800 + targetAngle;
	
	// S'assurer que la rotation finale est dans une plage raisonnable par rapport au départ
	// et qu'on fait bien au moins 5 tours
	while (finalRotation - startRotation < 1800) {
		finalRotation += 360;
	}
	while (finalRotation - startRotation > 2160) { // Max 6 tours
		finalRotation -= 360;
	}
	
	const totalRotation = finalRotation - startRotation;
	const wheel = document.getElementById('rouletteWheel');
	const wheelCenter = document.querySelector('.wheel-center');
	
	// Animation loop
	function animate() {
		const elapsed = Date.now() - startTime;
		const progress = Math.min(elapsed / duration, 1);
		
		// Easing function (décélération progressive) - effet de friction réaliste
		const eased = 1 - Math.pow(1 - progress, 3);
		
		// Calculer la rotation actuelle
		const currentRotation = startRotation + (totalRotation * eased);
		gameState.wheelRotation = currentRotation;
		
		// Appliquer la rotation à la roue (CSS seulement, pas le canvas)
		if (wheel) {
			wheel.style.transform = `rotate(${currentRotation}deg)`;
		}
		
		// Appliquer une contre-rotation au centre pour qu'il reste droit
		if (wheelCenter) {
			wheelCenter.style.transform = `translate(-50%, -50%) rotate(${-currentRotation}deg)`;
		}
		
		// Continuer l'animation si pas terminée
		if (progress < 1) {
			gameState.animationFrame = requestAnimationFrame(animate);
		} else {
			// Animation terminée - afficher le numéro gagnant (droit, sans rotation)
			const winningNumberDisplay = document.getElementById('winningNumber');
			winningNumberDisplay.textContent = winningNumber;
			winningNumberDisplay.style.display = 'flex';
			
			// Normaliser la rotation finale pour les prochains spins
			gameState.wheelRotation = finalRotation % 360;
			
			// Appliquer la contre-rotation finale au centre
			if (wheelCenter) {
				wheelCenter.style.transform = `translate(-50%, -50%) rotate(${-gameState.wheelRotation}deg)`;
			}
			
			// Vérification : calculer quel numéro devrait être sous la flèche
			const normalizedRotation = gameState.wheelRotation % 360;
			const adjustedRotation = (normalizedRotation + (segmentAngle / 2)) % 360;
			const segmentUnderArrow = Math.floor(adjustedRotation / segmentAngle) % ROULETTE_LAYOUT.length;
			const numberUnderArrow = ROULETTE_LAYOUT[segmentUnderArrow].num;
		}
	}
	
	// Démarrer l'animation
	if (gameState.animationFrame) {
		cancelAnimationFrame(gameState.animationFrame);
	}
	animate();
}

// Recevoir le résultat du spin (appelé par le serveur)
function receiveSpinResult(result) {
	gameState.isSpinning = false;
	
	// Mettre à jour le dernier résultat
	const lastResult = document.getElementById('lastResult');
	lastResult.innerHTML = `<span class="number-value">${result.winningNumber}</span>`;
	lastResult.className = `result-number ${result.winningColor}`;
	
	// Ajouter à l'historique
	gameState.history.unshift({num: result.winningNumber, color: result.winningColor});
	if (gameState.history.length > 15) {
		gameState.history.pop();
	}
	updateHistory();
	
	// Afficher le résultat
	if (result.totalWin > 0) {
		showNotification(`🎉 Vous avez gagné ${result.totalWin}💎!`, 'win');
	} else if (gameState.totalBet > 0) {
		showNotification(`Perdu! Numéro: ${result.winningNumber} (${result.winningColor})`, 'lose');
	}
	
	// Supprimer tous les jetons visuels
	document.querySelectorAll('.bet-chip').forEach(chip => {
		chip.remove();
	});
	
	// Réinitialiser les paris
	gameState.currentBets = [];
	gameState.totalBet = 0;
	updateActiveBets();
	
	// Mettre à jour le statut
	document.getElementById('timerStatus').textContent = 'Placez vos paris!';
	document.getElementById('timerValue').classList.remove('spinning');
}

// Mettre à jour l'historique
function updateHistory() {
	const historyDiv = document.getElementById('historyNumbers');
	historyDiv.innerHTML = '';
	
	gameState.history.forEach(item => {
		const numDiv = document.createElement('div');
		numDiv.className = `history-number ${item.color}`;
		numDiv.textContent = item.num;
		historyDiv.appendChild(numDiv);
	});
}

// Mettre à jour le timer (appelé par le serveur chaque seconde)
function updateTimer(timeRemaining, isSpinning) {
	gameState.timeRemaining = timeRemaining;
	gameState.isSpinning = isSpinning;
	
	const timerValue = document.getElementById('timerValue');
	const timerStatus = document.getElementById('timerStatus');
	
	if (timerValue) {
		timerValue.textContent = timeRemaining;
		
		// Changer la couleur en fonction du temps
		if (timeRemaining <= 5 && !isSpinning) {
			timerValue.classList.add('warning');
		} else {
			timerValue.classList.remove('warning');
		}
	}
	
	// Mettre à jour le statut si le timer reste à 15 (aucun pari)
	if (timerStatus && timeRemaining === 15 && !isSpinning && gameState.currentBets.length === 0) {
		timerStatus.textContent = 'En attente de joueurs...';
	} else if (timerStatus && !isSpinning) {
		timerStatus.textContent = 'Placez vos paris!';
	}
}

// Confirmation de pari (appelé par le serveur)
function betPlaced(status, message) {
	if (status === 'error') {
		showNotification(message, 'error');
		// Retirer le pari local en cas d'erreur serveur
		if (gameState.currentBets.length > 0) {
			const lastBet = gameState.currentBets.pop();
			gameState.totalBet -= lastBet.amount;
			
			// Retirer le jeton visuel
			updateVisualChipAfterError(lastBet.type, lastBet.value, lastBet.amount);
			
			updateActiveBets();
		}
	} else {
		// Ne pas afficher de notification pour chaque pari réussi (trop spam)
		// showNotification(message, 'success');
	}
}

// Mettre à jour le jeton visuel après une erreur serveur
function updateVisualChipAfterError(betType, betValue, amountToRemove) {
	const selector = `[data-type="${betType}"]${betValue ? `[data-value="${betValue}"]` : ''}`;
	const button = document.querySelector(selector);
	
	if (!button) return;
	
	const chip = button.querySelector('.bet-chip');
	if (!chip) return;
	
	const currentAmount = parseInt(chip.textContent.replace('💎', '')) || 0;
	const newAmount = currentAmount - amountToRemove;
	
	if (newAmount <= 0) {
		chip.remove();
	} else {
		chip.textContent = newAmount + '💎';
	}
}

// Mettre à jour les infos du joueur
function updatePlayerInfo(balance) {
	gameState.balance = balance;
	updateDisplay();
}

// Mettre à jour l'affichage
function updateDisplay() {
	document.getElementById('balance').textContent = gameState.balance.toLocaleString();
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

// Exposer les fonctions pour Lua (immédiatement, pas besoin d'attendre DOMContentLoaded)
window.updatePlayerInfo = updatePlayerInfo;
window.startSpin = startSpin;
window.receiveSpinResult = receiveSpinResult;
window.updateTimer = updateTimer;
window.betPlaced = betPlaced;
window.showNotification = showNotification;

// Initialisation
document.addEventListener('DOMContentLoaded', init);

// Fallback si DOMContentLoaded déjà passé
if (document.readyState === 'loading') {
	document.addEventListener('DOMContentLoaded', init);
} else {
	init();
}

// Fallback
setTimeout(function() {
	const grid = document.getElementById('numbersGrid');
	if (grid && grid.children.length === 1) { // Seulement le zéro
		init();
	}
}, 100);
