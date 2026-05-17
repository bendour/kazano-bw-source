return [[
<!DOCTYPE html>
<html lang="fr">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Vote Rewards Wheelspin</title>
	<link rel="stylesheet" href="wheelspin.css">
</head>
<body>
	<div class="container">
		<div class="header">
			<h1>🎰 WHEELSPIN</h1>
			<div class="wheelspins-count">
				<span id="wheelspins-available">0</span> Wheelspins disponibles
			</div>
		</div>
		
		<div class="wheel-container">
			<div class="wheel-pointer"></div>
			<canvas id="wheelCanvas" width="600" height="600"></canvas>
		</div>
		
		<div class="controls">
			<button id="spin-btn" class="btn btn-spin">TOURNER LA ROUE</button>
			<button id="close-btn" class="btn btn-close">FERMER</button>
		</div>
		
		<div id="reward-modal" class="modal">
			<div class="modal-content">
				<h2>🎉 FÉLICITATIONS !</h2>
				<div class="reward-display">
					<p class="reward-name" id="reward-name"></p>
					<p class="reward-desc" id="reward-desc"></p>
				</div>
				<button id="claim-btn" class="btn btn-claim">RÉCUPÉRER</button>
			</div>
		</div>
	</div>
	
	<script src="wheelspin.js"></script>
</body>
</html>
]]
