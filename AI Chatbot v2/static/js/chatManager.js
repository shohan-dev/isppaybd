// ==================== CHAT MANAGER ====================
class ChatManager {
    constructor(config) {
        this.config = config;
        this.currentChatId = null;
        this.chatHistory = [];
        this.allChats = [];
        this.loadFromStorage();
    }

    /**
     * Create a new chat
     */
    createNewChat() {
        // Save current chat if exists and has messages
        if (this.currentChatId && this.chatHistory.length > 0) {
            this.saveCurrentChat();
        }

        // Generate new chat ID
        this.currentChatId = Date.now().toString();
        this.chatHistory = [];

        // Save to storage
        this.saveToStorage();

        return this.currentChatId;
    }

    /**
     * Load a specific chat
     */
    loadChat(chatId) {
        const chat = this.allChats.find(c => c.id === chatId);
        if (!chat) return null;

        // Save current chat first if it has messages
        if (this.currentChatId && this.currentChatId !== chatId && this.chatHistory.length > 0) {
            this.saveCurrentChat();
        }

        this.currentChatId = chatId;
        this.chatHistory = chat.history || [];

        return chat;
    }

    /**
     * Save current chat
     */
    saveCurrentChat() {
        if (!this.currentChatId) return;

        // Don't save empty chats
        if (this.chatHistory.length === 0) return;

        const existingIndex = this.allChats.findIndex(c => c.id === this.currentChatId);

        const chatData = {
            id: this.currentChatId,
            title: this._generateTitle(),
            preview: this._generatePreview(),
            timestamp: Date.now(),
            history: this.chatHistory,
            messageCount: Math.floor(this.chatHistory.length / 2)
        };

        if (existingIndex >= 0) {
            this.allChats[existingIndex] = chatData;
        } else {
            this.allChats.unshift(chatData);
        }

        // Limit to last 50 chats
        if (this.allChats.length > 50) {
            this.allChats = this.allChats.slice(0, 50);
        }

        this.saveToStorage();
    }

    /**
     * Delete a chat
     */
    deleteChat(chatId) {
        this.allChats = this.allChats.filter(c => c.id !== chatId);
        
        if (this.currentChatId === chatId) {
            this.currentChatId = null;
            this.chatHistory = [];
        }

        this.saveToStorage();
    }

    /**
     * Add message to history
     */
    addToHistory(sender, message) {
        // Remove leading/trailing double quotes from message
        let cleanMsg = message;
        if (typeof cleanMsg === 'string') {
            cleanMsg = cleanMsg.replace(/^"+|"+$/g, '');
        }
        this.chatHistory.push(`${sender}: ${cleanMsg}`);
        
        // Auto-save after each message
        if (this.chatHistory.length % 2 === 0) { // After every bot response
            this.saveCurrentChat();
        }
    }

    /**
     * Get all chats
     */
    getAllChats() {
        return this.allChats;
    }

    /**
     * Get current chat history
     */
    getCurrentHistory() {
        return this.chatHistory;
    }

    /**
     * Generate chat title from first message
     */
    _generateTitle() {
        if (this.chatHistory.length === 0) return 'New Chat';
        
        const firstMessage = this.chatHistory[0];
        const message = firstMessage.replace(/^User:\s*/, '');
        
        // Clean up the title
        let title = message.substring(0, 40);
        
        // Remove extra formatting
        title = title.replace(/\*\*/g, '');
        title = title.replace(/\n/g, ' ');
        
        return title + (message.length > 40 ? '...' : '');
    }

    /**
     * Generate preview from last message
     */
    _generatePreview() {
        if (this.chatHistory.length === 0) return '';
        
        const lastMessage = this.chatHistory[this.chatHistory.length - 1];
        const message = lastMessage.replace(/^(User|Agent):\s*/, '');
        
        // Clean up the preview
        let preview = message.substring(0, 50);
        preview = preview.replace(/\*\*/g, '');
        preview = preview.replace(/\n/g, ' ');
        preview = preview.replace(/[✓✗⚠️]/g, '');
        
        return preview + (message.length > 50 ? '...' : '');
    }

    /**
     * Load chats from localStorage
     */
    loadFromStorage() {
        if (!this.config.CHAT.SAVE_TO_LOCAL_STORAGE) return;

        try {
            const stored = localStorage.getItem(this.config.STORAGE_KEYS.ALL_CHATS);
            if (stored) {
                this.allChats = JSON.parse(stored);
            }
        } catch (error) {
            console.error('Error loading from storage:', error);
        }
    }

    /**
     * Save chats to localStorage
     */
    saveToStorage() {
        if (!this.config.CHAT.SAVE_TO_LOCAL_STORAGE) return;

        try {
            localStorage.setItem(
                this.config.STORAGE_KEYS.ALL_CHATS,
                JSON.stringify(this.allChats)
            );
        } catch (error) {
            console.error('Error saving to storage:', error);
        }
    }

    /**
     * Clear all chats
     */
    clearAllChats() {
        this.allChats = [];
        this.currentChatId = null;
        this.chatHistory = [];
        this.saveToStorage();
    }
}
