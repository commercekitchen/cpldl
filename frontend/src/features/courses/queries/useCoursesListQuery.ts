import { useQuery } from '@tanstack/react-query';
import { listCourses, type ListCoursesParams } from '../api/coursesApi';
import type { Course } from '../types';

export function useCoursesListQuery(params: ListCoursesParams = {}) {
  const scope = params.scope ?? 'all';
  const limit = params.limit;

  return useQuery<Course[], Error>({
    queryKey: ['courses', 'list', { scope, limit }],
    queryFn: ({ signal }) => listCourses({ scope, limit }, { signal }),
  });
}
