"""
Configuration Management
Centralized configuration for the AI Agent system.
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Settings(BaseSettings):
    """
    Application settings with environment variable support.
    
    Create a .env file in the project root with:
    OPENAI_API_KEY=your_api_key_here
    MODEL_NAME=gpt-4o-mini
    """
    
    # API Keys
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    
    # Model Configuration
    MODEL_NAME: str = os.getenv("MODEL_NAME", "gpt-4o-mini")
    TEMPERATURE: float = float(os.getenv("TEMPERATURE", "0.0"))
    MAX_TOKENS: int = int(os.getenv("MAX_TOKENS", "1000"))
    
    # Agent Configuration
    MAX_ITERATIONS: int = int(os.getenv("MAX_ITERATIONS", "5"))
    VERBOSE_MODE: bool = os.getenv("VERBOSE_MODE", "false").lower() == "true"
    
    # Context Compression
    COMPRESSION_THRESHOLD: int = int(os.getenv("COMPRESSION_THRESHOLD", "5"))
    COMPRESSION_MODEL: str = os.getenv("COMPRESSION_MODEL", "gpt-4o-mini")
    
    # API Configuration
    API_TITLE: str = "AI Support Agent API"
    API_VERSION: str = "1.0.0"
    API_DESCRIPTION: str = "Production-grade AI Agent for ISP Customer Support Automation"
    
    # Database Configuration (for future use)
    DATABASE_URL: Optional[str] = os.getenv("DATABASE_URL", None)
    
    # Server Configuration
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    
    # CORS Configuration
    CORS_ORIGINS: list = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://localhost:5173",
    ]
    
    # Rate Limiting (for future implementation)
    RATE_LIMIT_PER_MINUTE: int = int(os.getenv("RATE_LIMIT_PER_MINUTE", "60"))
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Create global settings instance
settings = Settings()


def validate_settings() -> bool:
    """
    Validate that all required settings are properly configured.
    
    Returns:
        True if settings are valid, raises ValueError otherwise
    """
    if not settings.OPENAI_API_KEY:
        raise ValueError(
            "OPENAI_API_KEY is not set. Please set it in your .env file or environment variables."
        )
    
    if settings.TEMPERATURE < 0 or settings.TEMPERATURE > 1:
        raise ValueError("TEMPERATURE must be between 0 and 1")
    
    if settings.MAX_TOKENS < 1:
        raise ValueError("MAX_TOKENS must be greater than 0")
    
    return True
