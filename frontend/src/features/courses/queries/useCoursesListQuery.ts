import { useQuery } from '@tanstack/react-query';
import { listCourses, type ListCoursesParams } from '../api/coursesApi';
import type { Course } from '../types';
import { useLocale } from '../../../app/locale/LocaleContext';

export function useCoursesListQuery(params: ListCoursesParams = {}) {
  const scope = params.scope ?? 'all';
  const limit = params.limit;
  const { locale } = useLocale();

  return useQuery<Course[], Error>({
    queryKey: ['courses', 'list', { scope, limit, locale }],
    queryFn: ({ signal }) => listCourses({ scope, limit }, { signal }),
  });
}
