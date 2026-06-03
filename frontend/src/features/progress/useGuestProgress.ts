import { useCallback, useSyncExternalStore } from 'react';
import {
  clearGuestProgress,
  guestProgressCount,
  markGuestLessonComplete,
  readGuestProgressStore,
  subscribeToGuestProgress,
} from './guestProgress';

// Empty store snapshot for SSR / environments without localStorage.
const emptyStore = () => ({});

export function useGuestProgress() {
  const store = useSyncExternalStore(subscribeToGuestProgress, readGuestProgressStore, emptyStore);

  const isCompleted = useCallback((lessonId: string) => lessonId in store, [store]);

  const markComplete = useCallback((lessonId: string, courseId?: string) => {
    markGuestLessonComplete(lessonId, courseId);
  }, []);

  const clear = useCallback(() => {
    clearGuestProgress();
  }, []);

  return {
    isCompleted,
    count: Object.keys(store).length,
    markComplete,
    clear,
  };
}

// Lightweight version for components that only need the count.
export function useGuestProgressCount(): number {
  return useSyncExternalStore(subscribeToGuestProgress, guestProgressCount, () => 0);
}
