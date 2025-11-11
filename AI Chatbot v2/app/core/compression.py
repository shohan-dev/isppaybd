"""
Context Compression Module
Efficiently compresses conversation history to reduce token usage.
"""

from typing import List
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage

from .config import settings


class ContextCompressor:
    """
    Compress long chat history into concise summaries.
    
    Features:
    - Intelligent summarization
    - Preserves key information
    - Reduces token usage
    - Fast processing
    """

    def __init__(self, model_name: str = None):
        """
        Initialize the context compressor.
        
        Args:
            model_name: LLM model to use for compression (default: from settings)
        """
        self.model = ChatOpenAI(
            model=model_name or settings.COMPRESSION_MODEL,
            temperature=0,
            api_key=settings.OPENAI_API_KEY,
            max_tokens=200  # Keep compression output short
        )

    def compress(self, text: str) -> str:
        """
        Compress a single text block into a summary.
        
        Args:
            text: Text to compress
            
        Returns:
            Compressed summary (2-3 lines)
        """
        if not text or len(text) < 100:
            return text  # No need to compress short text
        
        prompt = f"""Compress the following conversation into 2-3 concise sentences. Focus ONLY on:
- The user's main problem or request
- Key account details (phone, status, etc.)
- Current state (resolved, pending, etc.)

Keep it factual and brief. No greetings or filler.

Context:
{text}

Compressed Summary:"""
        
        try:
            response = self.model([HumanMessage(content=prompt)])
            compressed = response.content.strip()
            
            # Remove any greeting or unnecessary phrases
            compressed = compressed.replace('The user', 'User')
            compressed = compressed.replace('The customer', 'User')
            
            return compressed
        except Exception as e:
            print(f"Compression error: {e}")
            return text  # Fallback to original if compression fails

    def compress_history(self, history: List[str]) -> str:
        """
        Compress a list of conversation messages.
        
        Args:
            history: List of conversation messages
            
        Returns:
            Single compressed summary string
        """
        if not history:
            return ""
        
        # If history is short, just join it
        if len(history) < settings.COMPRESSION_THRESHOLD:
            return "\n".join(history)
        
        # Combine all messages
        combined = "\n".join(history)
        
        # Compress the combined text
        return self.compress(combined)

    def smart_compress(self, history: List[str], current_message: str) -> str:
        """
        Intelligently compress history and combine with current message.
        
        Args:
            history: Previous conversation messages
            current_message: Current user message
            
        Returns:
            Optimized context string for agent input
        """
        if not history:
            return current_message
        
        # Always keep the last 2 messages uncompressed for context
        if len(history) <= 2:
            context = "\n".join(history)
            return f"{context}\n\nCurrent Message: {current_message}"
        
        # Compress older messages, keep recent ones
        older_messages = history[:-2]
        recent_messages = history[-2:]
        
        compressed_older = self.compress("\n".join(older_messages))
        recent_context = "\n".join(recent_messages)
        
        final_context = f"""Previous Context (Summary): {compressed_older}

Recent Conversation:
{recent_context}

Current Message: {current_message}"""
        
        return final_context


# Global compressor instance
compressor = ContextCompressor()
