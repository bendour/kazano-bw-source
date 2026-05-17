/* Styles pour le menu principal du casino */

#app {
	display: flex;
	flex-direction: column;
	height: 100vh;
	overflow: hidden;
}

/* Header */
.header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 20px 32px;
	border-bottom: 1px solid var(--border-color);
	animation: slideInLeft 0.5s ease;
}

.header-left, .header-center, .header-right {
	flex: 1;
}

.header-center {
	display: flex;
	justify-content: center;
}

.header-right {
	display: flex;
	justify-content: flex-end;
}

.logo {
	font-size: 28px;
	font-weight: 800;
	letter-spacing: 2px;
}

.balance-display {
	display: flex;
	align-items: center;
	gap: 12px;
	background: var(--surface-color);
	padding: 12px 24px;
	border-radius: var(--border-radius-lg);
	box-shadow: var(--shadow-md);
	border: 2px solid var(--border-color);
}

.balance-label {
	font-size: 14px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 1px;
	font-weight: 600;
}

.balance-amount {
	font-size: 32px;
	font-weight: 800;
	color: var(--accent-color);
	text-shadow: 0 2px 8px rgba(255, 193, 7, 0.3);
}

.balance-currency {
	font-size: 20px;
	color: var(--text-secondary);
	font-weight: 600;
}

/* Navigation */
.navigation {
	display: flex;
	gap: 8px;
	padding: 16px 32px;
	background: var(--surface-color);
	border-bottom: 1px solid var(--border-color);
	animation: slideInRight 0.5s ease;
}

.nav-item {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 8px;
	padding: 16px;
	background: transparent;
	border: 2px solid transparent;
	border-radius: var(--border-radius-md);
	cursor: pointer;
	transition: all var(--transition-normal);
	color: var(--text-secondary);
}

.nav-item:hover {
	background: var(--surface-hover);
	border-color: var(--primary-color);
	color: var(--text-primary);
}

.nav-item.active {
	background: var(--primary-color);
	border-color: var(--primary-color);
	color: var(--text-primary);
	box-shadow: var(--shadow-md);
}

.nav-icon {
	font-size: 24px;
}

.nav-label {
	font-size: 13px;
	font-weight: 600;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

/* Main Content */
.main-content {
	flex: 1;
	overflow-y: auto;
	padding: 32px;
}

.content-section {
	display: none;
	animation: fadeIn 0.5s ease;
}

.content-section.active {
	display: block;
}

.section-header {
	text-align: center;
	margin-bottom: 48px;
}

.section-header h2 {
	font-size: 36px;
	font-weight: 800;
	margin-bottom: 8px;
	background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	background-clip: text;
}

.section-subtitle {
	font-size: 16px;
	color: var(--text-secondary);
}

/* Games Grid */
.games-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
	gap: 24px;
	max-width: 1400px;
	margin: 0 auto;
}

.game-card {
	display: flex;
	flex-direction: column;
	gap: 20px;
	padding: 32px;
	position: relative;
	overflow: hidden;
	cursor: pointer;
}

.game-card::before {
	content: '';
	position: absolute;
	top: 0;
	left: -100%;
	width: 100%;
	height: 100%;
	background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
	transition: left 0.6s;
}

.game-card:hover::before {
	left: 100%;
}

.game-card.disabled {
	opacity: 0.6;
	cursor: not-allowed;
}

.game-card.disabled:hover {
	transform: translateY(0);
	border-color: var(--border-color);
}

.game-icon {
	font-size: 64px;
	text-align: center;
	animation: pulse 2s infinite;
}

.game-info {
	flex: 1;
}

.game-title {
	font-size: 24px;
	font-weight: 700;
	margin-bottom: 12px;
	color: var(--text-primary);
}

.game-description {
	font-size: 14px;
	color: var(--text-secondary);
	line-height: 1.6;
	margin-bottom: 20px;
}

.game-stats {
	display: flex;
	gap: 20px;
	padding-top: 16px;
	border-top: 1px solid var(--border-color);
}

.stat {
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.stat-label {
	font-size: 12px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.stat-value {
	font-size: 18px;
	font-weight: 700;
	color: var(--primary-color);
}

.game-play-btn {
	width: 100%;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.btn-arrow {
	font-size: 20px;
	transition: transform var(--transition-normal);
}

.game-play-btn:hover .btn-arrow {
	transform: translateX(4px);
}

/* Stats Grid */
.stats-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
	gap: 24px;
	max-width: 1200px;
	margin: 0 auto;
}

.stat-card {
	display: flex;
	align-items: center;
	gap: 20px;
	padding: 24px;
}

.stat-icon {
	font-size: 48px;
	width: 80px;
	height: 80px;
	display: flex;
	align-items: center;
	justify-content: center;
	background: var(--background-light);
	border-radius: var(--border-radius-lg);
}

.stat-content {
	flex: 1;
}

.stat-content h4 {
	font-size: 14px;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 8px;
	font-weight: 600;
}

.stat-number {
	font-size: 32px;
	font-weight: 800;
	color: var(--primary-color);
}

/* History List */
.history-list {
	max-width: 900px;
	margin: 0 auto;
}

.empty-state {
	text-align: center;
	padding: 80px 20px;
}

.empty-icon {
	font-size: 64px;
	margin-bottom: 16px;
	opacity: 0.5;
}

.empty-state p {
	font-size: 16px;
	color: var(--text-secondary);
}

/* Settings List */
.settings-list {
	max-width: 800px;
	margin: 0 auto;
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.setting-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 24px 32px;
}

.setting-info h4 {
	font-size: 18px;
	font-weight: 600;
	margin-bottom: 4px;
	color: var(--text-primary);
}

.setting-info p {
	font-size: 14px;
	color: var(--text-secondary);
}

/* Toggle Switch */
.toggle {
	position: relative;
	display: inline-block;
	width: 60px;
	height: 32px;
}

.toggle input {
	opacity: 0;
	width: 0;
	height: 0;
}

.toggle-slider {
	position: absolute;
	cursor: pointer;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: var(--surface-hover);
	transition: var(--transition-normal);
	border-radius: 32px;
	border: 2px solid var(--border-color);
}

.toggle-slider:before {
	position: absolute;
	content: "";
	height: 24px;
	width: 24px;
	left: 2px;
	bottom: 2px;
	background-color: var(--text-primary);
	transition: var(--transition-normal);
	border-radius: 50%;
}

.toggle input:checked + .toggle-slider {
	background-color: var(--primary-color);
	border-color: var(--primary-color);
}

.toggle input:checked + .toggle-slider:before {
	transform: translateX(28px);
}

/* Toast Notifications */
.toast {
	position: fixed;
	bottom: 32px;
	right: 32px;
	background: var(--surface-color);
	color: var(--text-primary);
	padding: 16px 24px;
	border-radius: var(--border-radius-md);
	box-shadow: var(--shadow-xl);
	border: 1px solid var(--border-color);
	min-width: 300px;
	transform: translateY(150%);
	transition: transform var(--transition-normal);
	z-index: 1000;
}

.toast.show {
	transform: translateY(0);
}

.toast.success {
	border-left: 4px solid var(--success-color);
}

.toast.error {
	border-left: 4px solid var(--error-color);
}

.toast.warning {
	border-left: 4px solid var(--warning-color);
}

/* Leaderboard Styles */
.leaderboard-container {
	margin-top: 24px;
	padding: 0;
	overflow: hidden;
}

.leaderboard-list {
	max-height: 600px;
	overflow-y: auto;
}

.leaderboard-item {
	display: flex;
	align-items: center;
	gap: 16px;
	padding: 16px 24px;
	border-bottom: 1px solid var(--border-color);
	transition: all var(--transition-normal);
	animation: fadeIn 0.5s ease;
}

.leaderboard-item:last-child {
	border-bottom: none;
}

.leaderboard-item:hover {
	background: var(--surface-hover);
}

.leaderboard-rank {
	font-size: 24px;
	font-weight: 800;
	min-width: 50px;
	text-align: center;
	color: var(--text-secondary);
}

.leaderboard-item:nth-child(1) .leaderboard-rank {
	color: #FFD700;
	font-size: 32px;
	text-shadow: 0 2px 8px rgba(255, 215, 0, 0.5);
}

.leaderboard-item:nth-child(2) .leaderboard-rank {
	color: #C0C0C0;
	font-size: 28px;
	text-shadow: 0 2px 8px rgba(192, 192, 192, 0.5);
}

.leaderboard-item:nth-child(3) .leaderboard-rank {
	color: #CD7F32;
	font-size: 28px;
	text-shadow: 0 2px 8px rgba(205, 127, 50, 0.5);
}

.leaderboard-player {
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.leaderboard-player-name {
	font-size: 18px;
	font-weight: 700;
	color: var(--text-primary);
}

.leaderboard-player-info {
	font-size: 12px;
	color: var(--text-secondary);
	display: flex;
	align-items: center;
	gap: 8px;
}

.leaderboard-game-icon {
	font-size: 14px;
}

.leaderboard-win {
	font-size: 24px;
	font-weight: 800;
	color: var(--success-color);
	text-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
	white-space: nowrap;
}

.leaderboard-item:nth-child(1) .leaderboard-win {
	color: #FFD700;
	text-shadow: 0 2px 8px rgba(255, 215, 0, 0.5);
}

/* Responsive */
@media (max-width: 768px) {
	.header {
		flex-direction: column;
		gap: 16px;
		padding: 16px;
	}

	.header-left, .header-center, .header-right {
		width: 100%;
		justify-content: center;
	}

	.navigation {
		padding: 12px;
	}

	.nav-label {
		display: none;
	}

	.main-content {
		padding: 16px;
	}

	.games-grid {
		grid-template-columns: 1fr;
	}
	
	.leaderboard-rank {
		font-size: 18px;
		min-width: 40px;
	}
	
	.leaderboard-item:nth-child(1) .leaderboard-rank,
	.leaderboard-item:nth-child(2) .leaderboard-rank,
	.leaderboard-item:nth-child(3) .leaderboard-rank {
		font-size: 22px;
	}
	
	.leaderboard-player-name {
		font-size: 16px;
	}
	
	.leaderboard-win {
		font-size: 18px;
	}
}

