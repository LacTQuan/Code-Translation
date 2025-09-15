export type Role = 'user' | 'assistant' | 'system';

export interface ChatMessage {
  role: Role;
  content: string;
}

export interface ChatRequest {
  messages: ChatMessage[];
  model: string;
  max_tokens?: number;
  temperature?: number;
  stream?: boolean;
}

export interface ChatResponse {
  message: string;
  model: string;
  usage?: Record<string, unknown> | null;
  finish_reason?: string | null;
  cost?: number | null;
  cost_per_token?: number | null;
  response_time?: number | null;
}

export interface ErrorResponse {
  error: string;
  details?: string | null;
}
