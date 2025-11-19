"""
Configuration Management
Centralized configuration for the AI Agent system.
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Settings(BaseSettings):
    """Central configuration with environment variable support."""

    # Gemini / Google Generative AI credentials
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY") or os.getenv("GEMINIUS_API_KEY", "")
    GOOGLE_APPLICATION_CREDENTIALS: str = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "")
    
    # Model Configuration
    MODEL_NAME: str = os.getenv("MODEL_NAME", "gemini-2.5-flash")
    TEMPERATURE: float = float(os.getenv("TEMPERATURE", "0.0"))
    MAX_TOKENS: int = int(os.getenv("MAX_TOKENS", "1000"))
    
    # Agent Configuration
    MAX_ITERATIONS: int = int(os.getenv("MAX_ITERATIONS", "5"))
    VERBOSE_MODE: bool = os.getenv("VERBOSE_MODE", "false").lower() == "true"
    
    # Context Compression
    COMPRESSION_THRESHOLD: int = int(os.getenv("COMPRESSION_THRESHOLD", "5"))
    COMPRESSION_MODEL: str = os.getenv("COMPRESSION_MODEL", "gemini-2.5-flash")
    
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
        "http://localhost:8001",
        "http://127.0.0.1:8000",
        "http://127.0.0.1:8001",
        "http://localhost:5173",
    ]
    
    # Rate Limiting (for future implementation)
    RATE_LIMIT_PER_MINUTE: int = int(os.getenv("RATE_LIMIT_PER_MINUTE", "60"))
    
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="allow",
    )


# Create global settings instance
settings = Settings()


def validate_settings() -> bool:
    """
    Validate that all required settings are properly configured.
    
    Returns:
        True if settings are valid, raises ValueError otherwise
    """
    # Require Gemini API key or Google ADC credentials
    if not (settings.GEMINI_API_KEY or settings.GOOGLE_APPLICATION_CREDENTIALS):
        raise ValueError(
            "No model API credentials configured. Set GEMINI_API_KEY (or GEMINIUS_API_KEY) or configure GOOGLE_APPLICATION_CREDENTIALS."
        )
    
    if settings.TEMPERATURE < 0 or settings.TEMPERATURE > 1:
        raise ValueError("TEMPERATURE must be between 0 and 1")
    
    if settings.MAX_TOKENS < 1:
        raise ValueError("MAX_TOKENS must be greater than 0")
    
    return True
