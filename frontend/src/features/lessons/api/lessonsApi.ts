import type { Lesson } from '../types';
import { apiFetch } from '../../../app/api/apiFetch';

export type CompleteLessonResponse = {
  course_completed?: boolean;
  redirect_path?: string;
};

type LessonResponse = Lesson & {
  course_id?: string;
};

function normalizeLesson(lesson: LessonResponse): Lesson {
  return {
    ...lesson,
    courseId: lesson.courseId ?? lesson.course_id,
  };
}

export async function fetchLesson(
  lessonId: string,
  opts: { signal?: AbortSignal } = {},
): Promise<Lesson> {
  const res = await apiFetch(`/api/v1/lessons/${lessonId}`, { signal: opts.signal });
  if (!res.ok) throw new Error(`Failed to load lesson: ${res.status}`);
  const json = (await res.json()) as LessonResponse;
  return normalizeLesson(json);
}

async function postCompleteLesson(
  url: URL,
  body: Record<string, string>,
  signal?: AbortSignal,
): Promise<CompleteLessonResponse> {
  const res = await apiFetch(url.toString(), {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
    signal,
  });

  if (!res.ok) {
    const text = await res.text().catch(() => '');
    const isHtml = text.includes('<!DOCTYPE html') || text.includes('<html');
    const details = isHtml ? '(HTML error page returned; likely wrong route)' : text.slice(0, 200);
    throw new Error(
      `completeLesson failed: ${res.status} ${res.statusText} at ${url.pathname + url.search} ${details}`.trim(),
    );
  }

  if (res.status === 204) return {};
  return (await res.json()) as CompleteLessonResponse;
}

export async function completeLesson(opts: {
  lessonId: number | string;
  courseId?: number | string;
  preview?: boolean;
  signal?: AbortSignal;
}): Promise<CompleteLessonResponse> {
  const { lessonId, courseId, preview, signal } = opts;
  const url = new URL('/api/v1/lessons/complete', window.location.origin);
  if (preview) url.searchParams.set('preview', 'true');
  const body = {
    lesson_id: String(lessonId),
    ...(courseId ? { course_id: String(courseId) } : {}),
  };

  try {
    return await postCompleteLesson(url, body, signal);
  } catch (err) {
    // Safari intermittently drops the session cookie on same-origin fetches
    // (WebKit bug 255524), which makes this write silently no-op for the
    // signed-in user. The retry is safe: completion is idempotent server-side.
    if (signal?.aborted) throw err;
    return await postCompleteLesson(url, body, signal);
  }
}

export type ListLessonsParams = {
  courseId?: string;
  limit?: number;
  scope?: 'popular' | 'all' | 'recommended' | 'newest';
};

export async function listLessons(
  params: ListLessonsParams = {},
  opts: { signal?: AbortSignal },
): Promise<Lesson[]> {
  const { signal } = opts;
  const url = new URL('/api/v1/lessons', window.location.origin);
  if (params.courseId) url.searchParams.set('course_id', params.courseId);
  if (params.limit) url.searchParams.set('limit', String(params.limit));
  if (params.scope) url.searchParams.set('scope', params.scope);

  const res = await apiFetch(url.toString(), { signal });
  if (!res.ok) throw new Error(`Failed to list lessons: ${res.status}`);

  const json = (await res.json()) as { lessons: LessonResponse[] };
  return json.lessons.map(normalizeLesson);
}
