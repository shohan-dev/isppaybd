from pydantic import BaseModel

class ChatRequest(BaseModel):
    message: str
    session_id: str = "default"  # For history persistence

class ChatResponse(BaseModel):
    response: str
