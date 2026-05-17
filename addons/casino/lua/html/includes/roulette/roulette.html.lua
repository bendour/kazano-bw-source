<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Roulette</title>
	<link rel="stylesheet" href="shared/base.css">
	<link rel="stylesheet" href="roulette/roulette.css">
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
				<h1 class="gradient-text">🔮 Roulette</h1>
				<p class="game-subtitle">Tous les joueurs parient sur le même spin • RTP 97.3%</p>
			</div>
			<div class="balance-display">
				<span class="balance-label">Solde</span>
				<span class="balance-amount" id="balance">0</span>
				<span class="balance-currency">💎</span>
			</div>
		</header>

		<!-- Zone de jeu -->
		<div class="game-container">
			<!-- Roulette et timer -->
			<div class="roulette-section">
				<!-- Timer -->
				<div class="timer-display" id="timerDisplay">
					<div class="timer-label">Prochain spin dans</div>
					<div class="timer-value" id="timerValue">15</div>
					<div class="timer-status" id="timerStatus">Placez vos paris!</div>
				</div>
				
				<!-- Roue de la roulette -->
				<div class="roulette-wheel-container">
					<div class="wheel-arrow">▼</div>
					<div class="roulette-wheel" id="rouletteWheel">
						<canvas id="rouletteCanvas" width="350" height="350"></canvas>
						<div class="wheel-center">
							<div class="winning-number" id="winningNumber">-</div>
						</div>
					</div>
				</div>
				
				<!-- Résultat et historique -->
				<div class="result-section">
					<div class="last-result">
						<span class="result-label">Dernier numéro:</span>
						<div class="result-number" id="lastResult">
							<span class="number-value">-</span>
						</div>
					</div>
					
					<div class="history-numbers" id="historyNumbers">
						<!-- L'historique sera généré par JS -->
					</div>
				</div>
			</div>
			
			<!-- Table de paris -->
			<div class="betting-section">
				<div class="betting-table-container">
					<h3>📋 Placez vos paris</h3>
					
					<!-- Contrôles de mise -->
					<div class="bet-controls">
						<label class="control-label">
							<span class="label-text">Montant du pari</span>
							<div class="input-group">
								<button class="btn btn-small" id="decreaseBet">-</button>
								<input type="number" 
									   id="betAmount" 
									   class="bet-input" 
									   min="1" 
									   max="10000"
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
					
					<!-- Table des paris simples -->
					<div class="simple-bets">
						<button class="bet-btn bet-red" data-type="red" data-value="red">
							<span class="bet-name">ROUGE</span>
							<span class="bet-payout">2:1</span>
						</button>
						<button class="bet-btn bet-black" data-type="black" data-value="black">
							<span class="bet-name">NOIR</span>
							<span class="bet-payout">2:1</span>
						</button>
						<button class="bet-btn" data-type="even" data-value="even">
							<span class="bet-name">PAIR</span>
							<span class="bet-payout">2:1</span>
						</button>
						<button class="bet-btn" data-type="odd" data-value="odd">
							<span class="bet-name">IMPAIR</span>
							<span class="bet-payout">2:1</span>
						</button>
						<button class="bet-btn" data-type="low" data-value="low">
							<span class="bet-name">1-18</span>
							<span class="bet-payout">2:1</span>
						</button>
						<button class="bet-btn" data-type="high" data-value="high">
							<span class="bet-name">19-36</span>
							<span class="bet-payout">2:1</span>
						</button>
					</div>
					
					<!-- Douzaines -->
					<div class="dozen-bets">
						<button class="bet-btn" data-type="dozen1" data-value="dozen1">
							<span class="bet-name">1-12</span>
							<span class="bet-payout">3:1</span>
						</button>
						<button class="bet-btn" data-type="dozen2" data-value="dozen2">
							<span class="bet-name">13-24</span>
							<span class="bet-payout">3:1</span>
						</button>
						<button class="bet-btn" data-type="dozen3" data-value="dozen3">
							<span class="bet-name">25-36</span>
							<span class="bet-payout">3:1</span>
						</button>
					</div>
					
					<!-- Grille de numéros -->
					<div class="numbers-grid" id="numbersGrid">
						<div class="number-zero bet-btn bet-green" data-type="straight" data-value="0">0</div>
						<!-- Les numéros 1-36 seront générés par JS -->
					</div>
				</div>
				
				<!-- Paris actifs -->
				<div class="active-bets-container">
					<div class="active-bets-header">
						<h4>💰 Vos paris actifs</h4>
						<button class="btn btn-small btn-danger" id="clearAllBets">Tout effacer</button>
					</div>
					<div class="active-bets-list" id="activeBetsList">
						<p class="no-bets">Aucun pari placé</p>
					</div>
					<div class="total-bet">
						<span>Total parié:</span>
						<span id="totalBet">0💎</span>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<script src="roulette/roulette.js"></script>
</body>
</html>
