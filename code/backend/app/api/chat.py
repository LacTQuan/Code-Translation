from app.models.chat import ChatRequest, ChatResponse
from typing import List
from fastapi import HTTPException, APIRouter
from app.services.llm_service import LLMService
import logging

router = APIRouter()

class ChatController:
  def __init__(self):
    self.llm_service = LLMService()
    self.logger = logging.getLogger(__name__)

  async def get_available_models(self) -> List[str]:
    return self.llm_service.get_available_models() 
  
  async def get_available_providers(self) -> List[str]:
    return self.llm_service.get_available_providers()
  
  async def generate_response(self, request: ChatRequest) -> ChatResponse:
    try:
      # if not self.llm_service.validate_model(request.model):
      #   raise HTTPException(
      #     status_code=400,
      #     detail=f"Model {request.model} is not supported"
      #   )
        
      if not request.messages:
        raise HTTPException(
          status_code=400,
          detail=f"Messages list cannot be empty"
        )
      
      response = await self.llm_service.generate_response(request=request)
      
      return response
    except HTTPException:
      raise # let the fastapi handle it
    except Exception as e:
      err = f"Error while generating response: {str(e)}"
      self.logger.error(err)
      raise HTTPException(
        status_code=500,
        detail=err
      )
      
chat_controller = ChatController()

@router.post("/chat", response_model=ChatResponse)
async def generate_response(request: ChatRequest) -> ChatResponse:
  return await chat_controller.generate_response(request=request)

@router.get("/models", response_model=List[str])
async def get_models():
  return await chat_controller.get_available_models()

@router.get("/providers", response_model=List[str])
async def get_providers():
  return await chat_controller.get_available_providers()
      