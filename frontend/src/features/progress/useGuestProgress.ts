import { useCallback, useSyncExternalStore } from 'react';
import {
  clearGuestProgress,
  guestProgressCount,
  markGuestCourseComplete,
  markGuestLessonComplete,
  readGuestCompletedCourses,
  readGuestProgressStore,
  subscribeToGuestProgress,
} from './guestProgress';

// Empty store snapshot for SSR / environments without localStorage.
const emptyStore = () => ({});
const emptyCompletedCourses: string[] = [];

export function useGuestProgress() {
  const store = useSyncExternalStore(subscribeToGuestProgress, readGuestProgressStore, emptyStore);
  const completedCourses = useSyncExternalStore(
    subscribeToGuestProgress,
    readGuestCompletedCourses,
    () => emptyCompletedCourses,
  );

  const isCompleted = useCallback((lessonId: string) => lessonId in store, [store]);
  const isCourseCompleted = useCallback(
    (courseId: string) => completedCourses.includes(courseId),
    [completedCourses],
  );

  const markComplete = useCallback((lessonId: string, courseId?: string) => {
    markGuestLessonComplete(lessonId, courseId);
  }, []);

  const markCourseComplete = useCallback((courseId: string) => {
    markGuestCourseComplete(courseId);
  }, []);

  const clear = useCallback(() => {
    clearGuestProgress();
  }, []);

  return {
    isCompleted,
    isCourseCompleted,
    count: Object.keys(store).length,
    markComplete,
    markCourseComplete,
    clear,
  };
}

// Lightweight version for components that only need the count.
export function useGuestProgressCount(): number {
  return useSyncExternalStore(subscribeToGuestProgress, guestProgressCount, () => 0);
}
