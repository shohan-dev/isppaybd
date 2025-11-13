# 🚀 AI Support Agent - Production-Grade ISP Chatbot

A complete, professional-grade AI Agent chatbot system built with **FastAPI** and **LangChain** for intelligent ISP customer support automation.

## ✨ Features

- 🤖 **Autonomous AI Agent** with Zero-Shot-React reasoning
- 🛠️ **Custom Tools Integration**:
  - User account lookup
  - Connection status checking
  - Support ticket creation
- 📦 **Context Compression** for efficient token usage
- ⚡ **FastAPI Backend** with async support
- 🔒 **Production-ready** architecture
- 📊 **Comprehensive logging** and error handling
- 🌐 **RESTful API** with OpenAPI documentation

## 📁 Project Structure

```
ai_chatbot/
│
├── app/
│   ├── main.py                 # FastAPI application entry point
│   ├── agent/
│   │   ├── __init__.py
│   │   ├── agent.py            # AI agent implementation
│   │   └── prompts.py          # System prompts and instructions
│   ├── tools/
│   │   ├── __init__.py
│   │   ├── user_tools.py       # User account management tools
│   │   ├── network_tools.py    # Network diagnostic tools
│   │   └── ticket_tools.py     # Support ticket tools
│   ├── core/
│   │   ├── config.py           # Configuration management
│   │   └── compression.py      # Context compression
│   └── database.py             # Database layer (mock)
│
├── requirements.txt            # Python dependencies
├── run.sh                      # Startup script
├── .env.example                # Environment variables template
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites

- Python 3.9+
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd "AI Chatbot"
   ```

2. **Create virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On macOS/Linux
   # or
   venv\Scripts\activate  # On Windows
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env and add your OPENAI_API_KEY
   ```

5. **Run the server**
   ```bash
   chmod +x run.sh
   ./run.sh
   # or
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

6. **Access the API**
   - API: http://localhost:8000
   - Interactive Docs: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

## 📡 API Usage

### Chat Endpoint

**POST** `/chat`

```json
{
  "message": "My internet is not working",
  "history": [
    "User: Hello",
    "Agent: Hi! How can I help you today?"
  ],
  "user_id": "+8801712345678"
}
```

**Response:**
```json
{
  "reply": "I'll check your connection status. Let me look that up for you...",
  "compressed_context": "User reported internet connectivity issue."
}
```

### Example with cURL

```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Check my internet connection for +8801712345678",
    "history": []
  }'
```

### Example with Python

```python
import requests

response = requests.post(
    "http://localhost:8000/chat",
    json={
        "message": "My internet is not working",
        "history": [],
        "user_id": "+8801712345678"
    }
)

print(response.json()["reply"])
```

## 🛠️ Configuration

Edit `.env` file to customize:

```env
# Model Configuration
OPENAI_API_KEY=your_key_here
MODEL_NAME=gpt-4o-mini
TEMPERATURE=0.0
MAX_TOKENS=1000

# Agent Configuration
MAX_ITERATIONS=5
VERBOSE_MODE=false

# Context Compression
COMPRESSION_THRESHOLD=5
COMPRESSION_MODEL=gpt-4o-mini

# Server Configuration
HOST=0.0.0.0
PORT=8000
```

## 🧰 Tools

### GetUserAccount
Fetch user account information using phone number.

### ConnectionStatus
Check internet connection status and diagnose issues.

### OpenTicket
Create support tickets for unresolved issues.

## 🔮 Future Enhancements

- [ ] Real database integration (PostgreSQL/MongoDB)
- [ ] Vector database for RAG (Retrieval-Augmented Generation)
- [ ] User authentication and session management
- [ ] Rate limiting and API keys
- [ ] Advanced analytics and monitoring
- [ ] Multi-language support
- [ ] WebSocket support for real-time chat
- [ ] Admin dashboard

## 📝 Development

### Running Tests
```bash
pytest tests/
```

### Code Quality
```bash
# Format code
black app/

# Lint
flake8 app/

# Type checking
mypy app/
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Authors

Built with ❤️ for Shohan Bro

## 🙏 Acknowledgments

- FastAPI for the amazing web framework
- LangChain for AI agent orchestration
- OpenAI for powerful language models

---

# run project command 
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

direct run 
# Windows
python -m uvicorn app.main:app --reload

# MAC
python3 -m uvicorn app.main:app --reload

**Happy Coding! 🚀**
