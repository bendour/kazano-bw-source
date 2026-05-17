return [[
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body {
    background: transparent;
    color: #fff;
    overflow: hidden;
}

.container {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 800px;
    max-height: 90vh;
    background: linear-gradient(135deg, rgba(20, 20, 30, 0.95) 0%, rgba(30, 30, 45, 0.95) 100%);
    border-radius: 20px;
    border: 1px solid rgba(139, 0, 0, 0.5);
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5), 0 0 100px rgba(139, 0, 0, 0.2);
    backdrop-filter: blur(20px);
    overflow: hidden;
}

/* Header */
.header {
    background: linear-gradient(135deg, #8B0000 0%, #5C0000 100%);
    padding: 20px 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.header h1 {
    font-size: 28px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 3px;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.close-btn {
    background: rgba(255, 255, 255, 0.1);
    border: none;
    color: #fff;
    width: 40px;
    height: 40px;
    border-radius: 10px;
    font-size: 20px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.close-btn:hover {
    background: rgba(255, 50, 50, 0.5);
    transform: rotate(90deg);
}

/* Content */
.content {
    padding: 25px;
    max-height: calc(90vh - 80px);
    overflow-y: auto;
}

.content::-webkit-scrollbar {
    width: 8px;
}

.content::-webkit-scrollbar-track {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 4px;
}

.content::-webkit-scrollbar-thumb {
    background: rgba(139, 0, 0, 0.5);
    border-radius: 4px;
}

/* Skills Section */
.skills-section h2, .skills-list-section h3, .keybinds-section h3 {
    font-size: 16px;
    text-transform: uppercase;
    letter-spacing: 2px;
    color: rgba(255, 255, 255, 0.7);
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.skills-container {
    display: flex;
    gap: 20px;
    justify-content: center;
}

/* Skill Card */
.skill-card {
    background: linear-gradient(145deg, rgba(40, 40, 55, 0.8) 0%, rgba(30, 30, 45, 0.8) 100%);
    border-radius: 15px;
    padding: 20px;
    width: 320px;
    text-align: center;
    border: 2px solid rgba(100, 100, 120, 0.3);
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.skill-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, transparent, rgba(139, 0, 0, 0.5), transparent);
}

.skill-card:hover {
    transform: translateY(-5px);
    border-color: rgba(139, 0, 0, 0.5);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.skill-card.rarity-1 { border-color: rgba(180, 180, 180, 0.5); }
.skill-card.rarity-2 { border-color: rgba(0, 150, 255, 0.5); }
.skill-card.rarity-3 { border-color: rgba(180, 70, 255, 0.5); }
.skill-card.rarity-4 { border-color: rgba(255, 180, 0, 0.5); }

.skill-slot-label {
    position: absolute;
    top: 10px;
    left: 10px;
    font-size: 11px;
    color: rgba(255, 255, 255, 0.4);
    letter-spacing: 1px;
}

.skill-icon {
    font-size: 40px;
    margin-bottom: 10px;
}

.skill-name {
    font-size: 22px;
    font-weight: 700;
    margin-bottom: 5px;
}

.skill-rarity {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 2px;
    margin-bottom: 10px;
}

.skill-rarity.rarity-1 { color: #b4b4b4; }
.skill-rarity.rarity-2 { color: #0096ff; }
.skill-rarity.rarity-3 { color: #b446ff; }
.skill-rarity.rarity-4 { color: #ffb400; }

.skill-desc {
    font-size: 13px;
    color: rgba(255, 255, 255, 0.6);
    line-height: 1.4;
    margin-bottom: 10px;
    min-height: 40px;
}

.skill-cooldown {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.4);
}

.skill-key {
    margin-top: 15px;
    font-size: 18px;
    font-weight: 700;
    color: #ffb400;
    background: rgba(255, 180, 0, 0.1);
    padding: 8px 20px;
    border-radius: 8px;
    display: inline-block;
}

/* Roll Section */
.roll-section {
    margin-top: 25px;
    text-align: center;
}

.roll-info {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.7);
    margin-bottom: 15px;
    padding: 12px 20px;
    background: rgba(50, 50, 60, 0.5);
    border-radius: 10px;
    display: inline-block;
}

.roll-info.has-cost {
    color: #ffb400;
}

.roll-btn {
    background: linear-gradient(135deg, #8B0000 0%, #5C0000 100%);
    border: none;
    color: #fff;
    padding: 18px 50px;
    font-size: 18px;
    font-weight: 700;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.3s ease;
    text-transform: uppercase;
    letter-spacing: 2px;
    box-shadow: 0 5px 20px rgba(139, 0, 0, 0.4);
}

.roll-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 30px rgba(139, 0, 0, 0.6);
}

.roll-btn:active {
    transform: translateY(0);
}

.roll-icon {
    margin-right: 10px;
    font-size: 22px;
}

/* Keybinds Section */
.keybinds-section {
    margin-top: 25px;
    padding: 20px;
    background: rgba(40, 40, 55, 0.5);
    border-radius: 12px;
}

.keybinds-container {
    display: flex;
    justify-content: center;
    gap: 40px;
}

.keybind-item {
    display: flex;
    align-items: center;
    gap: 15px;
}

.keybind-item label {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.7);
}

.keybind-btn {
    background: rgba(60, 60, 80, 0.8);
    border: 2px solid rgba(139, 0, 0, 0.5);
    color: #fff;
    padding: 10px 25px;
    font-size: 16px;
    font-weight: 700;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    min-width: 80px;
}

.keybind-btn:hover {
    background: rgba(139, 0, 0, 0.3);
    border-color: #8B0000;
}

.keybind-btn.binding {
    background: rgba(255, 180, 0, 0.3);
    border-color: #ffb400;
    animation: pulse 1s infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}

/* Skills List */
.skills-list-section {
    margin-top: 25px;
}

.skills-list {
    display: grid;
    gap: 10px;
    max-height: 200px;
    overflow-y: auto;
    padding-right: 5px;
}

.skill-list-item {
    display: flex;
    align-items: center;
    padding: 12px 15px;
    background: rgba(40, 40, 55, 0.6);
    border-radius: 10px;
    border-left: 3px solid #666;
    transition: all 0.2s ease;
}

.skill-list-item:hover {
    background: rgba(50, 50, 65, 0.8);
    transform: translateX(5px);
}

.skill-list-item.rarity-1 { border-left-color: #b4b4b4; }
.skill-list-item.rarity-2 { border-left-color: #0096ff; }
.skill-list-item.rarity-3 { border-left-color: #b446ff; }
.skill-list-item.rarity-4 { border-left-color: #ffb400; }

.skill-list-item .skill-info {
    flex: 1;
}

.skill-list-item .skill-name {
    font-size: 15px;
    font-weight: 600;
    margin-bottom: 2px;
}

.skill-list-item .skill-rarity {
    font-size: 11px;
    margin-bottom: 0;
}

.skill-list-item .skill-desc {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
    min-height: auto;
    margin-bottom: 0;
}

.skill-list-item .skill-cd {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.4);
    margin-left: 15px;
}

/* Modal */
.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.8);
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 1000;
}

.modal.active {
    display: flex;
}

.modal-content {
    background: linear-gradient(135deg, rgba(30, 30, 45, 0.98) 0%, rgba(40, 40, 55, 0.98) 100%);
    padding: 30px 40px;
    border-radius: 20px;
    text-align: center;
    border: 1px solid rgba(139, 0, 0, 0.5);
    max-width: 500px;
    animation: modalIn 0.3s ease;
}

@keyframes modalIn {
    from {
        opacity: 0;
        transform: scale(0.9);
    }
    to {
        opacity: 1;
        transform: scale(1);
    }
}

.modal-content h2 {
    font-size: 24px;
    margin-bottom: 20px;
    color: #ffb400;
}

.new-skill-card {
    background: rgba(50, 50, 65, 0.8);
    padding: 20px;
    border-radius: 12px;
    margin-bottom: 20px;
    border: 2px solid rgba(255, 180, 0, 0.3);
}

.replace-options {
    display: flex;
    gap: 15px;
    justify-content: center;
    margin: 20px 0;
}

.replace-btn {
    background: rgba(60, 60, 80, 0.8);
    border: 2px solid rgba(100, 100, 120, 0.5);
    color: #fff;
    padding: 15px 25px;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.3s ease;
    min-width: 150px;
}

.replace-btn:hover {
    background: rgba(139, 0, 0, 0.3);
    border-color: #8B0000;
}

.replace-slot {
    display: block;
    font-size: 11px;
    color: rgba(255, 255, 255, 0.5);
    margin-bottom: 5px;
}

.replace-skill-name {
    display: block;
    font-size: 16px;
    font-weight: 600;
}

.cancel-btn {
    background: transparent;
    border: 1px solid rgba(255, 255, 255, 0.3);
    color: rgba(255, 255, 255, 0.7);
    padding: 10px 30px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.cancel-btn:hover {
    background: rgba(255, 255, 255, 0.1);
}

/* Notification */
.notification {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%) translateY(-100px);
    background: linear-gradient(135deg, #8B0000 0%, #5C0000 100%);
    padding: 15px 30px;
    border-radius: 10px;
    font-weight: 600;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
    transition: transform 0.3s ease;
    z-index: 2000;
}

.notification.show {
    transform: translateX(-50%) translateY(0);
}

.notification.success {
    background: linear-gradient(135deg, #006400 0%, #004400 100%);
}

.notification.error {
    background: linear-gradient(135deg, #8B0000 0%, #5C0000 100%);
}

/* ============================================
   CS2 Style Roll Animation
   ============================================ */

.roll-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.9);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 5000;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.roll-overlay.active {
    opacity: 1;
}

.roll-container {
    text-align: center;
    position: relative;
}

.roll-header {
    margin-bottom: 30px;
}

.roll-header h2 {
    font-size: 32px;
    font-weight: 700;
    color: #fff;
    text-transform: uppercase;
    letter-spacing: 4px;
    text-shadow: 0 0 20px rgba(139, 0, 0, 0.8);
    animation: headerPulse 1s infinite;
}

@keyframes headerPulse {
    0%, 100% { opacity: 1; text-shadow: 0 0 20px rgba(139, 0, 0, 0.8); }
    50% { opacity: 0.8; text-shadow: 0 0 40px rgba(139, 0, 0, 1); }
}

.roll-window {
    width: 700px;
    height: 160px;
    background: linear-gradient(180deg, rgba(20, 20, 30, 0.95) 0%, rgba(10, 10, 15, 0.98) 100%);
    border-radius: 15px;
    border: 3px solid #8B0000;
    position: relative;
    overflow: hidden;
    box-shadow: 0 0 50px rgba(139, 0, 0, 0.5), inset 0 0 30px rgba(0, 0, 0, 0.8);
}

.roll-indicator {
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 4px;
    height: 100%;
    background: linear-gradient(180deg, #ffb400 0%, #ff8c00 50%, #ffb400 100%);
    z-index: 100;
    box-shadow: 0 0 20px rgba(255, 180, 0, 0.8), 0 0 40px rgba(255, 180, 0, 0.4);
}

.roll-indicator::before,
.roll-indicator::after {
    content: '';
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 0;
    border-left: 12px solid transparent;
    border-right: 12px solid transparent;
}

.roll-indicator::before {
    top: -2px;
    border-top: 15px solid #ffb400;
}

.roll-indicator::after {
    bottom: -2px;
    border-bottom: 15px solid #ffb400;
}

.roll-strip {
    display: flex;
    align-items: center;
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    gap: 10px;
    padding-left: 285px; /* 700/2 - 130/2 = 350 - 65 = 285 */
    will-change: transform;
}

.roll-item {
    flex-shrink: 0;
    width: 130px;
    height: 130px;
    border-radius: 12px;
    border: 3px solid #666;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background-color: rgba(30, 30, 40, 0.9);
    position: relative;
    overflow: hidden;
}

.roll-item.rarity-1 { border-color: #b4b4b4; }
.roll-item.rarity-2 { border-color: #0096ff; box-shadow: 0 0 15px rgba(0, 150, 255, 0.3); }
.roll-item.rarity-3 { border-color: #b446ff; box-shadow: 0 0 20px rgba(180, 70, 255, 0.4); }
.roll-item.rarity-4 { border-color: #ffb400; box-shadow: 0 0 25px rgba(255, 180, 0, 0.5); animation: legendaryGlow 1s infinite; }

@keyframes legendaryGlow {
    0%, 100% { box-shadow: 0 0 25px rgba(255, 180, 0, 0.5); }
    50% { box-shadow: 0 0 40px rgba(255, 180, 0, 0.8); }
}

.roll-item-icon {
    font-size: 40px;
    margin-bottom: 5px;
}

.roll-item-name {
    font-size: 13px;
    font-weight: 600;
    color: #fff;
    text-align: center;
    padding: 0 5px;
}

/* Roll Result */
.roll-result {
    margin-top: 30px;
    opacity: 0;
    transform: scale(0.5);
    transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.roll-result.show {
    opacity: 1;
    transform: scale(1);
}

.result-skill {
    display: inline-block;
    padding: 25px 50px;
    border-radius: 15px;
    background: linear-gradient(135deg, rgba(40, 40, 55, 0.95) 0%, rgba(30, 30, 45, 0.95) 100%);
    border: 3px solid #666;
}

.result-skill.rarity-1 { border-color: #b4b4b4; }
.result-skill.rarity-2 { border-color: #0096ff; box-shadow: 0 0 30px rgba(0, 150, 255, 0.5); }
.result-skill.rarity-3 { border-color: #b446ff; box-shadow: 0 0 40px rgba(180, 70, 255, 0.6); }
.result-skill.rarity-4 { border-color: #ffb400; box-shadow: 0 0 50px rgba(255, 180, 0, 0.7); animation: resultGlow 0.5s infinite; }

@keyframes resultGlow {
    0%, 100% { box-shadow: 0 0 50px rgba(255, 180, 0, 0.7); }
    50% { box-shadow: 0 0 80px rgba(255, 180, 0, 1), 0 0 120px rgba(255, 180, 0, 0.5); }
}

.result-icon {
    font-size: 60px;
    margin-bottom: 10px;
    animation: iconBounce 0.5s ease;
}

@keyframes iconBounce {
    0% { transform: scale(0); }
    50% { transform: scale(1.2); }
    100% { transform: scale(1); }
}

.result-name {
    font-size: 28px;
    font-weight: 700;
    margin-bottom: 5px;
}

.result-rarity {
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 3px;
}

/* Particles */
.particle {
    position: absolute;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    pointer-events: none;
    animation: particleFall 1.5s ease-out forwards;
}

@keyframes particleFall {
    0% {
        transform: translateY(0) rotate(0deg);
        opacity: 1;
    }
    100% {
        transform: translateY(200px) rotate(720deg);
        opacity: 0;
    }
}

/* Sound effect visual feedback */
.roll-window::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(90deg, 
        rgba(0, 0, 0, 0.8) 0%, 
        transparent 15%, 
        transparent 85%, 
        rgba(0, 0, 0, 0.8) 100%
    );
    pointer-events: none;
    z-index: 50;
}
]]
