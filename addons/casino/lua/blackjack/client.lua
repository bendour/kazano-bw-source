-- Côté client du Blackjack DHTML
-- Gère l'interface utilisateur et la communication avec le HTML

if CLIENT then
	Blackjack.UI = Blackjack.UI or {}
	Blackjack.UI.Frame = nil
	Blackjack.UI.HTML = nil
	Blackjack.UI.IsOpen = false
	
	-- Créer la commande pour ouvrir le blackjack
	concommand.Add("slots", function()
		Blackjack.UI:Open()
	end)
	
	-- Alias pour la commande
	concommand.Add("blackjack", function()
		Blackjack.UI:Open()
	end)
	
	concommand.Add("blackjack_open", function()
		Blackjack.UI:Open()
	end)
	
	-- Fonction pour ouvrir l'interface
	function Blackjack.UI:Open()
		if self.IsOpen then return end
		
		-- Créer la fenêtre principale
		self.Frame = vgui.Create("DFrame")
		self.Frame:SetSize(Blackjack:GetConfig("UI.WindowWidth"), Blackjack:GetConfig("UI.WindowHeight"))
		self.Frame:SetTitle("Blackjack Casino")
		self.Frame:SetDraggable(true)
		self.Frame:MakePopup()
		self.Frame:Center()
		self.Frame:SetDeleteOnClose(true)
		
		-- L'apparence est gérée entièrement en HTML/CSS
		
		-- Créer le panneau DHTML
		self.HTML = vgui.Create("DHTML", self.Frame)
		self.HTML:Dock(FILL)
		
		-- Charger le contenu HTML
		self.HTML:SetHTML(self:GetHTMLContent())
		
		-- Activer la communication Lua depuis JavaScript
		self.HTML:SetAllowLua(true)
		
		-- Ajouter les fonctions JavaScript vers Lua
		self:SetupFunctions()
		
		-- Gérer la fermeture
		self.Frame.OnClose = function()
			self.IsOpen = false
			self.Frame = nil
			self.HTML = nil
		end
		
		self.IsOpen = true
		
		-- Envoyer les informations initiales au JavaScript
		timer.Simple(0.5, function()
			if self.HTML and self.IsOpen then
				self:SendPlayerInfo()
			end
		end)
	end
	
	-- Fonction pour fermer l'interface
	function Blackjack.UI:Close()
		if self.Frame and self.Frame:IsValid() then
			self.Frame:Close()
		end
		self.IsOpen = false
	end
	
	-- Obtenir le contenu HTML
	function Blackjack.UI:GetHTMLContent()
		return [[
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Blackjack Casino</title>
	<style>
		* {
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}
		
		body {
			font-family: Arial, sans-serif;
			background: linear-gradient(135deg, #0d5f0d 0%, #1a7a1a 100%);
			color: white;
			overflow: hidden;
			height: 100vh;
		}
		
		#gameTable {
			width: 100%;
			height: 100vh;
			position: relative;
			background: radial-gradient(ellipse at center, #2a8f2a 0%, #0d5f0d 100%);
			border: 10px solid #8B4513;
			box-shadow: inset 0 0 50px rgba(0,0,0,0.5);
		}
		
		#dealerArea {
			position: absolute;
			top: 50px;
			left: 50%;
			transform: translateX(-50%);
			text-align: center;
		}
		
		#playerArea {
			position: absolute;
			bottom: 150px;
			left: 50%;
			transform: translateX(-50%);
			text-align: center;
		}
		
		.card {
			display: inline-block;
			width: 71px;
			height: 96px;
			margin: 0 5px;
			background: white;
			border: 2px solid black;
			border-radius: 8px;
			font-size: 24px;
			font-weight: bold;
			text-align: center;
			line-height: 96px;
			box-shadow: 0 4px 8px rgba(0,0,0,0.3);
			transition: all 0.3s ease;
		}
		
		.card.back {
			background: linear-gradient(45deg, #8b0000 25%, #dc143c 25%, #dc143c 50%, #8b0000 50%, #8b0000 75%, #dc143c 75%, #dc143c);
			background-size: 20px 20px;
			color: transparent;
		}
		
		.card.red {
			color: #dc143c;
		}
		
		.card.black {
			color: black;
		}
		
		#controls {
			position: absolute;
			bottom: 20px;
			left: 50%;
			transform: translateX(-50%);
			display: flex;
			gap: 10px;
		}
		
		button {
			padding: 12px 24px;
			font-size: 16px;
			font-weight: bold;
			border: none;
			border-radius: 5px;
			cursor: pointer;
			background: #4CAF50;
			color: white;
			transition: all 0.3s ease;
			box-shadow: 0 4px 8px rgba(0,0,0,0.3);
		}
		
		button:hover {
			background: #45a049;
			transform: translateY(-2px);
			box-shadow: 0 6px 12px rgba(0,0,0,0.4);
		}
		
		button:disabled {
			background: #666;
			cursor: not-allowed;
			transform: none;
		}
		
		#bettingArea {
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			background: rgba(0,0,0,0.8);
			padding: 30px;
			border-radius: 15px;
			text-align: center;
			display: block;
		}
		
		#chips {
			display: flex;
			justify-content: center;
			gap: 15px;
			margin: 20px 0;
		}
		
		.chip {
			width: 60px;
			height: 60px;
			border-radius: 50%;
			border: 3px dashed white;
			display: flex;
			align-items: center;
			justify-content: center;
			font-weight: bold;
			cursor: pointer;
			transition: all 0.3s ease;
			box-shadow: 0 4px 8px rgba(0,0,0,0.3);
		}
		
		.chip:hover {
			transform: scale(1.1);
		}
		
		#info {
			position: absolute;
			top: 10px;
			left: 10px;
			background: rgba(0,0,0,0.7);
			padding: 10px;
			border-radius: 5px;
			font-size: 14px;
		}
		
		#message {
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			font-size: 48px;
			font-weight: bold;
			text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
			display: none;
			animation: pulse 1s infinite;
		}
		
		@keyframes pulse {
			0% { transform: translate(-50%, -50%) scale(1); }
			50% { transform: translate(-50%, -50%) scale(1.1); }
			100% { transform: translate(-50%, -50%) scale(1); }
		}
		
		.win { color: #4CAF50; }
		.lose { color: #f44336; }
		.push { color: #ff9800; }
	</style>
</head>
<body>
	<div id="gameTable">
		<div id="info">
			<div>Solde: <span id="balance">0</span></div>
			<div>Mise: <span id="currentBet">0</span></div>
		</div>
		
		<div id="dealerArea">
			<div>Croupier</div>
			<div id="dealerCards"></div>
			<div id="dealerScore"></div>
		</div>
		
		<div id="playerArea">
			<div>Joueur</div>
			<div id="playerCards"></div>
			<div id="playerScore"></div>
		</div>
		
		<div id="bettingArea">
			<h2>Placez votre mise</h2>
			<div id="chips">
				<div class="chip" style="background: white; color: black;" value="100">100</div>
				<div class="chip" style="background: #ff0000;" value="250">250</div>
				<div class="chip" style="background: #0000ff;" value="500">500</div>
				<div class="chip" style="background: black;" value="1000">1K</div>
				<div class="chip" style="background: #ff00ff;" value="2500">2.5K</div>
				<div class="chip" style="background: #ffa500;" value="5000">5K</div>
			</div>
			<div>
				<button onclick="placeBet()">Miser</button>
				<button onclick="clearBet()">Effacer</button>
			</div>
		</div>
		
		<div id="controls">
			<button id="hitBtn" onclick="hit()" disabled>Tirer</button>
			<button id="standBtn" onclick="stand()" disabled>Rester</button>
			<button id="doubleBtn" onclick="doubleDown()" disabled>Double</button>
			<button id="newGameBtn" onclick="newGame()" style="display: none;">Nouvelle partie</button>
		</div>
		
		<div id="message"></div>
	</div>
	
	<script>
		// Variables du jeu
		let gameState = {
			deck: [],
			playerHand: [],
			dealerHand: [],
			currentBet: 0,
			playerBalance: 0,
			gameActive: false,
			playerTurn: true,
			dealerHiddenCard: null
		};
		
		// Configuration du jeu
		const BLACKJACK_PAYOUT = 2.5; // 3:2 payout
		const REGULAR_PAYOUT = 2; // 1:1 payout
		const DEALER_STANDS_ON = 17;
		
		// Fonctions de communication avec Lua
		function luaGetPlayerInfo() {
			blackjack.getPlayerInfo();
		}
		
		function luaPlaceBet(amount) {
			blackjack.placeBet(amount);
		}
		
		function luaTransactionComplete(success, newBalance, message) {
			if (success) {
				gameState.playerBalance = newBalance;
				updateDisplay();
				if (gameState.currentBet > 0) {
					startLocalGame();
				}
			} else {
				showMessage(message || "Erreur de transaction", "lose");
			}
		}
		
		// Initialisation
		window.onload = function() {
			luaGetPlayerInfo();
			setupChipListeners();
		};
		
		// Configuration des jetons
		function setupChipListeners() {
			const chips = document.querySelectorAll('.chip');
			chips.forEach(chip => {
				chip.addEventListener('click', function() {
					const value = parseInt(this.getAttribute('value'));
					addToBet(value);
				});
			});
		}
		
		// Fonctions du jeu
		function addToBet(amount) {
			if (gameState.currentBet + amount <= gameState.playerBalance) {
				gameState.currentBet += amount;
				updateDisplay();
			}
		}
		
		function clearBet() {
			gameState.currentBet = 0;
			updateDisplay();
		}
		
		function placeBet() {
			if (gameState.currentBet >= 100 && gameState.currentBet <= 10000) {
				if (gameState.currentBet <= gameState.playerBalance) {
					luaPlaceBet(gameState.currentBet);
				} else {
					showMessage("Solde insuffisant!", "lose");
				}
			} else {
				showMessage("Mise invalide! (100-10000)", "lose");
			}
		}
		
		function startLocalGame() {
			// Initialiser le jeu
			initializeDeck();
			shuffleDeck();
			
			// Distribuer les cartes initiales
			gameState.playerHand = [drawCard(), drawCard()];
			gameState.dealerHand = [drawCard(), drawCard()];
			gameState.dealerHiddenCard = gameState.dealerHand[1];
			
			gameState.gameActive = true;
			gameState.playerTurn = true;
			
			// Mettre à jour l'interface
			document.getElementById('bettingArea').style.display = 'none';
			document.getElementById('hitBtn').disabled = false;
			document.getElementById('standBtn').disabled = false;
			document.getElementById('doubleBtn').disabled = (gameState.playerBalance < gameState.currentBet);
			document.getElementById('newGameBtn').style.display = 'none';
			
			updateDisplay();
			updateCards();
			
			// Vérifier blackjack initial
			checkInitialBlackjack();
		}
		
		function initializeDeck() {
			gameState.deck = [];
			const suits = ['♠', '♥', '♦', '♣'];
			const ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
			
			for (let suit of suits) {
				for (let rank of ranks) {
					gameState.deck.push({
						rank: rank,
						suit: suit,
						value: getCardValue(rank)
					});
				}
			}
		}
		
		function shuffleDeck() {
			for (let i = gameState.deck.length - 1; i > 0; i--) {
				const j = Math.floor(Math.random() * (i + 1));
				const temp = gameState.deck[i];
				gameState.deck[i] = gameState.deck[j];
				gameState.deck[j] = temp;
			}
		}
		
		function drawCard() {
			return gameState.deck.pop();
		}
		
		function getCardValue(rank) {
			if (rank === 'A') return 11;
			if (['J', 'Q', 'K'].includes(rank)) return 10;
			return parseInt(rank);
		}
		
		function calculateHandValue(hand) {
			let value = 0;
			let aces = 0;
			
			for (let card of hand) {
				value += card.value;
				if (card.rank === 'A') aces++;
			}
			
			// Ajuster la valeur des As si nécessaire
			while (value > 21 && aces > 0) {
				value -= 10;
				aces--;
			}
			
			return value;
		}
		
		function updateCards() {
			// Mettre à jour les cartes du joueur
			const playerCardsDiv = document.getElementById('playerCards');
			playerCardsDiv.innerHTML = '';
			gameState.playerHand.forEach(card => {
				const cardDiv = createCardElement(card);
				playerCardsDiv.appendChild(cardDiv);
			});
			
			// Mettre à jour les cartes du croupier
			const dealerCardsDiv = document.getElementById('dealerCards');
			dealerCardsDiv.innerHTML = '';
			gameState.dealerHand.forEach((card, index) => {
				let cardDiv;
				if (index === 1 && gameState.playerTurn && gameState.gameActive) {
					// Cacher la deuxième carte du croupier
					cardDiv = createCardElement(null, true);
				} else {
					cardDiv = createCardElement(card);
				}
				dealerCardsDiv.appendChild(cardDiv);
			});
			
			// Mettre à jour les scores
			const playerScore = calculateHandValue(gameState.playerHand);
			document.getElementById('playerScore').textContent = `Score: ${playerScore}`;
			
			if (gameState.playerTurn && gameState.gameActive) {
				const firstCard = gameState.dealerHand[0];
				const visibleDealerScore = calculateHandValue([firstCard]);
				document.getElementById('dealerScore').textContent = `Score: ${visibleDealerScore}`;
			} else {
				const dealerScore = calculateHandValue(gameState.dealerHand);
				document.getElementById('dealerScore').textContent = `Score: ${dealerScore}`;
			}
		}
		
		function createCardElement(card, isHidden = false) {
			const cardDiv = document.createElement('div');
			if (isHidden) {
				cardDiv.className = 'card back';
			} else {
				cardDiv.className = 'card ' + (card.suit === '♥' || card.suit === '♦' ? 'red' : 'black');
				cardDiv.textContent = card.rank + card.suit;
			}
			return cardDiv;
		}
		
		function checkInitialBlackjack() {
			const playerScore = calculateHandValue(gameState.playerHand);
			const dealerScore = calculateHandValue(gameState.dealerHand);
			
			if (playerScore === 21 && dealerScore === 21) {
				endGame('push', "Double Blackjack! Égalité!");
			} else if (playerScore === 21) {
				endGame('blackjack', "Blackjack! Vous gagnez!");
			} else if (dealerScore === 21) {
				endGame('lose', "Croupier a Blackjack! Vous perdez!");
			}
		}
		
		function hit() {
			if (!gameState.gameActive || !gameState.playerTurn) return;
			
			gameState.playerHand.push(drawCard());
			updateCards();
			
			const playerScore = calculateHandValue(gameState.playerHand);
			if (playerScore > 21) {
				endGame('bust', "Bust! Vous perdez!");
			} else if (playerScore === 21) {
				stand();
			}
			
			// Désactiver double down après hit
			document.getElementById('doubleBtn').disabled = true;
		}
		
		function stand() {
			if (!gameState.gameActive || !gameState.playerTurn) return;
			
			gameState.playerTurn = false;
			document.getElementById('hitBtn').disabled = true;
			document.getElementById('standBtn').disabled = true;
			document.getElementById('doubleBtn').disabled = true;
			
			// Révéler la carte cachée du croupier
			updateCards();
			
			// Tour du croupier
			dealerPlay();
		}
		
		function doubleDown() {
			if (!gameState.gameActive || !gameState.playerTurn) return;
			if (gameState.playerBalance < gameState.currentBet) {
				showMessage("Solde insuffisant pour doubler!", "lose");
				return;
			}
			
			// Doubler la mise
			gameState.currentBet *= 2;
			
			// Tirer une seule carte
			gameState.playerHand.push(drawCard());
			updateCards();
			
			const playerScore = calculateHandValue(gameState.playerHand);
			if (playerScore > 21) {
				endGame('bust', "Bust! Vous perdez!");
			} else {
				stand();
			}
		}
		
		function dealerPlay() {
			const dealerScore = calculateHandValue(gameState.dealerHand);
			
			if (dealerScore < DEALER_STANDS_ON) {
				setTimeout(() => {
					gameState.dealerHand.push(drawCard());
					updateCards();
					dealerPlay();
				}, 1000);
			} else {
				// Déterminer le gagnant
				determineWinner();
			}
		}
		
		function determineWinner() {
			const playerScore = calculateHandValue(gameState.playerHand);
			const dealerScore = calculateHandValue(gameState.dealerHand);
			
			if (dealerScore > 21) {
				endGame('win', "Croupier bust! Vous gagnez!");
			} else if (playerScore > dealerScore) {
				endGame('win', "Vous gagnez!");
			} else if (dealerScore > playerScore) {
				endGame('lose', "Vous perdez!");
			} else {
				endGame('push', "Égalité!");
			}
		}
		
		function endGame(result, message) {
			gameState.gameActive = false;
			gameState.playerTurn = false;
			
			// Révéler toutes les cartes
			updateCards();
			
			// Afficher le message
			showMessage(message, result);
			
			// Calculer et appliquer les gains/pertes
			let winAmount = 0;
			if (result === 'blackjack') {
				winAmount = Math.floor(gameState.currentBet * BLACKJACK_PAYOUT);
			} else if (result === 'win') {
				winAmount = gameState.currentBet * REGULAR_PAYOUT;
			} else if (result === 'push') {
				winAmount = gameState.currentBet;
			}
			
			// Mettre à jour le solde (simulé localement, synchronisé avec Lua)
			if (result !== 'lose') {
				gameState.playerBalance += winAmount;
			}
			
			// Afficher le bouton nouvelle partie
			document.getElementById('newGameBtn').style.display = 'inline-block';
			document.getElementById('hitBtn').disabled = true;
			document.getElementById('standBtn').disabled = true;
			document.getElementById('doubleBtn').disabled = true;
			
			updateDisplay();
		}
		
		function newGame() {
			// Réinitialiser l'état du jeu
			gameState.gameActive = false;
			gameState.playerTurn = true;
			gameState.currentBet = 0;
			gameState.playerHand = [];
			gameState.dealerHand = [];
			gameState.dealerHiddenCard = null;
			
			// Vider les cartes
			document.getElementById('playerCards').innerHTML = '';
			document.getElementById('dealerCards').innerHTML = '';
			document.getElementById('playerScore').textContent = '';
			document.getElementById('dealerScore').textContent = '';
			
			// Afficher la zone de paris
			document.getElementById('bettingArea').style.display = 'block';
			document.getElementById('newGameBtn').style.display = 'none';
			
			updateDisplay();
		}
		
		// Mise à jour de l'affichage
		function updateDisplay() {
			document.getElementById('balance').textContent = gameState.playerBalance;
			document.getElementById('currentBet').textContent = gameState.currentBet;
		}
		
		// Fonctions appelées depuis Lua
		function updatePlayerInfo(balance) {
			gameState.playerBalance = balance;
			updateDisplay();
		}
		
		function showMessage(message, className) {
			const messageDiv = document.getElementById('message');
			messageDiv.textContent = message;
			messageDiv.className = className;
			messageDiv.style.display = 'block';
			
			setTimeout(() => {
				messageDiv.style.display = 'none';
			}, 3000);
		}
	</script>
</body>
</html>
	]]
	end
	
	-- Configuration des fonctions JavaScript vers Lua
	function Blackjack.UI:SetupFunctions()
		if not self.HTML then return end
		
		-- Obtenir les informations du joueur
		self.HTML:AddFunction("blackjack", "getPlayerInfo", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				local balance = Blackjack.Currency.GetMoney(LocalPlayer())
				self.HTML:Call(string.format("updatePlayerInfo(%d)", balance))
			end
		end)
		
		-- Placer une mise
		self.HTML:AddFunction("blackjack", "placeBet", function(amount)
			if LocalPlayer() and LocalPlayer():IsValid() then
				-- Envoyer la demande au serveur
				net.Start("Blackjack_PlaceBet")
				net.WriteInt(amount, 32)
				net.SendToServer()
			end
		end)
		
		-- Tirer une carte (non utilisé car la logique est en JS)
		self.HTML:AddFunction("blackjack", "hit", function()
			-- Fonction vide car la logique est gérée en JavaScript
		end)
		
		-- Rester (non utilisé car la logique est en JS)
		self.HTML:AddFunction("blackjack", "stand", function()
			-- Fonction vide car la logique est gérée en JavaScript
		end)
		
		-- Double down (non utilisé car la logique est en JS)
		self.HTML:AddFunction("blackjack", "doubleDown", function()
			-- Fonction vide car la logique est gérée en JavaScript
		end)
		
		-- Nouvelle partie (non utilisé car la logique est en JS)
		self.HTML:AddFunction("blackjack", "newGame", function()
			-- Fonction vide car la logique est gérée en JavaScript
		end)
	end
	
	-- Envoyer les informations du joueur
	function Blackjack.UI:SendPlayerInfo()
		if not self.HTML or not self.IsOpen then return end
		
		if LocalPlayer() and LocalPlayer():IsValid() then
			local balance = Blackjack.Currency.GetMoney(LocalPlayer())
			self.HTML:Call(string.format("updatePlayerInfo(%d)", balance))
		end
	end
	
	-- Mettre à jour le solde du joueur
	function Blackjack.UI:UpdateBalance()
		self:SendPlayerInfo()
	end
	
	-- Démarrer une partie
	function Blackjack.UI:StartGame(bet)
		if not self.HTML or not self.IsOpen then return end
		
		local balance = Blackjack.Currency.GetMoney(LocalPlayer())
		self.HTML:Call(string.format("startGame(%d, %d)", balance, bet))
	end
	
	-- Afficher un message
	function Blackjack.UI:ShowMessage(message, type)
		if not self.HTML or not self.IsOpen then return end
		
		local className = type or "info"
		self.HTML:Call(string.format("showMessage('%s', '%s')", message, className))
	end
	
	-- Mettre à jour les cartes du joueur
	function Blackjack.UI:UpdatePlayerCards(cards)
		if not self.HTML or not self.IsOpen then return end
		
		local cardsJson = util.TableToJSON(cards)
		self.HTML:Call(string.format("updatePlayerCards('%s')", cardsJson))
	end
	
	-- Mettre à jour les cartes du croupier
	function Blackjack.UI:UpdateDealerCards(cards, hideFirst)
		if not self.HTML or not self.IsOpen then return end
		
		local cardsJson = util.TableToJSON(cards)
		local hideFirstStr = hideFirst and "true" or "false"
		self.HTML:Call(string.format("updateDealerCards('%s', %s)", cardsJson, hideFirstStr))
	end
	
	print("[Blackjack] Client chargé avec succès")
end

-- Recevoir les résultats de transaction (niveau global)
net.Receive("Blackjack_TransactionComplete", function()
	local success = net.ReadBool()
	local newBalance = net.ReadInt(32)
	local message = net.ReadString()
	
	if Blackjack.UI.HTML and Blackjack.UI.IsOpen then
		Blackjack.UI.HTML:Call(string.format("luaTransactionComplete(%s, %d, '%s')", 
			tostring(success), newBalance, message:gsub("'", "\\'")))
	end
end)
