import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.chat import router as chat_router

logging.basicConfig(
  level=logging.INFO if not settings.debug else logging.DEBUG,
  format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)

class Application:
  def __init__(self):
    self.app = FastAPI(
      title=settings.app_name,
      version=settings.version,
      debug=settings.debug
    )
    self._setup_middleware()
    self._setup_routes()
  
  def _setup_middleware(self):
    self.app.add_middleware(
      CORSMiddleware,
      allow_origins=["*"],
      allow_methods=["*"],
      allow_headers=["*"]
    )
    
  def _setup_routes(self):
    self.app.include_router(
      chat_router,
      prefix=settings.api_v1_str
    )
    
    @self.app.get("/")
    async def root():
        return {
            "message": f"{settings.app_name} is running",
            "version": settings.version,
            "docs": "/docs"
        }
    
    @self.app.get("/health")
    async def health_check():
        return {"status": "healthy"}
    
application = Application()
app = application.app

if __name__ == "__main__":
  import uvicorn
  uvicorn.run("app.main:app", host="0.0.0.0", port=8080, reload=settings.debug)
