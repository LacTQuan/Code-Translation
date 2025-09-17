# Code Translation Project

A full-stack application for translating code between different programming languages using AI models. The project consists of a FastAPI backend and a React/TypeScript frontend.

## Project Structure

```
code-translation/
├── code/
│   ├── backend/          # FastAPI backend
│   └── frontend/         # React + TypeScript frontend
├── output/               # Generated translations by AI models
│   ├── [model-name]/
│   │   └── AStar/
│   │       ├── misleading-names/    # Results from misleading naming approach
│   │       ├── generic-names/       # Results from generic naming approach
│   │       └── descriptive-names/   # Results from descriptive naming approach
├── resources/            # Source code and prompts
│   ├── initial_prompt/   # Model-specific prompts
│   └── python-code/
│       └── AStar/
│           ├── misleading-names.py  # Source with confusing names
│           ├── generic-names.py     # Source with generic names
│           ├── descriptive-names.py # Source with clear names
│           └── AStar.py             # Reference implementation
├── NAMING_APPROACHES.md  # Detailed explanation of naming variants
└── README.md
```

## Research Context

This project investigates how different naming conventions in source code affect AI-powered code translation quality. The research uses three distinct approaches to naming:

1. **Misleading Names** (`misleading-names/`): Names that contradict actual behavior (e.g., a function called `BFS` that implements A*)
2. **Generic Names** (`generic-names/`): Non-descriptive, generic identifiers (e.g., `ClassA`, `function1`)
3. **Descriptive Names** (`descriptive-names/`): Clear, meaningful names that reflect actual purpose

For detailed information about the naming approaches, see [`NAMING_APPROACHES.md`](NAMING_APPROACHES.md).

## Features

- **Multi-model Support**: Works with various AI providers (OpenAI, Gemini, DeepSeek, etc.)
- **Real-time Translation**: Interactive chat interface for code translation
- **Research Framework**: Systematic testing of naming convention impacts on translation quality
- **Multiple Naming Approaches**: Three distinct variants for comprehensive analysis
- **Usage Tracking**: Monitor API usage and costs
- **Copy Functionality**: Easy copy-to-clipboard for generated code
- **Responsive UI**: Modern React interface

## Prerequisites

- **Python 3.8+** (for backend)
- **Node.js 16+** and **npm** (for frontend)
- **API Keys** for supported LLM providers (OpenAI, Gemini, DeepSeek, etc.)

## Backend Setup

### 1. Navigate to Backend Directory
```bash
cd code/backend
```

### 2. Create Virtual Environment
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows:
venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Environment Configuration
Create a `.env` file in the `code/backend` directory:

```bash
# Copy example and edit
cp .env.example .env
```

Add your API keys to the `.env` file:
```env
# API Keys
OPENAI_API_KEY=your_openai_key_here
OPENROUTER_API_KEY=your_openrouter_key_here
TOGETHERAI_API_KEY=your_together_key_here
GEMINI_API_KEY=your_gemini_key_here
DEEPSEEK_API_KEY=your_deepseek_key_here
HF_TOKEN=your_huggingface_token_here

# App Configuration
DEBUG=true
```

### 5. Run Backend Server
```bash
python -m app.main
```

The backend will be available at:
- **API**: http://localhost:8080
- **Documentation**: http://localhost:8080/docs
- **Health Check**: http://localhost:8080/health

## Frontend Setup

### 1. Navigate to Frontend Directory
```bash
cd code/frontend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Start Development Server
```bash
npm run dev
```

The frontend will be available at: **http://localhost:5173**

## Running Both Services

### Option 1: Manual (Recommended for development)
1. **Terminal 1** - Backend:
   ```bash
   cd code/backend
   source venv/bin/activate  # or venv\Scripts\activate on Windows
   python app/main.py
   ```

2. **Terminal 2** - Frontend:
   ```bash
   cd code/frontend
   npm run dev
   ```

### Option 2: Using Process Manager (Optional)
You can use tools like `concurrently` to run both services:

```bash
# Install concurrently globally
npm install -g concurrently

# From project root
concurrently "cd code/backend && source venv/bin/activate && python app/main.py" "cd code/frontend && npm run dev"
```

## API Endpoints

- `GET /` - Root endpoint with service info
- `GET /health` - Health check
- `POST /api/v1/chat` - Main chat/translation endpoint
- `GET /docs` - Interactive API documentation
