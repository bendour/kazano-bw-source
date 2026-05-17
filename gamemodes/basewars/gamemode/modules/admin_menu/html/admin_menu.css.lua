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

.admin-container {
    display: flex;
    width: 90vw;
    height: 90vh;
    margin: 5vh auto;
    background: rgba(20, 20, 30, 0.98);
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 25px 80px rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(255, 255, 255, 0.1);
}

/* Sidebar */
.sidebar {
    width: 280px;
    background: linear-gradient(180deg, rgba(30, 30, 45, 0.95) 0%, rgba(20, 20, 35, 0.98) 100%);
    padding: 24px;
    display: flex;
    flex-direction: column;
    border-right: 1px solid rgba(255, 255, 255, 0.08);
}

.sidebar-header {
    display: flex;
    align-items: center;
    gap: 16px;
    padding-bottom: 24px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    margin-bottom: 24px;
}

.admin-avatar {
    width: 56px;
    height: 56px;
    border-radius: 12px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    overflow: hidden;
}

.admin-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.admin-info {
    display: flex;
    flex-direction: column;
}

.admin-name {
    font-size: 16px;
    font-weight: 600;
    color: #fff;
}

.admin-rank {
    font-size: 13px;
    color: #a78bfa;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.sidebar-nav {
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex: 1;
}

.nav-btn {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 14px 18px;
    background: transparent;
    border: none;
    border-radius: 10px;
    color: rgba(255, 255, 255, 0.7);
    font-size: 15px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.nav-btn svg {
    width: 22px;
    height: 22px;
    stroke-width: 1.8;
}

.nav-btn:hover {
    background: rgba(255, 255, 255, 0.08);
    color: #fff;
}

.nav-btn.active {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.3) 0%, rgba(118, 75, 162, 0.3) 100%);
    color: #fff;
    border: 1px solid rgba(167, 139, 250, 0.3);
}

.close-btn {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 18px;
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.3);
    border-radius: 10px;
    color: #ef4444;
    font-size: 15px;
    cursor: pointer;
    transition: all 0.2s ease;
    margin-top: auto;
}

.close-btn svg {
    width: 20px;
    height: 20px;
}

.close-btn:hover {
    background: rgba(239, 68, 68, 0.25);
}

/* Main Content */
.main-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 24px;
    overflow: hidden;
}

.content-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.content-header h1 {
    font-size: 28px;
    font-weight: 700;
    background: linear-gradient(135deg, #667eea 0%, #a78bfa 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.search-bar {
    display: flex;
    align-items: center;
    gap: 12px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 8px 16px;
    width: 400px;
}

.search-bar svg {
    width: 20px;
    height: 20px;
    color: rgba(255, 255, 255, 0.4);
}

.search-bar input {
    flex: 1;
    background: transparent;
    border: none;
    color: #fff;
    font-size: 14px;
    outline: none;
}

.search-bar input::placeholder {
    color: rgba(255, 255, 255, 0.4);
}

.search-btn {
    padding: 8px 16px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    border-radius: 8px;
    color: #fff;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.search-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

/* Tab Content */
.tab-content {
    display: none;
    flex: 1;
    overflow-y: auto;
}

.tab-content.active {
    display: block;
}

/* Players Grid */
.players-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 16px;
}

.player-card {
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 12px;
    padding: 16px;
    display: flex;
    align-items: center;
    gap: 16px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.player-card:hover {
    background: rgba(255, 255, 255, 0.08);
    border-color: rgba(167, 139, 250, 0.3);
    transform: translateY(-2px);
}

.player-avatar {
    width: 48px;
    height: 48px;
    border-radius: 10px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    overflow: hidden;
}

.player-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.player-info {
    flex: 1;
}

.player-name {
    font-size: 15px;
    font-weight: 600;
    color: #fff;
    margin-bottom: 4px;
}

.player-status {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
}

.player-status.online {
    color: #22c55e;
}

.player-level {
    font-size: 13px;
    color: #a78bfa;
    font-weight: 500;
}

/* Warnings Container */
.warnings-container {
    display: flex;
    gap: 24px;
    height: 100%;
}

.warnings-sidebar {
    width: 280px;
    background: rgba(255, 255, 255, 0.04);
    border-radius: 12px;
    padding: 16px;
    overflow-y: auto;
}

.warnings-sidebar h3 {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.6);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 16px;
}

.online-player-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 12px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.online-player-item:hover, .online-player-item.active {
    background: rgba(167, 139, 250, 0.15);
}

.online-player-item .avatar {
    width: 32px;
    height: 32px;
    min-width: 32px;
    border-radius: 6px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    background-size: cover;
    background-position: center;
}

.online-player-item .name {
    font-size: 14px;
    color: #fff;
}

/* Offline warn section */
.offline-warn-section {
    margin-top: 20px;
    padding-top: 16px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.offline-warn-section h3 {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.6);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 12px;
}

.offline-warn-section input {
    width: 100%;
    padding: 10px 12px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    color: #fff;
    font-size: 13px;
    margin-bottom: 10px;
    transition: all 0.2s ease;
}

.offline-warn-section input:focus {
    outline: none;
    border-color: rgba(167, 139, 250, 0.5);
    background: rgba(255, 255, 255, 0.08);
}

.offline-warn-section input::placeholder {
    color: rgba(255, 255, 255, 0.4);
}

.offline-warn-section .btn {
    width: 100%;
    padding: 10px 16px;
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    border: none;
    border-radius: 8px;
    color: #fff;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.offline-warn-section .btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 15px rgba(245, 158, 11, 0.3);
}

.warnings-main {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.warnings-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    background: rgba(255, 255, 255, 0.04);
    border-radius: 12px;
    margin-bottom: 16px;
}

.warnings-header span {
    color: rgba(255, 255, 255, 0.6);
}

.add-warning-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    border: none;
    border-radius: 8px;
    color: #fff;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.add-warning-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 15px rgba(245, 158, 11, 0.4);
}

.warnings-list {
    flex: 1;
    overflow-y: auto;
}

.warning-item {
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(239, 68, 68, 0.2);
    border-radius: 10px;
    padding: 16px;
    margin-bottom: 12px;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.warning-info {
    flex: 1;
}

.warning-reason {
    font-size: 14px;
    color: #fff;
    margin-bottom: 8px;
}

.warning-meta {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
}

.warning-actions {
    display: flex;
    gap: 8px;
}

.warning-action-btn {
    padding: 8px;
    background: rgba(255, 255, 255, 0.06);
    border: none;
    border-radius: 6px;
    color: rgba(255, 255, 255, 0.6);
    cursor: pointer;
    transition: all 0.2s ease;
}

.warning-action-btn:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #fff;
}

.warning-action-btn.delete:hover {
    background: rgba(239, 68, 68, 0.2);
    color: #ef4444;
}

/* Factions */
.factions-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.faction-card {
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 12px;
    overflow: hidden;
}

.faction-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.faction-name {
    font-size: 18px;
    font-weight: 600;
}

.faction-actions {
    display: flex;
    gap: 8px;
}

.faction-members {
    padding: 16px 20px;
}

.faction-member {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 12px;
    border-radius: 8px;
    margin-bottom: 8px;
    background: rgba(255, 255, 255, 0.03);
}

.faction-member.leader {
    background: rgba(167, 139, 250, 0.1);
    border: 1px solid rgba(167, 139, 250, 0.2);
}

/* Logs */
.logs-container {
    display: flex;
    flex-direction: column;
    height: 100%;
}

.logs-filters {
    display: flex;
    gap: 16px;
    margin-bottom: 16px;
}

.logs-filters select, .logs-filters input {
    padding: 12px 16px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    color: #fff;
    font-size: 14px;
    outline: none;
}

.logs-filters select {
    min-width: 200px;
}

.logs-filters input {
    flex: 1;
}

.logs-filters .btn-action {
    padding: 10px 20px;
}

.logs-filters .btn-refresh {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 10px 16px;
    background: rgba(34, 197, 94, 0.2);
    border: 1px solid rgba(34, 197, 94, 0.3);
    color: #22c55e;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    font-size: 13px;
}

.logs-filters .btn-refresh:hover {
    background: rgba(34, 197, 94, 0.3);
    border-color: rgba(34, 197, 94, 0.5);
}

.logs-filters .btn-refresh svg {
    flex-shrink: 0;
}

.logs-list {
    flex: 1;
    overflow-y: auto;
}

.log-item {
    display: flex;
    gap: 16px;
    padding: 12px 16px;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 8px;
    margin-bottom: 8px;
    font-size: 13px;
}

.log-time {
    color: rgba(255, 255, 255, 0.4);
    min-width: 80px;
}

.log-category {
    color: #a78bfa;
    min-width: 100px;
    font-weight: 500;
}

.log-text {
    color: rgba(255, 255, 255, 0.8);
    flex: 1;
}

/* Loading Spinner */
.loading-spinner {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 60px;
    gap: 16px;
}

.spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba(167, 139, 250, 0.2);
    border-top-color: #a78bfa;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

.loading-spinner span {
    color: rgba(255, 255, 255, 0.5);
    font-size: 14px;
}

/* Modal */
.modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.7);
    backdrop-filter: blur(4px);
    z-index: 1000;
    justify-content: center;
    align-items: center;
}

.modal.active {
    display: flex;
}

.modal-content {
    background: rgba(30, 30, 45, 0.98);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 16px;
    width: 450px;
    max-height: 80vh;
    overflow: hidden;
}

.modal-content.modal-large {
    width: 600px;
}

.modal-content.modal-small {
    width: 380px;
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.modal-header h2 {
    font-size: 18px;
    font-weight: 600;
}

.modal-close {
    background: none;
    border: none;
    color: rgba(255, 255, 255, 0.5);
    font-size: 24px;
    cursor: pointer;
    transition: color 0.2s ease;
}

.modal-close:hover {
    color: #fff;
}

.modal-body {
    padding: 24px;
}

.modal-body textarea {
    width: 100%;
    min-height: 120px;
    padding: 14px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    color: #fff;
    font-size: 14px;
    resize: none;
    outline: none;
    margin-top: 16px;
}

.modal-body textarea:focus {
    border-color: rgba(167, 139, 250, 0.5);
}

.modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    padding: 16px 24px;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
}

/* Buttons */
.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-cancel {
    background: rgba(255, 255, 255, 0.1);
    color: #fff;
}

.btn-cancel:hover {
    background: rgba(255, 255, 255, 0.15);
}

.btn-confirm {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
}

.btn-confirm:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.btn-action {
    background: rgba(255, 255, 255, 0.08);
    color: #fff;
    margin-right: 8px;
    margin-bottom: 8px;
}

.btn-action:hover {
    background: rgba(255, 255, 255, 0.12);
}

.btn-action.btn-warning {
    background: rgba(245, 158, 11, 0.2);
    color: #f59e0b;
}

.btn-action.btn-warning:hover {
    background: rgba(245, 158, 11, 0.3);
}

.btn-action.btn-danger {
    background: rgba(239, 68, 68, 0.2);
    color: #ef4444;
}

.btn-action.btn-danger:hover {
    background: rgba(239, 68, 68, 0.3);
}

.btn-disband {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.3);
    color: #ef4444;
    padding: 8px 16px;
    border-radius: 6px;
    font-size: 13px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-disband:hover {
    background: rgba(239, 68, 68, 0.25);
}

/* Player Details */
.player-detail-grid {
    display: flex;
    gap: 32px;
    margin-bottom: 24px;
}

.player-detail-avatar {
    width: 140px;
    min-width: 140px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
}

.player-detail-avatar img {
    width: 120px;
    height: 120px;
    border-radius: 16px;
    object-fit: cover;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.player-status-badge {
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
}

.player-status-badge.online {
    background: rgba(34, 197, 94, 0.2);
    color: #22c55e;
    border: 1px solid rgba(34, 197, 94, 0.3);
}

.player-status-badge.offline {
    background: rgba(239, 68, 68, 0.2);
    color: #ef4444;
    border: 1px solid rgba(239, 68, 68, 0.3);
}

.player-detail-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.detail-section {
    background: rgba(255, 255, 255, 0.03);
    border-radius: 12px;
    padding: 16px;
}

.detail-section h3 {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.6);
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.detail-row {
    display: flex;
    justify-content: space-between;
    padding: 6px 0;
}

.detail-row:last-child {
    border-bottom: none;
}

.detail-label {
    color: rgba(255, 255, 255, 0.5);
    font-size: 13px;
}

.detail-value {
    color: #fff;
    font-size: 13px;
    font-weight: 500;
}

.detail-value.copyable {
    cursor: pointer;
    padding: 2px 8px;
    border-radius: 4px;
    background: rgba(255, 255, 255, 0.05);
    transition: all 0.2s ease;
    font-family: 'Consolas', monospace;
    position: relative;
}

.detail-value.copyable:hover {
    background: rgba(167, 139, 250, 0.2);
    color: #a78bfa;
}

.detail-value.copyable.copied {
    background: rgba(34, 197, 94, 0.2);
    color: #22c55e;
}

.copy-tooltip {
    position: absolute;
    top: -25px;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(34, 197, 94, 0.9);
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 11px;
    white-space: nowrap;
    pointer-events: none;
    animation: fadeInOut 1.5s ease;
}

@keyframes fadeInOut {
    0%, 100% { opacity: 0; }
    20%, 80% { opacity: 1; }
}

.detail-value.highlight {
    color: #a78bfa;
    font-size: 15px;
}

.detail-value.highlight-gold {
    color: #fbbf24;
    font-size: 15px;
}

.detail-value.highlight-green {
    color: #22c55e;
    font-size: 15px;
}

.detail-value.highlight-blue {
    color: #3b82f6;
    font-size: 15px;
}

.detail-value.highlight-purple {
    color: #a855f7;
    font-size: 15px;
}

.player-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    padding-top: 16px;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
}

/* Empty state */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: rgba(255, 255, 255, 0.4);
}

.empty-state svg {
    width: 64px;
    height: 64px;
    margin-bottom: 16px;
    opacity: 0.3;
}

/* Scrollbar */
::-webkit-scrollbar {
    width: 6px;
}

::-webkit-scrollbar-track {
    background: rgba(255, 255, 255, 0.03);
    border-radius: 3px;
}

::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.15);
    border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
    background: rgba(255, 255, 255, 0.25);
}

/* Logs Pagination */
.logs-pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 16px;
    padding: 16px;
    margin-top: 16px;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 8px;
}

.btn-page {
    padding: 10px 20px;
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.2) 0%, rgba(118, 75, 162, 0.2) 100%);
    border: 1px solid rgba(167, 139, 250, 0.3);
    border-radius: 6px;
    color: #fff;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-page:hover:not(:disabled) {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.4) 0%, rgba(118, 75, 162, 0.4) 100%);
    border-color: rgba(167, 139, 250, 0.5);
}

.btn-page:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}

.page-info {
    color: rgba(255, 255, 255, 0.7);
    font-size: 14px;
}

.log-date {
    color: rgba(255, 255, 255, 0.3);
    min-width: 90px;
    font-size: 12px;
}

/* Log category select optgroup */
.logs-filters select optgroup {
    background: #1a1a2e;
    color: #a78bfa;
    font-weight: 600;
}

.logs-filters select option {
    background: #1a1a2e;
    color: #fff;
    padding: 8px;
}

/* Member selection list */
.member-select-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    max-height: 300px;
    overflow-y: auto;
    margin-top: 12px;
}

.member-select-item {
    padding: 12px 16px;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    border: 1px solid transparent;
}

.member-select-item:hover {
    background: rgba(167, 139, 250, 0.2);
    border-color: rgba(167, 139, 250, 0.4);
}

.member-select-item span {
    color: #fff;
    font-weight: 500;
}

/* Copy tooltip */
.copy-tooltip {
    position: absolute;
    top: -30px;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(34, 197, 94, 0.9);
    color: #fff;
    padding: 4px 10px;
    border-radius: 4px;
    font-size: 11px;
    white-space: nowrap;
    animation: tooltipFade 1.5s ease forwards;
}

@keyframes tooltipFade {
    0% { opacity: 1; }
    70% { opacity: 1; }
    100% { opacity: 0; }
}

/* Immunities Tab */
.immunities-container {
    display: flex;
    flex-direction: column;
    gap: 24px;
    padding: 8px;
}

.immunity-section {
    background: rgba(255, 255, 255, 0.03);
    border-radius: 16px;
    padding: 24px;
    border: 1px solid rgba(255, 255, 255, 0.06);
}

.immunity-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
}

.immunity-section h3 {
    font-size: 18px;
    font-weight: 600;
    color: #fff;
    margin: 0 0 12px 0;
}

.immunity-header h3 {
    margin: 0;
}

.immunity-timer {
    font-size: 16px;
    font-weight: 600;
    padding: 6px 16px;
    border-radius: 20px;
    background: rgba(167, 139, 250, 0.2);
    color: #a78bfa;
}

.immunity-timer.active {
    background: rgba(239, 68, 68, 0.2);
    color: #ef4444;
}

.immunity-timer.inactive {
    background: rgba(34, 197, 94, 0.2);
    color: #22c55e;
}

.immunity-desc {
    color: rgba(255, 255, 255, 0.5);
    font-size: 14px;
    margin-bottom: 16px;
}

.immunity-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    max-height: 300px;
    overflow-y: auto;
}

.immunity-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 10px;
    border: 1px solid rgba(255, 255, 255, 0.05);
    transition: all 0.2s ease;
}

.immunity-item:hover {
    background: rgba(255, 255, 255, 0.05);
    border-color: rgba(255, 255, 255, 0.1);
}

.immunity-item-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.immunity-item-name {
    font-size: 14px;
    font-weight: 500;
    color: #fff;
}

.immunity-item-time {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
}

.immunity-item-time.has-immunity {
    color: #ef4444;
}

.immunity-item .btn {
    padding: 6px 16px;
    font-size: 12px;
}

.immunity-item .btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}
]]
