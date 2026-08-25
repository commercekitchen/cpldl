const STORAGE_KEY = 'dl_guest_progress';
const COMPLETED_COURSES_STORAGE_KEY = 'dl_guest_completed_courses';
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

// Cached the same way as the lesson store above, but keyed by courseId so
// course-listing views (CourseCard, etc.) can check completion in O(1)
// instead of re-fetching and scanning each course's full lesson list.
let _cachedCoursesJson = '';
let _cachedCompletedCourses: string[] = [];

export function readGuestCompletedCourses(): string[] {
  try {
    const json = localStorage.getItem(COMPLETED_COURSES_STORAGE_KEY) ?? '[]';
    if (json !== _cachedCoursesJson) {
      _cachedCoursesJson = json;
      _cachedCompletedCourses = JSON.parse(json) as string[];
    }
    return _cachedCompletedCourses;
  } catch {
    return _cachedCompletedCourses;
  }
}

export function isGuestCourseCompleted(courseId: string): boolean {
  return readGuestCompletedCourses().includes(courseId);
}

export function markGuestCourseComplete(courseId: string): void {
  const courses = readGuestCompletedCourses();
  if (courses.includes(courseId)) return;
  localStorage.setItem(COMPLETED_COURSES_STORAGE_KEY, JSON.stringify([...courses, courseId]));
  window.dispatchEvent(new Event(CHANGE_EVENT));
}

export function clearGuestProgress(): void {
  localStorage.removeItem(STORAGE_KEY);
  localStorage.removeItem(COMPLETED_COURSES_STORAGE_KEY);
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

// Called after successful sign-up/sign-in. Fires completeLesson for each
// stored entry, then clears localStorage.
//
// This runs sequentially, not concurrently: multiple lessons from the same
// course share one CourseProgress row, and the server's
// `CourseProgress.find_or_create_by!` has no unique index backing it. Firing
// these in parallel lets concurrent requests both miss the find and create
// duplicate rows, which can silently strand the assessment lesson's
// completed_at flip on the "wrong" duplicate.
//
// Entries that still fail (bad lesson id, network error) are kept in
// localStorage instead of discarded, so they aren't lost — they'll be
// retried the next time this runs.
export async function migrateGuestProgress(
  completeLesson: (lessonId: string, courseId?: string) => Promise<unknown>,
): Promise<void> {
  const entries = Object.entries(readGuestProgressStore());
  if (entries.length === 0) return;

  const failed: [string, GuestProgressEntry][] = [];
  for (const [lessonId, entry] of entries) {
    try {
      await completeLesson(lessonId, entry.courseId);
    } catch {
      failed.push([lessonId, entry]);
    }
  }

  if (failed.length === 0) {
    clearGuestProgress();
    return;
  }

  localStorage.setItem(STORAGE_KEY, JSON.stringify(Object.fromEntries(failed)));
  localStorage.removeItem(COMPLETED_COURSES_STORAGE_KEY);
  window.dispatchEvent(new Event(CHANGE_EVENT));
}
