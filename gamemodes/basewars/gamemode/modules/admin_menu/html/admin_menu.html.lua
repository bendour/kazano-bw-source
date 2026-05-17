return [[
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Menu - Kazano</title>
    <style>
        /* CSS_PLACEHOLDER */
    </style>
</head>
<body>
    <div class="admin-container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="admin-avatar" id="admin-avatar"></div>
                <div class="admin-info">
                    <span class="admin-name" id="admin-name">Admin</span>
                    <span class="admin-rank" id="admin-rank">superadmin</span>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <button class="nav-btn active" data-tab="players" onclick="switchTab('players')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                    <span>Joueurs</span>
                </button>
                <button class="nav-btn" data-tab="warnings" onclick="switchTab('warnings')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                        <line x1="12" y1="9" x2="12" y2="13"></line>
                        <line x1="12" y1="17" x2="12.01" y2="17"></line>
                    </svg>
                    <span>Warnings</span>
                </button>
                <button class="nav-btn" data-tab="factions" onclick="switchTab('factions')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                    <span>Factions</span>
                </button>
                <button class="nav-btn" data-tab="immunities" onclick="switchTab('immunities')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                    </svg>
                    <span>Immunités</span>
                </button>
                <button class="nav-btn" data-tab="logs" onclick="switchTab('logs')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                        <line x1="16" y1="13" x2="8" y2="13"></line>
                        <line x1="16" y1="17" x2="8" y2="17"></line>
                        <polyline points="10 9 9 9 8 9"></polyline>
                    </svg>
                    <span>Logs</span>
                </button>
            </nav>
            
            <button class="close-btn" onclick="closeMenu()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="18" y1="6" x2="6" y2="18"></line>
                    <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
                <span>Fermer</span>
            </button>
        </div>
        
        <!-- Main Content -->
        <div class="main-content">
            <div class="content-header">
                <h1 id="page-title">Gestion des Joueurs</h1>
                <div class="search-bar">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="8"></circle>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                    </svg>
                    <input type="text" id="search-input" placeholder="Rechercher un joueur (nom ou SteamID)..." onkeyup="handleSearch(event)">
                    <button class="search-btn" onclick="performSearch()">Rechercher</button>
                </div>
            </div>
            
            <!-- Players Tab -->
            <div class="tab-content active" id="tab-players">
                <div class="players-grid" id="players-grid">
                    <!-- Players will be loaded here -->
                    <div class="loading-spinner">
                        <div class="spinner"></div>
                        <span>Chargement des joueurs...</span>
                    </div>
                </div>
            </div>
            
            <!-- Warnings Tab -->
            <div class="tab-content" id="tab-warnings">
                <div class="warnings-container">
                    <div class="warnings-sidebar">
                        <h3>Joueurs en ligne</h3>
                        <div class="online-players" id="online-players-list">
                            <!-- Online players will be loaded here -->
                        </div>
                        <div class="offline-warn-section">
                            <h3>Joueur déconnecté</h3>
                            <input type="text" id="offline-steamid-input" placeholder="SteamID64...">
                            <button class="btn btn-action" onclick="warnOfflinePlayer()">Warn par SteamID</button>
                        </div>
                    </div>
                    <div class="warnings-main">
                        <div class="warnings-header" id="warnings-header">
                            <span>Sélectionnez un joueur pour voir ses warnings</span>
                        </div>
                        <div class="warnings-list" id="warnings-list">
                            <!-- Warnings will be loaded here -->
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Factions Tab -->
            <div class="tab-content" id="tab-factions">
                <div class="factions-list" id="factions-list">
                    <!-- Factions will be loaded here -->
                    <div class="loading-spinner">
                        <div class="spinner"></div>
                        <span>Chargement des factions...</span>
                    </div>
                </div>
            </div>
            
            <!-- Immunities Tab -->
            <div class="tab-content" id="tab-immunities">
                <div class="immunities-container">
                    <!-- Global Immunity -->
                    <div class="immunity-section">
                        <div class="immunity-header">
                            <h3>🛡️ Immunité Globale</h3>
                            <span class="immunity-timer" id="global-immunity-timer">Aucune</span>
                        </div>
                        <p class="immunity-desc">L'immunité globale empêche tous les raids sur le serveur.</p>
                        <button class="btn btn-action" id="reset-global-immunity" onclick="resetGlobalImmunity()">Réinitialiser</button>
                    </div>
                    
                    <!-- Faction Immunities -->
                    <div class="immunity-section">
                        <h3>🏰 Immunités des Factions</h3>
                        <p class="immunity-desc">Réinitialiser l'immunité d'une faction après un raid.</p>
                        <div class="immunity-list" id="faction-immunity-list">
                            <!-- Faction immunities will be loaded here -->
                        </div>
                    </div>
                    
                    <!-- Player Immunities -->
                    <div class="immunity-section">
                        <h3>👤 Immunités des Joueurs</h3>
                        <p class="immunity-desc">Réinitialiser l'immunité individuelle d'un joueur.</p>
                        <div class="immunity-list" id="player-immunity-list">
                            <!-- Player immunities will be loaded here -->
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Logs Tab -->
            <div class="tab-content" id="tab-logs">
                <div class="logs-container">
                    <div class="logs-filters">
                        <select id="log-category" onchange="filterLogs()">
                            <option value="all">Toutes les catégories</option>
                        </select>
                        <input type="text" id="log-search" placeholder="Rechercher dans les logs..." onkeyup="if(event.key==='Enter')searchLogs()">
                        <button class="btn btn-action" onclick="searchLogs()">Rechercher</button>
                        <button class="btn btn-refresh" onclick="refreshLogs()" title="Rafraîchir les logs">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                                <path d="M23 4v6h-6"></path>
                                <path d="M1 20v-6h6"></path>
                                <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
                            </svg>
                            Rafraîchir
                        </button>
                    </div>
                    <div class="logs-list" id="logs-list">
                        <!-- Logs will be loaded here -->
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Modal for adding warning -->
    <div class="modal" id="add-warning-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Ajouter un Warning</h2>
                <button class="modal-close" onclick="closeModal('add-warning-modal')">&times;</button>
            </div>
            <div class="modal-body">
                <p>Joueur: <strong id="warning-player-name"></strong></p>
                <input type="hidden" id="warning-player-id">
                <textarea id="warning-reason" placeholder="Raison du warning..."></textarea>
            </div>
            <div class="modal-footer">
                <button class="btn btn-cancel" onclick="closeModal('add-warning-modal')">Annuler</button>
                <button class="btn btn-confirm" onclick="submitWarning()">Confirmer</button>
            </div>
        </div>
    </div>
    
    <!-- Modal for player details -->
    <div class="modal" id="player-details-modal">
        <div class="modal-content modal-large">
            <div class="modal-header">
                <h2 id="player-detail-name">Détails du joueur</h2>
                <button class="modal-close" onclick="closeModal('player-details-modal')">&times;</button>
            </div>
            <div class="modal-body">
                <div class="player-detail-grid">
                    <div class="player-detail-avatar">
                        <img id="player-detail-avatar-img" src="" alt="Avatar">
                        <div class="player-status-badge" id="detail-status-badge">En ligne</div>
                    </div>
                    <div class="player-detail-info">
                        <div class="detail-section">
                            <h3>🎮 Informations Steam</h3>
                            <div class="detail-row">
                                <span class="detail-label">Pseudo Steam:</span>
                                <span class="detail-value" id="detail-name"></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">SteamID:</span>
                                <span class="detail-value copyable" id="detail-steamid" onclick="copyToClipboard(this)"></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">SteamID64:</span>
                                <span class="detail-value copyable" id="detail-steamid64" onclick="copyToClipboard(this)"></span>
                            </div>
                        </div>
                        <div class="detail-section">
                            <h3>📊 Statistiques</h3>
                            <div class="detail-row">
                                <span class="detail-label">Niveau:</span>
                                <span class="detail-value highlight" id="detail-level"></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Prestige:</span>
                                <span class="detail-value highlight-gold" id="detail-prestige"></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Temps de jeu:</span>
                                <span class="detail-value" id="detail-playtime"></span>
                            </div>
                        </div>
                        <div class="detail-section">
                            <h3>💰 Économie</h3>
                            <div class="detail-row">
                                <span class="detail-label">Argent:</span>
                                <span class="detail-value highlight-green" id="detail-money"></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Crédits:</span>
                                <span class="detail-value highlight-blue" id="detail-credits"></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Pointshop:</span>
                                <span class="detail-value highlight-purple" id="detail-pointshop"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="player-actions">
                    <button class="btn btn-action" onclick="gotoPlayer()">Téléporter</button>
                    <button class="btn btn-action" onclick="bringPlayer()">Amener</button>
                    <button class="btn btn-action btn-warning" onclick="openWarningModal()">Ajouter Warning</button>
                    <button class="btn btn-action btn-danger" onclick="kickPlayer()">Kick</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Change Leader Modal -->
    <div class="modal" id="change-leader-modal">
        <div class="modal-content modal-small">
            <div class="modal-header">
                <h2>Changer le Leader</h2>
                <button class="modal-close" onclick="closeModal('change-leader-modal')">&times;</button>
            </div>
            <div class="modal-body">
                <!-- Content will be dynamically generated -->
            </div>
        </div>
    </div>
    
    <!-- Confirmation Modal -->
    <div class="modal" id="confirm-modal">
        <div class="modal-content modal-small">
            <div class="modal-header">
                <h2 id="confirm-title">Confirmation</h2>
                <button class="modal-close" onclick="closeModal('confirm-modal')">&times;</button>
            </div>
            <div class="modal-body">
                <p id="confirm-message"></p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-cancel" onclick="closeModal('confirm-modal')">Annuler</button>
                <button class="btn btn-confirm" id="confirm-action-btn">Confirmer</button>
            </div>
        </div>
    </div>
    
    <script>
        /* JS_PLACEHOLDER */
    </script>
</body>
</html>
]]
