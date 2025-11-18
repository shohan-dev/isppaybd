"""
FastAPI Application
Main entry point for the AI Support Agent API.
"""

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
from typing import List, Optional
import uvicorn
import os
import re

from app.agent.agent import SupportAgent
from app.core.compression import ContextCompressor
from app.core.config import settings, validate_settings
from app.database import get_user_account, normalize_phone


# ==================== UTILITY FUNCTIONS ====================

def sanitize_agent_response(text: str) -> str:
    """
    Clean and sanitize AI response for better UX.
    Removes internal reasoning, robotic phrases, and formats nicely.
    """
    # Ensure text is a string
    if not isinstance(text, str):
        try:
            text = str(text)
        except Exception:
            text = ''

    # Remove chain-of-thought markers
    text = re.sub(r'(Thought|Observation|Action|Action Input|Final Answer):.*?\n', '', text, flags=re.IGNORECASE | re.MULTILINE)

    # Remove internal reasoning patterns (brackets / inline JSON)
    text = re.sub(r'\[.*?\]', '', text)
    # Remove JSON-like objects on their own line
    text = re.sub(r'(?m)^\s*\{.*\}\s*$', '', text)
    # Remove inline curly-brace blobs conservatively
    text = re.sub(r'\{[^\}]{1,2000}\}', '', text)
    
    # Remove robotic/AI phrases
    robotic_patterns = [
        r"(?i)as an ai.*?[.!?]",
        r"(?i)i am an ai.*?[.!?]",
        r"(?i)i have used the tool.*?[.!?]",
        r"(?i)let me use the tool.*?[.!?]",
        r"(?i)i will now.*?[.!?]",
        r"(?i)according to my (data|information|records).*?[.!?]",
        r"(?i)my programming.*?[.!?]",
    ]
    for pattern in robotic_patterns:
        text = re.sub(pattern, '', text)
    
    # Clean up formatting
    text = re.sub(r'\n{3,}', '\n\n', text)  # Max 2 line breaks
    text = re.sub(r' {2,}', ' ', text)       # Remove multiple spaces
    text = re.sub(r'^\s+|\s+$', '', text)    # Trim whitespace
    
    # Remove empty bullet points
    text = re.sub(r'^\s*[-*]\s*$', '', text, flags=re.MULTILINE)

    # Remove explicit tool-result lines (e.g., "Tool X result: {...}")
    text = re.sub(r'(?im)^\s*Tool\b.*$', '', text)

    # If the model returns a 'Final Answer:' block, try to extract it
    try:
        low = text.lower()
        if 'final answer:' in low:
            idx = low.rfind('final answer:')
            text = text[idx + len('final answer:'):].strip()
    except Exception:
        pass
    
    return text.strip()


# ==================== PYDANTIC MODELS ====================

class ChatRequest(BaseModel):
    """Request model for chat endpoint."""
    message: str = Field(..., min_length=1, description="User's message")
    history: List[str] = Field(default=[], description="Previous conversation messages")
    phone_number: Optional[str] = Field(None, description="User's phone number to lookup account_id")

    class Config:
        json_schema_extra = {
            "example": {
                "message": "My internet is not working",
                "history": [
                    "User: Hello",
                    "Agent: Hi! How can I help you today?"
                ],
                "phone_number": "01712345678"
            }
        }


class ChatResponse(BaseModel):
    """Response model for chat endpoint."""
    reply: str = Field(..., description="Agent's response")
    compressed_context: Optional[str] = Field(None, description="Compressed conversation context")
    
    class Config:
        json_schema_extra = {
            "example": {
                "reply": "I'll check your connection status. Please provide your phone number.",
                "compressed_context": "User reported internet connectivity issue."
            }
        }


class HealthResponse(BaseModel):
    """Response model for health check."""
    status: str
    version: str
    model: str


# ==================== FASTAPI APP INITIALIZATION ====================

# Validate configuration on startup
try:
    validate_settings()
except ValueError as e:
    print(f"⚠️  Configuration Error: {e}")
    print("Please check your .env file or environment variables.")

# Initialize FastAPI app
app = FastAPI(
    title=settings.API_TITLE,
    description=settings.API_DESCRIPTION,
    version=settings.API_VERSION,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files
static_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "static")
if os.path.exists(static_path):
    app.mount("/static", StaticFiles(directory=static_path), name="static")

# Initialize AI Agent and Context Compressor
agent = SupportAgent()
compressor = ContextCompressor()


# ==================== API ENDPOINTS ====================

@app.get("/")
async def root():
    """
    Serve the chatbot UI.
    """
    static_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "static", "index.html")
    if os.path.exists(static_path):
        return FileResponse(static_path)
    return HealthResponse(
        status="healthy",
        version=settings.API_VERSION,
        model=settings.MODEL_NAME
    )


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint for monitoring.
    """
    return HealthResponse(
        status="healthy",
        version=settings.API_VERSION,
        model=settings.MODEL_NAME
    )


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Main chat endpoint for AI agent interaction.
    
    Process:
    1. Receive user message and conversation history
    2. Compress history if needed
    3. Send to AI agent
    4. Return agent's response
    
    Args:
        request: ChatRequest containing message and history
        
    Returns:
        ChatResponse with agent's reply
    """
    try:
        # Step 0: Lookup account_id from phone number
        account_id = None
        if request.phone_number:
            try:
                normalized_phone = normalize_phone(request.phone_number)
                user_account = get_user_account(normalized_phone)
                if user_account:
                    account_id = user_account.get("account_id")
                    if settings.VERBOSE_MODE:
                        print(f"[Account Lookup] Phone: {normalized_phone} → Account: {account_id}")
            except Exception as e:
                if settings.VERBOSE_MODE:
                    print(f"[Account Lookup Failed] {e}")
        
        # Step 1: Smart compression of conversation history
        if request.history and len(request.history) >= settings.COMPRESSION_THRESHOLD:
            compressed = compressor.smart_compress(request.history, request.message)
            final_input = compressed
        elif request.history:
            # Keep recent history without compression
            recent_context = "\n".join(request.history[-3:])  # Last 3 messages
            final_input = f"{recent_context}\n\nUser: {request.message}"
        else:
            # First message - no history
            final_input = request.message
        
        # Step 2: Run agent with processed input and account_id
        agent_response = await agent.arun(final_input, account_id=account_id)
        
        # Step 2.5: Sanitize the response
        clean_response = sanitize_agent_response(agent_response)

        # Styled console output with timestamp, colored labels, and truncated/one-line message/response
        ts = __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        phone_display = request.phone_number or "anonymous"
        acc_display = account_id or "N/A"
        _clean = lambda s: " ".join(str(s).split())  # collapse whitespace/newlines
        _truncate = lambda s, n=300: s if len(s) <= n else s[: n - 1] + "…"
        msg = _truncate(_clean(request.message))
        resp = _truncate(_clean(clean_response))
        CYAN = "\033[1;36m"; YELLOW = "\033[1;33m"; GREEN = "\033[1;32m"; MAGENTA = "\033[1;35m"; BLUE = "\033[1;34m"; RESET = "\033[0m"
        print(f"{CYAN}[{ts}]{RESET} {YELLOW}Phone:{phone_display}{RESET} {BLUE}Account:{acc_display}{RESET} {GREEN}Msg:{RESET} {msg} {MAGENTA}→{RESET} {resp}")
        
        # Step 3: Return response
        return ChatResponse(
            reply=clean_response,
            compressed_context=compressed if request.history and len(request.history) >= settings.COMPRESSION_THRESHOLD else None
        )
        
    except Exception as e:
        # Log error (in production, use proper logging)
        print(f"Error in chat endpoint: {e}")
        
        # Return user-friendly error
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="I apologize, but I'm having trouble processing your request. Please try again."
        )


@app.post("/chat/sync", response_model=ChatResponse)
def chat_sync(request: ChatRequest):
    """
    Synchronous version of chat endpoint.
    Use this for compatibility with systems that don't support async.
    """
    try:
        # Lookup account_id from phone number
        account_id = None
        if request.phone_number:
            try:
                normalized_phone = normalize_phone(request.phone_number)
                user_account = get_user_account(normalized_phone)
                if user_account:
                    account_id = user_account.get("account_id")
            except Exception as e:
                if settings.VERBOSE_MODE:
                    print(f"[Account Lookup Failed] {e}")
        
        # Process history
        if request.history and len(request.history) >= settings.COMPRESSION_THRESHOLD:
            compressed = compressor.smart_compress(request.history, request.message)
            final_input = compressed
        elif request.history:
            recent_context = "\n".join(request.history[-3:])
            final_input = f"{recent_context}\n\nUser: {request.message}"
        else:
            final_input = request.message
        
        # Run agent (synchronous)
        agent_response = agent.run(final_input, account_id=account_id)
        
        # Sanitize response
        clean_response = sanitize_agent_response(agent_response)
        
        return ChatResponse(
            reply=clean_response,
            compressed_context=compressed if request.history and len(request.history) >= settings.COMPRESSION_THRESHOLD else None
        )
        
    except Exception as e:
        print(f"Error in sync chat endpoint: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="I apologize, but I'm having trouble processing your request. Please try again."
        )


# ==================== STARTUP & SHUTDOWN EVENTS ====================

@app.on_event("startup")
async def startup_event():
    """
    Run on application startup.
    """
    # Attempt to configure Google Generative AI if GEMINI_API_KEY or ADC present
    try:
        if getattr(settings, "GEMINI_API_KEY", "") or os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
            try:
                import google.generativeai as genai  # type: ignore
                if getattr(settings, "GEMINI_API_KEY", ""):
                    try:
                        genai.configure(api_key=settings.GEMINI_API_KEY)
                    except Exception:
                        # ADC may be used instead of API key
                        pass
            except Exception:
                # Not critical if the package isn't installed in this environment
                pass

    except Exception:
        pass

    print("🚀 AI Support Agent API starting...")
    print(f"📊 Model: {settings.MODEL_NAME}")
    print(f"🔧 Environment: {'Development' if settings.VERBOSE_MODE else 'Production'}")
    print(f"✅ API ready at http://{settings.HOST}:{settings.PORT}")


@app.on_event("shutdown")
async def shutdown_event():
    """
    Run on application shutdown.
    """
    print("👋 AI Support Agent API shutting down...")


# ==================== MAIN ENTRY POINT ====================

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.VERBOSE_MODE,  # Auto-reload in dev mode
        log_level="info"
    )
