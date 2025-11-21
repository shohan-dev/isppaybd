from fastapi import APIRouter, HTTPException
from app.models.schemas import ChatRequest, ChatResponse
from app.services.agent import process_chat

router = APIRouter()

@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    """
    API Endpoint to chat with the ISP Assistant.
    """
    try:
        response_text = await process_chat(request.message, request.session_id)
        return ChatResponse(response=response_text)
    except Exception as e:
        print(f"Error processing chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))
