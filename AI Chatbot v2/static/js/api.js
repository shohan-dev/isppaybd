// ==================== API SERVICE ====================
class APIService {
    constructor(config) {
        this.config = config;
        this.baseURL = config.API.BASE_URL;
        this.timeout = config.API.TIMEOUT;
        this.retryAttempts = config.API.RETRY_ATTEMPTS;
        this.retryDelay = config.API.RETRY_DELAY;
    }

    /**
     * Send a chat message to the API
     */
    async sendMessage(message, history = [], phoneNumber = null) {
        const endpoint = `${this.baseURL}${this.config.API.ENDPOINTS.CHAT}`;
        
        const payload = {
            message: message,
            history: history.slice(-this.config.CHAT.MAX_HISTORY_LENGTH),
            phone_number: phoneNumber
        };

        return await this._fetchWithRetry(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload)
        });
    }

    /**
     * Check API health status
     */
    async checkHealth() {
        const endpoint = `${this.baseURL}${this.config.API.ENDPOINTS.HEALTH}`;
        
        try {
            const response = await fetch(endpoint);
            return await response.json();
        } catch (error) {
            console.error('Health check failed:', error);
            return { status: 'error', error: error.message };
        }
    }

    /**
     * Fetch with retry logic
     */
    async _fetchWithRetry(url, options, attempt = 1) {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), this.timeout);

            const response = await fetch(url, {
                ...options,
                signal: controller.signal
            });

            clearTimeout(timeoutId);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            return await response.json();
        } catch (error) {
            if (attempt < this.retryAttempts) {
                console.log(`Retry attempt ${attempt} of ${this.retryAttempts}`);
                await this._delay(this.retryDelay * attempt);
                return this._fetchWithRetry(url, options, attempt + 1);
            }
            throw error;
        }
    }

    /**
     * Delay utility
     */
    _delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
