import { useState } from 'react';

type Props = {
  text: string;
  className?: string;
  label?: string;
  copiedLabel?: string;
};

export default function CopyButton({
  text,
  className,
  label = 'Copy',
  copiedLabel = 'Copied',
}: Props) {
  const [copied, setCopied] = useState(false);

  async function handleCopy() {
    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(text);
      } else {
        const ta = document.createElement('textarea');
        ta.value = text;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
      }
      setCopied(true);
      setTimeout(() => setCopied(false), 1200);
    } catch {
      console.error('Copy failed');
    }
  }

  return (
    <button
      type="button"
      onClick={handleCopy}
      className={`copy-btn ${copied ? 'is-copied' : ''} ${className ?? ''}`}
      aria-label={copied ? copiedLabel : label}
      title={copied ? copiedLabel : label}
    >
      {copied ? copiedLabel : label}
    </button>
  );
}
