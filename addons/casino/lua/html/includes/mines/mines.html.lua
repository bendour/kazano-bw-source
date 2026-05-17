<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Mines</title>
	<link rel="stylesheet" href="shared/base.css">
	<link rel="stylesheet" href="mines/mines.css">
</head>
<body>
	<!-- Notification en haut à droite -->
	<div id="notification" class="notification"></div>
	
	<div id="app">
		<!-- Header -->
		<header class="game-header glass">
			<button class="btn btn-secondary back-btn" id="backBtn">
				<span>← Retour au menu</span>
			</button>
			<div class="game-title">
				<h1>💣 Mines</h1>
			</div>
			<div class="balance-display">
				<span class="balance-label">Solde</span>
				<span class="balance-amount" id="balance">0</span>
				<span class="balance-currency">💎</span>
			</div>
		</header>

		<!-- Zone de jeu -->
		<div id="gameContainer" class="game-container">
			<!-- Panneau de configuration -->
			<div id="configPanel" class="config-panel card">
				<h2>Configuration</h2>
				
				<div class="config-section">
					<label class="config-label">
						<span class="label-text">Mise</span>
						<div class="input-group">
							<input type="number" 
								   id="betInput" 
								   class="bet-input" 
								   placeholder="Votre mise"
								   min="1" 
								   max="10000"
								   value="100">
							<span class="input-currency">💎</span>
						</div>
					</label>
					
					<div class="quick-bets">
						<button class="btn btn-small" data-bet="10">10</button>
						<button class="btn btn-small" data-bet="100">100</button>
						<button class="btn btn-small" data-bet="500">500</button>
						<button class="btn btn-small" data-bet="1000">1K</button>
					</div>
				</div>
				
				<div class="config-section">
					<label class="config-label">
						<span class="label-text">Nombre de bombes: <span id="bombCountDisplay">3</span></span>
						<input type="range" 
							   id="bombCountSlider" 
							   class="bomb-slider" 
							   min="1" 
							   max="24" 
							   value="3">
					</label>
					<div class="bomb-info">
						<span class="bomb-risk">Risque: <span id="riskLevel">Faible</span></span>
					</div>
				</div>
				
				<button class="btn btn-success btn-large" id="startBtn">
					<span>Commencer la partie</span>
				</button>
				
				<div class="bet-limits">Min: 1💎 - Max: 10,000💎</div>
			</div>
			
			<!-- Grille de jeu -->
			<div class="game-board">
				<div class="board-header">
					<div class="game-stats">
						<div class="stat">
							<span class="stat-label">Cases révélées</span>
							<span class="stat-value" id="revealedCount">0</span>
						</div>
						<div class="stat">
							<span class="stat-label">Multiplicateur</span>
							<span class="stat-value multiplier" id="multiplier">1.00x</span>
						</div>
						<div class="stat">
							<span class="stat-label">Gain potentiel</span>
							<span class="stat-value potential-win" id="potentialWin">0💎</span>
						</div>
					</div>
				</div>
				
				<div id="grid" class="mines-grid">
					<!-- 25 cases générées par JS -->
				</div>
				
				<div class="board-footer">
					<button class="btn btn-warning btn-large" id="cashOutBtn" style="display: none;">
						<span>💰 Encaisser</span>
					</button>
					<button class="btn btn-secondary" id="newGameBtn" style="display: none;">
						<span>Nouvelle partie</span>
					</button>
				</div>
			</div>
		</div>
	</div>

	<script src="mines/mines.js"></script>
</body>
</html>
