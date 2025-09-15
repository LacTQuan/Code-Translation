import { useCallback, useRef, useState } from "react";
import type { ChatMessage, ChatRequest } from "../api/types";
import { chat, chatStream } from "../api/client";
import type { UsageInfo } from "../pages/ChatPage";

type SendOptions = {
  model?: string;
  max_tokens?: number;
  temperature?: number;
  stream?: boolean;
  appendHistory?: boolean;
};

export function useChat(defaultModel = "gpt-3.5-turbo") {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const abortRef = useRef<AbortController | null>(null);

  const send = useCallback(
    async (
      userText: string,
      opts: SendOptions = {},
      setUsageHistory: React.Dispatch<React.SetStateAction<UsageInfo[]>>
    ) => {
      setError(null);

      const userMsg: ChatMessage = { role: "user", content: userText };
      const history = [...messages, userMsg];

      // UI shows the full chat history regardless of what we send to backend
      setMessages(history);
      setIsLoading(true);

      abortRef.current?.abort();
      abortRef.current = new AbortController();

      const historyForPayload =
        opts.appendHistory ?? true ? history : [userMsg];

      const payload: ChatRequest = {
        messages: historyForPayload,
        model: opts.model ?? defaultModel,
        max_tokens: opts.max_tokens ?? 150,
        temperature: opts.temperature ?? 0.7,
        stream: Boolean(opts.stream),
      };

      try {
        console.log("SENDING PAYLOAD:", payload);
        const res = await chat(payload, abortRef.current.signal);
        console.log("USAGE DATA:", res.usage);
        console.log("COST DATA:", res.cost);
        console.log("COST PER TOKEN DATA:", res.cost_per_token);
        console.log("RESPONSE TIME DATA:", res.response_time);
        setUsageHistory((prev) => [
          ...prev,
          {
            prompt_tokens: Number(res.usage?.prompt_tokens ?? 0),
            completion_tokens: Number(res.usage?.completion_tokens ?? 0),
            total_tokens: Number(res.usage?.total_tokens ?? 0),
            cost: Number(res.cost ?? 0),
            model: res.model,
            timestamp: new Date().toISOString(),
            temperature: Number(payload.temperature ?? 0),
            response_time: Number(res.response_time ?? 0),
          },
        ]);
        setMessages((curr) => [
          ...curr,
          { role: "assistant", content: res.message } as ChatMessage,
        ]);
      } catch (e: any) {
        setError(e?.message ?? "Request failed");
      } finally {
        setIsLoading(false);
      }
    },
    [messages, defaultModel]
  );

  const abort = useCallback(() => {
    abortRef.current?.abort();
    setIsLoading(false);
  }, []);

  const clear = useCallback(() => {
    setMessages([]);
    setError(null);
  }, []);

  return { messages, isLoading, error, send, abort, clear };
}
