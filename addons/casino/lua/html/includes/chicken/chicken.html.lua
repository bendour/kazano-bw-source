<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Chicken Road</title>
	<link rel="stylesheet" href="shared/base.css">
	<link rel="stylesheet" href="chicken/chicken.css">
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
				<h1 class="gradient-text">🐔 Chicken Road</h1>
				<p class="game-subtitle">Évitez les os et multipliez vos gains!</p>
			</div>
			<div class="balance-display">
				<span class="balance-label">Solde</span>
				<span class="balance-amount" id="balance">0</span>
				<span class="balance-currency">💎</span>
			</div>
		</header>

		<!-- Zone de jeu -->
		<div class="game-container">
			<!-- Panneau de configuration -->
			<div class="config-panel">
				<div class="card">
					<h3>⚙️ Configuration</h3>
					
					<!-- Mise -->
					<div class="control-group">
						<label class="control-label">
							<span class="label-text">Montant de la mise</span>
							<div class="input-group">
								<button class="btn btn-small" id="decreaseBet">-</button>
								<input type="number" 
									   id="betAmount" 
									   class="bet-input" 
									   min="1" 
									   max="100000"
									   value="10">
								<button class="btn btn-small" id="increaseBet">+</button>
							</div>
						</label>
						
						<div class="quick-bets">
							<button class="btn btn-small" data-amount="10">10💎</button>
							<button class="btn btn-small" data-amount="50">50💎</button>
							<button class="btn btn-small" data-amount="100">100💎</button>
							<button class="btn btn-small" data-amount="500">500💎</button>
						</div>
					</div>
					
					<!-- Difficulté -->
					<div class="control-group">
						<label class="control-label">
							<span class="label-text">Difficulté</span>
						</label>
						<div class="difficulty-buttons">
							<button class="difficulty-btn active" data-difficulty="facile">
								<span class="diff-name">Facile</span>
								<span class="diff-info">3 os</span>
							</button>
							<button class="difficulty-btn" data-difficulty="normal">
								<span class="diff-name">Normal</span>
								<span class="diff-info">5 os</span>
							</button>
							<button class="difficulty-btn" data-difficulty="difficile">
								<span class="diff-name">Difficile</span>
								<span class="diff-info">8 os</span>
							</button>
							<button class="difficulty-btn" data-difficulty="extreme">
								<span class="diff-name">Extrême</span>
								<span class="diff-info">12 os</span>
							</button>
						</div>
					</div>
					
					<!-- Boutons d'action -->
					<div class="action-buttons">
						<button class="btn btn-primary" id="startBtn">
							<span>🎮 Commencer</span>
						</button>
						<button class="btn btn-success" id="cashOutBtn" style="display: none;">
							<span>💰 Retirer</span>
						</button>
					</div>
				</div>
				
				<!-- Statistiques du jeu -->
				<div class="card stats-card">
					<h3>📊 Partie en cours</h3>
					<div class="stats-grid">
						<div class="stat-item">
							<span class="stat-label">Cases révélées</span>
							<span class="stat-value" id="revealedCount">0</span>
						</div>
						<div class="stat-item">
							<span class="stat-label">Multiplicateur</span>
							<span class="stat-value gradient-text" id="multiplier">x1.00</span>
						</div>
						<div class="stat-item">
							<span class="stat-label">Gain potentiel</span>
							<span class="stat-value" id="potentialWin">0 💎</span>
						</div>
					</div>
				</div>
			</div>
			
			<!-- Grille de jeu -->
			<div class="game-board">
				<div class="grid-container" id="gridContainer">
					<!-- Grille 5x5 générée par JS -->
				</div>
			</div>
		</div>
	</div>
	
	<script src="chicken/chicken.js"></script>
</body>
</html>
