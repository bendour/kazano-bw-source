// JavaScript pour le menu principal du casino

// État de l'application
const appState = {
	balance: 0,
	currentSection: 'games',
	settings: {
		sound: true,
		animations: true,
		notifications: true
	},
	stats: {
		totalWins: 0,
		totalGames: 0,
		winRate: 0,
		biggestWin: 0
	},
	history: []
};

// Initialisation
document.addEventListener('DOMContentLoaded', function() {
	initNavigation();
	initSettings();
	initGameCards();
	loadPlayerData();
	
	// Bouton fermer
	document.getElementById('closeBtn').addEventListener('click', closeMenu);
});

// Navigation entre les sections
function initNavigation() {
	const navItems = document.querySelectorAll('.nav-item');
	
	navItems.forEach(item => {
		item.addEventListener('click', function() {
			const section = this.dataset.section;
			switchSection(section);
		});
	});
}

function switchSection(sectionName) {
	// Mettre à jour la navigation
	document.querySelectorAll('.nav-item').forEach(item => {
		item.classList.remove('active');
	});
	document.querySelector(`[data-section="${sectionName}"]`).classList.add('active');
	
	// Mettre à jour le contenu
	document.querySelectorAll('.content-section').forEach(section => {
		section.classList.remove('active');
	});
	document.getElementById(`${sectionName}-section`).classList.add('active');
	
	appState.currentSection = sectionName;
}

// Initialisation des paramètres
function initSettings() {
	const soundToggle = document.getElementById('soundToggle');
	const animToggle = document.getElementById('animToggle');
	const notifToggle = document.getElementById('notifToggle');
	
	soundToggle.addEventListener('change', function() {
		appState.settings.sound = this.checked;
		saveSetting('sound', this.checked);
		showToast(this.checked ? 'Sons activés' : 'Sons désactivés', 'success');
	});
	
	animToggle.addEventListener('change', function() {
		appState.settings.animations = this.checked;
		saveSetting('animations', this.checked);
		document.body.classList.toggle('no-animations', !this.checked);
		showToast(this.checked ? 'Animations activées' : 'Animations désactivées', 'success');
	});
	
	notifToggle.addEventListener('change', function() {
		appState.settings.notifications = this.checked;
		saveSetting('notifications', this.checked);
		showToast(this.checked ? 'Notifications activées' : 'Notifications désactivées', 'success');
	});
}

// Initialisation des cartes de jeu
function initGameCards() {
	const gameCards = document.querySelectorAll('.game-card:not(.disabled)');
	
	gameCards.forEach(card => {
		const playBtn = card.querySelector('.game-play-btn');
		const gameName = card.dataset.game;
		
		playBtn.addEventListener('click', function(e) {
			e.stopPropagation();
			openGame(gameName);
		});
		
		card.addEventListener('click', function() {
			if (!this.classList.contains('disabled')) {
				openGame(gameName);
			}
		});
	});
}

// Charger les données du joueur depuis Lua
function loadPlayerData() {
	if (typeof casino !== 'undefined' && casino.getPlayerInfo) {
		casino.getPlayerInfo();
	}
}

// Mettre à jour les informations du joueur (appelé depuis Lua)
function updatePlayerInfo(balance, balanceFormatted, stats) {
	appState.balance = balance;
	
	// Mettre à jour l'affichage du solde avec le format personnalisé
	const balanceElement = document.getElementById('balance');
	if (balanceFormatted) {
		// Utiliser le format fourni par Lua (BaseWars formatage)
		balanceElement.textContent = balanceFormatted;
	} else {
		// Fallback au formatage par défaut
		animateNumber(balanceElement, balance);
	}
	
	// Mettre à jour les statistiques si fournies
	if (stats && typeof stats === 'string') {
		try {
			appState.stats = JSON.parse(stats);
			updateStatsDisplay();
		} catch(e) {
			console.error('Failed to parse stats:', e);
		}
	} else if (stats && typeof stats === 'object') {
		appState.stats = stats;
		updateStatsDisplay();
	}
}

// Animer un nombre
function animateNumber(element, targetValue) {
	const startValue = parseInt(element.textContent.replace(/\s/g, '')) || 0;
	const duration = 1000;
	const startTime = Date.now();
	
	function update() {
		const elapsed = Date.now() - startTime;
		const progress = Math.min(elapsed / duration, 1);
		
		const currentValue = Math.floor(startValue + (targetValue - startValue) * progress);
		element.textContent = formatNumber(currentValue);
		
		if (progress < 1) {
			requestAnimationFrame(update);
		}
	}
	
	update();
}

// Formater un nombre avec des espaces
function formatNumber(num) {
	return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

// Mettre à jour l'affichage des statistiques
function updateStatsDisplay() {
	document.getElementById('totalWins').textContent = formatNumber(appState.stats.totalWins) + ' 💎';
	document.getElementById('totalGames').textContent = formatNumber(appState.stats.totalGames);
	document.getElementById('winRate').textContent = appState.stats.winRate + '%';
	document.getElementById('biggestWin').textContent = formatNumber(appState.stats.biggestWin) + ' 💎';
}

// Ouvrir un jeu
function openGame(gameName) {
	if (typeof casino !== 'undefined' && casino.openGame) {
		casino.openGame(gameName);
		showToast(`Ouverture de ${gameName}...`, 'success');
	}
}

// Fermer le menu
function closeMenu() {
	if (typeof casino !== 'undefined' && casino.close) {
		casino.close();
	}
}

// Sauvegarder un paramètre
function saveSetting(key, value) {
	if (typeof casino !== 'undefined' && casino.saveSetting) {
		casino.saveSetting(key, value);
	}
}

// Afficher une notification toast
function showToast(message, type = 'success') {
	const toast = document.getElementById('toast');
	toast.textContent = message;
	toast.className = `toast ${type}`;
	
	// Afficher le toast
	setTimeout(() => {
		toast.classList.add('show');
	}, 10);
	
	// Masquer après 3 secondes
	setTimeout(() => {
		toast.classList.remove('show');
	}, 3000);
}

// Ajouter une entrée à l'historique
function addHistoryEntry(game, result, amount, timestamp) {
	appState.history.unshift({
		game,
		result,
		amount,
		timestamp
	});
	
	// Limiter à 50 entrées
	if (appState.history.length > 50) {
		appState.history.pop();
	}
	
	updateHistoryDisplay();
}

// Charger l'historique complet (depuis la DB)
function loadHistory(historyData) {
	// Convertir les timestamps de secondes en millisecondes
	appState.history = historyData.map(entry => ({
		game: entry.game,
		result: entry.result,
		amount: entry.amount,
		timestamp: entry.timestamp * 1000
	}));
	
	updateHistoryDisplay();
}

// Mettre à jour l'affichage de l'historique
function updateHistoryDisplay() {
	const historyList = document.getElementById('historyList');
	
	if (appState.history.length === 0) {
		historyList.innerHTML = `
			<div class="empty-state">
				<div class="empty-icon">📋</div>
				<p>Aucune partie jouée pour le moment</p>
			</div>
		`;
		return;
	}
	
	historyList.innerHTML = appState.history.map(entry => {
		const isWin = entry.result === 'win' || entry.result === 'blackjack';
		const resultClass = isWin ? 'win' : 'lose';
		const resultIcon = isWin ? '+' : '-';
		
		return `
			<div class="history-entry card">
				<div class="history-icon">${getGameIcon(entry.game)}</div>
				<div class="history-info">
					<h4>${entry.game}</h4>
					<p>${formatTimestamp(entry.timestamp)}</p>
				</div>
				<div class="history-result ${resultClass}">
					<span>${resultIcon}${formatNumber(Math.abs(entry.amount))} 💎</span>
				</div>
			</div>
		`;
	}).join('');
}

// Obtenir l'icône d'un jeu
function getGameIcon(gameName) {
	const icons = {
		'Blackjack': '🃏',
		'Slots': '🎰',
		'Roulette': '🎡',
		'Mines': '💣',
		'blackjack': '🃏',
		'slots': '🎰',
		'roulette': '🎡',
		'mines': '💣',
		'poker': '♠️'
	};
	return icons[gameName] || '🎮';
}

// Formater un timestamp
function formatTimestamp(timestamp) {
	const date = new Date(timestamp);
	const now = new Date();
	const diff = now - date;
	
	if (diff < 60000) return 'À l\'instant';
	if (diff < 3600000) return Math.floor(diff / 60000) + ' min';
	if (diff < 86400000) return Math.floor(diff / 3600000) + ' h';
	
	return date.toLocaleDateString('fr-FR');
}

// Fonctions appelées depuis Lua
window.updatePlayerInfo = updatePlayerInfo;
window.showToast = showToast;
window.addHistoryEntry = addHistoryEntry;
window.loadHistory = loadHistory;
window.loadLeaderboard = loadLeaderboard;

// Charger le leaderboard
function loadLeaderboard(leaderboardData) {
	const leaderboardList = document.getElementById('leaderboardList');
	
	if (!leaderboardData || leaderboardData.length === 0) {
		leaderboardList.innerHTML = `
			<div class="empty-state">
				<div class="empty-icon">🏆</div>
				<p>Aucune donnée pour le moment</p>
			</div>
		`;
		return;
	}
	
	leaderboardList.innerHTML = leaderboardData.map((entry, index) => {
		const rank = index + 1;
		const medal = rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : `#${rank}`;
		
		return `
			<div class="leaderboard-item">
				<div class="leaderboard-rank">${medal}</div>
				<div class="leaderboard-player">
					<div class="leaderboard-player-name">${entry.playerName}</div>
					<div class="leaderboard-player-info">
						<span class="leaderboard-game-icon">${getGameIcon(entry.game)}</span>
						<span>${entry.game} • ${formatTimestamp(entry.timestamp * 1000)}</span>
					</div>
				</div>
				<div class="leaderboard-win">${formatNumber(entry.winAmount)} 💎</div>
			</div>
		`;
	}).join('');
}

