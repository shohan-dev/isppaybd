import os
import google.generativeai as genai
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
import database

# 1. Load Environment Variables
load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")
MODEL_NAME = os.getenv("MODEL_NAME", "gemini-pro")

if not API_KEY:
    raise ValueError("GEMINI_API_KEY not found in .env file")

# 2. Configure Gemini
genai.configure(api_key=API_KEY)
model = genai.GenerativeModel(MODEL_NAME)

# 3. Initialize FastAPI App
app = FastAPI(title="ISP AI Assistant API")

# Setup Templates
templates = Jinja2Templates(directory="templates")

# 4. Define Request Models
class ChatRequest(BaseModel):
    message: str

# 5. System Prompt / Context
# We inject the database content into the system context so the AI knows about the users.
# In a real production app with millions of users, you would use RAG (Retrieval Augmented Generation)
# to fetch only relevant records. For 10 users, dumping them in context is fine.

ISP_CONTEXT = f"""
You are a helpful and professional AI Assistant for 'FastNet ISP'.
Your goal is to assist customers with their internet service questions, billing, and technical issues.

Here is the current database of users and their details:
{database.get_all_users()}

INSTRUCTIONS:
1. If the user asks about a specific person, look up their details in the data provided above.
2. If the user asks general questions (e.g., "Why is my internet slow?"), provide general troubleshooting steps.
3. Be polite, concise, and professional.
4. If you don't know the answer, say so. Do not make up information not in the database.
5. If a user asks for sensitive info (like credit card numbers), politely decline.
"""

chat_history = []

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    """Serves the chat interface."""
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/chat")
async def chat_endpoint(request: ChatRequest):
    """
    API Endpoint to chat with the ISP Assistant.
    """
    user_message = request.message
    
    try:
        # Construct the prompt with history and context
        # We keep a simple history for this session
        
        prompt_parts = [ISP_CONTEXT]
        
        # Add recent history (last 5 turns) to maintain conversation context
        for turn in chat_history[-5:]:
            prompt_parts.append(f"User: {turn['user']}")
            prompt_parts.append(f"Assistant: {turn['assistant']}")
            
        prompt_parts.append(f"User: {user_message}")
        prompt_parts.append("Assistant:")
        
        full_prompt = "\n".join(prompt_parts)

        # Generate response
        response = model.generate_content(full_prompt)
        ai_response = response.text
        
        # Update history
        chat_history.append({"user": user_message, "assistant": ai_response})
        
        return {"response": ai_response}

    except Exception as e:
        print(f"Error generating response: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
