/* Styles pour le jeu Mines */

#app {
	display: flex;
	flex-direction: column;
	height: 100vh;
	overflow: hidden;
	background: var(--background-dark);
}

/* Notification minimaliste */
.notification {
	position: fixed;
	top: 20px;
	right: 20px;
	padding: 16px 24px;
	border-radius: 8px;
	font-size: 16px;
	font-weight: 600;
	background: var(--surface-color);
	border-left: 4px solid;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
	transform: translateX(400px);
	transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
	z-index: 9999;
	max-width: 320px;
}

.notification.show {
	transform: translateX(0);
}

.notification.win {
	border-color: var(--success-color);
	color: var(--success-color);
}

.notification.lose {
	border-color: var(--error-color);
	color: var(--error-color);
}

.notification.push {
	border-color: var(--warning-color);
	color: var(--warning-color);
}

.notification.error {
	border-color: var(--error-color);
	color: var(--error-color);
}

/* Header */
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

.back-btn {
	font-size: 14px;
}

.game-title h1 {
	font-size: 28px;
	font-weight: 700;
	background: linear-gradient(135deg, var(--primary-light), var(--accent-light));
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	background-clip: text;
	filter: grayscale(1);
	-webkit-filter: grayscale(1);
}

.balance-display {
	display: flex;
	align-items: center;
	gap: 8px;
	padding: 12px 20px;
	background: var(--card-bg);
	border-radius: var(--border-radius-lg);
	border: 1px solid var(--border-color);
}

.balance-label {
	font-size: 12px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
}

.balance-amount {
	font-size: 20px;
	font-weight: 700;
	color: var(--primary-light);
}

.balance-currency {
	font-size: 16px;
	color: var(--text-secondary);
}

/* Container principal */
.game-container {
	display: flex;
	gap: 24px;
	padding: 32px;
	flex: 1;
	overflow: auto;
}

/* Panneau de configuration */
.config-panel {
	min-width: 320px;
	max-width: 320px;
	padding: 24px;
	background: var(--card-bg);
	border-radius: var(--border-radius-lg);
	border: 1px solid var(--border-color);
	height: fit-content;
}

.config-panel h2 {
	margin: 0 0 24px 0;
	font-size: 20px;
	color: var(--text-primary);
}

.config-section {
	margin-bottom: 24px;
}

.config-label {
	display: block;
	width: 100%;
}

.label-text {
	display: block;
	margin-bottom: 8px;
	font-size: 14px;
	font-weight: 600;
	color: var(--text-secondary);
}

.input-group {
	position: relative;
	display: flex;
	align-items: center;
}

.bet-input {
	width: 100%;
	padding: 12px 40px 12px 16px;
	background: var(--background-dark);
	border: 1px solid var(--border-color);
	border-radius: var(--border-radius);
	color: var(--text-primary);
	font-size: 16px;
	font-weight: 600;
	transition: border-color var(--transition-fast);
}

.bet-input:focus {
	outline: none;
	border-color: var(--primary-color);
}

.input-currency {
	position: absolute;
	right: 16px;
	color: var(--text-secondary);
	pointer-events: none;
}

.quick-bets {
	display: flex;
	gap: 8px;
	margin-top: 12px;
}

.quick-bets .btn {
	flex: 1;
	padding: 8px;
	font-size: 14px;
}

.bomb-slider {
	width: 100%;
	height: 6px;
	background: var(--background-dark);
	border-radius: 3px;
	outline: none;
	-webkit-appearance: none;
}

.bomb-slider::-webkit-slider-thumb {
	-webkit-appearance: none;
	appearance: none;
	width: 20px;
	height: 20px;
	background: var(--primary-color);
	border-radius: 50%;
	cursor: pointer;
	transition: background var(--transition-fast);
}

.bomb-slider::-webkit-slider-thumb:hover {
	background: var(--primary-light);
}

.bomb-slider::-moz-range-thumb {
	width: 20px;
	height: 20px;
	background: var(--primary-color);
	border-radius: 50%;
	cursor: pointer;
	border: none;
}

.bomb-info {
	margin-top: 8px;
	text-align: center;
	font-size: 14px;
	color: var(--text-secondary);
}

.bomb-risk {
	font-weight: 600;
}

#riskLevel {
	color: var(--success-color);
}

#riskLevel.medium {
	color: var(--warning-color);
}

#riskLevel.high {
	color: var(--error-color);
}

.bet-limits {
	margin-top: 16px;
	text-align: center;
	font-size: 12px;
	color: var(--text-disabled);
}

/* Grille de jeu */
.game-board {
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 24px;
}

.board-header {
	background: var(--card-bg);
	border-radius: var(--border-radius-lg);
	border: 1px solid var(--border-color);
	padding: 20px;
}

.game-stats {
	display: flex;
	justify-content: space-around;
	gap: 24px;
}

.stat {
	text-align: center;
}

.stat-label {
	display: block;
	font-size: 12px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
	margin-bottom: 8px;
}

.stat-value {
	display: block;
	font-size: 24px;
	font-weight: 700;
	color: var(--text-primary);
}

.stat-value.multiplier {
	color: var(--primary-light);
}

.stat-value.potential-win {
	color: var(--success-color);
}

/* Grille 5x5 */
.mines-grid {
	display: grid;
	grid-template-columns: repeat(5, 1fr);
	gap: 12px;
	padding: 20px;
	background: var(--card-bg);
	border-radius: var(--border-radius-lg);
	border: 1px solid var(--border-color);
	max-width: 600px;
	margin: 0 auto;
	position: relative;
	z-index: 1;
}

.mine-tile {
	aspect-ratio: 1;
	min-height: 80px;
	min-width: 80px;
	background: var(--surface-color);
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 32px;
	cursor: pointer;
	transition: all var(--transition-fast);
	position: relative;
	overflow: hidden;
	z-index: 2;
}

.mine-tile:hover:not(.revealed):not(.disabled) {
	background: var(--surface-hover);
	border-color: var(--primary-color);
	transform: translateY(-2px);
}

.mine-tile:active:not(.revealed):not(.disabled) {
	transform: translateY(0);
}

.mine-tile.disabled {
	cursor: not-allowed;
	opacity: 0.5;
}

.mine-tile.revealed {
	cursor: default;
	animation: revealTile 0.3s ease;
}

.mine-tile.revealed.safe {
	background: var(--success-color);
	border-color: var(--success-color);
	color: white;
}

.mine-tile.revealed.bomb {
	background: var(--error-color);
	border-color: var(--error-color);
	color: white;
	animation: explode 0.5s ease;
}

@keyframes revealTile {
	0% {
		transform: rotateY(0deg);
	}
	50% {
		transform: rotateY(90deg);
	}
	100% {
		transform: rotateY(0deg);
	}
}

@keyframes explode {
	0%, 100% {
		transform: scale(1);
	}
	25% {
		transform: scale(1.2);
	}
	50% {
		transform: scale(0.95);
	}
	75% {
		transform: scale(1.1);
	}
}

/* Footer de la grille */
.board-footer {
	display: flex;
	justify-content: center;
	gap: 16px;
}

.board-footer .btn {
	min-width: 200px;
}

/* Responsive */
@media (max-width: 1024px) {
	.game-container {
		flex-direction: column;
	}
	
	.config-panel {
		max-width: 100%;
	}
	
	.mines-grid {
		max-width: 100%;
	}
}

@media (max-width: 640px) {
	.game-header {
		flex-direction: column;
		gap: 16px;
	}
	
	.mines-grid {
		gap: 8px;
		padding: 16px;
	}
	
	.mine-tile {
		font-size: 24px;
	}
	
	.game-stats {
		flex-direction: column;
		gap: 16px;
	}
}
