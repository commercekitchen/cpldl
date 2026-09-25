import { useEffect, useRef } from 'react';
import { useOutletContext } from 'react-router-dom';
import type { UserLayoutOutletContext } from './UserLayout';

// UserLayout refreshes the screen reader's browse-mode buffer on route change,
// but pages that fetch their content after mounting (dangerouslySetInnerHTML
// bodies loaded via a query) render only a loading placeholder at that point.
// Call this with a `ready` flag that flips from false to true once the real
// content is in the DOM, so the buffer gets refreshed again against it.
// Only the false -> true transition fires, so background refetches that leave
// `ready` true don't yank focus during normal use.
export function useAnnounceContentReady(ready: boolean) {
  const { announceContent } = useOutletContext<UserLayoutOutletContext>();
  const wasReady = useRef(ready);

  useEffect(() => {
    if (!wasReady.current && ready) {
      announceContent();
    }
    wasReady.current = ready;
  }, [ready, announceContent]);
}
