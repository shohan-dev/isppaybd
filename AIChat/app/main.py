from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from app.core.config import settings
from app.api.endpoints import chat

app = FastAPI(title=settings.PROJECT_NAME, version=settings.VERSION)

# Setup Templates
templates = Jinja2Templates(directory="templates")

# Include Routers
app.include_router(chat.router, prefix="/api")

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    """Serves the chat interface."""
    return templates.TemplateResponse("index.html", {"request": request})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
