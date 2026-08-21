import { useCallback, useEffect, useRef } from 'react';

type Options = {
  iframeRef: React.RefObject<HTMLIFrameElement | null>;
  onCompleted: () => void | Promise<void>;
  enabled?: boolean;
};

export function useLessonCompletionListener({ iframeRef, onCompleted, enabled = true }: Options) {
  const firedRef = useRef(false);

  useEffect(() => {
    if (!enabled) return;

    const handler = (event: MessageEvent) => {
      if (event.data !== 'lesson_completed') return;

      // Ensure the message came from *our* iframe, not some other window/iframe/extension.
      const iframeWindow = iframeRef.current?.contentWindow;
      if (!iframeWindow || event.source !== iframeWindow) return;

      // One-shot guard: prevent duplicates
      if (firedRef.current) return;
      firedRef.current = true;

      void onCompleted();
    };

    window.addEventListener('message', handler, true);
    return () => window.removeEventListener('message', handler, true);
  }, [iframeRef, onCompleted, enabled]);

  // Exposed so callers whose route reuses this component instance across lessons
  // (no remount) can reset the one-shot guard when the lesson changes.
  const reset = useCallback(() => {
    firedRef.current = false;
  }, []);

  return { reset };
}
