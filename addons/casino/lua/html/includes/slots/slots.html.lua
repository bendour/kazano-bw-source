<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Le Bandit - Machine à Sous</title>
	<link rel="stylesheet" href="shared/base.css">
	<link rel="stylesheet" href="slots/slots.css">
</head>
<body>
	<!-- Notification -->
	<div id="notification" class="notification"></div>
	
	<div id="app">
		<!-- Header -->
		<header class="game-header">
			<button class="btn btn-secondary back-btn" id="backBtn">
				<span>← Retour au menu</span>
			</button>
			<div class="game-title">
				<h1 class="gradient-text">🎰 Machine à Sous</h1>
				<p class="game-subtitle">Slot Classique 5×5 • RTP 94.5%</p>
			</div>
			<div class="balance-display">
				<span class="balance-label">Solde</span>
				<span class="balance-amount" id="balance">0</span>
				<span class="balance-currency">💎</span>
			</div>
		</header>

		<!-- Zone de jeu -->
		<div class="game-container">
			<!-- Machine à sous -->
			<div class="slot-machine">
				<!-- Cadre décoratif -->
				<div class="machine-frame">
					<div class="machine-top">
						<div class="smokey-banner">
							<span class="smokey-icon">🦝</span>
							<span class="smokey-text">Smokey's Casino</span>
							<span class="smokey-icon">🦝</span>
						</div>
					</div>
					
					<!-- Grille 5x5 -->
					<div class="reels-container">
						<div id="reelsGrid" class="reels-grid">
							<!-- Les rouleaux seront générés par JS -->
						</div>
						
						<!-- Overlay pour les animations de gain -->
						<div id="winOverlay" class="win-overlay"></div>
					</div>
					
					<!-- Panneau d'information des gains -->
					<div class="win-display" id="winDisplay">
						<div class="win-amount">
							<span class="win-label">Gain:</span>
							<span class="win-value" id="winAmount">0💎</span>
						</div>
						<div class="win-multiplier" id="winMultiplier"></div>
					</div>
					
					<!-- Panneau de contrôle -->
					<div class="controls-panel">
						<div class="bet-controls">
							<label class="control-label">
								<span class="label-text">Mise par tour</span>
								<div class="input-group">
									<button class="btn btn-small" id="decreaseBet">-</button>
									<input type="number" 
										   id="betInput" 
										   class="bet-input" 
										   min="1" 
										   max="10000"
										   value="10">
									<button class="btn btn-small" id="increaseBet">+</button>
								</div>
							</label>
							
							<div class="quick-bets">
								<button class="btn btn-small" data-bet="1">1💎</button>
								<button class="btn btn-small" data-bet="10">10💎</button>
								<button class="btn btn-small" data-bet="100">100💎</button>
								<button class="btn btn-small" data-bet="1000">1K💎</button>
								<button class="btn btn-small" id="maxBet">MAX</button>
							</div>
						</div>
						
						<!-- Bouton SPIN -->
						<button class="btn btn-primary spin-btn" id="spinBtn">
							<span class="spin-text">TOURNER</span>
							<span class="spin-icon">🎰</span>
						</button>
					</div>
				</div>
			</div>
			
			<!-- Panneau latéral - Infos et bonus -->
			<div class="info-panel">
				<!-- Statistiques de session -->
				<div class="card stats-card">
					<h3>📊 Session</h3>
					<div class="stat-row">
						<span class="stat-label">Tours joués</span>
						<span class="stat-value" id="spinsCount">0</span>
					</div>
					<div class="stat-row">
						<span class="stat-label">Gain total</span>
						<span class="stat-value" id="totalWins">0💎</span>
					</div>
					<div class="stat-row">
						<span class="stat-label">Plus gros gain</span>
						<span class="stat-value" id="biggestWin">0💎</span>
					</div>
				</div>
				
				<!-- Tableau des gains -->
				<div class="card paytable-card">
					<h3>💵 Tableau des gains</h3>
					<div class="paytable">
						<div class="paytable-row">
							<span class="symbol">🦝×5</span>
							<span class="payout">100x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">🔫×5</span>
							<span class="payout">50x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">🤠×5</span>
							<span class="payout">40x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">�×5</span>
							<span class="payout">30x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">🂡×5</span>
							<span class="payout">20x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">♔×5</span>
							<span class="payout">15x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">♕×5</span>
							<span class="payout">10x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">🃏×5</span>
							<span class="payout">8x</span>
						</div>
						<div class="paytable-row">
							<span class="symbol">🔟×5</span>
							<span class="payout">5x</span>
						</div>
					</div>
					<p class="paytable-note">Lignes de paiement • Max gain: 5000x</p>
				</div>
			</div>
		</div>
	</div>
	
	<script src="slots/slots.js"></script>
</body>
</html>
