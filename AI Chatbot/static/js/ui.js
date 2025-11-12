// ==================== UI CONTROLLER ====================
class UIController {
    constructor(config) {
        this.config = config;
        this.elements = {};
        this.initializeElements();
    }

    /**
     * Initialize DOM elements
     */
    initializeElements() {
        this.elements = {
            chatMessages: document.getElementById('chatMessages'),
            messageInput: document.getElementById('messageInput'),
            sendBtn: document.getElementById('sendBtn'),
            chatHistory: document.getElementById('chatHistory'),
            typingIndicator: document.getElementById('typingIndicator'),
            // support both `welcomeScreen` and `welcome-screen` id variants
            welcomeScreen: document.getElementById('welcomeScreen') || document.getElementById('welcome-screen'),
            sidebar: document.getElementById('sidebar'),
            settingsModal: document.getElementById('settingsModal')
        };
    }

    /**
     * Add message bubble to chat
     */
    addMessage(sender, text, timestamp = null) {
        const messagesContainer = this.elements.chatMessages;
        
        // Hide welcome screen if visible (support both id variants)
        const welcome1 = document.getElementById('welcomeScreen');
        const welcome2 = document.getElementById('welcome-screen');
        if (this.elements.welcomeScreen) {
            this.elements.welcomeScreen.style.display = 'none';
        }
        if (welcome1) welcome1.style.display = 'none';
        if (welcome2) welcome2.style.display = 'none';

        // Sanitize and format text
        const sanitizedText = this._sanitizeAndFormat(text);

        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}`;
        messageDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-${sender === 'user' ? 'user' : 'robot'}"></i>
            </div>
            <div class="message-content">
                <div class="message-bubble">${sanitizedText}</div>
                <div class="message-time">${timestamp || this._getCurrentTime()}</div>
            </div>
        `;

        messagesContainer.appendChild(messageDiv);
        
        // Animate the message
        messageDiv.style.opacity = '0';
        messageDiv.style.transform = 'translateY(10px)';
        setTimeout(() => {
            messageDiv.style.transition = 'all 0.3s ease';
            messageDiv.style.opacity = '1';
            messageDiv.style.transform = 'translateY(0)';
        }, 10);
        
        if (this.config.CHAT.AUTO_SCROLL) {
            this._scrollToBottom();
        }

        return messageDiv;
    }

    /**
     * Show typing indicator
     */
    showTyping() {
        // Render typing indicator as an inline bot message bubble so it appears in-flow
        try {
            const container = this.elements.chatMessages;
            if (!container) return;

            // Do not add multiple typing placeholders
            if (container.querySelector('.message.bot.typing')) return;

            const messageDiv = document.createElement('div');
            messageDiv.className = 'message bot typing';

            messageDiv.innerHTML = `
                <div class="message-avatar">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                    <div class="message-bubble typing-bubble">
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                    </div>
                    <div class="message-time">${this._getCurrentTime()}</div>
                </div>
            `;

            container.appendChild(messageDiv);
            // slight delay before animation/scroll
            setTimeout(() => {
                messageDiv.style.opacity = '1';
                this._scrollToBottom();
            }, 20);
        } catch (e) {
            // fallback: show existing typingIndicator block
            if (this.elements.typingIndicator) this.elements.typingIndicator.style.display = 'flex';
        }
    }

    /**
     * Hide typing indicator
     */
    hideTyping() {
        try {
            const container = this.elements.chatMessages;
            if (!container) return;

            const typing = container.querySelector('.message.bot.typing');
            if (typing) {
                // smooth fade then remove
                typing.style.transition = 'opacity 0.2s ease, transform 0.2s ease';
                typing.style.opacity = '0';
                typing.style.transform = 'translateY(6px)';
                setTimeout(() => typing.remove(), 220);
                return;
            }
        } catch (e) {
            // ignore
        }

        // fallback: hide existing typingIndicator block
        if (this.elements.typingIndicator) {
            this.elements.typingIndicator.style.opacity = '0';
            setTimeout(() => {
                this.elements.typingIndicator.style.display = 'none';
            }, 300);
        }
    }

    /**
     * Clear all messages
     */
    clearMessages() {
        if (this.elements.chatMessages) {
            this.elements.chatMessages.innerHTML = this._getWelcomeScreenHTML();
        }
    }

    /**
     * Update chat history sidebar
     */
    updateChatHistory(chats, currentChatId) {
        const container = this.elements.chatHistory;
        if (!container) return;

        if (chats.length === 0) {
            container.innerHTML = `
                <div style="padding: 16px; text-align: center; color: var(--text-muted); font-size: 14px;">
                    ${this.config.MESSAGES.INFO.NO_HISTORY}
                </div>
            `;
            return;
        }

        container.innerHTML = chats.map(chat => `
            <div class="chat-history-item ${chat.id === currentChatId ? 'active' : ''}" 
                 onclick="app.loadChat('${chat.id}')">
                <i class="fas fa-comment"></i>
                <div class="chat-info">
                    <div class="chat-title-small">${this._escapeHtml(chat.title)}</div>
                    <div class="chat-preview">${this._escapeHtml(chat.preview)}</div>
                </div>
                <div class="chat-time">${this._formatTimestamp(chat.timestamp)}</div>
            </div>
        `).join('');
    }

    /**
     * Toggle sidebar
     */
    toggleSidebar() {
        if (this.elements.sidebar) {
            this.elements.sidebar.classList.toggle('collapsed');
        }
    }

    /**
     * Toggle settings modal
     */
    toggleSettings() {
        if (this.elements.settingsModal) {
            const isVisible = this.elements.settingsModal.style.display !== 'none';
            this.elements.settingsModal.style.display = isVisible ? 'none' : 'flex';
        }
    }

    /**
     * Show error message
     */
    showError(message) {
        this.addMessage('bot', `❌ Error: ${message}`);
    }

    /**
     * Enable/disable send button
     */
    setSendButtonState(enabled) {
        if (this.elements.sendBtn) {
            this.elements.sendBtn.disabled = !enabled;
        }
    }

    /**
     * Get input value
     */
    getInputValue() {
        return this.elements.messageInput ? this.elements.messageInput.value.trim() : '';
    }

    /**
     * Clear input
     */
    clearInput() {
        if (this.elements.messageInput) {
            this.elements.messageInput.value = '';
            this.elements.messageInput.focus();
        }
    }

    /**
     * Focus input
     */
    focusInput() {
        if (this.elements.messageInput) {
            this.elements.messageInput.focus();
        }
    }

    /**
     * Show notification
     */
    showNotification(message, type = 'info') {
        // You can implement a toast notification system here
        console.log(`[${type.toUpperCase()}] ${message}`);
    }

    /**
     * Get welcome screen HTML
     */
    _getWelcomeScreenHTML() {
        return `
            <div class="welcome-screen" id="welcomeScreen">
                <div class="welcome-icon">
                    <i class="fas fa-robot"></i>
                </div>
                <h2>Welcome to AI Support Agent</h2>
                <p>Your intelligent ISP support assistant</p>
                
                <div class="quick-actions">
                    <h3>Quick Actions</h3>
                    <div class="action-cards">
                        ${this.config.QUICK_ACTIONS.map(action => `
                            <div class="action-card" onclick="app.sendQuickMessage('${action.message}')">
                                <i class="fas ${action.icon}"></i>
                                <span>${action.label}</span>
                            </div>
                        `).join('')}
                    </div>
                </div>
            </div>
        `;
    }

    /**
     * Scroll to bottom of messages
     */
    _scrollToBottom() {
        if (this.elements.chatMessages) {
            this.elements.chatMessages.scrollTop = this.elements.chatMessages.scrollHeight;
        }
    }

    /**
     * Get current time formatted
     */
    _getCurrentTime() {
        const now = new Date();
        return now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    }

    /**
     * Format timestamp
     */
    _formatTimestamp(timestamp) {
        const date = new Date(timestamp);
        const now = new Date();
        const diff = now - date;

        if (diff < 60000) return 'Just now';
        if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
        if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;
        if (diff < 604800000) return `${Math.floor(diff / 86400000)}d ago`;

        return date.toLocaleDateString();
    }

    /**
     * Escape HTML to prevent XSS
     */
    _escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Sanitize and format message text
     */
    _sanitizeAndFormat(text) {
        // First, escape HTML to prevent XSS
        let formatted = this._escapeHtml(text);
        
        // Format line breaks
        formatted = formatted.replace(/\n/g, '<br>');
        
        // Format bullet points
        formatted = formatted.replace(/^[\-\*]\s+(.+)$/gm, '<div class="bullet-point">• $1</div>');
        
        // Format numbered lists
        formatted = formatted.replace(/^(\d+)\.\s+(.+)$/gm, '<div class="numbered-point">$1. $2</div>');
        
        // Format phone numbers (make them look nicer)
        formatted = formatted.replace(/(\+?\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9})/g, 
            '<span class="phone-number">$1</span>');
        
        // Format bold text (between **)
        formatted = formatted.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
        
        // Format ticket IDs
        formatted = formatted.replace(/(TKT\d+)/g, '<span class="ticket-id">$1</span>');
        
        // Format status indicators
        formatted = formatted.replace(/✓/g, '<span class="status-success">✓</span>');
        formatted = formatted.replace(/✗/g, '<span class="status-error">✗</span>');
        formatted = formatted.replace(/⚠️/g, '<span class="status-warning">⚠️</span>');
        
        return formatted;
    }
}
