import type { Course } from '../../courses/types';
import { apiFetch } from '../../../app/api/apiFetch';

export type CourseSearchSuggestion = Pick<Course, 'id' | 'title' | 'summary' | 'categoryName'>;

const SEARCH_ENDPOINT = '/api/v1/search';

async function fetchSearch(
  query: string,
  opts: { signal?: AbortSignal } = {},
): Promise<unknown> {
  if (!query.trim()) return [];
  const url = new URL(SEARCH_ENDPOINT, window.location.origin);
  url.searchParams.set('q', query);
  url.searchParams.set('type', 'course');

  const res = await apiFetch(url.toString(), { signal: opts.signal });
  if (!res.ok) throw new Error(`Failed to search courses: ${res.status}`);
  return await res.json();
}

export async function searchCourseSuggestions(
  query: string,
  opts: { signal?: AbortSignal } = {},
): Promise<CourseSearchSuggestion[]> {
  const json = (await fetchSearch(query, opts)) as
    | CourseSearchSuggestion[]
    | { courses?: CourseSearchSuggestion[]; results?: CourseSearchSuggestion[] };

  if (Array.isArray(json)) return json;
  return json.courses ?? json.results ?? [];
}

export async function searchCourses(
  query: string,
  opts: { signal?: AbortSignal } = {},
): Promise<Course[]> {
  const json = (await fetchSearch(query, opts)) as Course[] | { courses?: Course[]; results?: Course[] };

  if (Array.isArray(json)) return json;
  return json.courses ?? json.results ?? [];
}
