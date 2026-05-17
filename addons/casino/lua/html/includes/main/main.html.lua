<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Casino - Menu Principal</title>
	<link rel="stylesheet" href="shared/base.css">
	<link rel="stylesheet" href="main/main.css">
</head>
<body>
	<div id="app">
		<!-- Header avec informations du joueur -->
		<header class="header glass">
			<div class="header-left">
				<h1 class="logo"><span class="logo-emoji">🎰</span> <span class="gradient-text">CASINO</span></h1>
			</div>
			<div class="header-center">
				<div class="balance-display">
					<span class="balance-label">Solde</span>
					<span class="balance-amount" id="balance">0</span>
					<span class="balance-currency">💎</span>
				</div>
			</div>
			<div class="header-right">
				<button class="btn btn-secondary" id="closeBtn">✕ Fermer</button>
			</div>
		</header>

		<!-- Navigation -->
		<nav class="navigation">
			<button class="nav-item active" data-section="games">
				<span class="nav-icon">🎮</span>
				<span class="nav-label">Jeux</span>
			</button>
			<button class="nav-item" data-section="stats">
				<span class="nav-icon">📊</span>
				<span class="nav-label">Statistiques</span>
			</button>
			<button class="nav-item" data-section="history">
				<span class="nav-icon">📜</span>
				<span class="nav-label">Historique</span>
			</button>
			<button class="nav-item" data-section="settings">
				<span class="nav-icon">⚙️</span>
				<span class="nav-label">Paramètres</span>
			</button>
		</nav>

		<!-- Section principale -->
		<main class="main-content">
			<!-- Section Jeux -->
			<section id="games-section" class="content-section active">
				<div class="section-header">
					<h2>Sélectionnez un jeu</h2>
					<p class="section-subtitle">Tentez votre chance et gagnez gros !</p>
				</div>

				<div class="games-grid">
					<!-- Blackjack -->
					<div class="game-card card" data-game="blackjack">
						<div class="game-icon">🃏</div>
						<div class="game-info">
							<h3 class="game-title">Blackjack</h3>
							<p class="game-description">Le classique du casino. Battez le croupier et obtenez 21 !</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">100💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Mise max</span>
									<span class="stat-value">10K💎</span>
								</div>
							</div>
						</div>
						<button class="btn btn-success game-play-btn">
							<span>Jouer maintenant</span>
							<span class="btn-arrow">→</span>
						</button>
					</div>

					<!-- Mines -->
					<div class="game-card card" data-game="mines">
						<div class="game-icon">💣</div>
						<div class="game-info">
							<h3 class="game-title">Mines</h3>
							<p class="game-description">Démineur style casino. Évitez les bombes et multipliez vos gains !</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">1💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Grille</span>
									<span class="stat-value">5x5</span>
								</div>
							</div>
						</div>
						<button class="btn btn-success game-play-btn">
							<span>Jouer maintenant</span>
							<span class="btn-arrow">→</span>
						</button>
					</div>

					<!-- Le Bandit (Machine à sous) -->
					<div class="game-card card" data-game="slots">
						<div class="game-icon">🎰</div>
						<div class="game-info">
							<h3 class="game-title">Le Bandit</h3>
							<p class="game-description">Machine à sous Far West • 1024 façons de gagner !</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">1💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Max gain</span>
									<span class="stat-value">10,000x</span>
								</div>
							</div>
						</div>
						<button class="btn btn-success game-play-btn">
							<span>Jouer maintenant</span>
							<span class="btn-arrow">→</span>
						</button>
					</div>

					<!-- Roulette Européenne -->
					<div class="game-card card" data-game="roulette">
						<div class="game-icon">🔮</div>
						<div class="game-info">
							<h3 class="game-title">Roulette Européenne</h3>
							<p class="game-description">Tous les joueurs parient sur le même spin !</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">1💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Max gain</span>
									<span class="stat-value">36x</span>
								</div>
							</div>
						</div>
						<button class="btn btn-success game-play-btn">
							<span>Jouer maintenant</span>
							<span class="btn-arrow">→</span>
						</button>
					</div>

					<!-- Chicken Road (Coming soon) -->
					<div class="game-card card disabled">
						<div class="game-icon">🐔</div>
						<div class="game-info">
							<h3 class="game-title">Chicken Road</h3>
							<p class="game-description">Évitez les os et multipliez vos gains!</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">1💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Max multi</span>
									<span class="stat-value">100x+</span>
								</div>
							</div>
						</div>
						<button class="btn btn-secondary game-play-btn" disabled>
							<span>Bientôt disponible</span>
						</button>
					</div>

					<!-- Slots (Coming soon) -->
					<div class="game-card card disabled">
						<div class="game-icon">🎲</div>
						<div class="game-info">
							<h3 class="game-title">Dés</h3>
							<p class="game-description">Jeu de dés arrive bientôt !</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">50💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Jackpot</span>
									<span class="stat-value">50K💎</span>
								</div>
							</div>
						</div>
						<button class="btn btn-secondary game-play-btn" disabled>
							<span>Bientôt disponible</span>
						</button>
					</div>

					<!-- Crash (Coming soon) -->
					<div class="game-card card disabled">
						<div class="game-icon">🚀</div>
						<div class="game-info">
							<h3 class="game-title">Crash</h3>
							<p class="game-description">La fusée décolle ! Encaissez avant le crash !</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">1💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Multi max</span>
									<span class="stat-value">∞</span>
								</div>
							</div>
						</div>
						<button class="btn btn-secondary game-play-btn" disabled>
							<span>Bientôt disponible</span>
						</button>
					</div>

					<!-- Poker (Coming soon) -->
					<div class="game-card card disabled">
						<div class="game-icon">♠️</div>
						<div class="game-info">
							<h3 class="game-title">Poker</h3>
							<p class="game-description">Bluffez et remportez la mise !</p>
							<div class="game-stats">
								<div class="stat">
									<span class="stat-label">Mise min</span>
									<span class="stat-value">200💎</span>
								</div>
								<div class="stat">
									<span class="stat-label">Joueurs</span>
									<span class="stat-value">2-6</span>
								</div>
							</div>
						</div>
						<button class="btn btn-secondary game-play-btn" disabled>
							<span>Bientôt disponible</span>
						</button>
					</div>
				</div>
			</section>

			<!-- Section Statistiques -->
			<section id="stats-section" class="content-section">
				<div class="section-header">
					<h2>Vos statistiques</h2>
					<p class="section-subtitle">Suivez vos performances</p>
				</div>

				<div class="stats-grid">
					<div class="stat-card card">
						<div class="stat-icon">💰</div>
						<div class="stat-content">
							<h4>Gains totaux</h4>
							<p class="stat-number" id="totalWins">0 💎</p>
						</div>
					</div>
					<div class="stat-card card">
						<div class="stat-icon">🎲</div>
						<div class="stat-content">
							<h4>Parties jouées</h4>
							<p class="stat-number" id="totalGames">0</p>
						</div>
					</div>
					<div class="stat-card card">
						<div class="stat-icon">📈</div>
						<div class="stat-content">
							<h4>Taux de victoire</h4>
							<p class="stat-number" id="winRate">0%</p>
						</div>
					</div>
					<div class="stat-card card">
						<div class="stat-icon">🏆</div>
						<div class="stat-content">
							<h4>Plus gros gain</h4>
							<p class="stat-number" id="biggestWin">0 💎</p>
						</div>
					</div>
				</div>

				<!-- Leaderboard Global -->
				<div class="section-header" style="margin-top: 40px;">
					<h2>🏆 Classement des Plus Gros Gains</h2>
					<p class="section-subtitle">Top 10 des joueurs les plus chanceux</p>
				</div>

				<div class="leaderboard-container card">
					<div id="leaderboardList" class="leaderboard-list">
						<div class="empty-state">
							<div class="empty-icon">🏆</div>
							<p>Chargement du classement...</p>
						</div>
					</div>
				</div>
			</section>

			<!-- Section Historique -->
			<section id="history-section" class="content-section">
				<div class="section-header">
					<h2>Historique des parties</h2>
					<p class="section-subtitle">Vos dernières sessions</p>
				</div>

				<div class="history-list" id="historyList">
					<div class="empty-state">
						<div class="empty-icon">📋</div>
						<p>Aucune partie jouée pour le moment</p>
					</div>
				</div>
			</section>

			<!-- Section Paramètres -->
			<section id="settings-section" class="content-section">
				<div class="section-header">
					<h2>Paramètres</h2>
					<p class="section-subtitle">Personnalisez votre expérience</p>
				</div>

				<div class="settings-list">
					<div class="setting-item card">
						<div class="setting-info">
							<h4>Sons</h4>
							<p>Activer/désactiver les effets sonores</p>
						</div>
						<label class="toggle">
							<input type="checkbox" id="soundToggle" checked>
							<span class="toggle-slider"></span>
						</label>
					</div>
					<div class="setting-item card">
						<div class="setting-info">
							<h4>Animations</h4>
							<p>Activer/désactiver les animations</p>
						</div>
						<label class="toggle">
							<input type="checkbox" id="animToggle" checked>
							<span class="toggle-slider"></span>
						</label>
					</div>
					<div class="setting-item card">
						<div class="setting-info">
							<h4>Notifications</h4>
							<p>Recevoir des notifications de gains</p>
						</div>
						<label class="toggle">
							<input type="checkbox" id="notifToggle" checked>
							<span class="toggle-slider"></span>
						</label>
					</div>
				</div>
			</section>
		</main>
	</div>

	<!-- Toast pour les notifications -->
	<div id="toast" class="toast"></div>

	<script src="main/main.js"></script>
</body>
</html>
