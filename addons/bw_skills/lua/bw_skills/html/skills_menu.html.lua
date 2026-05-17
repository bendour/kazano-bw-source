return [[
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BW Skills</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>⚡ COMPÉTENCES</h1>
            <button class="close-btn" onclick="closeMenu()">✕</button>
        </div>

        <!-- Main Content -->
        <div class="content">
            <!-- Skills Slots -->
            <div class="skills-section">
                <h2>Mes Compétences</h2>
                <div class="skills-container">
                    <div class="skill-card" id="skill-slot-1">
                        <div class="skill-slot-label">SLOT 1</div>
                        <div class="skill-icon" id="skill-icon-1">?</div>
                        <div class="skill-name" id="skill-name-1">Vide</div>
                        <div class="skill-rarity" id="skill-rarity-1">-</div>
                        <div class="skill-desc" id="skill-desc-1">Aucune compétence équipée</div>
                        <div class="skill-cooldown" id="skill-cd-1"></div>
                        <div class="skill-key" id="skill-key-1">[Z]</div>
                    </div>
                    <div class="skill-card" id="skill-slot-2">
                        <div class="skill-slot-label">SLOT 2</div>
                        <div class="skill-icon" id="skill-icon-2">?</div>
                        <div class="skill-name" id="skill-name-2">Vide</div>
                        <div class="skill-rarity" id="skill-rarity-2">-</div>
                        <div class="skill-desc" id="skill-desc-2">Aucune compétence équipée</div>
                        <div class="skill-cooldown" id="skill-cd-2"></div>
                        <div class="skill-key" id="skill-key-2">[X]</div>
                    </div>
                </div>
            </div>

            <!-- Roll Section -->
            <div class="roll-section">
                <div class="roll-info" id="roll-info">
                    Rolls gratuits restants: 2/2
                </div>
                <button class="roll-btn" id="roll-btn" onclick="rollSkill()">
                    <span class="roll-icon">🎲</span>
                    ROLL UNE COMPÉTENCE
                </button>
            </div>

            <!-- Keybinds Section -->
            <div class="keybinds-section">
                <h3>Configuration des Touches</h3>
                <div class="keybinds-container">
                    <div class="keybind-item">
                        <label>Slot 1:</label>
                        <button class="keybind-btn" id="keybind-1" onclick="bindKey(1)">Z</button>
                    </div>
                    <div class="keybind-item">
                        <label>Slot 2:</label>
                        <button class="keybind-btn" id="keybind-2" onclick="bindKey(2)">X</button>
                    </div>
                </div>
            </div>

            <!-- Skills List -->
            <div class="skills-list-section">
                <h3>Compétences Disponibles</h3>
                <div class="skills-list" id="skills-list">
                    <!-- Populated by JS -->
                </div>
            </div>
        </div>
    </div>

    <!-- Replace Modal -->
    <div class="modal" id="replace-modal">
        <div class="modal-content">
            <h2>🎉 Nouvelle Compétence!</h2>
            <div class="new-skill-card" id="new-skill-card">
                <div class="skill-name" id="new-skill-name">-</div>
                <div class="skill-rarity" id="new-skill-rarity">-</div>
                <div class="skill-desc" id="new-skill-desc">-</div>
            </div>
            <p>Quelle compétence voulez-vous remplacer?</p>
            <div class="replace-options">
                <button class="replace-btn" id="replace-slot-1" onclick="replaceSkill(1)">
                    <span class="replace-slot">Slot 1</span>
                    <span class="replace-skill-name" id="replace-name-1">-</span>
                </button>
                <button class="replace-btn" id="replace-slot-2" onclick="replaceSkill(2)">
                    <span class="replace-slot">Slot 2</span>
                    <span class="replace-skill-name" id="replace-name-2">-</span>
                </button>
            </div>
            <button class="cancel-btn" onclick="cancelReplace()">Annuler</button>
        </div>
    </div>

    <!-- Notification -->
    <div class="notification" id="notification">
        <span id="notification-text"></span>
    </div>

    <script src="skills_menu.js"></script>
</body>
</html>
]]
