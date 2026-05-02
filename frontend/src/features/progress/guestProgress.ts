const STORAGE_KEY = 'dl_guest_progress';
const CHANGE_EVENT = 'dl_guest_progress_changed';

type GuestProgressEntry = { courseId?: string };
type GuestProgressStore = Record<string, GuestProgressEntry>; // keyed by string lessonId

// Module-level cache so useSyncExternalStore always gets the same reference
// when the underlying data hasn't changed.
let _cachedJson = '';
let _cachedStore: GuestProgressStore = {};

export function readGuestProgressStore(): GuestProgressStore {
  try {
    const json = localStorage.getItem(STORAGE_KEY) ?? '{}';
    if (json !== _cachedJson) {
      _cachedJson = json;
      _cachedStore = JSON.parse(json) as GuestProgressStore;
    }
    return _cachedStore;
  } catch {
    return _cachedStore;
  }
}

export function markGuestLessonComplete(lessonId: string, courseId?: string): void {
  const store = readGuestProgressStore();
  if (store[lessonId]) return;
  store[lessonId] = courseId ? { courseId } : {};
  localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
  window.dispatchEvent(new Event(CHANGE_EVENT));
}

export function clearGuestProgress(): void {
  localStorage.removeItem(STORAGE_KEY);
  window.dispatchEvent(new Event(CHANGE_EVENT));
}

export function guestProgressCount(): number {
  return Object.keys(readGuestProgressStore()).length;
}

export function subscribeToGuestProgress(callback: () => void): () => void {
  window.addEventListener(CHANGE_EVENT, callback);
  window.addEventListener('storage', callback);
  return () => {
    window.removeEventListener(CHANGE_EVENT, callback);
    window.removeEventListener('storage', callback);
  };
}

// Called after successful sign-up. Fires completeLesson for each stored entry,
// then clears localStorage. Individual failures are silently ignored so a bad
// lesson ID doesn't block the user.
export async function migrateGuestProgress(
  completeLesson: (lessonId: string, courseId?: string) => Promise<unknown>,
): Promise<void> {
  const entries = Object.entries(readGuestProgressStore());
  if (entries.length === 0) return;
  await Promise.allSettled(
    entries.map(([lessonId, { courseId }]) => completeLesson(lessonId, courseId)),
  );
  clearGuestProgress();
}
