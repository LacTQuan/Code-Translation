import type { ChatRequest, ChatResponse, ErrorResponse } from './types';

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/api/v1';

export async function chat(
  payload: ChatRequest,
  signal?: AbortSignal
): Promise<ChatResponse> {
  const res = await fetch(`${API_BASE_URL}/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    signal,
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    let msg = `HTTP ${res.status}`;
    try {
      const e = (await res.json()) as ErrorResponse;
      msg = e?.error ?? msg;
    } catch { /* ignore */ }
    throw new Error(msg);
  }

  const data = (await res.json()) as ChatResponse;
  return data;
}

export async function chatStream(
  payload: ChatRequest,
  onToken: (textChunk: string) => void,
  signal?: AbortSignal
): Promise<ChatResponse> {
  const res = await fetch(`${API_BASE_URL}/chat`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    },
    body: JSON.stringify({ ...payload, stream: true }),
    signal,
  });

  const ct = res.headers.get('Content-Type') ?? '';
  if (!ct.includes('text/event-stream')) {
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = (await res.json()) as ChatResponse;
    onToken(data.message ?? '');
    return data;
  }

  const reader = res.body?.getReader();
  if (!reader) throw new Error('Streaming not supported by this browser.');

  const decoder = new TextDecoder('utf-8');
  let buffer = '';
  let finalMessage = '';
  let model = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    buffer += decoder.decode(value, { stream: true });

    const events = buffer.split('\n\n');
    buffer = events.pop() ?? '';

    for (const evt of events) {
      const line = evt.split('\n').find(l => l.startsWith('data: '));
      if (!line) continue;

      const data = line.slice(6).trim();
      if (data === '[DONE]') {
        return {
          message: finalMessage,
          model: model || payload.model,
          usage: null,
          finish_reason: 'stop',
        };
      }

      try {
        const parsed = JSON.parse(data);
        const textChunk = parsed?.delta ?? parsed?.message ?? parsed?.text ?? '';
        if (typeof textChunk === 'string' && textChunk.length) {
          finalMessage += textChunk;
          onToken(textChunk);
        }
        if (parsed?.model && typeof parsed.model === 'string') {
          model = parsed.model;
        }
      } catch {
        finalMessage += data;
        onToken(data);
      }
    }
  }

  return {
    message: finalMessage,
    model: model || payload.model,
    usage: null,
    finish_reason: 'eof',
  };
}
