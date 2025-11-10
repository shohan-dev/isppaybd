"""
AI Agent Implementation
Handles the core agent logic using LangChain with integrated tools.
"""

from typing import Optional
from langchain.agents import initialize_agent, AgentType
from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory

from .prompts import SYSTEM_PROMPT
from ..tools.user_tools import GetUserAccountTool
from ..tools.network_tools import ConnectionStatusTool
from ..tools.ticket_tools import OpenTicketTool
from ..core.config import settings


class SupportAgent:
    """
    Production-grade AI Support Agent with tool integration.
    
    Features:
    - Zero-Shot-React reasoning
    - Multi-tool support
    - Context-aware responses
    - Error handling and fallbacks
    """

    def __init__(self, api_key: Optional[str] = None):
        """
        Initialize the Support Agent with LLM and tools.
        
        Args:
            api_key: OpenAI API key (optional, falls back to settings)
        """
        self.model = ChatOpenAI(
            model=settings.MODEL_NAME,
            temperature=settings.TEMPERATURE,
            api_key=api_key or settings.OPENAI_API_KEY,
            max_tokens=settings.MAX_TOKENS
        )

        # Initialize tools
        self.tools = [
            GetUserAccountTool,
            ConnectionStatusTool,
            OpenTicketTool
        ]

        # Initialize agent with Zero-Shot-React pattern
        self.agent = initialize_agent(
            tools=self.tools,
            llm=self.model,
            agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
            verbose=settings.VERBOSE_MODE,
            handle_parsing_errors=True,
            max_iterations=settings.MAX_ITERATIONS,
            agent_kwargs={
                "prefix": SYSTEM_PROMPT
            }
        )

    def run(self, message: str) -> str:
        """
        Execute the agent with a user message.
        
        Args:
            message: User input message
            
        Returns:
            Agent's response as a string
        """
        try:
            response = self.agent.run(message)
            return response
        except Exception as e:
            # Graceful error handling
            error_msg = f"I apologize, but I encountered an issue: {str(e)}"
            if settings.VERBOSE_MODE:
                print(f"Agent Error: {e}")
            return error_msg

    async def arun(self, message: str) -> str:
        """
        Async version of run method.
        
        Args:
            message: User input message
            
        Returns:
            Agent's response as a string
        """
        try:
            response = await self.agent.arun(message)
            return response
        except Exception as e:
            error_msg = f"I apologize, but I encountered an issue: {str(e)}"
            if settings.VERBOSE_MODE:
                print(f"Agent Error: {e}")
            return error_msg
