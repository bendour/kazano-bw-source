return [[
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background: transparent;
	color: #fff;
	overflow: hidden;
}

.container {
	width: 100%;
	height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.header {
	text-align: center;
	margin-bottom: 30px;
}

.header h1 {
	font-size: 48px;
	text-shadow: 0 0 20px rgba(255, 215, 0, 0.8);
	margin-bottom: 10px;
	animation: glow 2s ease-in-out infinite;
}

@keyframes glow {
	0%, 100% {
		text-shadow: 0 0 20px rgba(255, 215, 0, 0.8);
	}
	50% {
		text-shadow: 0 0 40px rgba(255, 215, 0, 1);
	}
}

.wheelspins-count {
	font-size: 24px;
	color: #FFD700;
	font-weight: bold;
}

.wheel-container {
	position: relative;
	margin: 30px 0;
}

.wheel-pointer {
	position: absolute;
	top: -30px;
	left: 50%;
	transform: translateX(-50%);
	width: 0;
	height: 0;
	border-left: 20px solid transparent;
	border-right: 20px solid transparent;
	border-top: 40px solid #FFD700;
	z-index: 10;
	filter: drop-shadow(0 0 10px rgba(255, 215, 0, 0.8));
}

#wheelCanvas {
	border-radius: 50%;
	box-shadow: 0 0 40px rgba(255, 215, 0, 0.5);
}

.controls {
	display: flex;
	gap: 20px;
	margin-top: 30px;
}

.btn {
	padding: 15px 40px;
	font-size: 18px;
	font-weight: bold;
	border: none;
	border-radius: 10px;
	cursor: pointer;
	transition: all 0.3s ease;
	text-transform: uppercase;
	box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
}

.btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 7px 20px rgba(0, 0, 0, 0.4);
}

.btn:active {
	transform: translateY(0);
}

.btn-spin {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	color: white;
}

.btn-spin:hover {
	background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
}

.btn-spin:disabled {
	background: #555;
	cursor: not-allowed;
	opacity: 0.5;
}

.btn-close {
	background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
	color: white;
}

.btn-close:hover {
	background: linear-gradient(135deg, #f5576c 0%, #f093fb 100%);
}

.modal {
	display: none;
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background: rgba(0, 0, 0, 0.8);
	z-index: 100;
	align-items: center;
	justify-content: center;
}

.modal.show {
	display: flex;
	animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
	from {
		opacity: 0;
	}
	to {
		opacity: 1;
	}
}

.modal-content {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	padding: 40px;
	border-radius: 20px;
	text-align: center;
	max-width: 500px;
	box-shadow: 0 0 50px rgba(255, 215, 0, 0.5);
	animation: scaleIn 0.3s ease;
}

@keyframes scaleIn {
	from {
		transform: scale(0.8);
		opacity: 0;
	}
	to {
		transform: scale(1);
		opacity: 1;
	}
}

.modal-content h2 {
	font-size: 36px;
	margin-bottom: 20px;
	text-shadow: 0 0 20px rgba(255, 255, 255, 0.5);
}

.reward-display {
	margin: 30px 0;
	padding: 20px;
	background: rgba(0, 0, 0, 0.3);
	border-radius: 10px;
}

.reward-name {
	font-size: 32px;
	font-weight: bold;
	margin-bottom: 10px;
	color: #FFD700;
}

.reward-desc {
	font-size: 18px;
	color: #fff;
}

.btn-claim {
	background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
	color: white;
	padding: 15px 50px;
	font-size: 20px;
}

.btn-claim:hover {
	background: linear-gradient(135deg, #f5576c 0%, #f093fb 100%);
}

@keyframes spin {
	from {
		transform: rotate(0deg);
	}
	to {
		transform: rotate(360deg);
	}
}

.spinning {
	animation: spin 0.1s linear infinite;
}
]]
