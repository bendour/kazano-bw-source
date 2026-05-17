return [[
// Skills Data
let playerData = {
    skill1: null,
    skill2: null,
    rolls_used: 0,
    key1: 'Z',
    key2: 'X'
};

let allSkills = {};
let pendingNewSkill = null;
let bindingSlot = null;
let isRolling = false;

const rarityNames = {
    1: 'Commun',
    2: 'Rare',
    3: 'Épique',
    4: 'Légendaire'
};

const rarityColors = {
    1: '#b4b4b4',
    2: '#0096ff',
    3: '#b446ff',
    4: '#ffb400'
};

const rarityGlows = {
    1: 'rgba(180, 180, 180, 0.5)',
    2: 'rgba(0, 150, 255, 0.6)',
    3: 'rgba(180, 70, 255, 0.6)',
    4: 'rgba(255, 180, 0, 0.7)'
};

const skillIcons = {
    'dash': '💨',
    'double_jump': '⬆️',
    'heal': '❤️',
    'speed_boost': '⚡',
    'invisibility': '👁️',
    'shield': '🛡️',
    'teleport': '🌀',
    'explosion': '💥',
    'slide': '🛷',
    'quick_reload': '🔄',
    'soft_landing': '🪶',
    'vampire': '🧛',
    'temp_armor': '🛡️',
    'smoke_bomb': '💨',
    'thermal_vision': '🔥',
    'rage': '😡',
    'swap': '🔀',
    'immortality': '✨',
    'seismic_slam': '💢',
    'clone': '👥',
    'grapple': '⚓',
    'bounce': '🦘',
    'camouflage': '🦥',
    'adrenaline': '💉',
    'trap_mine': '💣',
    'energy_drain': '🔋',
    'force_field': '🟦',
    'death_mark': '💀',
    'phase': '👻',
    'resurrection': '👼',
    'lightning': '⚡',
    'time_slow': '⏱️'
};

// Initialize
function init() {
    console.log('BW Skills Menu initialized');
}

// Update skills display
function updateSkillsDisplay() {
    updateSkillCard(1, playerData.skill1);
    updateSkillCard(2, playerData.skill2);
    updateRollInfo();
    updateKeybinds();
}

function updateSkillCard(slot, skillId) {
    const card = document.getElementById('skill-slot-' + slot);
    const iconEl = document.getElementById('skill-icon-' + slot);
    const nameEl = document.getElementById('skill-name-' + slot);
    const rarityEl = document.getElementById('skill-rarity-' + slot);
    const descEl = document.getElementById('skill-desc-' + slot);
    const cdEl = document.getElementById('skill-cd-' + slot);
    const keyEl = document.getElementById('skill-key-' + slot);
    
    card.classList.remove('rarity-1', 'rarity-2', 'rarity-3', 'rarity-4');
    rarityEl.classList.remove('rarity-1', 'rarity-2', 'rarity-3', 'rarity-4');
    
    if (skillId && allSkills[skillId]) {
        const skill = allSkills[skillId];
        card.classList.add('rarity-' + skill.rarity);
        
        iconEl.textContent = skillIcons[skillId] || '⭐';
        nameEl.textContent = skill.name;
        nameEl.style.color = rarityColors[skill.rarity];
        rarityEl.textContent = rarityNames[skill.rarity];
        rarityEl.classList.add('rarity-' + skill.rarity);
        descEl.textContent = skill.description;
        cdEl.textContent = 'Cooldown: ' + skill.cooldown + 's';
    } else {
        iconEl.textContent = '?';
        nameEl.textContent = 'Vide';
        nameEl.style.color = '#666';
        rarityEl.textContent = '-';
        descEl.textContent = 'Aucune compétence équipée';
        cdEl.textContent = '';
    }
    
    const keyName = slot === 1 ? playerData.key1 : playerData.key2;
    keyEl.textContent = '[' + keyName.toUpperCase() + ']';
}

function updateRollInfo() {
    const infoEl = document.getElementById('roll-info');
    const freeRolls = 2;
    const rollCost = 1000;
    
    if (playerData.rolls_used >= freeRolls) {
        infoEl.textContent = 'Coût du prochain roll: ' + rollCost + ' crédits';
        infoEl.classList.add('has-cost');
    } else {
        const remaining = freeRolls - playerData.rolls_used;
        infoEl.textContent = 'Rolls gratuits restants: ' + remaining + '/' + freeRolls;
        infoEl.classList.remove('has-cost');
    }
}

function updateKeybinds() {
    document.getElementById('keybind-1').textContent = playerData.key1.toUpperCase();
    document.getElementById('keybind-2').textContent = playerData.key2.toUpperCase();
}

function populateSkillsList() {
    const listEl = document.getElementById('skills-list');
    listEl.innerHTML = '';
    
    const sortedSkills = Object.entries(allSkills).sort((a, b) => b[1].rarity - a[1].rarity);
    
    for (const [id, skill] of sortedSkills) {
        const item = document.createElement('div');
        item.className = 'skill-list-item rarity-' + skill.rarity;
        item.innerHTML = `
            <div class="skill-info">
                <div class="skill-name" style="color: ${rarityColors[skill.rarity]}">${skillIcons[id] || '⭐'} ${skill.name}</div>
                <div class="skill-rarity rarity-${skill.rarity}">${rarityNames[skill.rarity]}</div>
                <div class="skill-desc">${skill.description}</div>
            </div>
            <div class="skill-cd">CD: ${skill.cooldown}s</div>
        `;
        listEl.appendChild(item);
    }
}

// ============================================
// CS2 Style Roll Animation
// ============================================

function createRollItem(skillId) {
    const skill = allSkills[skillId];
    if (!skill) return null;
    
    const item = document.createElement('div');
    item.className = 'roll-item rarity-' + skill.rarity;
    item.innerHTML = `
        <div class="roll-item-icon">${skillIcons[skillId] || '⭐'}</div>
        <div class="roll-item-name">${skill.name}</div>
    `;
    item.style.borderColor = rarityColors[skill.rarity];
    item.style.background = `linear-gradient(135deg, rgba(30,30,40,0.95) 0%, ${rarityGlows[skill.rarity]} 100%)`;
    return item;
}

function generateRollItems(winningSkillId, count = 50) {
    const items = [];
    const skillIds = Object.keys(allSkills);
    
    // Générer des items aléatoires
    for (let i = 0; i < count; i++) {
        // Position gagnante (vers la fin, avec un peu de random)
        if (i === count - 8) {
            items.push(winningSkillId);
        } else {
            // Pondérer par rareté
            const rand = Math.random() * 100;
            let selectedId;
            
            if (rand < 50) {
                // Commun
                selectedId = skillIds.filter(id => allSkills[id].rarity === 1)[Math.floor(Math.random() * skillIds.filter(id => allSkills[id].rarity === 1).length)];
            } else if (rand < 80) {
                // Rare
                selectedId = skillIds.filter(id => allSkills[id].rarity === 2)[Math.floor(Math.random() * skillIds.filter(id => allSkills[id].rarity === 2).length)];
            } else if (rand < 95) {
                // Épique
                selectedId = skillIds.filter(id => allSkills[id].rarity === 3)[Math.floor(Math.random() * skillIds.filter(id => allSkills[id].rarity === 3).length)];
            } else {
                // Légendaire
                selectedId = skillIds.filter(id => allSkills[id].rarity === 4)[Math.floor(Math.random() * skillIds.filter(id => allSkills[id].rarity === 4).length)];
            }
            
            items.push(selectedId || skillIds[Math.floor(Math.random() * skillIds.length)]);
        }
    }
    
    return items;
}

function showRollAnimation(winningSkillId, callback) {
    isRolling = true;
    
    // Créer l'overlay
    const overlay = document.createElement('div');
    overlay.id = 'roll-overlay';
    overlay.className = 'roll-overlay';
    
    overlay.innerHTML = `
        <div class="roll-container">
            <div class="roll-header">
                <h2>🎲 ROLL EN COURS...</h2>
            </div>
            <div class="roll-window">
                <div class="roll-indicator"></div>
                <div class="roll-strip" id="roll-strip"></div>
            </div>
            <div class="roll-result" id="roll-result"></div>
        </div>
    `;
    
    document.body.appendChild(overlay);
    
    // Générer les items
    const strip = document.getElementById('roll-strip');
    const items = generateRollItems(winningSkillId, 50);
    const itemWidth = 140; // 130px width + 10px gap
    
    items.forEach(skillId => {
        const item = createRollItem(skillId);
        if (item) strip.appendChild(item);
    });
    
    // Animation
    requestAnimationFrame(() => {
        overlay.classList.add('active');
        
        setTimeout(() => {
            // Position finale (item gagnant au centre)
            // Avec padding-left: 285px, l'item 0 est centré à translateX(0)
            // Pour centrer l'item N, on doit décaler de -N * 140
            const winningIndex = 50 - 8;
            
            // Random offset pour ne pas toujours atterrir au centre exact (+/- 50px)
            const randomOffset = Math.floor(Math.random() * 100) - 50;
            
            const targetPos = -(winningIndex * itemWidth) + randomOffset;
            
            strip.style.transition = 'transform 5s cubic-bezier(0.15, 0.85, 0.25, 1)';
            strip.style.transform = `translateX(${targetPos}px)`;
            
            // Après l'animation
            setTimeout(() => {
                const skill = allSkills[winningSkillId];
                const resultEl = document.getElementById('roll-result');
                
                // Afficher le résultat
                resultEl.innerHTML = `
                    <div class="result-skill rarity-${skill.rarity}">
                        <div class="result-icon">${skillIcons[winningSkillId] || '⭐'}</div>
                        <div class="result-name" style="color: ${rarityColors[skill.rarity]}">${skill.name}</div>
                        <div class="result-rarity" style="color: ${rarityColors[skill.rarity]}">${rarityNames[skill.rarity]}</div>
                    </div>
                `;
                resultEl.classList.add('show');
                
                // Effet de particules pour légendaire/épique
                if (skill.rarity >= 3) {
                    createParticles(skill.rarity);
                }
                
                // Fermer après 2 secondes
                setTimeout(() => {
                    overlay.classList.remove('active');
                    setTimeout(() => {
                        overlay.remove();
                        isRolling = false;
                        if (callback) callback();
                    }, 300);
                }, 2000);
                
            }, 5200);
        }, 100);
    });
}

function createParticles(rarity) {
    const colors = rarity === 4 ? ['#ffb400', '#ffd700', '#ff8c00'] : ['#b446ff', '#9932cc', '#da70d6'];
    const container = document.querySelector('.roll-container');
    
    for (let i = 0; i < 30; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.background = colors[Math.floor(Math.random() * colors.length)];
        particle.style.left = Math.random() * 100 + '%';
        particle.style.animationDelay = Math.random() * 0.5 + 's';
        particle.style.animationDuration = (1 + Math.random()) + 's';
        container.appendChild(particle);
        
        setTimeout(() => particle.remove(), 2000);
    }
}

// Actions
function closeMenu() {
    if (isRolling) return;
    // Si un roll est en attente (modal de remplacement ouverte), l'annuler
    if (pendingNewSkill) {
        bwskills.cancelRoll();
        pendingNewSkill = null;
    }
    bwskills.close();
}

function rollSkill() {
    if (isRolling) return;
    bwskills.roll();
}

function replaceSkill(slot) {
    if (pendingNewSkill) {
        bwskills.replace(slot, pendingNewSkill);
        closeReplaceModal();
    }
}

function cancelReplace() {
    pendingNewSkill = null;
    // Annuler le roll côté serveur
    bwskills.cancelRoll();
    closeReplaceModal();
}

function closeReplaceModal() {
    document.getElementById('replace-modal').classList.remove('active');
}

function showReplaceModal(newSkillId) {
    pendingNewSkill = newSkillId;
    const skill = allSkills[newSkillId];
    
    if (!skill) return;
    
    document.getElementById('new-skill-name').textContent = skill.name;
    document.getElementById('new-skill-name').style.color = rarityColors[skill.rarity];
    document.getElementById('new-skill-rarity').textContent = rarityNames[skill.rarity];
    document.getElementById('new-skill-rarity').style.color = rarityColors[skill.rarity];
    document.getElementById('new-skill-desc').textContent = skill.description;
    
    const newSkillCard = document.getElementById('new-skill-card');
    newSkillCard.style.borderColor = rarityColors[skill.rarity];
    
    const skill1 = allSkills[playerData.skill1];
    const skill2 = allSkills[playerData.skill2];
    
    document.getElementById('replace-name-1').textContent = skill1 ? skill1.name : 'Vide';
    document.getElementById('replace-name-2').textContent = skill2 ? skill2.name : 'Vide';
    
    document.getElementById('replace-modal').classList.add('active');
}

function bindKey(slot) {
    const btn = document.getElementById('keybind-' + slot);
    btn.classList.add('binding');
    btn.textContent = '...';
    bindingSlot = slot;
    
    bwskills.startBind(slot);
}

function finishBind(slot, keyName) {
    const btn = document.getElementById('keybind-' + slot);
    btn.classList.remove('binding');
    btn.textContent = keyName.toUpperCase();
    bindingSlot = null;
    
    if (slot === 1) {
        playerData.key1 = keyName;
    } else {
        playerData.key2 = keyName;
    }
}

function showNotification(message, type) {
    const notif = document.getElementById('notification');
    const textEl = document.getElementById('notification-text');
    
    textEl.textContent = message;
    notif.className = 'notification ' + type + ' show';
    
    setTimeout(() => {
        notif.classList.remove('show');
    }, 3000);
}

// Called from Lua
function receiveData(data) {
    playerData.skill1 = data.skill1;
    playerData.skill2 = data.skill2;
    playerData.rolls_used = data.rolls_used || 0;
    playerData.key1 = data.key1 || 'Z';
    playerData.key2 = data.key2 || 'X';
    
    updateSkillsDisplay();
}

function receiveSkills(skills) {
    allSkills = skills;
    populateSkillsList();
    updateSkillsDisplay();
}

function onRollResult(success, skillId, needsReplace) {
    if (success) {
        const skill = allSkills[skillId];
        if (skill) {
            // Lancer l'animation CS2
            showRollAnimation(skillId, function() {
                if (needsReplace) {
                    showReplaceModal(skillId);
                } else {
                    showNotification('Vous avez obtenu: ' + skill.name, 'success');
                }
            });
            
            playerData.rolls_used++;
            updateRollInfo();
        }
    } else {
        showNotification(skillId, 'error');
    }
}

function onSkillEquipped(slot, skillId) {
    if (slot === 1) {
        playerData.skill1 = skillId;
    } else {
        playerData.skill2 = skillId;
    }
    updateSkillsDisplay();
    
    const skill = allSkills[skillId];
    if (skill) {
        showNotification(skill.name + ' équipé dans le slot ' + slot, 'success');
    }
}

document.addEventListener('DOMContentLoaded', init);
]]
