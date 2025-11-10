"""
FastAPI Application
Main entry point for the AI Support Agent API.
"""

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional
import uvicorn

from app.agent.agent import SupportAgent
from app.core.compression import ContextCompressor
from app.core.config import settings, validate_settings


# ==================== PYDANTIC MODELS ====================

class ChatRequest(BaseModel):
    """Request model for chat endpoint."""
    message: str = Field(..., min_length=1, description="User's message")
    history: List[str] = Field(default=[], description="Previous conversation messages")
    user_id: Optional[str] = Field(None, description="Optional user identifier for tracking")

    class Config:
        json_schema_extra = {
            "example": {
                "message": "My internet is not working",
                "history": [
                    "User: Hello",
                    "Agent: Hi! How can I help you today?"
                ],
                "user_id": "+8801712345678"
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

# Initialize AI Agent and Context Compressor
agent = SupportAgent()
compressor = ContextCompressor()


# ==================== API ENDPOINTS ====================

@app.get("/", response_model=HealthResponse)
async def root():
    """
    Root endpoint - API health check.
    """
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
        
        # Step 2: Run agent with processed input
        agent_response = await agent.arun(final_input)
        
        # Step 3: Return response
        return ChatResponse(
            reply=agent_response,
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
        agent_response = agent.run(final_input)
        
        return ChatResponse(
            reply=agent_response,
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
