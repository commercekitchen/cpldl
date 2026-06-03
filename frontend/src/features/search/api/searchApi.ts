import type { Course } from '../../courses/types';
import type { Lesson } from '../../lessons/types';
import { apiFetch } from '../../../app/api/apiFetch';

export type CourseSearchSuggestion = Pick<Course, 'id' | 'title' | 'summary' | 'categoryName'>;

export type SearchResults = {
  courses: Course[];
  lessons: Lesson[];
};

const SEARCH_ENDPOINT = '/api/v1/search';

async function fetchSearch(
  query: string,
  opts: { signal?: AbortSignal } = {},
): Promise<unknown> {
  if (!query.trim()) return { courses: [], lessons: [] };
  const url = new URL(SEARCH_ENDPOINT, window.location.origin);
  url.searchParams.set('q', query);

  const res = await apiFetch(url.toString(), { signal: opts.signal });
  if (!res.ok) throw new Error(`Failed to search: ${res.status}`);
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

export async function searchAll(
  query: string,
  opts: { signal?: AbortSignal } = {},
): Promise<SearchResults> {
  const json = (await fetchSearch(query, opts)) as {
    courses?: Course[];
    lessons?: Lesson[];
  };

  return {
    courses: json.courses ?? [],
    lessons: json.lessons ?? [],
  };
}
