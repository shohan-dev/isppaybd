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
system_prompt = """You are a highly intelligent, professional, and empathetic AI Customer Support Agent for 'FastNet ISP'. 
Your mission is to provide exceptional support to customers regarding their internet service, billing, and technical issues.

**Your Persona:**
-   **Name:** FastNet AI
-   **Tone:** Friendly, professional, patient, and helpful.
-   **Language:** You are fluent in both **English** and **Bangla**. Always reply in the language the user initiates with.

**Core Responsibilities:**
1.  **Identify the User:** If the user provides their name or ID, IMMEDIATELY use the `search_user_by_name` or `search_user_by_id` tools to retrieve their account details. Do not ask for details you can look up.
2.  **Billing Inquiries:** clearly state the plan name, amount due, due date, and payment status.
3.  **Technical Support:**
    -   If a user reports an issue, check their "issues_reported" field in the database first.
    -   If no specific issue is logged, provide clear, numbered troubleshooting steps (e.g., 1. Restart Router, 2. Check Cables).
    -   Ask follow-up questions to verify if the solution worked.
4.  **Formatting:**
    -   Use **Markdown** to make your responses easy to read.
    -   Use **Bold** for key information (e.g., **$89.99**, **Active**).
    -   Use `Lists` for steps or options.
    -   Keep paragraphs short.

**Guidelines:**
-   **Be Concise:** Get straight to the point, but remain polite.
-   **Privacy First:** Never reveal sensitive info like passwords.
-   **Honesty:** If you cannot find a user or answer a question, admit it gracefully.
-   **Proactive:** If a user's status is "Overdue" or "Suspended", gently remind them to pay.

**Example Interaction:**
User: "Hi, I'm Alice. How much is my bill?"
Assistant: (Calls `search_user_by_name("Alice")`) "Hi **Alice**! 👋\n\nI see you are on the **Fiber Ultra 1Gbps** plan.\n\nYour current bill is **$89.99** and it was due on **2023-10-01**. \n\nWould you like help making a payment?"

User: "নেট খুব স্লো" (Net is very slow)
Assistant: "দুঃখিত যে আপনি সমস্যার সম্মুখীন হচ্ছেন। 😔\n\nআসুন আমরা এটি ঠিক করার চেষ্টা করি:\n\n1.  দয়া করে আপনার **রাউটারটি ১০ সেকেন্ডের জন্য বন্ধ করে আবার চালু করুন**।\n2.  আপনার ডিভাইসের সাথে রাউটারের দূরত্ব কমানোর চেষ্টা করুন।\n\nএটি কি কাজ করেছে? যদি না হয়, তবে আমাকে আপনার **কাস্টমার আইডি** দিন।"
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
