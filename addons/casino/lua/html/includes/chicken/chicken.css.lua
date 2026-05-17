/* Chicken Road CSS */

.game-container {
	display: flex;
	gap: 20px;
	padding: 20px;
	max-width: 1400px;
	margin: 0 auto;
	height: calc(100vh - 100px);
}

.config-panel {
	flex: 0 0 350px;
	display: flex;
	flex-direction: column;
	gap: 20px;
}

.game-board {
	flex: 1;
	display: flex;
	align-items: center;
	justify-content: center;
}

/* Configuration */
.control-group {
	margin-bottom: 24px;
}

.control-label {
	display: block;
	margin-bottom: 12px;
}

.label-text {
	display: block;
	font-size: 14px;
	color: var(--text-secondary);
	margin-bottom: 8px;
	font-weight: 600;
}

.input-group {
	display: flex;
	gap: 8px;
	align-items: center;
}

.bet-input {
	flex: 1;
	padding: 12px;
	background: var(--background-medium);
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius);
	color: var(--text-primary);
	font-size: 16px;
	font-weight: 600;
	text-align: center;
	transition: all 0.2s;
}

.bet-input:focus {
	outline: none;
	border-color: var(--primary-color);
	box-shadow: 0 0 0 3px rgba(198, 40, 40, 0.1);
}

.quick-bets {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 8px;
	margin-top: 8px;
}

/* Difficulté */
.difficulty-buttons {
	display: grid;
	grid-template-columns: repeat(2, 1fr);
	gap: 12px;
}

.difficulty-btn {
	padding: 12px;
	background: var(--background-medium);
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius);
	color: var(--text-primary);
	cursor: pointer;
	transition: all 0.2s;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 4px;
}

.difficulty-btn:hover {
	border-color: var(--primary-color);
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.difficulty-btn.active {
	background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
	border-color: var(--primary-color);
	box-shadow: 0 4px 12px rgba(198, 40, 40, 0.4);
}

.diff-name {
	font-weight: 600;
	font-size: 14px;
}

.diff-info {
	font-size: 12px;
	color: var(--text-secondary);
}

.difficulty-btn.active .diff-info {
	color: rgba(255, 255, 255, 0.8);
}

/* Boutons d'action */
.action-buttons {
	display: flex;
	flex-direction: column;
	gap: 12px;
	margin-top: 8px;
}

.btn-primary {
	background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
	border-color: var(--primary-color);
	color: white;
	padding: 16px;
	font-size: 16px;
}

.btn-primary:hover {
	background: linear-gradient(135deg, var(--primary-light), var(--primary-color));
	box-shadow: 0 4px 16px rgba(198, 40, 40, 0.4);
}

.btn-primary:disabled {
	opacity: 0.5;
	cursor: not-allowed;
	transform: none !important;
}

.btn-success {
	background: linear-gradient(135deg, var(--success-color), #388E3C);
	border-color: var(--success-color);
	color: white;
	padding: 16px;
	font-size: 16px;
	animation: pulse-glow 2s ease-in-out infinite;
}

.btn-success:hover {
	background: linear-gradient(135deg, #66BB6A, var(--success-color));
	box-shadow: 0 4px 16px rgba(76, 175, 80, 0.4);
}

@keyframes pulse-glow {
	0%, 100% { box-shadow: 0 4px 12px rgba(76, 175, 80, 0.4); }
	50% { box-shadow: 0 4px 20px rgba(76, 175, 80, 0.6); }
}

/* Statistiques */
.stats-card h3 {
	margin-bottom: 16px;
}

.stats-grid {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.stat-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12px;
	background: var(--background-medium);
	border-radius: var(--border-radius);
}

.stat-label {
	font-size: 14px;
	color: var(--text-secondary);
}

.stat-value {
	font-size: 18px;
	font-weight: 700;
	color: var(--text-primary);
}

/* Grille de jeu */
.grid-container {
	display: grid;
	grid-template-columns: repeat(5, 1fr);
	gap: 12px;
	padding: 20px;
	background: var(--card-bg);
	border: 2px solid var(--border-color);
	border-radius: 16px;
	max-width: 600px;
	box-shadow: var(--shadow-lg);
}

.tile {
	aspect-ratio: 1;
	background: linear-gradient(135deg, var(--background-medium), var(--background-dark));
	border: 2px solid var(--border-color);
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 48px;
	cursor: pointer;
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	position: relative;
	overflow: hidden;
}

.tile::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background: linear-gradient(135deg, transparent, rgba(255, 255, 255, 0.1));
	opacity: 0;
	transition: opacity 0.3s;
}

.tile:not(.revealed):not(.disabled):hover {
	transform: translateY(-8px);
	border-color: var(--primary-color);
	box-shadow: 0 8px 20px rgba(198, 40, 40, 0.4);
}

.tile:not(.revealed):not(.disabled):hover::before {
	opacity: 1;
}

.tile.disabled {
	cursor: not-allowed;
	opacity: 0.6;
}

.tile.revealed {
	cursor: default;
	animation: reveal 0.5s ease-out;
}

.tile.revealed.safe {
	background: linear-gradient(135deg, #4CAF50, #388E3C);
	border-color: #4CAF50;
	box-shadow: 0 4px 16px rgba(76, 175, 80, 0.4);
}

.tile.revealed.bone {
	background: linear-gradient(135deg, #f44336, #d32f2f);
	border-color: #f44336;
	box-shadow: 0 4px 16px rgba(244, 67, 54, 0.4);
	animation: shake 0.5s ease-out, reveal 0.5s ease-out;
}

@keyframes reveal {
	0% {
		transform: scale(0.8) rotateY(180deg);
		opacity: 0;
	}
	100% {
		transform: scale(1) rotateY(0deg);
		opacity: 1;
	}
}

@keyframes shake {
	0%, 100% { transform: translateX(0); }
	25% { transform: translateX(-10px); }
	75% { transform: translateX(10px); }
}

/* Notification personnalisée */
.notification {
	position: fixed;
	top: 100px;
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
	min-width: 300px;
	box-shadow: var(--shadow-lg);
}

.notification.show {
	opacity: 1;
	transform: translateX(0);
}

.notification.started {
	border-color: #2196F3;
	background: linear-gradient(135deg, var(--surface-color), rgba(33, 150, 243, 0.1));
}

.notification.cashout,
.notification.perfect {
	border-color: var(--success-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(76, 175, 80, 0.1));
}

.notification.lose {
	border-color: var(--error-color);
	background: linear-gradient(135deg, var(--surface-color), rgba(244, 67, 54, 0.1));
}

.notification.error {
	border-color: #FF9800;
	background: linear-gradient(135deg, var(--surface-color), rgba(255, 152, 0, 0.1));
}

/* Responsive */
@media (max-width: 1200px) {
	.game-container {
		flex-direction: column;
	}
	
	.config-panel {
		flex: 0 0 auto;
	}
	
	.grid-container {
		max-width: 500px;
	}
}

@media (max-width: 768px) {
	.difficulty-buttons {
		grid-template-columns: 1fr;
	}
	
	.grid-container {
		gap: 8px;
		max-width: 100%;
	}
	
	.tile {
		font-size: 32px;
	}
}
