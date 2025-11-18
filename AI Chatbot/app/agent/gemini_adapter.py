"""
Thin Gemini/Generative AI adapter to replace ChatOpenAI usage.

Provides a minimal compatible surface used by the agent:
- constructor(model, temperature, api_key, max_tokens)
- bind_tools(tools_list) -> self
- invoke(messages) -> ResponseShim (with .content and .tool_calls)
- ainvoke(messages) -> async wrapper around invoke

This adapter uses `google.generativeai` (google-generativeai) when available
and falls back to a simple local echo if the package is not installed during development.
"""

from typing import List, Any, Optional
import asyncio
import os

try:
    import google.generativeai as genai  # type: ignore
    _HAS_GENAI = True
except Exception:
    genai = None
    _HAS_GENAI = False


class ResponseShim:
    def __init__(self, content: str, tool_calls: Optional[List[dict]] = None):
        self.content = content
        self.tool_calls = tool_calls or []


class GeminiChatAdapter:
    def __init__(self, model: str = "gemini-2.5-flash", temperature: float = 0.0, api_key: Optional[str] = None, max_tokens: int = 1000):
        self.model = model
        self.temperature = temperature
        self.api_key = api_key or os.getenv("GEMINI_API_KEY", "")
        self.max_tokens = max_tokens
        self._tools = []

        if _HAS_GENAI and self.api_key:
            try:
                genai.configure(api_key=self.api_key)
            except Exception:
                # If ADC (service account) is used, genai will pick up credentials from env
                pass

    def bind_tools(self, tools_list: List[Any]):
        # Keep the API compatible with ChatOpenAI.bind_tools
        self._tools = list(tools_list)
        return self

    def _convert_messages(self, messages: List[Any]) -> List[dict]:
        converted = []
        for m in messages:
            role = getattr(m, "type", None) or getattr(m, "role", None)
            content = getattr(m, "content", None)
            if role is None:
                # Try LangChain message classes: HumanMessage/AIMessage/SystemMessage
                cls_name = m.__class__.__name__.lower()
                if "human" in cls_name or "user" in cls_name:
                    role = "user"
                elif "system" in cls_name:
                    role = "system"
                elif "ai" in cls_name or "assistant" in cls_name:
                    role = "assistant"
                else:
                    role = "user"
            converted.append({"role": role, "content": content})
        return converted

    def invoke(self, messages: List[Any]) -> ResponseShim:
        """Invoke Gemini model with proper Google Generative AI SDK and tool calling support."""
        try:
            print(f"[DEBUG] invoke() called with {len(messages)} messages, {len(self._tools)} tools")
            converted = self._convert_messages(messages)
            
            if not _HAS_GENAI or not self.api_key:
                return ResponseShim(
                    content="I'm your ISP support assistant! How can I help with your internet today?",
                    tool_calls=[]
                )
            
            # Separate system and chat messages
            system_instruction = ""
            chat_history = []
            
            for msg in converted:
                role = msg.get("role", "user")
                content = msg.get("content", "")
                
                if role == "system":
                    system_instruction = content
                elif role == "user":
                    chat_history.append({"role": "user", "parts": [content]})
                elif role in ["assistant", "ai"]:
                    chat_history.append({"role": "model", "parts": [content]})
            
            # Convert tools to Gemini function declarations using genai.protos types
            from google.ai import generativelanguage as glm
            
            tools_list = None
            if self._tools:
                tools_list = []
                for tool in self._tools:
                    # The tool is already an instance (StructuredTool from @tool decorator)
                    tool_name = tool.name if hasattr(tool, 'name') else tool.__class__.__name__
                    tool_description = tool.description if hasattr(tool, 'description') else "Tool function"
                    
                    print(f"[DEBUG] Processing tool: {tool_name}")
                    
                    # Extract parameters from the tool's args_schema
                    parameters = {}
                    required_params = []
                    
                    if hasattr(tool, 'args_schema') and tool.args_schema:
                        try:
                            schema_dict = tool.args_schema.schema()
                            props = schema_dict.get('properties', {})
                            required_params = schema_dict.get('required', [])
                            
                            print(f"[DEBUG] Tool {tool_name} properties: {props.keys()}")
                            
                            # Convert each property to Gemini format
                            for prop_name, prop_schema in props.items():
                                prop_type = prop_schema.get('type', 'string')
                                prop_desc = prop_schema.get('description', '')
                                
                                # Map JSON schema types to Gemini types
                                if prop_type == 'string':
                                    type_val = glm.Type.STRING
                                elif prop_type == 'integer':
                                    type_val = glm.Type.INTEGER
                                elif prop_type == 'number':
                                    type_val = glm.Type.NUMBER
                                elif prop_type == 'boolean':
                                    type_val = glm.Type.BOOLEAN
                                else:
                                    type_val = glm.Type.STRING
                                
                                parameters[prop_name] = glm.Schema(
                                    type=type_val,
                                    description=prop_desc
                                )
                        except Exception as e:
                            print(f"Error extracting schema for {tool_name}: {e}")
                    
                    # Create FunctionDeclaration
                    func_decl = glm.FunctionDeclaration(
                        name=tool_name,
                        description=tool_description,
                        parameters=glm.Schema(
                            type=glm.Type.OBJECT,
                            properties=parameters,
                            required=required_params
                        )
                    )
                    tools_list.append(func_decl)
            
            print(f"[DEBUG] Tools list: {[t.name for t in tools_list] if tools_list else 'None'}")
            
            # Create model with system instruction and tools
            model = genai.GenerativeModel(
                self.model,
                system_instruction=system_instruction if system_instruction else None,
                tools=tools_list if tools_list else None
            )
            
            generation_config = {
                "temperature": self.temperature,
                "max_output_tokens": self.max_tokens,
            }
            
            # Start chat with history
            chat = model.start_chat(history=chat_history[:-1] if len(chat_history) > 1 else [])
            
            # Send last user message
            last_message = chat_history[-1]["parts"][0] if chat_history else "Hello"
            print(f"[DEBUG] Sending message: {last_message[:100]}...")
            response = chat.send_message(last_message, generation_config=generation_config)
            
            # Extract text and tool calls
            text = ""
            tool_calls = []
            
            if hasattr(response, 'candidates') and response.candidates:
                candidate = response.candidates[0]
                if hasattr(candidate, 'content') and hasattr(candidate.content, 'parts'):
                    for part in candidate.content.parts:
                        # Check for function calls
                        if hasattr(part, 'function_call'):
                            fc = part.function_call
                            tool_calls.append({
                                "name": fc.name,
                                "args": dict(fc.args) if hasattr(fc, 'args') else {}
                            })
                            print(f"[DEBUG] Tool call: {fc.name} with args {dict(fc.args) if hasattr(fc, 'args') else {}}")
                        # Check for text
                        elif hasattr(part, 'text'):
                            text += part.text
            
            # Fallback to response.text if available
            if not text and not tool_calls:
                if hasattr(response, 'text'):
                    text = response.text
            
            if not text and not tool_calls:
                text = "I'm having trouble generating a response. Please try again."
            
            print(f"[DEBUG] Response text: {text[:100] if text else 'None'}..., tool_calls: {len(tool_calls)}")
            return ResponseShim(content=text.strip(), tool_calls=tool_calls)
            
        except Exception as e:
            error_msg = str(e)
            print(f"Gemini adapter error: {error_msg}")
            
            if "API key" in error_msg or "authentication" in error_msg.lower():
                return ResponseShim(
                    content="There's an authentication issue. Please check the API key configuration.",
                    tool_calls=[]
                )
            else:
                return ResponseShim(
                    content="I'm your ISP support assistant! Having a small hiccup, but I'm here to help. What's going on with your internet?",
                    tool_calls=[]
                )

    async def ainvoke(self, messages: List[Any]) -> ResponseShim:
        # Run sync invocation in thread pool to avoid blocking
        loop = asyncio.get_running_loop()
        return await loop.run_in_executor(None, self.invoke, messages)
