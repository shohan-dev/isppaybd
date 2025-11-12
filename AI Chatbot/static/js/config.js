// ==================== CONFIGURATION ====================
const CONFIG = {
    // API Configuration
    API: {
        BASE_URL: window.location.origin,
        ENDPOINTS: {
            CHAT: '/chat',
            HEALTH: '/health',
            CHAT_SYNC: '/chat/sync'
        },
        TIMEOUT: 30000, // 30 seconds
        RETRY_ATTEMPTS: 3,
        RETRY_DELAY: 1000 // 1 second
    },
    
    // Chat Configuration
    CHAT: {
        MAX_HISTORY_LENGTH: 10,
        MAX_MESSAGE_LENGTH: 2000,
        TYPING_DELAY: 1000, // milliseconds
        AUTO_SCROLL: true,
        SAVE_TO_LOCAL_STORAGE: true
    },
    
    // UI Configuration
    UI: {
        THEME: {
            DEFAULT: 'dark',
            AVAILABLE: ['light', 'dark']
        },
        ANIMATION: {
            ENABLED: true,
            DURATION: 300 // milliseconds
        },
        SIDEBAR: {
            DEFAULT_COLLAPSED: false,
            MOBILE_BREAKPOINT: 768
        }
    },
    
    // Storage Keys
    STORAGE_KEYS: {
        ALL_CHATS: 'allChats',
        CURRENT_CHAT: 'currentChatId',
        THEME: 'theme',
        API_ENDPOINT: 'apiEndpoint',
        USER_PHONE: 'userPhone',
        USER_SETTINGS: 'userSettings'
    },
    
    // Quick Actions
    QUICK_ACTIONS: [
        {
            icon: 'fa-wifi',
            label: 'Check Connection',
            message: 'Check my internet connection status'
        },
        {
            icon: 'fa-wallet',
            label: 'Account Balance',
            message: 'What is my account balance?'
        },
        {
            icon: 'fa-headset',
            label: 'Technical Support',
            message: 'I need technical support for my internet connection'
        },
        {
            icon: 'fa-ticket-alt',
            label: 'Open Ticket',
            message: 'I want to create a support ticket'
        }
    ],
    
    // Messages
    MESSAGES: {
        ERRORS: {
            NETWORK: 'Network error. Please check your connection and try again.',
            SERVER: 'Server error. Please try again later.',
            TIMEOUT: 'Request timeout. Please try again.',
            GENERIC: 'An error occurred. Please try again.',
            EMPTY_MESSAGE: 'Please enter a message.',
            API_KEY_MISSING: 'API key not configured. Please check settings.'
        },
        SUCCESS: {
            CHAT_CREATED: 'New chat created successfully.',
            SETTINGS_SAVED: 'Settings saved successfully.'
        },
        INFO: {
            TYPING: 'Agent is typing...',
            CONNECTING: 'Connecting to server...',
            NO_HISTORY: 'No chat history yet'
        }
        ,
        OFFTOPIC: `Hey there! 😊

I'm your ISP support assistant. I can help you with:
• Slow or not working internet
• Checking connection status
• Billing, plan, and payment info
• Router or WiFi problems
• Opening support tickets

Tell me what's happening, and I'll take care of it! 💪`
    }
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
