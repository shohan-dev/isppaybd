import os
import json
from typing import List, Dict
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage
from app.core.config import settings
from app.services.tools import isp_tools

# --- History Management ---
class HistoryManager:
    def __init__(self, file_path: str):
        self.file_path = file_path
        self._ensure_file()

    def _ensure_file(self):
        if not os.path.exists(self.file_path):
            os.makedirs(os.path.dirname(self.file_path), exist_ok=True)
            with open(self.file_path, "w") as f:
                json.dump({}, f)

    def load_history(self, session_id: str) -> List[Dict]:
        try:
            with open(self.file_path, "r") as f:
                data = json.load(f)
                return data.get(session_id, [])
        except Exception:
            return []

    def save_history(self, session_id: str, history: List[Dict]):
        try:
            with open(self.file_path, "r") as f:
                data = json.load(f)
            
            data[session_id] = history
            
            with open(self.file_path, "w") as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            print(f"Error saving history: {e}")

history_manager = HistoryManager(settings.HISTORY_FILE)

# --- Agent Setup ---

llm = ChatGoogleGenerativeAI(
    model=settings.MODEL_NAME,
    google_api_key=settings.GEMINI_API_KEY,
    temperature=0.3, # Lower temperature for more factual responses
    convert_system_message_to_human=True
)

# Improved System Prompt
system_prompt = """You are a highly intelligent, professional, and friendly AI Assistant for 'FastNet ISP'. 
Your primary goal is to assist customers with internet service inquiries, billing details, and technical troubleshooting.

**Core Responsibilities:**
1.  **User Lookup:** Always try to identify the user if they provide a name or ID. Use the available tools (`search_user_by_name`, `search_user_by_id`) to fetch their real-time data.
2.  **Billing & Plans:** Explain their current plan, bill amount, and status clearly.
3.  **Troubleshooting:** Provide general troubleshooting steps for speed or connection issues if no specific user issue is found in the database.
4.  **Tone & Language:** 
    - You MUST support both **English** and **Bangla**. Detect the user's language and respond in the same language.
    - Maintain a **natural, human-friendly tone**. Avoid robotic phrasing.
    - Keep answers **concise and short** unless a detailed explanation is requested.
5.  **Privacy:** Never reveal sensitive personal information (like passwords or credit card numbers) even if asked.
6.  **Unknowns:** If you don't know the answer or can't find the user, admit it politely. Do not hallucinate data.

**Tools:**
You have access to tools to look up user information. USE THEM. Do not guess user details.

**Example Interaction:**
User: "Hi, I'm Alice. How much is my bill?"
Assistant: (Calls `search_user_by_name("Alice")`) "Hi Alice! Your current bill is $89.99 for the Fiber Ultra plan. It is due on 2023-10-01."

User: "আমার ইন্টারনেট খুব ধীর।" (My internet is very slow.)
Assistant: "দুঃখিত যে আপনি সমস্যার সম্মুখীন হচ্ছেন। আপনি কি আপনার রাউটারটি রিস্টার্ট করার চেষ্টা করেছেন? যদি সমস্যাটি থেকে যায়, তবে আমাকে আপনার কাস্টমার আইডি দিন, আমি চেক করে দেখব।"
"""

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ]
)

agent = create_tool_calling_agent(llm, isp_tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=isp_tools, verbose=True)

async def process_chat(message: str, session_id: str = "default") -> str:
    # 1. Load History
    raw_history = history_manager.load_history(session_id)
    chat_history = []
    for turn in raw_history:
        if turn["role"] == "user":
            chat_history.append(HumanMessage(content=turn["content"]))
        elif turn["role"] == "assistant":
            chat_history.append(AIMessage(content=turn["content"]))

    # 2. Invoke Agent
    response = await agent_executor.ainvoke({
        "input": message,
        "chat_history": chat_history
    })
    
    ai_message = response["output"]

    # 3. Update & Save History
    # We append the new interaction
    raw_history.append({"role": "user", "content": message})
    raw_history.append({"role": "assistant", "content": ai_message})
    
    # Limit history to last 20 turns to keep context manageable (optional, but good practice)
    if len(raw_history) > 20:
        raw_history = raw_history[-20:]

    history_manager.save_history(session_id, raw_history)

    return ai_message
