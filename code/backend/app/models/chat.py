from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any, Tuple
from enum import Enum

class ModelProvider(str, Enum):
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    OLLAMA = "ollama"

class ChatMessage(BaseModel):
    role: str = Field(..., description="Role of the message sender (user, assistant, system)")
    content: str = Field(..., description="Content of the message")

class ChatRequest(BaseModel):
    messages: List[ChatMessage] = Field(..., description="List of chat messages")
    model: str = Field(default="gpt-5-nano", description="Model to use for completion")
    max_tokens: Optional[int] = Field(default=150, ge=1, le=4000, description="Maximum tokens to generate")
    temperature: Optional[float] = Field(default=0.7, ge=0.0, le=2.0, description="Sampling temperature")
    stream: Optional[bool] = Field(default=False, description="Whether to stream the response")

class ChatResponse(BaseModel):
    message: str = Field(..., description="Generated response message")
    model: str = Field(..., description="Model used for generation")
    usage: Optional[Dict[str, Any]] = Field(default=None, description="Token usage information")
    cost: Optional[float] = Field(default=None, description="Cost of the request")
    cost_per_token: Optional[float] = Field(default=None, description="Cost per token")
    finish_reason: Optional[str] = Field(default=None, description="Reason for completion finish")
    response_time: Optional[float] = Field(default=None, description="Time taken for the response")

class ErrorResponse(BaseModel):
    error: str = Field(..., description="Error message")
    details: Optional[str] = Field(default=None, description="Additional error details")
