
/* Roulette Européenne CSS */

/* Header (utilise les styles de base.css) */
.game-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 20px 32px;
	background: var(--surface-color);
	border-bottom: 2px solid var(--primary-color);
	box-shadow: var(--shadow-md);
	position: relative;
	z-index: 10;
}

.game-title {
	text-align: center;
	flex: 1;
}

.game-title h1 {
	font-size: 32px;
	font-weight: 700;
	margin: 0 0 8px 0;
}

.game-subtitle {
	font-size: 14px;
	color: var(--text-secondary);
	margin: 0;
}

.balance-display {
	display: flex;
	align-items: center;
	gap: 12px;
	background: var(--background-medium);
	padding: 12px 20px;
	border-radius: var(--border-radius);
	border: 2px solid var(--primary-color);
}

.balance-label {
	font-size: 12px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
}

.balance-amount {
	font-size: 24px;
	font-weight: 700;
	color: var(--text-primary);
}

.balance-currency {
	font-size: 20px;
}

/* Boutons génériques */
.btn {
	padding: 12px 24px;
	border-radius: var(--border-radius);
	font-weight: 600;
	font-size: 14px;
	cursor: pointer;
	transition: all 0.2s;
	border: 2px solid;
	background: var(--surface-color);
	color: var(--text-primary);
}

.btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.btn-small {
	padding: 6px 14px;
	font-size: 12px;
}

.btn-danger {
	background: linear-gradient(135deg, #f44336, #d32f2f);
	border-color: #f44336;
	color: white;
}

.btn-danger:hover {
	background: linear-gradient(135deg, #e53935, #c62828);
	border-color: #e53935;
	box-shadow: 0 4px 12px rgba(244, 67, 54, 0.4);
}

.gradient-text {
	background: linear-gradient(135deg, var(--primary-light), var(--accent-light));
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	background-clip: text;
}

/* Notification */
.notification {
	position: fixed;
	top: 20px;
	right: 20px;
	background: var(--surface-color);
	color: var(--text-primary);
	padding: 16px 24px;
	border-radius: var(--border-radius);
	border: 2px solid var(--border-color);
	font-weight: 600;
	opacity: 0;
	transform: translateX(400px);
	transition: all var(--transition-normal);
	z-index: 9999;
	min-width: 250px;
	box-shadow: var(--shadow-lg);
}

.notification.show {
	opacity: 1;
	transform: translateX(0);
}

.notification.win {
	border-color: var(--success-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(76, 175, 80, 0.1));
}

.notification.lose {
	border-color: var(--error-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(244, 67, 54, 0.1));
}

.notification.error {
	border-color: var(--error-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(244, 67, 54, 0.1));
}

.notification.success {
	border-color: var(--success-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(76, 175, 80, 0.1));
}

/* Timer Display */
.timer-display {
	background: linear-gradient(135deg, var(--surface-color), var(--background-medium));
	border: 3px solid var(--primary-color);
	border-radius: 16px;
	padding: 24px;
	text-align: center;
	margin-bottom: 24px;
	box-shadow: var(--shadow-lg);
}

.timer-label {
	font-size: 14px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
	margin-bottom: 8px;
}

.timer-value {
	font-size: 64px;
	font-weight: 700;
	color: var(--primary-color);
	text-shadow: 0 0 20px rgba(198, 40, 40, 0.5);
	margin: 12px 0;
	font-family: 'Courier New', monospace;
}

.timer-value.warning {
	color: #FFA500;
	animation: pulse-timer 1s ease-in-out infinite;
}

.timer-value.spinning {
	color: var(--success-color);
}

@keyframes pulse-timer {
	0%, 100% { transform: scale(1); }
	50% { transform: scale(1.1); }
}

.timer-status {
	font-size: 16px;
	color: var(--text-primary);
	font-weight: 600;
}

/* Container principal */
.game-container {
	display: flex;
	gap: 20px;
	padding: 20px;
	max-width: 1600px;
	margin: 0 auto;
	height: calc(100vh - 100px);
	overflow: hidden;
}

/* Section roulette */
.roulette-section {
	width: 450px;
	display: flex;
	flex-direction: column;
}

/* Roue de la roulette */
.roulette-wheel-container {
	flex: 1;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 20px;
	background: var(--surface-color);
	border-radius: 16px;
	border: 2px solid var(--border-color);
	margin-bottom: 20px;
	position: relative;
	overflow: visible;
}

.wheel-arrow {
	position: absolute;
	top: 20px;
	left: 50%;
	transform: translateX(-50%);
	font-size: 48px;
	color: #FFD700;
	z-index: 20;
	filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.8));
	text-shadow: 
		0 0 10px rgba(255, 215, 0, 0.8),
		0 0 20px rgba(255, 215, 0, 0.6),
		0 2px 4px rgba(0, 0, 0, 0.5);
	pointer-events: none;
}

.roulette-wheel {
	width: 350px;
	height: 350px;
	border-radius: 50%;
	background: #8B4513;
	border: 8px solid #FFD700;
	position: relative;
	box-shadow: 
		0 0 40px rgba(255, 215, 0, 0.5),
		inset 0 0 60px rgba(0, 0, 0, 0.8);
	overflow: visible;
	transition: none;
}

#rouletteCanvas {
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	border-radius: 50%;
}

.wheel-center {
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	width: 120px;
	height: 120px;
	background: linear-gradient(135deg, #1a1a1a, #0a0a0a);
	border-radius: 50%;
	border: 4px solid #FFD700;
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 
		0 0 20px rgba(255, 215, 0, 0.6),
		inset 0 0 20px rgba(0, 0, 0, 0.8);
	z-index: 10;
	/* Empêcher la rotation du centre avec la roue */
	transition: transform 0.1s linear;
}

.winning-number {
	font-size: 48px;
	font-weight: 700;
	color: #FFD700;
	text-shadow: 0 0 10px rgba(255, 215, 0, 0.8);
	display: none; /* Caché par défaut, affiché par JS */
}

/* Résultats et historique */
.result-section {
	background: var(--card-bg);
	border: 2px solid var(--border-color);
	border-radius: 12px;
	padding: 16px;
}

.last-result {
	display: flex;
	align-items: center;
	gap: 12px;
	margin-bottom: 16px;
	padding-bottom: 16px;
	border-bottom: 2px solid var(--border-color);
}

.result-label {
	font-size: 14px;
	color: var(--text-secondary);
	font-weight: 600;
}

.result-number {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 50px;
	height: 50px;
	border-radius: 50%;
	font-size: 24px;
	font-weight: 700;
	border: 3px solid;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.result-number.red {
	background: linear-gradient(135deg, #ff4444, #cc0000);
	border-color: #ff6666;
	color: white;
}

.result-number.black {
	background: linear-gradient(135deg, #333333, #000000);
	border-color: #555555;
	color: white;
}

.result-number.green {
	background: linear-gradient(135deg, #4CAF50, #1B5E20);
	border-color: #66BB6A;
	color: white;
}

.history-numbers {
	display: flex;
	gap: 6px;
	flex-wrap: wrap;
}

.history-number {
	width: 32px;
	height: 32px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 12px;
	font-weight: 700;
	border: 2px solid;
	color: white;
}

.history-number.red {
	background: linear-gradient(135deg, #ff4444, #cc0000);
	border-color: #ff6666;
}

.history-number.black {
	background: linear-gradient(135deg, #333333, #000000);
	border-color: #555555;
}

.history-number.green {
	background: linear-gradient(135deg, #4CAF50, #1B5E20);
	border-color: #66BB6A;
}

/* Section de paris */
.betting-section {
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 16px;
	overflow-y: auto;
	padding-right: 8px;
}

.betting-table-container {
	background: var(--card-bg);
	border: 2px solid var(--border-color);
	border-radius: 12px;
	padding: 20px;
}

.betting-table-container h3 {
	margin: 0 0 16px 0;
	font-size: 18px;
	color: var(--text-primary);
	border-bottom: 2px solid var(--primary-color);
	padding-bottom: 12px;
}

/* Contrôles de mise */
.bet-controls {
	margin-bottom: 20px;
}

.control-label {
	display: block;
	margin-bottom: 12px;
}

.label-text {
	display: block;
	font-size: 13px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
	margin-bottom: 8px;
}

.input-group {
	display: flex;
	gap: 8px;
	align-items: center;
}

.bet-input {
	flex: 1;
	background: var(--background-medium);
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius);
	padding: 10px;
	color: var(--text-primary);
	font-size: 16px;
	font-weight: 600;
	text-align: center;
}

.bet-input:focus {
	outline: none;
	border-color: var(--primary-color);
	box-shadow: 0 0 0 3px rgba(198, 40, 40, 0.2);
}

.quick-bets {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 8px;
	margin-top: 12px;
}

/* Boutons de paris */
.bet-btn {
	background: linear-gradient(135deg, var(--surface-color), var(--background-color));
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius);
	padding: 12px;
	color: var(--text-primary);
	font-weight: 600;
	cursor: pointer;
	transition: all 0.2s ease;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 4px;
	position: relative;
	overflow: visible;
}

.bet-btn:hover {
	border-color: var(--primary-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(198, 40, 40, 0.1));
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(198, 40, 40, 0.3);
}

.bet-btn:active {
	transform: translateY(0);
}

.bet-btn.active {
	border-color: var(--success-color);
	background: linear-gradient(135deg, rgba(76, 175, 80, 0.2), rgba(76, 175, 80, 0.1));
	box-shadow: 0 0 12px rgba(76, 175, 80, 0.4);
}

/* Jeton de mise sur les boutons */
.bet-chip {
	position: absolute;
	top: -10px;
	right: -10px;
	background: linear-gradient(135deg, #FFD700, #FFA500);
	color: #000;
	border: 3px solid #fff;
	border-radius: 50%;
	width: 36px;
	height: 36px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 12px;
	font-weight: 700;
	box-shadow: 0 3px 10px rgba(0, 0, 0, 0.5);
	animation: chip-appear 0.3s ease;
	z-index: 10;
}

@keyframes chip-appear {
	0% {
		transform: scale(0) rotate(0deg);
		opacity: 0;
	}
	50% {
		transform: scale(1.3) rotate(180deg);
	}
	100% {
		transform: scale(1) rotate(360deg);
		opacity: 1;
	}
}

.bet-red {
	background: linear-gradient(135deg, #ff4444, #cc0000);
	color: white;
	border-color: #ff6666;
}

.bet-red:hover {
	background: linear-gradient(135deg, #ff6666, #dd2222);
	border-color: #ff8888;
}

.bet-black {
	background: linear-gradient(135deg, #333333, #000000);
	color: white;
	border-color: #555555;
}

.bet-black:hover {
	background: linear-gradient(135deg, #555555, #222222);
	border-color: #777777;
}

.bet-green {
	background: linear-gradient(135deg, #4CAF50, #1B5E20);
	color: white;
	border-color: #66BB6A;
}

.bet-green:hover {
	background: linear-gradient(135deg, #66BB6A, #2E7D32);
	border-color: #81C784;
}

.bet-name {
	font-size: 14px;
}

.bet-payout {
	font-size: 11px;
	color: #FFD700;
}

/* Paris simples */
.simple-bets {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 10px;
	margin-bottom: 16px;
}

/* Douzaines */
.dozen-bets {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 10px;
	margin-bottom: 16px;
}

/* Grille de numéros */
.numbers-grid {
	display: grid;
	grid-template-columns: repeat(12, 1fr);
	gap: 4px;
}

.number-zero {
	grid-column: 1 / -1;
	font-size: 20px;
	padding: 16px;
}

.number-cell {
	aspect-ratio: 1;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 14px;
	font-weight: 700;
	grid-column: span 4;
}

/* Paris actifs */
.active-bets-container {
	background: var(--card-bg);
	border: 2px solid var(--border-color);
	border-radius: 12px;
	padding: 16px;
	max-height: 300px;
	display: flex;
	flex-direction: column;
}

.active-bets-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 12px;
	border-bottom: 2px solid var(--primary-color);
	padding-bottom: 10px;
}

.active-bets-header h4 {
	margin: 0;
	font-size: 16px;
	color: var(--text-primary);
}

.active-bets-container h4 {
	margin: 0 0 12px 0;
	font-size: 16px;
	color: var(--text-primary);
	border-bottom: 2px solid var(--primary-color);
	padding-bottom: 10px;
}

.active-bets-list {
	flex: 1;
	overflow-y: auto;
	margin-bottom: 12px;
}

.no-bets {
	text-align: center;
	color: var(--text-secondary);
	font-size: 14px;
	padding: 20px;
}

.bet-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 8px 12px;
	background: var(--surface-color);
	border: 1px solid var(--border-color);
	border-radius: var(--border-radius);
	margin-bottom: 6px;
	transition: all 0.2s;
}

.bet-item:hover {
	background: var(--card-bg);
	border-color: var(--primary-color);
}

.bet-item-info {
	flex: 1;
	display: flex;
	align-items: center;
	gap: 8px;
}

.bet-item-name {
	font-size: 13px;
	color: var(--text-primary);
	font-weight: 600;
}

.bet-item-amount {
	font-size: 13px;
	color: var(--primary-color);
	font-weight: 700;
}

.bet-item-remove {
	background: transparent;
	border: 1px solid var(--error-color);
	color: var(--error-color);
	padding: 4px 10px;
	border-radius: 6px;
	font-size: 11px;
	cursor: pointer;
	transition: all 0.2s;
	font-weight: 600;
}

.bet-item-remove:hover {
	background: var(--error-color);
	color: white;
	transform: scale(1.05);
}

.total-bet {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12px;
	background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
	border-radius: var(--border-radius);
	color: white;
	font-weight: 700;
	font-size: 16px;
}

/* Responsive */
@media (max-width: 1400px) {
	.game-container {
		flex-direction: column;
		height: auto;
		overflow-y: auto;
	}
	
	.roulette-section {
		width: 100%;
	}
	
	.betting-section {
		overflow-y: visible;
	}
}
