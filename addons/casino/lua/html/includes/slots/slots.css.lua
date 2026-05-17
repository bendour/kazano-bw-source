
/* Le Bandit - Machine à Sous CSS */

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

/* Machine à sous */
.slot-machine {
	flex: 1;
	max-width: 850px;
	display: flex;
	flex-direction: column;
}

.machine-frame {
	background: linear-gradient(135deg, #1a0a00, #2d1810);
	border: 4px solid #8B4513;
	border-radius: 20px;
	padding: 20px;
	box-shadow: 
		0 10px 40px rgba(0, 0, 0, 0.5),
		inset 0 2px 10px rgba(139, 69, 19, 0.3);
	position: relative;
}

.machine-frame::before {
	content: '';
	position: absolute;
	top: -4px;
	left: -4px;
	right: -4px;
	bottom: -4px;
	background: linear-gradient(135deg, #CD853F, #8B4513, #654321);
	border-radius: 20px;
	z-index: -1;
}

/* Haut de la machine */
.machine-top {
	background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
	border: 3px solid #FFD700;
	border-radius: 12px 12px 0 0;
	padding: 12px;
	margin: -20px -20px 16px -20px;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.smokey-banner {
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 16px;
	font-size: 24px;
	font-weight: 700;
	color: #FFD700;
	text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
}

.smokey-icon {
	font-size: 32px;
	animation: bounce 2s infinite;
}

@keyframes bounce {
	0%, 100% { transform: translateY(0); }
	50% { transform: translateY(-10px); }
}

/* Container des rouleaux */
.reels-container {
	position: relative;
	background: #000;
	border: 4px solid #FFD700;
	border-radius: 12px;
	padding: 12px;
	margin-bottom: 16px;
	box-shadow: 
		inset 0 0 20px rgba(0, 0, 0, 0.8),
		0 4px 12px rgba(255, 215, 0, 0.3);
}

/* Grille 5x5 */
.reels-grid {
	display: grid;
	grid-template-columns: repeat(5, 1fr);
	gap: 6px;
	position: relative;
	z-index: 1;
}

.reel-cell {
	aspect-ratio: 1;
	background: linear-gradient(135deg, #1a1a1a, #0a0a0a);
	border: 2px solid #333;
	border-radius: 8px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 32px;
	position: relative;
	overflow: hidden;
	transition: all 0.3s ease;
}

.reel-cell::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background: linear-gradient(135deg, rgba(255, 255, 255, 0.1), transparent);
	pointer-events: none;
}

.reel-cell.spinning {
	animation: spin 0.1s linear infinite;
}

@keyframes spin {
	0% { transform: translateY(0); }
	100% { transform: translateY(-100%); }
}

.reel-cell.winning {
	background: linear-gradient(135deg, #FFD700, #FFA500);
	border-color: #FFD700;
	animation: pulse 0.5s ease-in-out 3;
	box-shadow: 0 0 20px rgba(255, 215, 0, 0.8);
}

@keyframes pulse {
	0%, 100% { transform: scale(1); }
	50% { transform: scale(1.1); }
}

.reel-cell.golden-square {
	background: linear-gradient(135deg, #FFD700, #FF8C00);
	border-color: #FFD700;
	box-shadow: 0 0 30px rgba(255, 215, 0, 1);
	animation: golden-glow 1s ease-in-out infinite;
}

@keyframes golden-glow {
	0%, 100% { box-shadow: 0 0 20px rgba(255, 215, 0, 0.8); }
	50% { box-shadow: 0 0 40px rgba(255, 215, 0, 1); }
}

/* Overlay de gain */
.win-overlay {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background: radial-gradient(circle, rgba(255, 215, 0, 0.3), transparent);
	opacity: 0;
	pointer-events: none;
	z-index: 2;
	transition: opacity 0.3s ease;
}

.win-overlay.active {
	opacity: 1;
	animation: flash 0.5s ease-in-out 3;
}

@keyframes flash {
	0%, 100% { opacity: 0; }
	50% { opacity: 1; }
}

/* Affichage des gains */
.win-display {
	background: linear-gradient(135deg, var(--surface-color), var(--background-medium));
	border: 2px solid var(--primary-color);
	border-radius: 12px;
	padding: 12px;
	margin-bottom: 12px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.win-amount {
	display: flex;
	align-items: center;
	gap: 12px;
}

.win-label {
	font-size: 14px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
}

.win-value {
	font-size: 32px;
	font-weight: 700;
	color: var(--success-color);
	text-shadow: 0 0 10px rgba(76, 175, 80, 0.5);
}

.win-multiplier {
	font-size: 18px;
	font-weight: 600;
	color: var(--primary-light);
}

/* Panneau de contrôle */
.controls-panel {
	background: linear-gradient(135deg, #2d1810, #1a0a00);
	border: 3px solid #8B4513;
	border-radius: 12px;
	padding: 16px;
}

.bet-controls {
	margin-bottom: 16px;
}

.control-label {
	display: block;
	margin-bottom: 12px;
}

.label-text {
	display: block;
	font-size: 14px;
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
	padding: 12px 16px;
	color: var(--text-primary);
	font-size: 18px;
	font-weight: 600;
	text-align: center;
	transition: all var(--transition-fast);
}

.bet-input:focus {
	outline: none;
	border-color: var(--primary-color);
	box-shadow: 0 0 0 3px rgba(198, 40, 40, 0.2);
}

.quick-bets {
	display: grid;
	grid-template-columns: repeat(5, 1fr);
	gap: 8px;
	margin-top: 12px;
}

.quick-bets .btn {
	padding: 8px;
	font-size: 12px;
}

/* Bouton SPIN */
.spin-btn {
	width: 100%;
	padding: 16px;
	font-size: 22px;
	font-weight: 700;
	background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
	border: 3px solid #FFD700;
	border-radius: 12px;
	color: #FFD700;
	text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
	box-shadow: 
		0 6px 20px rgba(198, 40, 40, 0.4),
		inset 0 2px 8px rgba(255, 255, 255, 0.2);
	transition: all 0.3s ease;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 12px;
}

.spin-btn:hover {
	transform: translateY(-2px);
	box-shadow: 
		0 8px 25px rgba(198, 40, 40, 0.5),
		inset 0 2px 8px rgba(255, 255, 255, 0.3);
}

.spin-btn:active {
	transform: translateY(0);
}

.spin-btn:disabled {
	opacity: 0.5;
	cursor: not-allowed;
	transform: none;
}

.spin-btn.spinning {
	animation: spin-button 1s linear infinite;
}

@keyframes spin-button {
	0% { transform: rotate(0deg); }
	100% { transform: rotate(360deg); }
}

.spin-icon {
	font-size: 32px;
	animation: spin-icon 2s linear infinite;
}

@keyframes spin-icon {
	0% { transform: rotate(0deg); }
	100% { transform: rotate(360deg); }
}

/* Panneau d'informations */
.info-panel {
	width: 340px;
	display: flex;
	flex-direction: column;
	gap: 16px;
	overflow-y: auto;
	max-height: 100%;
	padding-right: 8px;
}

.card {
	background: var(--card-bg);
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius-lg);
	padding: 18px;
	box-shadow: var(--shadow-md);
	flex-shrink: 0;
}

.card h3 {
	font-size: 16px;
	font-weight: 700;
	margin: 0 0 14px 0;
	color: var(--text-primary);
	border-bottom: 2px solid var(--primary-color);
	padding-bottom: 10px;
	text-transform: uppercase;
	letter-spacing: 1px;
}

/* Stats */
.stat-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 8px 0;
	border-bottom: 1px solid var(--border-color);
}

.stat-row:last-child {
	border-bottom: none;
}

.stat-label {
	font-size: 13px;
	color: var(--text-secondary);
}

.stat-value {
	font-size: 14px;
	font-weight: 700;
	color: var(--primary-light);
}

/* Bonus */
.bonus-list {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.bonus-item {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 12px;
	background: var(--surface-color);
	border: 1px solid var(--border-color);
	border-radius: var(--border-radius);
	transition: all var(--transition-fast);
	opacity: 0.5;
}

.bonus-item.active {
	opacity: 1;
	border-color: var(--success-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(76, 175, 80, 0.1));
	box-shadow: 0 0 15px rgba(76, 175, 80, 0.3);
}

.bonus-icon {
	font-size: 28px;
}

.bonus-info {
	flex: 1;
}

.bonus-name {
	font-size: 14px;
	font-weight: 600;
	color: var(--text-primary);
	margin-bottom: 4px;
}

.bonus-desc {
	font-size: 12px;
	color: var(--text-secondary);
}

/* Tableau des gains */
.paytable-card {
	max-height: none;
	overflow: visible;
}

.paytable {
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.paytable-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 10px 12px;
	background: linear-gradient(135deg, var(--surface-color), rgba(198, 40, 40, 0.05));
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius);
	transition: all 0.2s ease;
}

.paytable-row:hover {
	border-color: var(--primary-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(198, 40, 40, 0.1));
	transform: translateX(5px);
	box-shadow: 0 2px 8px rgba(198, 40, 40, 0.2);
}

.paytable-row .symbol {
	font-size: 22px;
	text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.paytable-row .payout {
	font-size: 15px;
	font-weight: 700;
	color: #FFD700;
	background: linear-gradient(135deg, #FFD700, #FFA500);
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	background-clip: text;
	text-shadow: 0 0 10px rgba(255, 215, 0, 0.3);
}

.paytable-note {
	font-size: 11px;
	color: var(--text-secondary);
	text-align: center;
	margin: 10px 0 0 0;
	padding: 8px;
	background: rgba(198, 40, 40, 0.1);
	border: 1px solid var(--border-color);
	border-radius: var(--border-radius);
	font-weight: 600;
}

/* Responsive */
@media (max-width: 1400px) {
	.game-container {
		flex-direction: column;
	}
	
	.slot-machine {
		max-width: 100%;
	}
	
	.info-panel {
		width: 100%;
		flex-direction: row;
		flex-wrap: wrap;
	}
	
	.info-panel .card {
		flex: 1;
		min-width: 300px;
	}
}

@media (max-width: 768px) {
	.game-header {
		flex-direction: column;
		gap: 16px;
		padding: 16px;
	}
	
	.reel-cell {
		font-size: 32px;
	}
	
	.info-panel {
		flex-direction: column;
	}
	
	.info-panel .card {
		width: 100%;
	}
}
