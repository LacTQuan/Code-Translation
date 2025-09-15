import { useState } from 'react';
import ChatForm from '../components/ChatForm';
import MessageList from '../components/MessageList';
import UsageDisplay from '../components/UsageDisplay';
import { useChat } from '../hooks/useChat';

export type UsageInfo = {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
  cost?: number;
  model: string;
  timestamp: string;
  temperature?: number;
};

export default function ChatPage() {
  const { messages, isLoading, error, send, clear } = useChat('gpt-5-nano');
  const [usageHistory, setUsageHistory] = useState<UsageInfo[]>([]);

  const handleSend = async (text: string, options: {
    model?: string;
    max_tokens?: number;
    temperature?: number;
    stream?: boolean;
    appendHistory?: boolean;
  }) => {
    await send(text, options, setUsageHistory);
  };

  return (
    <div className="container">
      <div className="main-content">
        <header>
          <h1>LLM Code Translation Testing</h1>
          <div className="actions">
            <button onClick={clear} disabled={isLoading}>Clear</button>
            <button onClick={() => setUsageHistory([])} disabled={isLoading}>Clear Usage</button>
            {/* <button onClick={abort} disabled={!isLoading}>Abort</button> */}
          </div>
        </header>

        {error && <div className="error">Error: {error}</div>}

        <MessageList messages={messages} />
        <ChatForm onSend={handleSend} isLoading={isLoading} usageHistory={usageHistory} />
      </div>
      
      <UsageDisplay usageHistory={usageHistory} />
    </div>
  );
}
