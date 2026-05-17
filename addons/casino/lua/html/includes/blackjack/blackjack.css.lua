/* Styles CleanUI rouge sombre pour le Blackjack */

/* Notification minimaliste en haut à droite */
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

.notification.blackjack {
	border-color: #FFD700;
	color: #FFD700;
	animation: notifGlow 1.5s ease-in-out infinite;
}

@keyframes notifGlow {
	0%, 100% {
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3), 0 0 20px rgba(255, 215, 0, 0.3);
	}
	50% {
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3), 0 0 30px rgba(255, 215, 0, 0.6);
	}
}

#app {
	display: flex;
	flex-direction: column;
	height: 100vh;
	overflow: hidden;
	background: var(--background-dark);
}

/* Header CleanUI */
.game-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 20px 32px;
	background: var(--surface-color);
	border-bottom: 2px solid var(--primary-color);
	box-shadow: var(--shadow-md);
	animation: slideInLeft 0.5s ease;
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
	letter-spacing: 1px;
}

/* Table de jeu CleanUI */
.game-table {
	flex: 1;
	position: relative;
	background: var(--background-medium);
	border: none;
	box-shadow: inset 0 0 50px rgba(0, 0, 0, 0.5);
	overflow: hidden;
}

/* Zone croupier */
.dealer-area {
	position: absolute;
	top: 80px;
	left: 50%;
	transform: translateX(-50%);
	text-align: center;
	animation: fadeIn 0.8s ease;
}

/* Zone joueur */
.player-area {
	position: absolute;
	bottom: 180px;
	left: 50%;
	transform: translateX(-50%);
	text-align: center;
	animation: fadeIn 0.8s ease 0.2s both;
}

/* Labels des joueurs */
.player-label {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 16px;
	margin-bottom: 20px;
	padding: 12px 24px;
	background: var(--card-bg);
	border-radius: var(--border-radius);
	border: 1px solid var(--border-color);
	box-shadow: var(--card-shadow);
	min-width: 300px;
	transition: all var(--transition-normal);
}

.player-label:hover {
	border-color: var(--primary-color);
	box-shadow: var(--shadow-md);
}

.dealer-area .player-label {
	margin-bottom: 0;
	margin-top: 20px;
}

.player-name {
	font-size: 18px;
	font-weight: 700;
	color: var(--text-primary);
	text-transform: uppercase;
	letter-spacing: 1px;
}

.player-score {
	font-size: 24px;
	font-weight: 800;
	color: var(--accent-color);
	min-width: 80px;
	text-align: right;
}

/* Conteneur de cartes */
.cards-container {
	display: flex;
	justify-content: center;
	gap: 12px;
	min-height: 140px;
	perspective: 1000px;
}

/* Cartes */
.card {
	width: 90px;
	height: 126px;
	background: white;
	border: 3px solid #333;
	border-radius: 12px;
	box-shadow: var(--shadow-lg);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 40px;
	font-weight: 800;
	position: relative;
	transform-style: preserve-3d;
	transition: transform 0.3s;
}

/* Animations des cartes */
@keyframes dealCard {
	0% {
		transform: translateY(-300px) translateX(-50px) rotateZ(-15deg);
		opacity: 0;
	}
	60% {
		transform: translateY(20px) translateX(0) rotateZ(5deg);
	}
	100% {
		transform: translateY(0) translateX(0) rotateZ(0);
		opacity: 1;
	}
}

@keyframes flipCard {
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

.card.hidden {
	background: linear-gradient(135deg, #3a0000 25%, transparent 25%, transparent 50%, #3a0000 50%, #3a0000 75%, transparent 75%, transparent),
				linear-gradient(135deg, transparent 25%, #5a0000 25%, #5a0000 50%, transparent 50%, transparent 75%, #5a0000 75%, #5a0000);
	background-size: 20px 20px;
	background-position: 0 0, 10px 10px;
	color: #8B0000;
	font-size: 48px;
	box-shadow: inset 0 0 20px rgba(0,0,0,0.6), var(--shadow-lg);
}

.card.hidden .card-back {
	font-size: 64px;
	font-weight: 900;
	text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}

.card.back {
	background: linear-gradient(135deg, #3a0000 25%, transparent 25%, transparent 50%, #3a0000 50%, #3a0000 75%, transparent 75%, transparent),
				linear-gradient(135deg, transparent 25%, #5a0000 25%, #5a0000 50%, transparent 50%, transparent 75%, #5a0000 75%, #5a0000);
	background-size: 20px 20px;
	background-position: 0 0, 10px 10px;
	box-shadow: inset 0 0 20px rgba(0,0,0,0.4), var(--shadow-lg);
}

.card.red {
	color: #dc143c;
}

.card.black {
	color: #1a1a1a;
}

.card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	border-radius: 10px;
	background: linear-gradient(135deg, rgba(255,255,255,0.3) 0%, transparent 50%);
	pointer-events: none;
}

/* Zone de mise CleanUI */
.betting-area {
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	padding: 40px;
	border-radius: var(--border-radius-lg);
	text-align: center;
	min-width: 600px;
	animation: fadeIn 0.5s ease;
	background: var(--card-bg);
	border: 2px solid var(--primary-color);
	box-shadow: var(--shadow-lg);
}

.betting-area h2 {
	font-size: 28px;
	font-weight: 700;
	margin-bottom: 30px;
	background: linear-gradient(135deg, var(--primary-light), var(--accent-light));
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	background-clip: text;
	letter-spacing: 1px;
}

.bet-display {
	display: flex;
	justify-content: center;
	align-items: center;
	gap: 16px;
	padding: 20px 32px;
	background: var(--surface-color);
	border-radius: var(--border-radius);
	margin-bottom: 20px;
	border: 1px solid var(--border-color);
	box-shadow: var(--card-shadow);
}

.bet-label {
	font-size: 16px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
	font-weight: 600;
	min-width: 60px;
}

.bet-input {
	flex: 1;
	font-size: 32px;
	font-weight: 700;
	color: var(--accent-color);
	background: var(--background-dark);
	border: 2px solid var(--border-color);
	border-radius: var(--border-radius);
	padding: 12px 20px;
	text-align: center;
	outline: none;
	transition: all var(--transition-normal);
	max-width: 300px;
}

.bet-input:focus {
	border-color: var(--primary-color);
	box-shadow: 0 0 0 3px rgba(198, 40, 40, 0.2);
	background: var(--surface-color);
}

.bet-input::placeholder {
	color: var(--text-secondary);
	opacity: 0.5;
	font-size: 18px;
}

.bet-currency {
	font-size: 24px;
	color: var(--primary-color);
	font-weight: 700;
	min-width: 40px;
}

.bet-info {
	text-align: center;
	margin-bottom: 24px;
}

.bet-limits {
	font-size: 13px;
	color: var(--text-secondary);
	opacity: 0.8;
}

/* Jetons (désactivés - remplacés par input)
.chips-container {
	display: grid;
	grid-template-columns: repeat(6, 1fr);
	gap: 16px;
	margin-bottom: 32px;
}

.chip {
	width: 80px;
	height: 80px;
	border-radius: 50%;
	border: 4px solid;
	display: flex;
	align-items: center;
	justify-content: center;
	font-weight: 800;
	cursor: pointer;
	transition: all var(--transition-normal);
	box-shadow: var(--shadow-md);
	position: relative;
	overflow: hidden;
}

.chip::before {
	content: '';
	position: absolute;
	width: 60%;
	height: 60%;
	border-radius: 50%;
	border: 3px dashed rgba(255,255,255,0.5);
}

.chip:nth-child(1) {
	background: linear-gradient(135deg, #ffffff, #e0e0e0);
	border-color: #333;
	color: #333;
}

.chip:nth-child(2) {
	background: linear-gradient(135deg, #ff4444, #cc0000);
	border-color: #fff;
	color: #fff;
}

.chip:nth-child(3) {
	background: linear-gradient(135deg, #4444ff, #0000cc);
	border-color: #fff;
	color: #fff;
}

.chip:nth-child(4) {
	background: linear-gradient(135deg, #1a1a1a, #000);
	border-color: #ffa500;
	color: #ffa500;
}

.chip:nth-child(5) {
	background: linear-gradient(135deg, #ff00ff, #cc00cc);
	border-color: #fff;
	color: #fff;
}

.chip:nth-child(6) {
	background: linear-gradient(135deg, #ffa500, #ff8c00);
	border-color: #fff;
	color: #fff;
}

.chip:hover {
	transform: scale(1.1) translateY(-4px);
	box-shadow: var(--shadow-xl);
}

.chip:active {
	transform: scale(0.95);
}

.chip-value {
	font-size: 18px;
	text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
	z-index: 1;
}
*/

/* Actions de mise CleanUI */
.betting-actions {
	display: flex;
	gap: 16px;
	justify-content: center;
}

.betting-actions .btn {
	flex: 1;
	max-width: 200px;
}

/* Contrôles de jeu CleanUI */
.game-controls {
	position: absolute;
	bottom: 30px;
	left: 50%;
	transform: translateX(-50%);
	display: flex;
	gap: 16px;
	animation: slideInRight 0.5s ease;
}

.game-controls .btn {
	padding: 14px 28px;
	font-size: 15px;
	font-weight: 600;
}

.game-controls .btn span {
	display: flex;
	align-items: center;
	gap: 8px;
}

/* Message de résultat CleanUI - utilisé pour les erreurs de mise */
.game-message {
	position: fixed;
	top: 80px;
	left: 50%;
	transform: translateX(-50%) translateY(-100px);
	font-size: 16px;
	font-weight: 600;
	padding: 12px 24px;
	border-radius: 8px;
	background: var(--surface-color);
	border-left: 4px solid;
	pointer-events: none;
	z-index: 9998;
	transition: all 0.3s ease;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
	opacity: 0;
}

.game-message.show {
	transform: translateX(-50%) translateY(0);
	opacity: 1;
}

.game-message.lose {
	color: var(--error-color);
	border-color: var(--error-color);
}
		0 0 40px rgba(255, 193, 7, 0.5);
}



/* Responsive */
@media (max-width: 768px) {
	.game-header {
		flex-direction: column;
		gap: 16px;
	}

	.betting-area {
		min-width: 90%;
		padding: 24px;
	}

	.chips-container {
		grid-template-columns: repeat(3, 1fr);
	}

	.game-controls {
		flex-wrap: wrap;
		justify-content: center;
	}

	.game-message {
		font-size: 40px;
		padding: 24px 48px;
	}
}
