from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
  app_name: str = "Backend API"
  version: str = "1.0.0"
  debug: bool = True
  
  api_v1_str: str = "/api/v1"
  
  backend_cors_origins: List[str] = ["*"]
  
  # Supported models
  supported_models: List[str] = ["gpt"]
  
  # API keys -> loaded from .env file
  openai_api_key: str = ""
  openrouter_api_key: str = ""
  togetherai_api_key: str = ""
  gemini_api_key: str = ""
  deepseek_api_key: str = ""
  hf_token: str = ""
  
  
  class Config:
      env_file = ".env"
      case_sensitive = False
        
settings = Settings()
    