import type { ChatMessage } from '../api/types';
import CopyButton from './CopyButton';

type Props = { messages: ChatMessage[] };

export default function MessageList({ messages }: Props) {
  return (
    <div className="msg-list">
      {messages.map((m, i) => (
        <div key={i} className={`msg msg-${m.role}`}>
          <div className="msg-header">
            <div className="msg-role">{m.role}</div>
            <div className="msg-actions">
              <CopyButton text={m.content} />
            </div>
          </div>
          <div className="msg-bubble">{m.content}</div>
        </div>
      ))}
    </div>
  );
}
