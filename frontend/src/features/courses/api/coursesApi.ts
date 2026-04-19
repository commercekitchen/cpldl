import type { Course } from '../types';
import { apiFetch } from '../../../app/api/apiFetch';

export async function fetchCourse(
  courseId: string,
  opts: { signal?: AbortSignal } = {},
): Promise<Course> {
  const res = await apiFetch(`/api/v1/courses/${courseId}`, { signal: opts.signal });
  if (!res.ok) throw new Error(`Failed to load course: ${res.status}`);
  return (await res.json()) as Course;
}

export type ListCoursesParams = {
  limit?: number;
  scope?: 'homepage' | 'all' | 'recommended' | 'newest' | 'tracked';
};

export async function listCourses(
  params: ListCoursesParams = {},
  opts: { signal?: AbortSignal },
): Promise<Course[]> {
  const { signal } = opts;
  const url = new URL('/api/v1/courses', window.location.origin);
  if (params.limit) url.searchParams.set('limit', String(params.limit));
  if (params.scope) url.searchParams.set('scope', params.scope);

  const res = await apiFetch(url.toString(), { signal });
  if (!res.ok) throw new Error(`Failed to list courses: ${res.status}`);

  const json = (await res.json()) as { courses: Course[] };
  return json.courses;
}
