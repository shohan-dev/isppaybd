"""
Improved AI Agent for ISP Customer Support
Production-Optimized, Faster, Cleaner, Safer
"""

from typing import Optional, Dict, Any, List
from .gemini_adapter import GeminiChatAdapter
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from langchain_core.tools import BaseTool
import re
import json

from .prompts import SYSTEM_PROMPT
from ..tools.user_tools import GetUserAccountTool
from ..tools.network_tools import ConnectionStatusTool
from ..tools.ticket_tools import OpenTicketTool
from ..core.config import settings


# ---------------------------------------------------------
# 1) Improved ISP Query Classifier (Fast + Accurate)
# ---------------------------------------------------------
ISP_PATTERN = re.compile(
    r"(internet|connection|wifi|wi-fi|network|router|modem|slow|speed|down|"
    r"outage|bill|billing|payment|account|plan|package|upgrade|support|ticket|"
    r"issue|problem|broadband|fiber|data|bandwidth|latency|ping|mbps|disconnect|"
    r"offline|online|setup|install|restart|lag|buffer|drop|losing)"
)

BENGALI_ISP_PATTERN = re.compile(
    r"(net|speed|slow|kosto|kaj|kore|na|bondho|bill|connection|chole|na)"
)


def is_isp_related_query(message: str) -> bool:
    text = message.lower()

    # English detection
    if ISP_PATTERN.search(text):
        return True

    # Bengali detection
    if BENGALI_ISP_PATTERN.search(text):
        return True

    # Short tech questions
    if len(text.split()) <= 4 and any(
        w in text for w in ["why", "how", "what", "help", "support"]
    ):
        return True

    return False


# ---------------------------------------------------------
# 2) Main Support Agent
# ---------------------------------------------------------
class SupportAgent:
    def __init__(self, api_key: Optional[str] = None):
        """
        ISP AI Support Agent with tools + off-topic handling.
        """
        # Use Gemini adapter (google-generativeai) instead of ChatOpenAI
        self.model = GeminiChatAdapter(
            model=settings.MODEL_NAME,
            temperature=settings.TEMPERATURE,
            api_key=api_key or settings.GEMINI_API_KEY,
            max_tokens=settings.MAX_TOKENS,
        ).bind_tools([
            GetUserAccountTool,
            ConnectionStatusTool,
            OpenTicketTool,
        ])

        self.tools_map = {
            "GetUserAccountTool": GetUserAccountTool,
            "ConnectionStatusTool": ConnectionStatusTool,
            "OpenTicketTool": OpenTicketTool,
        }

        # Clean Off Topic Message
        self.off_topic_response = (
            "Hey there! 😊\n\n"
            "I'm your ISP support assistant. I can help you with:\n"
            "• Slow or not working internet\n"
            "• Checking connection status\n"
            "• Billing, plan, and payment info\n"
            "• Router or WiFi problems\n"
            "• Opening support tickets\n\n"
            "Tell me what's happening, and I'll take care of it! 💪"
        )
    
    def _execute_tool(self, tool_name: str, tool_input: Dict[str, Any]) -> str:
        """Execute a tool and return its result."""
        try:
            tool = self.tools_map.get(tool_name)
            if not tool:
                return f"Tool {tool_name} not found"
            return tool._run(**tool_input)
        except Exception as e:
            return f"Error executing {tool_name}: {str(e)}"
    
    async def _aexecute_tool(self, tool_name: str, tool_input: Dict[str, Any]) -> str:
        """Execute a tool asynchronously and return its result."""
        try:
            tool = self.tools_map.get(tool_name)
            if not tool:
                return f"Tool {tool_name} not found"
            return await tool._arun(**tool_input)
        except Exception as e:
            return f"Error executing {tool_name}: {str(e)}"

    # ---------------------------------------------------------
    # Sync Run
    # ---------------------------------------------------------
    def run(self, message: str, account_id: Optional[str] = None) -> str:
        try:
            # Off-topic check
            if not is_isp_related_query(message):
                return self.off_topic_response

            # Add context
            if account_id:
                message = f"[User Account ID: {account_id}]\n{message}"

            # Create messages
            messages = [
                SystemMessage(content=SYSTEM_PROMPT),
                HumanMessage(content=message)
            ]
            
            # Run model with tools
            max_iterations = settings.MAX_ITERATIONS
            for iteration in range(max_iterations):
                response = self.model.invoke(messages)
                
                # Check if model wants to use tools
                if hasattr(response, 'tool_calls') and response.tool_calls:
                    # Execute tools
                    for tool_call in response.tool_calls:
                        tool_name = tool_call.get('name', '')
                        tool_input = tool_call.get('args', {})
                        tool_result = self._execute_tool(tool_name, tool_input)
                        
                        # Add tool result to messages
                        assistant_text = getattr(response, 'content', '') or f"Using {tool_name}"
                        if assistant_text:
                            messages.append(AIMessage(content=assistant_text))
                        messages.append(HumanMessage(content=f"The {tool_name} returned: {tool_result}. Based on this information, provide a helpful response to the user."))
                else:
                    # No more tools to call, return final response
                    return response.content if response.content else "I'm here to help! What can I do for you?"
            
            # Max iterations reached
            return self.off_topic_response

        except Exception as e:
            err = str(e).lower()
            print(f"[AGENT ERROR] {type(e).__name__}: {e}")

            # Iteration limit → treat as off-topic
            if "iteration" in err or "limit" in err:
                return self.off_topic_response

            # Other errors
            return (
                "Oops! Something went wrong. 😅\n\n"
                "Can you tell me what issue you are facing with your internet?\n"
                "• Slow/No connection?\n"
                "• Billing or account issues?\n"
                "• Router or WiFi problem?\n\n"
                "I'll fix it for you! 💡"
            )

    # ---------------------------------------------------------
    # Async Run
    # ---------------------------------------------------------
    async def arun(self, message: str, account_id: Optional[str] = None) -> str:
        try:
            if not is_isp_related_query(message):
                return self.off_topic_response

            if account_id:
                message = f"[User Account ID: {account_id}]\n{message}"

            # Create messages
            messages = [
                SystemMessage(content=SYSTEM_PROMPT),
                HumanMessage(content=message)
            ]
            
            # Run model with tools
            max_iterations = settings.MAX_ITERATIONS
            for iteration in range(max_iterations):
                response = await self.model.ainvoke(messages)
                
                # Check if model wants to use tools
                if hasattr(response, 'tool_calls') and response.tool_calls:
                    # Execute tools
                    for tool_call in response.tool_calls:
                        tool_name = tool_call.get('name', '')
                        tool_input = tool_call.get('args', {})
                        tool_result = await self._aexecute_tool(tool_name, tool_input)
                        
                        # Add tool result to messages
                        assistant_text = getattr(response, 'content', '') or f"Using {tool_name}"
                        if assistant_text:
                            messages.append(AIMessage(content=assistant_text))
                        messages.append(HumanMessage(content=f"The {tool_name} returned: {tool_result}. Based on this information, provide a helpful response to the user."))
                else:
                    # No more tools to call, return final response
                    return response.content if response.content else "I'm here to help! What can I do for you?"
            
            # Max iterations reached
            return self.off_topic_response

        except Exception as e:
            err = str(e).lower()
            print(f"[AGENT ERROR ASYNC] {type(e).__name__}: {e}")

            if "iteration" in err or "limit" in err:
                return self.off_topic_response

            return (
                "Hmm, I didn't catch that. 🤔\n"
                "Tell me what's happening with your internet and I'll help you!"
            )
