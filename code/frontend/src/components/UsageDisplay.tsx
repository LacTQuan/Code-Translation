import { useState } from "react";

type UsageInfo = {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
  cost?: number;
  model: string;
  timestamp: string;
  temperature?: number;
  response_time?: number;
};

type Props = {
  usageHistory: UsageInfo[];
};

export default function UsageDisplay({ usageHistory }: Props) {
  const [isExpanded, setIsExpanded] = useState(true);
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null);

  const totalTokens = usageHistory.reduce(
    (sum, usage) => sum + usage.total_tokens,
    0
  );
  const totalCost = usageHistory.reduce(
    (sum, usage) => sum + (usage.cost || 0),
    0
  );

  const copyUsageDetails = async (usage: UsageInfo, index: number) => {
    const details = `Model: ${usage.model}
Temperature: ${usage.temperature || "N/A"}
Response Time: ${usage.response_time ? usage.response_time + " ms" : "N/A"}
Timestamp: ${new Date(usage.timestamp).toLocaleString()}
Prompt Tokens: ${usage.prompt_tokens}
Completion Tokens: ${usage.completion_tokens}
Total Tokens: ${usage.total_tokens}
Cost: $${usage.cost?.toFixed(4) || "0.0000"}`;

    try {
      await navigator.clipboard.writeText(details);
      setCopiedIndex(index);
      setTimeout(() => setCopiedIndex(null), 2000);
    } catch (err) {
      console.error("Failed to copy:", err);
    }
  };

  return (
    <div className="usage-display">
      <div className="usage-header" onClick={() => setIsExpanded(!isExpanded)}>
        <h3>Usage & Cost</h3>
        <span className="toggle">{isExpanded ? "▼" : "▶"}</span>
      </div>

      {isExpanded && (
        <div className="usage-content">
          <div className="usage-summary">
            <div className="summary-item">
              <span className="label">Total Tokens:</span>
              <span className="value">{totalTokens.toLocaleString()}</span>
            </div>
            <div className="summary-item">
              <span className="label">Total Cost:</span>
              <span className="value">${totalCost.toFixed(4)}</span>
            </div>
          </div>

          <div className="usage-history">
            <h4>Recent Calls</h4>
            {usageHistory.length === 0 ? (
              <p className="no-data">No usage data yet</p>
            ) : (
              <div className="history-list">
                {usageHistory
                  .slice(-10)
                  .reverse()
                  .map((usage, index) => (
                    <div key={index} className="history-item">
                      <div className="history-header">
                        <span className="model">{usage.model}</span>
                        <div className="header-actions">
                          <span className="timestamp">
                            {new Date(usage.timestamp).toLocaleTimeString()}
                          </span>
                          <button
                            className={`copy-btn ${
                              copiedIndex === index ? "is-copied" : ""
                            }`}
                            onClick={() => copyUsageDetails(usage, index)}
                            title="Copy usage details"
                          >
                            {copiedIndex === index ? "✓" : "📋"}
                          </button>
                        </div>
                      </div>
                      <div className="history-details">
                        <span className="tokens">
                          IN {usage.prompt_tokens} → OUT{" "}
                          {usage.completion_tokens}
                          (Total: {usage.total_tokens})
                        </span>
                        {usage.cost && (
                          <span className="cost">${usage.cost.toFixed(4)}</span>
                        )}
                      </div>
                    </div>
                  ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
