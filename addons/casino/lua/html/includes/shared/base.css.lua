/* Base CSS - Design glassmorphic rouge sombre pour le casino */

:root {
	/* Couleurs principales - CleanUI Rouge sombre */
	--primary-color: #C62828;
	--primary-light: #E53935;
	--primary-dark: #B71C1C;
	--accent-color: #D32F2F;
	--accent-light: #EF5350;
	
	/* Couleurs de fond - Foncées et propres */
	--background-dark: #0A0A0A;
	--background-medium: #121212;
	--background-light: #1E1E1E;
	
	/* Couleurs de surface - Flat design */
	--surface-color: #181818;
	--surface-hover: #202020;
	
	/* CleanUI - Pas de glassmorphisme */
	--card-bg: #1A1A1A;
	--card-border: #2A2A2A;
	--card-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
	
	/* Couleurs de texte */
	--text-primary: #FFFFFF;
	--text-secondary: #AAAAAA;
	--text-disabled: #666666;
	
	/* Couleurs d'état - CleanUI */
	--success-color: #43A047;
	--warning-color: #FB8C00;
	--error-color: #E53935;
	--info-color: #1E88E5;
	
	/* Bordures et ombres - CleanUI */
	--border-color: #2A2A2A;
	--border-radius: 4px;
	--border-radius-lg: 8px;
	--border-radius-xl: 12px;
	
	/* Ombres subtiles */
	--shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.2);
	--shadow-md: 0 2px 8px rgba(0, 0, 0, 0.3);
	--shadow-lg: 0 4px 16px rgba(0, 0, 0, 0.4);
	--shadow-xl: 0 8px 32px rgba(0, 0, 0, 0.5);
	
	/* Transitions */
	--transition-fast: 0.15s ease;
	--transition-normal: 0.3s ease;
	--transition-slow: 0.5s ease;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
	background: var(--background-dark);
	color: var(--text-primary);
	overflow: hidden;
	height: 100vh;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
}

/* Scrollbar personnalisé */
::-webkit-scrollbar {
	width: 8px;
	height: 8px;
}

::-webkit-scrollbar-track {
	background: var(--background-dark);
}

::-webkit-scrollbar-thumb {
	background: var(--primary-color);
	border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
	background: var(--primary-light);
}

/* Boutons CleanUI - Flat design */
.btn {
	padding: 12px 24px;
	font-size: 14px;
	font-weight: 600;
	border: none;
	border-radius: var(--border-radius);
	cursor: pointer;
	background: var(--primary-color);
	color: var(--text-primary);
	transition: all var(--transition-normal);
	box-shadow: var(--shadow-sm);
	text-transform: uppercase;
	letter-spacing: 0.5px;
	position: relative;
	overflow: hidden;
}

.btn::before {
	content: '';
	position: absolute;
	top: 50%;
	left: 50%;
	width: 0;
	height: 0;
	border-radius: 50%;
	background: rgba(255, 255, 255, 0.1);
	transform: translate(-50%, -50%);
	transition: width 0.6s, height 0.6s;
}

.btn:hover::before {
	width: 300px;
	height: 300px;
}

.btn:hover {
	background: var(--primary-light);
	box-shadow: var(--shadow-md);
	transform: translateY(-1px);
}

.btn:active {
	transform: translateY(0);
	box-shadow: var(--shadow-sm);
}

.btn:disabled {
	background: var(--surface-color);
	color: var(--text-disabled);
	cursor: not-allowed;
	box-shadow: none;
	transform: none;
	opacity: 0.6;
}

.btn-success {
	background: var(--success-color);
}

.btn-success:hover {
	background: #66BB6A;
	box-shadow: 0 2px 8px rgba(67, 160, 71, 0.4);
}

.btn-warning {
	background: var(--warning-color);
}

.btn-warning:hover {
	background: #FFA726;
	box-shadow: 0 2px 8px rgba(251, 140, 0, 0.4);
}

.btn-error {
	background: var(--error-color);
}

.btn-error:hover {
	background: #EF5350;
	box-shadow: 0 2px 8px rgba(229, 57, 53, 0.4);
}

.btn-secondary {
	background: var(--surface-color);
	color: var(--text-secondary);
}

.btn-secondary:hover {
	background: var(--surface-hover);
	box-shadow: var(--shadow-md);
}

/* Cards CleanUI - Flat design */
.card {
	background: var(--card-bg);
	border-radius: var(--border-radius-lg);
	padding: 24px;
	box-shadow: var(--card-shadow);
	border: 1px solid var(--card-border);
	transition: all var(--transition-normal);
}

.card:hover {
	box-shadow: var(--shadow-md);
	transform: translateY(-2px);
	border-color: var(--primary-color);
}

/* Animations */
@keyframes fadeIn {
	from {
		opacity: 0;
		transform: translateY(20px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

@keyframes slideInRight {
	from {
		opacity: 0;
		transform: translateX(50px);
	}
	to {
		opacity: 1;
		transform: translateX(0);
	}
}

@keyframes slideInLeft {
	from {
		opacity: 0;
		transform: translateX(-50px);
	}
	to {
		opacity: 1;
		transform: translateX(0);
	}
}

@keyframes pulse {
	0%, 100% {
		transform: scale(1);
	}
	50% {
		transform: scale(1.05);
	}
}

@keyframes shimmer {
	0% {
		background-position: -1000px 0;
	}
	100% {
		background-position: 1000px 0;
	}
}

.fade-in {
	animation: fadeIn 0.5s ease forwards;
}

.slide-in-right {
	animation: slideInRight 0.5s ease forwards;
}

.slide-in-left {
	animation: slideInLeft 0.5s ease forwards;
}

/* Utilitaires CleanUI */
.bordered {
	border: 1px solid var(--border-color);
}

.shadow {
	box-shadow: var(--shadow-md);
}

.text-accent {
	color: var(--accent-color);
}

/* Gradient text rouge */
.gradient-text {
	background: linear-gradient(135deg, var(--primary-light), var(--accent-color));
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	background-clip: text;
	filter: grayscale(1);
	-webkit-filter: grayscale(1);
}

/* Loading spinner rouge */
.spinner {
	width: 40px;
	height: 40px;
	border: 3px solid var(--surface-color);
	border-top-color: var(--primary-color);
	border-radius: 50%;
	animation: spin 1s linear infinite;
}

@keyframes spin {
	to { transform: rotate(360deg); }
}
]]
