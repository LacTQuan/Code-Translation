import type { FormEvent } from "react";
import { useEffect, useState } from "react";

type UsageInfo = {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
  cost?: number;
  model: string;
  timestamp: string;
  temperature?: number;
};

type Props = {
  onSend: (
    text: string,
    options: {
      model?: string;
      max_tokens?: number;
      temperature?: number;
      stream?: boolean;
      appendHistory?: boolean;
    }
  ) => void;
  isLoading: boolean;
  usageHistory?: UsageInfo[];
};

export default function ChatForm({ onSend, isLoading, usageHistory = [] }: Props) {
  const [input, setInput] = useState("");
  const [model, setModel] = useState("");
  const [availableModels, setAvailableModels] = useState<string[]>([]);
  const [temperature, setTemperature] = useState(0.7);
  const [maxTokens, setMaxTokens] = useState(150);
  const [stream, setStream] = useState(false);
  const [appendHistory, setAppendHistory] = useState(false);

  const submit = (e: FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;
    onSend(input.trim(), {
      model,
      temperature,
      max_tokens: maxTokens,
      stream,
      appendHistory,
    });
    setInput("");
  };

  useEffect(() => {
    const fetchModels = async () => {
        setAvailableModels([
          "gemini/gemini-2.5-pro",
          "gemini/gemini-2.5-flash", 
          "gpt-5",
          "gpt-5-mini",
          "openrouter/qwen/qwen3-coder",
          "deepseek/deepseek-reasoner",
        ]);
        setModel("gemini/gemini-2.5-pro");
    };

    fetchModels();
  }, []);

  return (
    <form className="chat-form" onSubmit={submit}>
      <div className="row">
        <select
          className="model"
          value={model}
          onChange={(e) => {
            setModel(e.target.value);
            // Automatically set temperature to 1.0 for GPT-5 models
            if (e.target.value.startsWith("gpt-5")) {
              setTemperature(1.0);
            }
          }}
        >
          {availableModels.length === 0 ? (
            <option disabled>Loading models...</option>
          ) : (
            availableModels.map((modelName) => (
              <option key={modelName} value={modelName}>
                {modelName}
              </option>
            ))
          )}
        </select>
        <label className="slider">
          temp
          <input
            type="number"
            step="0.1"
            min={0}
            max={2}
            disabled={model.startsWith("gpt-5")}
            value={model.startsWith("gpt-5") ? 1.0 : temperature}
            onChange={(e) => setTemperature(parseFloat(e.target.value))}
          />
        </label>
        {/* <label className="slider">
          max_tokens
          <input
            type="number" min={1} max={4000}
            value={maxTokens}
            onChange={e => setMaxTokens(parseInt(e.target.value, 10))}
          />
        </label>
        <label className="checkbox">
          <input type="checkbox" checked={stream} onChange={e => setStream(e.target.checked)} />
          stream
        </label> */}
        <label className="checkbox">
          {" "}
          {/* NEW */}
          <input
            type="checkbox"
            checked={appendHistory}
            onChange={(e) => setAppendHistory(e.target.checked)}
          />
          append previous message
        </label>
      </div>

      <div className="row">
        <textarea
          className="prompt"
          rows={3}
          placeholder="Type your prompt..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
        />
      </div>

      <div className="row">
        <button type="submit" disabled={isLoading}>
          {isLoading ? "Sending…" : "Send"}
        </button>
      </div>
    </form>
  );
}
