"""
Improved AI Agent for ISP Customer Support
Production-Optimized, Faster, Cleaner, Safer
"""

from typing import Optional
from langchain.agents import initialize_agent, AgentType
from langchain_openai import ChatOpenAI
import re

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
        self.model = ChatOpenAI(
            model=settings.MODEL_NAME,
            temperature=settings.TEMPERATURE,
            api_key=api_key or settings.OPENAI_API_KEY,
            max_tokens=settings.MAX_TOKENS,
        )

        self.tools = [
            GetUserAccountTool,
            ConnectionStatusTool,
            OpenTicketTool,
        ]

        # LangChain Agent Initialization
        self.agent = initialize_agent(
            tools=self.tools,
            llm=self.model,
            agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
            verbose=settings.VERBOSE_MODE,
            handle_parsing_errors=True,
            max_iterations=settings.MAX_ITERATIONS,
            early_stopping_method="generate",
            agent_kwargs={"prefix": SYSTEM_PROMPT},
        )

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

            # Run agent
            return self.agent.run(message)

        except Exception as e:
            err = str(e).lower()

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
                "I’ll fix it for you! 💡"
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

            return await self.agent.arun(message)

        except Exception as e:
            err = str(e).lower()

            if "iteration" in err or "limit" in err:
                return self.off_topic_response

            return (
                "Hmm, I didn't catch that. 🤔\n"
                "Tell me what's happening with your internet and I'll help you!"
            )
