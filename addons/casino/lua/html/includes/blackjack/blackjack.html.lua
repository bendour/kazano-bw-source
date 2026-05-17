<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Blackjack</title>
	<link rel="stylesheet" href="shared/base.css">
	<link rel="stylesheet" href="blackjack/blackjack.css">
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
				<h1><span style="filter: none;">🃏</span> Blackjack</h1>
			</div>
			<div class="balance-display">
				<span class="balance-label">Solde</span>
				<span class="balance-amount" id="balance">0</span>
				<span class="balance-currency">💎</span>
			</div>
		</header>

		<!-- Table de jeu -->
		<div id="gameTable" class="game-table">
			<!-- Zone du croupier -->
			<div class="dealer-area">
				<div class="player-label">
					<span class="player-name">Croupier</span>
					<span class="player-score" id="dealerScore"></span>
				</div>
				<div class="cards-container" id="dealerCards"></div>
			</div>

			<!-- Zone du joueur -->
			<div class="player-area">
				<div class="cards-container" id="playerCards"></div>
				<div class="player-label">
					<span class="player-name">Vous</span>
					<span class="player-score" id="playerScore"></span>
				</div>
			</div>

			<!-- Zone de mise -->
			<div id="bettingArea" class="betting-area glass">
				<h2>Placez votre mise</h2>
				<div class="bet-display">
					<span class="bet-label">Mise</span>
					<input type="number" 
						   class="bet-input" 
						   id="betInput" 
						   placeholder="Entrez votre mise"
						   min="1" 
						   max="10000"
						   value="">
					<span class="bet-currency">💎</span>
				</div>
				
				<div class="bet-info">
					<span class="bet-limits">Min: 1💎 - Max: 10,000💎</span>
				</div>

				<div class="betting-actions">
					<button class="btn btn-success btn-large" id="betBtn">Miser et Jouer</button>
				</div>
			</div>

			<!-- Contrôles de jeu -->
			<div id="gameControls" class="game-controls">
				<button class="btn btn-success" id="hitBtn" disabled>
					<span>🃏 Tirer</span>
				</button>
				<button class="btn btn-warning" id="standBtn" disabled>
					<span>✋ Rester</span>
				</button>
				<button class="btn" id="doubleBtn" disabled>
					<span>💰 Doubler</span>
				</button>
				<button class="btn btn-secondary" id="newGameBtn" style="display: none;">
					<span>🔄 Nouvelle partie</span>
				</button>
			</div>
		</div>

		<!-- Message de résultat -->
		<div id="message" class="game-message"></div>
	</div>

	<script src="blackjack/blackjack.js"></script>
</body>
</html>
