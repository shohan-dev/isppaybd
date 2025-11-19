"""
Improved AI Agent for ISP Customer Support
Production-Optimized, Faster, Cleaner, Safer
"""

from typing import Optional, Dict, Any, List
from .gemini_adapter import GeminiChatAdapter
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage, ToolMessage
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
        # Shared tool registry
        self.tools: List[BaseTool] = [
            GetUserAccountTool,
            ConnectionStatusTool,
            OpenTicketTool,
        ]
        self.tools_map: Dict[str, BaseTool] = {tool.name: tool for tool in self.tools}

        gemini_key = api_key or settings.GEMINI_API_KEY or None
        base_model = GeminiChatAdapter(
            model=settings.MODEL_NAME,
            temperature=settings.TEMPERATURE,
            api_key=gemini_key,
            max_tokens=settings.MAX_TOKENS,
        )

        self.model = base_model.bind_tools(self.tools)

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

    def _build_messages(
        self,
        history: Optional[List[str]],
        message: str,
        account_id: Optional[str],
        summary: Optional[str],
    ) -> List[SystemMessage | HumanMessage | AIMessage | ToolMessage]:
        """Convert raw history strings into LangChain messages."""
        stack: List[Any] = [SystemMessage(content=SYSTEM_PROMPT)]

        if summary:
            stack.append(
                SystemMessage(
                    content=f"Conversation summary so far:\n{summary}"
                )
            )

        for entry in history or []:
            trimmed = (entry or "").strip()
            if not trimmed:
                continue
            lower = trimmed.lower()
            if lower.startswith("agent:"):
                stack.append(AIMessage(content=trimmed.split(":", 1)[1].strip()))
            elif lower.startswith("user:"):
                stack.append(HumanMessage(content=trimmed.split(":", 1)[1].strip()))
            else:
                stack.append(HumanMessage(content=trimmed))

        user_message = message
        if account_id:
            user_message = f"[User Account ID: {account_id}] {user_message}"
        stack.append(HumanMessage(content=user_message))
        return stack
    
    def _normalize_tool_calls(self, tool_calls: Any) -> List[Dict[str, Any]]:
        """Convert provider-specific tool calls into simple dictionaries."""
        normalized: List[Dict[str, Any]] = []
        if not tool_calls:
            return normalized

        for call in tool_calls:
            name = None
            call_id = None
            args: Any = {}

            if isinstance(call, dict):
                name = call.get("name") or call.get("function", {}).get("name")
                call_id = call.get("id") or call.get("function", {}).get("id")
                args = call.get("args") or call.get("function", {}).get("arguments", {})
            else:
                name = getattr(call, "name", None) or getattr(getattr(call, "function", None), "name", None)
                call_id = getattr(call, "id", None) or getattr(getattr(call, "function", None), "id", None)
                args = (
                    getattr(call, "args", None)
                    or getattr(call, "arguments", None)
                    or getattr(getattr(call, "function", None), "arguments", None)
                )

            if isinstance(args, str):
                try:
                    args = json.loads(args)
                except Exception:
                    args = {"input": args}
            elif hasattr(args, "items"):
                args = dict(args)

            if name:
                normalized.append({"name": name, "args": args or {}, "id": call_id or name})

        return normalized

    def _execute_tool(self, tool_name: str, tool_input: Optional[Dict[str, Any]]) -> str:
        """Execute a tool and return its result."""
        try:
            tool = self.tools_map.get(tool_name)
            if not tool:
                return f"Tool {tool_name} not found"
            payload: Any = tool_input if tool_input is not None else {}
            return str(tool.invoke(payload))
        except Exception as e:
            return f"Error executing {tool_name}: {str(e)}"
    
    async def _aexecute_tool(self, tool_name: str, tool_input: Optional[Dict[str, Any]]) -> str:
        """Execute a tool asynchronously and return its result."""
        try:
            tool = self.tools_map.get(tool_name)
            if not tool:
                return f"Tool {tool_name} not found"
            payload: Any = tool_input if tool_input is not None else {}
            return str(await tool.ainvoke(payload))
        except Exception as e:
            return f"Error executing {tool_name}: {str(e)}"

    # ---------------------------------------------------------
    # Sync Run
    # ---------------------------------------------------------
    def run(
        self,
        message: str,
        history: Optional[List[str]] = None,
        account_id: Optional[str] = None,
        summary: Optional[str] = None,
    ) -> str:
        try:
            # Off-topic check
            if not is_isp_related_query(message):
                return self.off_topic_response

            messages = self._build_messages(history, message, account_id, summary)
            
            max_iterations = settings.MAX_ITERATIONS
            for iteration in range(max_iterations):
                response = self.model.invoke(messages)

                if isinstance(response, AIMessage):
                    ai_response = response
                else:
                    ai_response = AIMessage(
                        content=getattr(response, "content", "") or "",
                        additional_kwargs={
                            "tool_calls": getattr(response, "tool_calls", [])
                        },
                    )

                normalized_calls = self._normalize_tool_calls(getattr(ai_response, "tool_calls", []))
                if normalized_calls:
                    messages.append(ai_response)
                    for tool_call in normalized_calls:
                        tool_name = tool_call.get("name", "")
                        tool_input = tool_call.get("args", {})
                        tool_result = self._execute_tool(tool_name, tool_input)
                        tool_call_id = tool_call.get("id") or tool_name
                        messages.append(
                            ToolMessage(
                                content=str(tool_result),
                                tool_call_id=tool_call_id,
                            )
                        )
                else:
                    # No more tools to call, return final response
                    return ai_response.content if ai_response.content else "I'm here to help! What can I do for you?"
            
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
    async def arun(
        self,
        message: str,
        history: Optional[List[str]] = None,
        account_id: Optional[str] = None,
        summary: Optional[str] = None,
    ) -> str:
        try:
            if not is_isp_related_query(message):
                return self.off_topic_response

            messages = self._build_messages(history, message, account_id, summary)
            
            max_iterations = settings.MAX_ITERATIONS
            for iteration in range(max_iterations):
                response = await self.model.ainvoke(messages)

                if isinstance(response, AIMessage):
                    ai_response = response
                else:
                    ai_response = AIMessage(
                        content=getattr(response, "content", "") or "",
                        additional_kwargs={
                            "tool_calls": getattr(response, "tool_calls", [])
                        },
                    )

                normalized_calls = self._normalize_tool_calls(getattr(ai_response, "tool_calls", []))
                if normalized_calls:
                    messages.append(ai_response)
                    for tool_call in normalized_calls:
                        tool_name = tool_call.get("name", "")
                        tool_input = tool_call.get("args", {})
                        tool_result = await self._aexecute_tool(tool_name, tool_input)
                        tool_call_id = tool_call.get("id") or tool_name
                        messages.append(
                            ToolMessage(
                                content=str(tool_result),
                                tool_call_id=tool_call_id,
                            )
                        )
                else:
                    # No more tools to call, return final response
                    return ai_response.content if ai_response.content else "I'm here to help! What can I do for you?"
            
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
