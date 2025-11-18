// ==================== MAIN APPLICATION ====================
class ChatbotApp {
    constructor() {
        this.config = CONFIG;
        this.api = new APIService(this.config);
        this.chatManager = new ChatManager(this.config);
        this.ui = new UIController(this.config);
        this.isProcessing = false;
        
        this.initialize();
    }

    /**
     * Initialize the application
     */
    async initialize() {
        console.log('🚀 Initializing AI Chatbot...');
        
        // Load settings
        this.loadSettings();
        
        // Setup event listeners
        this.setupEventListeners();
        
        // Load chat history
        this.updateChatHistoryUI();
        
        // Check API health
        await this.checkAPIHealth();
        
        // Focus input
        this.ui.focusInput();

        // Auto-insert assistant welcome/off-topic message after short delay
        // Avoid inserting if chat already has messages to prevent duplicates.
        setTimeout(() => {
            try {
                const messagesContainer = this.ui.elements.chatMessages;
                if (!messagesContainer) return;

                // If there are any existing message bubbles, don't auto-insert
                if (messagesContainer.querySelectorAll('.message').length > 0) return;

                // Get message text from config (fallback to NO_HISTORY if missing)
                const msgText = (this.config && this.config.MESSAGES && this.config.MESSAGES.OFFTOPIC)
                    ? this.config.MESSAGES.OFFTOPIC
                    : (this.config.MESSAGES.INFO.NO_HISTORY || 'Hello!');

                // Hide any welcome screen variants (some files use different IDs)
                const welcome1 = document.getElementById('welcome-screen');
                const welcome2 = document.getElementById('welcomeScreen');
                if (welcome1) welcome1.style.display = 'none';
                if (welcome2) welcome2.style.display = 'none';

                // Add bot message to UI as a regular message bubble (not absolutely positioned)
                let addedEl = null;
                if (this.ui && typeof this.ui.addMessage === 'function') {
                    addedEl = this.ui.addMessage('bot', msgText);
                } else {
                    // Fallback: directly append using legacy function if present
                    if (typeof addMessageToUI === 'function') addMessageToUI('bot', msgText);
                }

                // Add to chat history manager so it shows in saved chats
                if (this.chatManager && typeof this.chatManager.addToHistory === 'function') {
                    this.chatManager.addToHistory('Agent', msgText);
                }

                // Refresh sidebar chat history
                this.updateChatHistoryUI();

                // Ensure the chat scrolls to bottom so the greeting appears near the input
                // Multiple attempts to ensure scroll happens after all layout/animations
                const forceScrollBottom = () => {
                    try {
                        const container = document.getElementById('chatMessages');
                        if (container) {
                            container.scrollTop = container.scrollHeight;
                        }
                    } catch (e) {
                        // ignore
                    }
                };
                
                // Immediate scroll
                forceScrollBottom();
                // After animation
                setTimeout(forceScrollBottom, 50);
                // Final fallback
                setTimeout(forceScrollBottom, 350);

            } catch (err) {
                console.warn('Auto-insert welcome message failed:', err);
            }
        }, 500); // 500ms delay
        
        console.log('✅ Chatbot initialized successfully');
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Send message on form submit
        const form = document.querySelector('.chat-input-form');
        if (form) {
            form.addEventListener('submit', (e) => this.handleSendMessage(e));
        }

        // Send message on Enter key
        const input = this.ui.elements.messageInput;
        if (input) {
            input.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    this.handleSendMessage(e);
                }
            });
        }

        // Close modal on outside click
        window.addEventListener('click', (e) => {
            if (e.target === this.ui.elements.settingsModal) {
                this.ui.toggleSettings();
            }
        });

        // Settings change listeners
        const apiEndpointInput = document.getElementById('apiEndpoint');
        const userPhoneInput = document.getElementById('userPhone');
        
        if (apiEndpointInput) {
            apiEndpointInput.addEventListener('change', (e) => {
                this.config.API.BASE_URL = e.target.value;
                this.api.baseURL = e.target.value;
                localStorage.setItem(this.config.STORAGE_KEYS.API_ENDPOINT, e.target.value);
            });
        }
        
        if (userPhoneInput) {
            userPhoneInput.addEventListener('change', (e) => {
                localStorage.setItem(this.config.STORAGE_KEYS.USER_PHONE, e.target.value);
            });
        }
    }

    /**
     * Handle send message
     */
    async handleSendMessage(event) {
        event.preventDefault();
        
        if (this.isProcessing) return;
        
        const message = this.ui.getInputValue();
        
        // Validate message
        if (!message) {
            this.ui.showError(this.config.MESSAGES.ERRORS.EMPTY_MESSAGE);
            return;
        }

        if (message.length > this.config.CHAT.MAX_MESSAGE_LENGTH) {
            this.ui.showError(`Message too long. Maximum ${this.config.CHAT.MAX_MESSAGE_LENGTH} characters.`);
            return;
        }

        // Clear input
        this.ui.clearInput();
        
        // Add user message to UI
        this.ui.addMessage('user', message);
        
        // Add to chat history
        this.chatManager.addToHistory('User', message);
        
        // Show typing indicator
        this.ui.showTyping();
        this.ui.setSendButtonState(false);
        this.isProcessing = true;

        try {
            // Get phone number for account lookup (backend will find account_id)
            const phoneNumber = localStorage.getItem(this.config.STORAGE_KEYS.USER_PHONE) || null;
            
            // Send to API
            const response = await this.api.sendMessage(
                message,
                this.chatManager.getCurrentHistory(),
                phoneNumber
            );

            // Hide typing indicator
            this.ui.hideTyping();

            // Add bot response to UI
            this.ui.addMessage('bot', response.reply);

            // Add to chat history
            this.chatManager.addToHistory('Agent', response.reply);

            // Update chat history sidebar
            this.updateChatHistoryUI();

        } catch (error) {
            console.error('Error sending message:', error);
            this.ui.hideTyping();
            
            let errorMessage = this.config.MESSAGES.ERRORS.GENERIC;
            
            if (error.name === 'AbortError') {
                errorMessage = this.config.MESSAGES.ERRORS.TIMEOUT;
            } else if (error.message.includes('Failed to fetch')) {
                errorMessage = this.config.MESSAGES.ERRORS.NETWORK;
            } else if (error.message.includes('HTTP error')) {
                errorMessage = this.config.MESSAGES.ERRORS.SERVER;
            }
            
            this.ui.showError(errorMessage);
        } finally {
            this.ui.setSendButtonState(true);
            this.isProcessing = false;
            this.ui.focusInput();
        }
    }

    /**
     * Send quick message
     */
    sendQuickMessage(message) {
        const input = this.ui.elements.messageInput;
        if (input) {
            input.value = message;
            const form = document.querySelector('.chat-input-form');
            if (form) {
                form.dispatchEvent(new Event('submit'));
            }
        }
    }

    /**
     * Start a new chat
     */
    startNewChat() {
        // Save current chat if it has messages
        if (this.chatManager.chatHistory.length > 0) {
            this.chatManager.saveCurrentChat();
        }

        // Create new chat
        this.chatManager.createNewChat();
        
        // Clear UI
        this.ui.clearMessages();
        
        // Show welcome screen
        const welcomeScreen = document.getElementById('welcome-screen');
        if (welcomeScreen) {
            welcomeScreen.style.display = 'flex';
        }
        
        // Update sidebar to show new chat
        this.updateChatHistoryUI();
        
        // Focus input
        this.ui.focusInput();
        
        console.log('New chat started:', this.chatManager.currentChatId);
    }

    /**
     * Load existing chat
     */
    loadChat(chatId) {
        const chat = this.chatManager.loadChat(chatId);
        if (!chat) {
            console.error('Chat not found:', chatId);
            return;
        }

        console.log('Loading chat:', chatId, 'with', chat.history.length, 'messages');

        // Clear current messages
        this.ui.clearMessages();

        // Hide welcome screen
        const welcomeScreen = document.getElementById('welcome-screen');
        if (welcomeScreen) {
            welcomeScreen.style.display = 'none';
        }

        // Reconstruct messages from history
        if (chat.history && chat.history.length > 0) {
            chat.history.forEach((entry, index) => {
                const colonIndex = entry.indexOf(': ');
                if (colonIndex === -1) {
                    console.warn('Invalid history entry:', entry);
                    return;
                }
                
                const sender = entry.substring(0, colonIndex).trim();
                const message = entry.substring(colonIndex + 2);
                const senderType = sender.toLowerCase() === 'user' ? 'user' : 'bot';
                
                this.ui.addMessage(senderType, message);
            });
        }

        // Update sidebar to highlight current chat
        this.updateChatHistoryUI();
        
        // Focus input
        this.ui.focusInput();
    }

    /**
     * Delete a chat
     */
    async deleteChat(chatId) {
        if (!confirm('Are you sure you want to delete this chat?')) {
            return;
        }

        this.chatManager.deleteChat(chatId);
        
        // If we deleted the current chat, start a new one
        if (this.chatManager.currentChatId === null || this.chatManager.currentChatId === chatId) {
            this.startNewChat();
        } else {
            this.updateChatHistoryUI();
        }
    }
    /**
     * Update chat history UI
     */
    updateChatHistoryUI() {
        const chats = this.chatManager.getAllChats();
        this.ui.updateChatHistory(chats, this.chatManager.currentChatId);
    }

    /**
     * Check API health
     */
    async checkAPIHealth() {
        try {
            const health = await this.api.checkHealth();
            console.log('API Health:', health);
            
            if (health.status === 'healthy') {
                console.log('✅ API is healthy');
            } else {
                console.warn('⚠️ API health check returned:', health);
            }
        } catch (error) {
            console.error('❌ API health check failed:', error);
        }
    }

    /**
     * Change theme
     */
    changeTheme(theme) {
        if (theme === 'light') {
            document.body.classList.add('light-theme');
        } else {
            document.body.classList.remove('light-theme');
        }
        localStorage.setItem(this.config.STORAGE_KEYS.THEME, theme);
    }

    /**
     * Load settings from localStorage
     */
    loadSettings() {
        // Load theme
        const theme = localStorage.getItem(this.config.STORAGE_KEYS.THEME) || this.config.UI.THEME.DEFAULT;
        this.changeTheme(theme);

        // Load API endpoint
        const savedEndpoint = localStorage.getItem(this.config.STORAGE_KEYS.API_ENDPOINT);
        if (savedEndpoint) {
            this.config.API.BASE_URL = savedEndpoint;
            this.api.baseURL = savedEndpoint;
            const input = document.getElementById('apiEndpoint');
            if (input) input.value = savedEndpoint;
        } else {
            // Set default to current origin
            const input = document.getElementById('apiEndpoint');
            if (input) input.value = window.location.origin;
        }

        // Load user phone
        const savedPhone = localStorage.getItem(this.config.STORAGE_KEYS.USER_PHONE);
        if (savedPhone) {
            const input = document.getElementById('userPhone');
            if (input) input.value = savedPhone;
        }
    }

    /**
     * Toggle sidebar
     */
    toggleSidebar() {
        this.ui.toggleSidebar();
    }

    /**
     * Toggle settings
     */
    toggleSettings() {
        this.ui.toggleSettings();
    }

    /**
     * Clear all chats
     */
    clearAllChats() {
        if (confirm('Are you sure you want to delete all chats? This action cannot be undone.')) {
            this.chatManager.clearAllChats();
            this.createNewChat();
            this.ui.showNotification('All chats cleared', 'success');
        }
    }
}

// ==================== GLOBAL FUNCTIONS ====================
let app;

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    app = new ChatbotApp();
});

// Global helper functions for HTML onclick handlers
function createNewChat() {
    if (app) app.createNewChat();
}

function toggleSidebar() {
    if (app) app.toggleSidebar();
}

function toggleSettings() {
    if (app) app.toggleSettings();
}

function changeTheme(theme) {
    if (app) app.changeTheme(theme);
}

function sendQuickMessage(message) {
    if (app) app.sendQuickMessage(message);
}

// ==================== INITIALIZATION ====================
document.addEventListener('DOMContentLoaded', function() {
    loadChatHistory();
    loadSettings();
    
    // Auto-focus input
    document.getElementById('messageInput').focus();
    
    // Handle Enter key
    document.getElementById('messageInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage(e);
        }
    });
});

// ==================== CHAT FUNCTIONALITY ====================
async function sendMessage(event) {
    event.preventDefault();
    
    const input = document.getElementById('messageInput');
    const message = input.value.trim();
    
    if (!message) return;
    
    // Clear input
    input.value = '';
    
    // Hide welcome screen
    const welcomeScreen = document.getElementById('welcomeScreen');
    if (welcomeScreen) {
        welcomeScreen.style.display = 'none';
    }
    
    // Add user message to UI
    addMessageToUI('user', message);
    
    // Add to history
    chatHistory.push(`User: ${message}`);
    
    // Show typing indicator
    showTypingIndicator();
    
    // Disable send button
    const sendBtn = document.getElementById('sendBtn');
    sendBtn.disabled = true;
    
    try {
        // Send to API
        const response = await fetch(`${apiEndpoint}/chat`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                message: message,
                history: chatHistory.slice(-10), // Last 10 messages for context
                user_id: getUserPhone()
            })
        });
        
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        
        const data = await response.json();
        const reply = data.reply;
        
        // Hide typing indicator
        hideTypingIndicator();
        
        // Add bot response to UI
        addMessageToUI('bot', reply);
        
        // Add to history
        chatHistory.push(`Agent: ${reply}`);
        
        // Update chat in storage
        updateCurrentChat(message, reply);
        
    } catch (error) {
        console.error('Error:', error);
        hideTypingIndicator();
        addMessageToUI('bot', 'Sorry, I encountered an error. Please check if the server is running and try again.');
    } finally {
        // Re-enable send button
        sendBtn.disabled = false;
        input.focus();
    }
}

function sendQuickMessage(message) {
    const input = document.getElementById('messageInput');
    input.value = message;
    const form = document.querySelector('.chat-input-form');
    sendMessage({ preventDefault: () => {}, target: form });
}

function addMessageToUI(sender, text) {
    // Prefer UIController if available to ensure consistent rendering and scroll behavior
    if (typeof app !== 'undefined' && app && app.ui && typeof app.ui.addMessage === 'function') {
        try { app.ui.addMessage(sender, text); return; } catch (e) { /* fallback */ }
    }

    const chatMessages = document.getElementById('chatMessages');
    
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${sender}`;
    
    const avatar = document.createElement('div');
    avatar.className = 'message-avatar';
    avatar.innerHTML = sender === 'user' ? '<i class="fas fa-user"></i>' : '<i class="fas fa-robot"></i>';
    
    const content = document.createElement('div');
    content.className = 'message-content';
    
    const bubble = document.createElement('div');
    bubble.className = 'message-bubble';
    bubble.textContent = text;
    
    const time = document.createElement('div');
    time.className = 'message-time';
    time.textContent = getCurrentTime();
    
    content.appendChild(bubble);
    content.appendChild(time);
    
    messageDiv.appendChild(avatar);
    messageDiv.appendChild(content);
    
    chatMessages.appendChild(messageDiv);

    // Only auto-scroll if user is near bottom (within 120px)
    try {
        const distanceFromBottom = chatMessages.scrollHeight - chatMessages.clientHeight - chatMessages.scrollTop;
        if (distanceFromBottom < 120) {
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
    } catch (e) {
        // fallback: always scroll
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }
}

function showTypingIndicator() {
    // Prefer UIController's inline typing bubble if app exists
    if (typeof app !== 'undefined' && app && app.ui && typeof app.ui.showTyping === 'function') {
        try { app.ui.showTyping(); return; } catch (e) { /* fallback */ }
    }

    const el = document.getElementById('typingIndicator');
    if (el) el.style.display = 'flex';
}

function hideTypingIndicator() {
    // Prefer UIController's inline typing bubble if app exists
    if (typeof app !== 'undefined' && app && app.ui && typeof app.ui.hideTyping === 'function') {
        try { app.ui.hideTyping(); return; } catch (e) { /* fallback */ }
    }

    const el = document.getElementById('typingIndicator');
    if (el) el.style.display = 'none';
}

// ==================== CHAT MANAGEMENT ====================
function createNewChat() {
    // Save current chat if exists
    if (currentChatId && chatHistory.length > 0) {
        saveCurrentChat();
    }
    
    // Create new chat
    currentChatId = Date.now().toString();
    chatHistory = [];
    
    // Clear messages
    const chatMessages = document.getElementById('chatMessages');
    chatMessages.innerHTML = `
        <div class="welcome-screen" id="welcomeScreen">
            <div class="welcome-icon">
                <i class="fas fa-robot"></i>
            </div>
            <h2>Welcome to AI Support Agent</h2>
            <p>Your intelligent ISP support assistant</p>
            
            <div class="quick-actions">
                <h3>Quick Actions</h3>
                <div class="action-cards">
                    <div class="action-card" onclick="sendQuickMessage('Check my internet connection')">
                        <i class="fas fa-wifi"></i>
                        <span>Check Connection</span>
                    </div>
                    <div class="action-card" onclick="sendQuickMessage('What is my account balance?')">
                        <i class="fas fa-wallet"></i>
                        <span>Account Balance</span>
                    </div>
                    <div class="action-card" onclick="sendQuickMessage('I need technical support')">
                        <i class="fas fa-headset"></i>
                        <span>Technical Support</span>
                    </div>
                    <div class="action-card" onclick="sendQuickMessage('Create a support ticket')">
                        <i class="fas fa-ticket-alt"></i>
                        <span>Open Ticket</span>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Update UI
    loadChatHistory();
    document.getElementById('messageInput').focus();
}

function loadChat(chatId) {
    const chat = allChats.find(c => c.id === chatId);
    if (!chat) return;
    
    // Save current chat first
    if (currentChatId && chatHistory.length > 0) {
        saveCurrentChat();
    }
    
    currentChatId = chatId;
    chatHistory = chat.history || [];
    
    // Clear and rebuild messages
    const chatMessages = document.getElementById('chatMessages');
    chatMessages.innerHTML = '';
    
    // Add messages to UI
    chat.messages.forEach(msg => {
        addMessageToUI(msg.sender, msg.text);
    });
    
    // Update active state
    loadChatHistory();
}

function saveCurrentChat() {
    if (!currentChatId) return;
    
    const existingIndex = allChats.findIndex(c => c.id === currentChatId);
    
    const chatData = {
        id: currentChatId,
        title: chatHistory[0] ? chatHistory[0].substring(0, 50) : 'New Chat',
        preview: chatHistory[chatHistory.length - 1] ? chatHistory[chatHistory.length - 1].substring(0, 60) : '',
        timestamp: Date.now(),
        history: chatHistory,
        messages: extractMessages()
    };
    
    if (existingIndex >= 0) {
        allChats[existingIndex] = chatData;
    } else {
        allChats.unshift(chatData);
    }
    
    localStorage.setItem('allChats', JSON.stringify(allChats));
}

function updateCurrentChat(userMsg, botMsg) {
    saveCurrentChat();
    loadChatHistory();
}

function extractMessages() {
    const messages = [];
    const chatMessages = document.querySelectorAll('.message');
    
    chatMessages.forEach(msg => {
        const sender = msg.classList.contains('user') ? 'user' : 'bot';
        const text = msg.querySelector('.message-bubble').textContent;
        messages.push({ sender, text });
    });
    
    return messages;
}

function loadChatHistory() {
    const historyContainer = document.getElementById('chatHistory');
    historyContainer.innerHTML = '';
    
    if (allChats.length === 0) {
        historyContainer.innerHTML = '<div style="padding: 16px; text-align: center; color: var(--text-muted); font-size: 14px;">No chat history yet</div>';
        return;
    }
    
    allChats.forEach(chat => {
        const item = document.createElement('div');
        item.className = `chat-history-item ${chat.id === currentChatId ? 'active' : ''}`;
        item.onclick = () => loadChat(chat.id);
        
        item.innerHTML = `
            <i class="fas fa-comment"></i>
            <div class="chat-info">
                <div class="chat-title-small">${chat.title}</div>
                <div class="chat-preview">${chat.preview}</div>
            </div>
            <div class="chat-time">${formatTimestamp(chat.timestamp)}</div>
        `;
        
        historyContainer.appendChild(item);
    });
}

function deleteChat(chatId) {
    allChats = allChats.filter(c => c.id !== chatId);
    localStorage.setItem('allChats', JSON.stringify(allChats));
    
    if (currentChatId === chatId) {
        createNewChat();
    } else {
        loadChatHistory();
    }
}

// ==================== UTILITY FUNCTIONS ====================
function getCurrentTime() {
    const now = new Date();
    return now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
}

function formatTimestamp(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    
    if (diff < 60000) return 'Just now';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;
    if (diff < 604800000) return `${Math.floor(diff / 86400000)}d ago`;
    
    return date.toLocaleDateString();
}

function getUserPhone() {
    return document.getElementById('userPhone')?.value || '';
}

// ==================== UI CONTROLS ====================
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('collapsed');
}

function toggleSettings() {
    const modal = document.getElementById('settingsModal');
    modal.style.display = modal.style.display === 'none' ? 'flex' : 'none';
}

function changeTheme(theme) {
    if (theme === 'light') {
        document.body.classList.add('light-theme');
    } else {
        document.body.classList.remove('light-theme');
    }
    localStorage.setItem('theme', theme);
}

function loadSettings() {
    const theme = localStorage.getItem('theme') || 'dark';
    const savedEndpoint = localStorage.getItem('apiEndpoint');
    const savedPhone = localStorage.getItem('userPhone');
    
    if (theme === 'light') {
        document.body.classList.add('light-theme');
    }
    
    if (savedEndpoint) {
        apiEndpoint = savedEndpoint;
        document.getElementById('apiEndpoint').value = savedEndpoint;
    }
    
    if (savedPhone) {
        document.getElementById('userPhone').value = savedPhone;
    }
    
    // Save settings on change
    document.getElementById('apiEndpoint')?.addEventListener('change', function(e) {
        apiEndpoint = e.target.value;
        localStorage.setItem('apiEndpoint', apiEndpoint);
    });
    
    document.getElementById('userPhone')?.addEventListener('change', function(e) {
        localStorage.setItem('userPhone', e.target.value);
    });
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('settingsModal');
    if (event.target === modal) {
        modal.style.display = 'none';
    }
}
