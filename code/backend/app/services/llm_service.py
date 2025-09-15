import litellm
from app.core.config import settings
from app.models.chat import ChatRequest, ChatResponse
import logging
import time

litellm.set_verbose = settings.debug

class LLMService:
  def __init__(self):
    self.logger = logging.getLogger(__name__)
    self._setup_api_keys()
    
  def _setup_api_keys(self):
    pass

  async def generate_response(self, request: ChatRequest) -> ChatResponse:
    try:
      messages = [{"role": msg.role, "content": msg.content} for msg in request.messages]

      self.logger.info(f"Generating completion with model: {request.model} {settings.togetherai_api_key}")
      
      start_time = int(time.time() * 1000)
      response = await litellm.acompletion(
        model=request.model,
        messages=messages,
        # max_tokens=request.max_tokens, # -> maximum tokens to generate in the chat commpletion
        temperature=request.temperature, # -> the higher the more creative
        # stream=request.stream
      ) 
      end_time = int(time.time() * 1000)
      
      message_content = response.choices[0].message.content
      finish_reason = response.choices[0].finish_reason
      usage = response.usage.dict() if response.usage else None
      
      
      cost = None
      cost_per_token = None
      
      try:
        cost = litellm.completion_cost(completion_response=response)
        if cost and usage and usage.get('total_tokens', 0) > 0:
          cost_per_token = cost / usage['total_tokens']
      except Exception as cost_error:
        self.logger.warning(f"Could not calculate cost: {cost_error}")
      
      return ChatResponse(
        message=message_content,
        model=request.model,
        usage=usage,
        cost=cost,
        cost_per_token=cost_per_token,
        finish_reason=finish_reason,
        response_time=end_time - start_time
      )
      
    except Exception as e:
      self.logger.error(f"Error in chat completion: {str(e)}")
      raise e  # Re-raise the exception so the API layer can handle it properly
    
  def get_available_models(self):
    return list(litellm.model_list)
  
  def get_available_providers(self):
    return list(litellm.provider_list)
    
  def validate_model(self, model: str):
    return model in litellm.model_list
