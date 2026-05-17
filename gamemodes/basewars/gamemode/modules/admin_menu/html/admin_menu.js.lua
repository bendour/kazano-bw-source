return [[
// Global state
let currentTab = 'players';
let selectedPlayer = null;
let playersData = [];
let warningsData = [];
let factionsData = [];
let logsData = [];
let logCategories = {};
let currentLogModule = 'all';
let currentLogPage = 1;
let maxLogPage = 1;
let isInitialized = false;

// Initialize - defer to avoid blocking
document.addEventListener('DOMContentLoaded', function() {
    console.log('Admin Menu loaded');
    // Use requestAnimationFrame to allow the UI to render first
    requestAnimationFrame(function() {
        setTimeout(function() {
            isInitialized = true;
            requestPlayers();
        }, 50);
    });
});

// Close menu
function closeMenu() {
    if (typeof adminmenu !== 'undefined') {
        adminmenu.close();
    }
}

// Copy text to clipboard (via Lua)
function copyToClipboard(element) {
    const text = element.textContent || element.innerText;
    if (typeof adminmenu !== 'undefined' && adminmenu.copyToClipboard) {
        adminmenu.copyToClipboard(text);
        
        // Visual feedback
        element.classList.add('copied');
        const originalText = element.textContent;
        const tooltip = document.createElement('span');
        tooltip.className = 'copy-tooltip';
        tooltip.textContent = 'Copié!';
        element.appendChild(tooltip);
        
        setTimeout(() => {
            element.classList.remove('copied');
            if (tooltip.parentNode) tooltip.remove();
        }, 1500);
    }
}

// Switch tabs
function switchTab(tabName) {
    currentTab = tabName;
    
    // Update nav buttons
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.tab === tabName) {
            btn.classList.add('active');
        }
    });
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    document.getElementById('tab-' + tabName).classList.add('active');
    
    // Update title
    const titles = {
        'players': 'Gestion des Joueurs',
        'warnings': 'Gestion des Warnings',
        'factions': 'Gestion des Factions',
        'immunities': 'Gestion des Immunités',
        'logs': 'Logs du Serveur'
    };
    document.getElementById('page-title').textContent = titles[tabName] || 'Admin Menu';
    
    // Load data for tab
    switch(tabName) {
        case 'players':
            requestPlayers();
            break;
        case 'warnings':
            requestOnlinePlayers();
            break;
        case 'factions':
            requestFactions();
            break;
        case 'immunities':
            requestImmunities();
            break;
        case 'logs':
            requestLogCategories();
            requestLogs('all', 1);
            break;
    }
}

// Search handling
function handleSearch(event) {
    if (event.key === 'Enter') {
        performSearch();
    }
}

function performSearch() {
    const query = document.getElementById('search-input').value.trim();
    if (query === '') return;
    
    if (typeof adminmenu !== 'undefined') {
        adminmenu.searchPlayer(query);
    }
}

// Request players from Lua
function requestPlayers() {
    showLoading('players-grid');
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestPlayers();
    }
}

// Receive players from Lua
function receivePlayers(data) {
    try {
        playersData = JSON.parse(data);
        renderPlayers();
    } catch(e) {
        console.error('Error parsing players:', e);
    }
}

// Generate Steam avatar URL from SteamID64
function getSteamAvatarUrl(steamid64) {
    // Use Steam CDN with hash generated from SteamID64
    // Format: https://avatars.steamstatic.com/[hash]_full.jpg
    // We'll use the Steam community avatar endpoint instead
    return 'https://avatars.cloudflare.steamstatic.com/' + steamid64 + '_full.jpg';
}

// Alternative: Use Steam API endpoint that redirects to avatar
function getSteamAvatarUrlAlt(steamid64) {
    return 'https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/avatars/' + getAvatarHash(steamid64);
}

// Render players grid with chunked rendering for performance
function renderPlayers() {
    const grid = document.getElementById('players-grid');
    
    if (playersData.length === 0) {
        grid.innerHTML = '<div class="empty-state"><p>Aucun joueur trouvé</p></div>';
        return;
    }
    
    // Clear grid first
    grid.innerHTML = '';
    
    // Render in chunks to avoid freeze
    const CHUNK_SIZE = 10;
    let currentIndex = 0;
    
    function renderChunk() {
        const fragment = document.createDocumentFragment();
        const end = Math.min(currentIndex + CHUNK_SIZE, playersData.length);
        
        for (let i = currentIndex; i < end; i++) {
            const player = playersData[i];
            const statusClass = player.online ? 'online' : '';
            const statusText = player.online ? 'En ligne' : 'Vu ' + player.lastSeen;
            
            const card = document.createElement('div');
            card.className = 'player-card';
            card.onclick = () => openPlayerDetails(player.steamid64);
            card.innerHTML = `
                <div class="player-avatar">
                    <img src="https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_medium.jpg" data-steamid="${player.steamid64}" alt="">
                </div>
                <div class="player-info">
                    <div class="player-name">${escapeHtml(player.name)}</div>
                    <div class="player-status ${statusClass}">${statusText}</div>
                </div>
                <div class="player-level">Niv. ${player.level || 1}</div>
            `;
            fragment.appendChild(card);
        }
        
        grid.appendChild(fragment);
        currentIndex = end;
        
        // Load avatars for this chunk
        const newCards = grid.querySelectorAll('.player-card:nth-child(n+' + (currentIndex - CHUNK_SIZE + 1) + ')');
        newCards.forEach(card => {
            const img = card.querySelector('img[data-steamid]');
            if (img) loadSteamAvatar(img);
        });
        
        // Continue with next chunk if needed
        if (currentIndex < playersData.length) {
            requestAnimationFrame(renderChunk);
        }
    }
    
    renderChunk();
}

// Load Steam avatar using the XML profile endpoint
function loadSteamAvatar(imgElement) {
    const steamid64 = imgElement.dataset.steamid;
    if (!steamid64) return;
    
    // Use a workaround: Steam Web API avatar URL pattern
    // Since we can't directly fetch XML from DHTML due to CORS, we use a fallback
    imgElement.src = 'https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_medium.jpg';
    
    // Try to fetch from localStorage cache first
    const cached = localStorage.getItem('avatar_' + steamid64);
    if (cached) {
        imgElement.src = cached;
        return;
    }
    
    // Request avatar from Lua
    if (typeof adminmenu !== 'undefined' && adminmenu.requestAvatar) {
        adminmenu.requestAvatar(steamid64);
    }
}

// Open player details modal
function openPlayerDetails(steamid64) {
    selectedPlayer = steamid64;
    
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestPlayerDetails(steamid64);
    }
}

// Receive player details
function receivePlayerDetails(data) {
    try {
        const player = JSON.parse(data);
        
        document.getElementById('player-detail-name').textContent = player.name;
        document.getElementById('detail-name').textContent = player.name;
        document.getElementById('detail-steamid').textContent = player.steamid || 'N/A';
        document.getElementById('detail-steamid64').textContent = player.steamid64;
        document.getElementById('detail-level').textContent = player.level || '1';
        document.getElementById('detail-money').textContent = player.money || '0 $';
        document.getElementById('detail-playtime').textContent = formatTime(player.playtime || 0);
        document.getElementById('detail-prestige').textContent = player.prestige || '0';
        document.getElementById('detail-credits').textContent = formatNumber(player.credits || 0);
        document.getElementById('detail-pointshop').textContent = formatNumber(player.pointshop || 0);
        
        // Set avatar
        const avatarImg = document.getElementById('player-detail-avatar-img');
        if (avatarImg) {
            avatarImg.dataset.steamid = player.steamid64;
            // Try cached avatar first
            const cached = localStorage.getItem('avatar_' + player.steamid64);
            if (cached) {
                avatarImg.src = cached;
            } else {
                avatarImg.src = 'https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg';
                if (typeof adminmenu !== 'undefined' && adminmenu.requestAvatar) {
                    adminmenu.requestAvatar(player.steamid64);
                }
            }
        }
        
        // Update status badge
        const statusBadge = document.getElementById('detail-status-badge');
        if (player.online) {
            statusBadge.textContent = 'En ligne';
            statusBadge.className = 'player-status-badge online';
        } else {
            statusBadge.textContent = 'Hors ligne';
            statusBadge.className = 'player-status-badge offline';
        }
        
        openModal('player-details-modal');
    } catch(e) {
        console.error('Error parsing player details:', e);
    }
}

// Receive avatar URL from Lua
function receiveAvatar(steamid64, avatarUrl) {
    if (!avatarUrl) return;
    
    // Cache the avatar URL
    localStorage.setItem('avatar_' + steamid64, avatarUrl);
    
    // Update all images with this steamid
    document.querySelectorAll('img[data-steamid="' + steamid64 + '"]').forEach(img => {
        img.src = avatarUrl;
    });
    
    // Update warning player avatars (divs with background-image)
    const warningAvatar = document.getElementById('warning-avatar-' + steamid64);
    if (warningAvatar) {
        warningAvatar.style.backgroundImage = `url('${avatarUrl}')`;
        warningAvatar.style.backgroundSize = 'cover';
    }
}

// Warnings functions
function requestOnlinePlayers() {
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestOnlinePlayers();
    }
}

function receiveOnlinePlayers(data) {
    try {
        const players = JSON.parse(data);
        const list = document.getElementById('online-players-list');
        
        let html = '';
        players.forEach(player => {
            // Check avatar cache
            const cachedAvatar = localStorage.getItem('avatar_' + player.steamid64);
            const avatarStyle = cachedAvatar ? `background-image: url('${cachedAvatar}'); background-size: cover;` : '';
            
            html += `
                <div class="online-player-item" onclick="selectWarningPlayer('${player.steamid64}', '${escapeHtml(player.name)}')">
                    <div class="avatar" id="warning-avatar-${player.steamid64}" style="${avatarStyle}"></div>
                    <div class="name">${escapeHtml(player.name)}</div>
                </div>
            `;
            
            // Request avatar if not cached
            if (!cachedAvatar && typeof adminmenu !== 'undefined' && adminmenu.requestAvatar) {
                adminmenu.requestAvatar(player.steamid64);
            }
        });
        
        list.innerHTML = html || '<p style="color: rgba(255,255,255,0.4); padding: 10px;">Aucun joueur en ligne</p>';
    } catch(e) {
        console.error('Error parsing online players:', e);
    }
}

function selectWarningPlayer(steamid64, name) {
    selectedPlayer = steamid64;
    
    // Update active state
    document.querySelectorAll('.online-player-item').forEach(item => {
        item.classList.remove('active');
    });
    if (event && event.currentTarget) {
        event.currentTarget.classList.add('active');
    }
    
    // Update header
    document.getElementById('warnings-header').innerHTML = `
        <span>Warnings de <strong>${name}</strong></span>
        <button class="add-warning-btn" onclick="openAddWarningModal('${steamid64}', '${escapeHtml(name)}')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            Ajouter Warning
        </button>
    `;
    
    // Request warnings
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestWarnings(steamid64);
    }
}

// Warn offline player by SteamID
function warnOfflinePlayer() {
    const steamidInput = document.getElementById('offline-steamid-input');
    let steamid = steamidInput.value.trim();
    
    if (steamid === '') {
        alert('Veuillez entrer un SteamID64');
        return;
    }
    
    // Try to convert SteamID to SteamID64 if needed
    steamid = convertToSteamID64(steamid);
    
    if (!steamid || steamid.length < 10) {
        alert('SteamID invalide. Utilisez le format SteamID64 (ex: 00000000000000000)');
        return;
    }
    
    // Select the offline player
    selectedPlayer = steamid;
    
    // Clear active state on online players
    document.querySelectorAll('.online-player-item').forEach(item => {
        item.classList.remove('active');
    });
    
    // Update header with offline player info
    document.getElementById('warnings-header').innerHTML = `
        <span>Warnings de <strong>Joueur hors ligne</strong> (${steamid})</span>
        <button class="add-warning-btn" onclick="openAddWarningModal('${steamid}', 'Joueur hors ligne')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            Ajouter Warning
        </button>
    `;
    
    // Request warnings for this player
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestWarnings(steamid);
    }
    
    // Clear input
    steamidInput.value = '';
}

// Convert various SteamID formats to SteamID64
function convertToSteamID64(input) {
    // Already SteamID64
    if (/^[0-9]{17}$/.test(input)) {
        return input;
    }
    
    // STEAM_X:Y:Z format
    const steamIdMatch = input.match(/^STEAM_([0-5]):([01]):([0-9]+)$/i);
    if (steamIdMatch) {
        const y = parseInt(steamIdMatch[2]);
        const z = parseInt(steamIdMatch[3]);
        const steamid64 = BigInt('76561197960265728') + BigInt(z * 2) + BigInt(y);
        return steamid64.toString();
    }
    
    // [U:1:X] format
    const steam3Match = input.match(/^\\[U:1:([0-9]+)\\]$/i);
    if (steam3Match) {
        const accountId = BigInt(steam3Match[1]);
        const steamid64 = BigInt('76561197960265728') + accountId;
        return steamid64.toString();
    }
    
    // Just numbers (assume it's account ID or steamid64)
    if (/^[0-9]+$/.test(input)) {
        const num = BigInt(input);
        if (num < BigInt('76561197960265728')) {
            // It's an account ID
            return (BigInt('76561197960265728') + num).toString();
        }
        return input;
    }
    
    return input;
}

function receiveWarnings(data) {
    try {
        warningsData = JSON.parse(data);
        renderWarnings();
    } catch(e) {
        console.error('Error parsing warnings:', e);
    }
}

function renderWarnings() {
    const list = document.getElementById('warnings-list');
    
    if (warningsData.length === 0) {
        list.innerHTML = '<div class="empty-state"><p>Aucun warning pour ce joueur</p></div>';
        return;
    }
    
    let html = '';
    warningsData.forEach(warn => {
        html += `
            <div class="warning-item">
                <div class="warning-info">
                    <div class="warning-reason">${escapeHtml(warn.reason)}</div>
                    <div class="warning-meta">Par ${warn.adminName || 'Console'} - ${warn.date}</div>
                </div>
                <div class="warning-actions">
                    <button class="warning-action-btn delete" onclick="deleteWarning(${warn.id})" title="Supprimer">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                            <polyline points="3 6 5 6 21 6"></polyline>
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        </svg>
                    </button>
                </div>
            </div>
        `;
    });
    
    list.innerHTML = html;
}

function openAddWarningModal(steamid64, name) {
    document.getElementById('warning-player-name').textContent = name;
    document.getElementById('warning-player-id').value = steamid64;
    document.getElementById('warning-reason').value = '';
    openModal('add-warning-modal');
}

function submitWarning() {
    const steamid64 = document.getElementById('warning-player-id').value;
    const reason = document.getElementById('warning-reason').value.trim();
    
    if (reason === '') {
        alert('Veuillez entrer une raison');
        return;
    }
    
    if (typeof adminmenu !== 'undefined') {
        adminmenu.addWarning(steamid64, reason);
    }
    
    closeModal('add-warning-modal');
    
    // Refresh warnings after a short delay
    setTimeout(() => {
        if (selectedPlayer) {
            adminmenu.requestWarnings(selectedPlayer);
        }
    }, 500);
}

function deleteWarning(warningId) {
    if (typeof adminmenu !== 'undefined') {
        adminmenu.deleteWarning(warningId);
    }
    
    // Refresh warnings after a short delay
    setTimeout(() => {
        if (selectedPlayer) {
            adminmenu.requestWarnings(selectedPlayer);
        }
    }, 500);
}

// Factions functions
function requestFactions() {
    showLoading('factions-list');
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestFactions();
    }
}

function receiveFactions(data) {
    try {
        factionsData = JSON.parse(data);
        renderFactions();
    } catch(e) {
        console.error('Error parsing factions:', e);
    }
}

function renderFactions() {
    const list = document.getElementById('factions-list');
    
    if (factionsData.length === 0) {
        list.innerHTML = '<div class="empty-state"><p>Aucune faction active</p></div>';
        return;
    }
    
    let html = '';
    factionsData.forEach(faction => {
        html += `
            <div class="faction-card">
                <div class="faction-header">
                    <span class="faction-name" style="color: ${faction.color || '#fff'}">${escapeHtml(faction.name)}</span>
                    <div class="faction-actions">
                        <button class="btn-disband" onclick="disbandFaction('${escapeHtml(faction.name)}')">Dissoudre</button>
                    </div>
                </div>
                <div class="faction-members">
                    ${renderFactionMembers(faction)}
                </div>
            </div>
        `;
    });
    
    list.innerHTML = html;
}

function renderFactionMembers(faction) {
    let html = '';
    
    // Leader first
    if (faction.leader && faction.leader.steamid64) {
        html += `
            <div class="faction-member leader">
                <span>👑 ${escapeHtml(faction.leader.name)} (Leader)</span>
                ${faction.members && faction.members.length > 0 ? 
                    `<button class="btn btn-action" onclick="showChangeLeaderModal('${escapeHtml(faction.name)}', '${faction.leader.steamid64}')">Changer Leader</button>` 
                    : ''}
            </div>
        `;
    }
    
    // Members
    if (faction.members && faction.members.length > 0) {
        faction.members.forEach(member => {
            html += `
                <div class="faction-member">
                    <span>${escapeHtml(member.name)}</span>
                    <button class="btn btn-action btn-danger" onclick="kickFromFaction('${escapeHtml(faction.name)}', '${member.steamid64}')">Kick</button>
                </div>
            `;
        });
    }
    
    if (!faction.leader || !faction.leader.steamid64) {
        html += '<p style="color: rgba(255,255,255,0.4);">Aucun leader</p>';
    }
    
    if (!faction.members || faction.members.length === 0) {
        html += '<p style="color: rgba(255,255,255,0.4);">Aucun autre membre</p>';
    }
    
    return html;
}

// Show modal to select new leader from members
function showChangeLeaderModal(factionName, currentLeaderSteamID) {
    // Find the faction
    const faction = factionsData.find(f => f.name === factionName);
    if (!faction || !faction.members || faction.members.length === 0) {
        showNotification('Aucun membre disponible pour devenir leader', 'error');
        return;
    }
    
    // Build member list HTML
    let membersHtml = '';
    faction.members.forEach(member => {
        membersHtml += `
            <div class="member-select-item" onclick="selectNewLeader('${escapeHtml(factionName)}', '${currentLeaderSteamID}', '${member.steamid64}', this)">
                <span>${escapeHtml(member.name)}</span>
            </div>
        `;
    });
    
    // Create modal content
    const modalBody = document.querySelector('#change-leader-modal .modal-body');
    if (modalBody) {
        modalBody.innerHTML = `
            <p>Sélectionnez le nouveau leader pour <strong>${escapeHtml(factionName)}</strong>:</p>
            <div class="member-select-list">
                ${membersHtml}
            </div>
        `;
        openModal('change-leader-modal');
    }
}

function selectNewLeader(factionName, oldLeaderSteamID, newLeaderSteamID, element) {
    if (typeof adminmenu !== 'undefined') {
        adminmenu.changeLeader(factionName, oldLeaderSteamID, newLeaderSteamID);
    }
    closeModal('change-leader-modal');
    showNotification('Leader changé avec succès', 'success');
}

function disbandFaction(factionName) {
    showConfirm('Dissoudre la faction', `Êtes-vous sûr de vouloir dissoudre la faction "${factionName}" ?`, () => {
        if (typeof adminmenu !== 'undefined') {
            adminmenu.disbandFaction(factionName);
        }
    });
}

function kickFromFaction(factionName, steamid64) {
    showConfirm('Expulser le membre', 'Êtes-vous sûr de vouloir expulser ce membre de la faction ?', () => {
        if (typeof adminmenu !== 'undefined') {
            adminmenu.kickFromFaction(factionName, steamid64);
        }
    });
}

// Logs functions
let logsLoading = false;
let logsLoadingTimeout = null;

function requestLogCategories() {
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestLogCategories();
    }
}

function receiveLogCategories(data) {
    try {
        logCategories = JSON.parse(data);
        renderLogCategories();
    } catch(e) {
        console.error('Error parsing log categories:', e);
    }
}

function renderLogCategories() {
    const select = document.getElementById('log-category');
    if (!select) return;
    
    let html = '<option value="all">Tous les logs</option>';
    
    for (const [group, modules] of Object.entries(logCategories)) {
        html += `<optgroup label="${escapeHtml(group)}">`;
        modules.forEach(module => {
            const selected = currentLogModule === module ? 'selected' : '';
            html += `<option value="${escapeHtml(module)}" ${selected}>${escapeHtml(module)}</option>`;
        });
        html += '</optgroup>';
    }
    
    select.innerHTML = html;
}

function requestLogs(module, page) {
    // Clear any existing timeout
    if (logsLoadingTimeout) {
        clearTimeout(logsLoadingTimeout);
        logsLoadingTimeout = null;
    }
    
    // Reset loading state if stuck
    logsLoading = false;
    
    logsLoading = true;
    
    module = module || currentLogModule;
    page = page || currentLogPage;
    
    currentLogModule = module;
    currentLogPage = page;
    
    showLoading('logs-list');
    
    // Set a timeout to reset loading state if no response
    logsLoadingTimeout = setTimeout(() => {
        if (logsLoading) {
            logsLoading = false;
            const list = document.getElementById('logs-list');
            if (list) {
                list.innerHTML = '<div class="empty-state"><p>Erreur de chargement. <a href="#" onclick="refreshLogs()">Réessayer</a></p></div>';
            }
        }
    }, 10000); // 10 second timeout
    
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestLogs(module, page);
    }
}

function receiveLogs(data) {
    // Clear timeout
    if (logsLoadingTimeout) {
        clearTimeout(logsLoadingTimeout);
        logsLoadingTimeout = null;
    }
    
    logsLoading = false;
    try {
        const response = JSON.parse(data);
        logsData = response.logs || [];
        currentLogPage = response.page || 1;
        maxLogPage = response.maxPage || 1;
        renderLogs();
        renderLogPagination();
    } catch(e) {
        console.error('Error parsing logs:', e);
        const list = document.getElementById('logs-list');
        if (list) {
            list.innerHTML = '<div class="empty-state"><p>Erreur de parsing des logs</p></div>';
        }
    }
}

// Manual refresh function
function refreshLogs() {
    logsLoading = false;
    requestLogs(currentLogModule, currentLogPage);
}

function renderLogs() {
    const list = document.getElementById('logs-list');
    
    if (logsData.length === 0) {
        list.innerHTML = '<div class="empty-state"><p>Aucun log disponible pour cette catégorie</p></div>';
        return;
    }
    
    // Clear and render in chunks for better performance
    list.innerHTML = '';
    
    const CHUNK_SIZE = 15;
    let currentIndex = 0;
    
    function renderChunk() {
        const fragment = document.createDocumentFragment();
        const end = Math.min(currentIndex + CHUNK_SIZE, logsData.length);
        
        for (let i = currentIndex; i < end; i++) {
            const log = logsData[i];
            const item = document.createElement('div');
            item.className = 'log-item';
            item.innerHTML = `
                <span class="log-time">${log.time}</span>
                <span class="log-date">${log.date}</span>
                <span class="log-category">${escapeHtml(log.category)}</span>
                <span class="log-text">${escapeHtml(log.text)}</span>
            `;
            fragment.appendChild(item);
        }
        
        list.appendChild(fragment);
        currentIndex = end;
        
        if (currentIndex < logsData.length) {
            requestAnimationFrame(renderChunk);
        }
    }
    
    renderChunk();
}

function renderLogPagination() {
    let pagination = document.getElementById('logs-pagination');
    if (!pagination) {
        const container = document.querySelector('.logs-container');
        pagination = document.createElement('div');
        pagination.id = 'logs-pagination';
        pagination.className = 'logs-pagination';
        container.appendChild(pagination);
    }
    
    if (maxLogPage <= 1) {
        pagination.innerHTML = '';
        return;
    }
    
    let html = `
        <button class="btn btn-page" onclick="changePage(-1)" ${currentLogPage <= 1 ? 'disabled' : ''}>
            ← Précédent
        </button>
        <span class="page-info">Page ${currentLogPage} / ${maxLogPage}</span>
        <button class="btn btn-page" onclick="changePage(1)" ${currentLogPage >= maxLogPage ? 'disabled' : ''}>
            Suivant →
        </button>
    `;
    
    pagination.innerHTML = html;
}

function changePage(delta) {
    const newPage = currentLogPage + delta;
    if (newPage >= 1 && newPage <= maxLogPage) {
        requestLogs(currentLogModule, newPage);
    }
}

function filterLogs() {
    const category = document.getElementById('log-category').value;
    const search = document.getElementById('log-search').value.trim();
    
    if (search !== '') {
        // Search mode
        currentLogModule = '#' + search;
    } else {
        currentLogModule = category;
    }
    
    currentLogPage = 1;
    requestLogs(currentLogModule, 1);
}

function searchLogs() {
    const search = document.getElementById('log-search').value.trim();
    if (search === '') {
        const category = document.getElementById('log-category').value;
        currentLogModule = category;
    } else {
        currentLogModule = '#' + search;
    }
    currentLogPage = 1;
    requestLogs(currentLogModule, 1);
}

// Player actions
function gotoPlayer() {
    if (selectedPlayer && typeof adminmenu !== 'undefined') {
        adminmenu.gotoPlayer(selectedPlayer);
    }
    closeModal('player-details-modal');
}

function bringPlayer() {
    if (selectedPlayer && typeof adminmenu !== 'undefined') {
        adminmenu.bringPlayer(selectedPlayer);
    }
    closeModal('player-details-modal');
}

function openWarningModal() {
    const name = document.getElementById('player-detail-name').textContent;
    closeModal('player-details-modal');
    openAddWarningModal(selectedPlayer, name);
}

function kickPlayer() {
    const name = document.getElementById('player-detail-name').textContent;
    showConfirm('Kick le joueur', `Êtes-vous sûr de vouloir kick "${name}" ?`, () => {
        if (typeof adminmenu !== 'undefined') {
            adminmenu.kickPlayer(selectedPlayer);
        }
        closeModal('player-details-modal');
    });
}

// Modal functions
function openModal(modalId) {
    document.getElementById(modalId).classList.add('active');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

function showConfirm(title, message, onConfirm) {
    document.getElementById('confirm-title').textContent = title;
    document.getElementById('confirm-message').textContent = message;
    
    const confirmBtn = document.getElementById('confirm-action-btn');
    confirmBtn.onclick = () => {
        onConfirm();
        closeModal('confirm-modal');
    };
    
    openModal('confirm-modal');
}

// Utility functions
function showLoading(elementId) {
    document.getElementById(elementId).innerHTML = `
        <div class="loading-spinner">
            <div class="spinner"></div>
            <span>Chargement...</span>
        </div>
    `;
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatMoney(amount) {
    return new Intl.NumberFormat('fr-FR').format(amount) + ' $';
}

function formatNumber(amount) {
    return new Intl.NumberFormat('fr-FR').format(amount);
}

function formatTime(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return hours + 'h ' + minutes + 'm';
}

// Set admin info from Lua
function setAdminInfo(name, rank, avatarUrl) {
    document.getElementById('admin-name').textContent = name;
    document.getElementById('admin-rank').textContent = rank;
    if (avatarUrl) {
        document.getElementById('admin-avatar').innerHTML = '<img src="' + avatarUrl + '" alt="Avatar">';
    }
}

// ==================== IMMUNITIES ====================

let immunitiesData = {
    global: 0,
    factions: [],
    players: []
};
let immunityUpdateInterval = null;

function requestImmunities() {
    if (typeof adminmenu !== 'undefined') {
        adminmenu.requestImmunities();
    }
    
    // Start update interval for timers
    if (immunityUpdateInterval) clearInterval(immunityUpdateInterval);
    immunityUpdateInterval = setInterval(updateImmunityTimers, 1000);
}

function receiveImmunities(data) {
    try {
        immunitiesData = JSON.parse(data);
        renderImmunities();
    } catch(e) {
        console.error('Error parsing immunities:', e);
    }
}

function renderImmunities() {
    // Global immunity
    const globalTimer = document.getElementById('global-immunity-timer');
    if (globalTimer) {
        if (immunitiesData.global > 0) {
            globalTimer.textContent = formatImmunityTime(immunitiesData.global);
            globalTimer.className = 'immunity-timer active';
        } else {
            globalTimer.textContent = 'Aucune';
            globalTimer.className = 'immunity-timer inactive';
        }
    }
    
    // Faction immunities
    const factionList = document.getElementById('faction-immunity-list');
    if (factionList) {
        if (!immunitiesData.factions || immunitiesData.factions.length === 0) {
            factionList.innerHTML = '<p style="color: rgba(255,255,255,0.4);">Aucune faction avec immunité</p>';
        } else {
            let html = '';
            immunitiesData.factions.forEach(faction => {
                const hasImmunity = faction.immunity > 0;
                html += `
                    <div class="immunity-item">
                        <div class="immunity-item-info">
                            <span class="immunity-item-name" style="color: ${faction.color}">${escapeHtml(faction.name)}</span>
                            <span class="immunity-item-time ${hasImmunity ? 'has-immunity' : ''}" data-faction="${escapeHtml(faction.name)}" data-time="${faction.immunity}">
                                ${hasImmunity ? formatImmunityTime(faction.immunity) : 'Aucune immunité'}
                            </span>
                        </div>
                        <button class="btn btn-action" onclick="resetFactionImmunity('${escapeHtml(faction.name)}')" ${!hasImmunity ? 'disabled' : ''}>
                            Réinitialiser
                        </button>
                    </div>
                `;
            });
            factionList.innerHTML = html;
        }
    }
    
    // Player immunities
    const playerList = document.getElementById('player-immunity-list');
    if (playerList) {
        if (!immunitiesData.players || immunitiesData.players.length === 0) {
            playerList.innerHTML = '<p style="color: rgba(255,255,255,0.4);">Aucun joueur en ligne</p>';
        } else {
            let html = '';
            immunitiesData.players.forEach(player => {
                const hasImmunity = player.immunity > 0;
                html += `
                    <div class="immunity-item">
                        <div class="immunity-item-info">
                            <span class="immunity-item-name">${escapeHtml(player.name)}</span>
                            <span class="immunity-item-time ${hasImmunity ? 'has-immunity' : ''}" data-player="${player.steamid64}" data-time="${player.immunity}">
                                ${hasImmunity ? formatImmunityTime(player.immunity) : 'Aucune immunité'}
                            </span>
                        </div>
                        <button class="btn btn-action" onclick="resetPlayerImmunity('${player.steamid64}')" ${!hasImmunity ? 'disabled' : ''}>
                            Réinitialiser
                        </button>
                    </div>
                `;
            });
            playerList.innerHTML = html;
        }
    }
}

function updateImmunityTimers() {
    // Update global timer
    if (immunitiesData.global > 0) {
        immunitiesData.global--;
        const globalTimer = document.getElementById('global-immunity-timer');
        if (globalTimer && immunitiesData.global > 0) {
            globalTimer.textContent = formatImmunityTime(immunitiesData.global);
        } else if (globalTimer) {
            globalTimer.textContent = 'Aucune';
            globalTimer.className = 'immunity-timer inactive';
        }
    }
    
    // Update faction timers
    document.querySelectorAll('.immunity-item-time[data-faction]').forEach(el => {
        let time = parseInt(el.dataset.time) || 0;
        if (time > 0) {
            time--;
            el.dataset.time = time;
            if (time > 0) {
                el.textContent = formatImmunityTime(time);
            } else {
                el.textContent = 'Aucune immunité';
                el.classList.remove('has-immunity');
                const btn = el.closest('.immunity-item').querySelector('button');
                if (btn) btn.disabled = true;
            }
        }
    });
    
    // Update player timers
    document.querySelectorAll('.immunity-item-time[data-player]').forEach(el => {
        let time = parseInt(el.dataset.time) || 0;
        if (time > 0) {
            time--;
            el.dataset.time = time;
            if (time > 0) {
                el.textContent = formatImmunityTime(time);
            } else {
                el.textContent = 'Aucune immunité';
                el.classList.remove('has-immunity');
                const btn = el.closest('.immunity-item').querySelector('button');
                if (btn) btn.disabled = true;
            }
        }
    });
}

function formatImmunityTime(seconds) {
    if (seconds <= 0) return 'Aucune';
    
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    
    if (hours > 0) {
        return hours + 'h ' + minutes + 'm ' + secs + 's';
    } else if (minutes > 0) {
        return minutes + 'm ' + secs + 's';
    }
    return secs + 's';
}

function resetGlobalImmunity() {
    showConfirm('Réinitialiser l\'immunité globale', 'Êtes-vous sûr de vouloir réinitialiser l\'immunité globale du serveur ?', () => {
        if (typeof adminmenu !== 'undefined') {
            adminmenu.resetGlobalImmunity();
        }
        immunitiesData.global = 0;
        renderImmunities();
        showNotification('Immunité globale réinitialisée', 'success');
    });
}

function resetFactionImmunity(factionName) {
    showConfirm('Réinitialiser l\'immunité', `Êtes-vous sûr de vouloir réinitialiser l'immunité de la faction "${factionName}" ?`, () => {
        if (typeof adminmenu !== 'undefined') {
            adminmenu.resetFactionImmunity(factionName);
        }
        // Update local data
        const faction = immunitiesData.factions.find(f => f.name === factionName);
        if (faction) faction.immunity = 0;
        renderImmunities();
        showNotification('Immunité de la faction réinitialisée', 'success');
    });
}

function resetPlayerImmunity(steamid64) {
    showConfirm('Réinitialiser l\'immunité', 'Êtes-vous sûr de vouloir réinitialiser l\'immunité de ce joueur ?', () => {
        if (typeof adminmenu !== 'undefined') {
            adminmenu.resetPlayerImmunity(steamid64);
        }
        // Update local data
        const player = immunitiesData.players.find(p => p.steamid64 === steamid64);
        if (player) player.immunity = 0;
        renderImmunities();
        showNotification('Immunité du joueur réinitialisée', 'success');
    });
}
]]
