return [[
// Vote Rewards Wheelspin JavaScript
let canvas, ctx;
let rewards = [];
let wheelspins = 0;
let isSpinning = false;
let currentRotation = 0;
let targetRotation = 0;

// Initialisation
document.addEventListener('DOMContentLoaded', function() {
	canvas = document.getElementById('wheelCanvas');
	ctx = canvas.getContext('2d');
	
	console.log('DOM loaded, waiting for data injection from Lua...');
	
	// Les données seront injectées directement par Lua via dhtml:Call()
	// En attendant, on dessine une roue vide
	if (rewards.length === 0) {
		// Afficher un message de chargement
		ctx.fillStyle = '#ffffff';
		ctx.font = '20px Arial';
		ctx.textAlign = 'center';
		ctx.fillText('Chargement...', canvas.width / 2, canvas.height / 2);
	}
	
	// Event listeners
	document.getElementById('spin-btn').addEventListener('click', spinWheel);
	document.getElementById('close-btn').addEventListener('click', closeWindow);
	document.getElementById('claim-btn').addEventListener('click', closeRewardModal);
});

// Mettre à jour l'affichage des wheelspins
function updateWheelspins(count) {
	wheelspins = count;
	document.getElementById('wheelspins-available').textContent = count;
	
	const spinBtn = document.getElementById('spin-btn');
	if (count <= 0) {
		spinBtn.disabled = true;
		spinBtn.textContent = 'AUCUN WHEELSPIN';
	} else {
		spinBtn.disabled = false;
		spinBtn.textContent = 'TOURNER LA ROUE';
	}
}

// Dessiner la roue
function drawWheel() {
	const centerX = canvas.width / 2;
	const centerY = canvas.height / 2;
	const radius = 280;
	
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	ctx.save();
	ctx.translate(centerX, centerY);
	ctx.rotate(currentRotation * Math.PI / 180);
	
	const angleStep = 360 / rewards.length;
	
	for (let i = 0; i < rewards.length; i++) {
		const reward = rewards[i];
		const startAngle = (i * angleStep) * Math.PI / 180;
		const endAngle = ((i + 1) * angleStep) * Math.PI / 180;
		
		// Dessiner la section
		ctx.beginPath();
		ctx.moveTo(0, 0);
		ctx.arc(0, 0, radius, startAngle, endAngle);
		ctx.closePath();
		
		// Couleur de la section
		ctx.fillStyle = `rgb(${reward.color.r}, ${reward.color.g}, ${reward.color.b})`;
		ctx.fill();
		
		// Bordure
		ctx.strokeStyle = '#000';
		ctx.lineWidth = 3;
		ctx.stroke();
		
		// Texte
		ctx.save();
		ctx.rotate((startAngle + endAngle) / 2);
		ctx.textAlign = 'center';
		ctx.fillStyle = '#fff';
		ctx.font = 'bold 16px Arial';
		ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
		ctx.shadowBlur = 4;
		ctx.fillText(reward.name, radius * 0.7, 0);
		ctx.restore();
	}
	
	// Cercle central
	ctx.beginPath();
	ctx.arc(0, 0, 40, 0, 2 * Math.PI);
	ctx.fillStyle = '#FFD700';
	ctx.fill();
	ctx.strokeStyle = '#000';
	ctx.lineWidth = 3;
	ctx.stroke();
	
	ctx.restore();
}

// Lancer la roue
function spinWheel() {
	if (isSpinning || wheelspins <= 0) return;
	
	isSpinning = true;
	document.getElementById('spin-btn').disabled = true;
	
	// Notifier Lua - le serveur va nous renvoyer l'index de la récompense
	if (typeof voterewards !== 'undefined') {
		voterewards.spin();
	}
	
	// Décrémenter les wheelspins localement
	updateWheelspins(wheelspins - 1);
}

// Faire tourner la roue vers une récompense spécifique (appelé depuis Lua)
function spinToReward(rewardIndex) {
	// Calculer l'angle pour s'arrêter sur la bonne case
	// L'index est 1-based (Lua), on le convertit en 0-based
	const index = rewardIndex - 1;
	const angleStep = 360 / rewards.length;
	
	// L'angle cible pour que la flèche (en haut) pointe sur cette case
	// La flèche est à 270° (en haut), donc on calcule l'angle pour que la case soit là
	const targetAngle = 270 - (index * angleStep) - (angleStep / 2);
	
	// Ajouter plusieurs tours + l'angle cible
	const spins = 5 + Math.floor(Math.random() * 3); // 5-7 tours
	targetRotation = currentRotation + (360 * spins) + (targetAngle - (currentRotation % 360) + 360) % 360;
	
	animateWheel();
}

// Animer la roue
function animateWheel() {
	const duration = 5000; // 5 secondes
	const startTime = Date.now();
	const startRotation = currentRotation;
	
	function animate() {
		const elapsed = Date.now() - startTime;
		const progress = Math.min(elapsed / duration, 1);
		
		// Easing cubique pour ralentissement progressif
		const eased = 1 - Math.pow(1 - progress, 3);
		
		currentRotation = startRotation + (targetRotation - startRotation) * eased;
		drawWheel();
		
		if (progress < 1) {
			requestAnimationFrame(animate);
		} else {
			currentRotation = targetRotation % 360;
			isSpinning = false;
			document.getElementById('spin-btn').disabled = false;
		}
	}
	
	animate();
}

// Afficher la récompense (appelé depuis Lua)
function showReward(reward) {
	const modal = document.getElementById('reward-modal');
	document.getElementById('reward-name').textContent = reward.name;
	
	let desc = '';
	if (reward.type === 'credits') {
		desc = 'Vous avez gagné ' + reward.value + ' crédits !';
	} else if (reward.type === 'weapon') {
		desc = 'Une arme permanente a été ajoutée à votre inventaire !';
	} else if (reward.type === 'skin') {
		desc = 'Un nouveau skin a été débloqué dans votre Pointshop !';
	}
	
	document.getElementById('reward-desc').textContent = desc;
	modal.classList.add('show');
}

// Fermer la modal de récompense
function closeRewardModal() {
	document.getElementById('reward-modal').classList.remove('show');
}

// Fermer la fenêtre
function closeWindow() {
	if (typeof voterewards !== 'undefined') {
		voterewards.close();
	}
}

// Fonction exposée pour mettre à jour depuis Lua
window.updateWheelspins = updateWheelspins;
window.showReward = showReward;
window.spinToReward = spinToReward;
]]
