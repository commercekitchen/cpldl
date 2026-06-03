import { useQuery } from '@tanstack/react-query';
import { listLessons, type ListLessonsParams } from '../api/lessonsApi';
import type { Lesson } from '../types';
import { useLocale } from '../../../app/locale/LocaleContext';

export function useLessonsListQuery(params: ListLessonsParams = {}) {
  const scope = params.scope ?? 'all';
  const limit = params.limit ?? 10;
  const courseId = params.courseId ?? null;
  const { locale } = useLocale();

  return useQuery<Lesson[], Error>({
    queryKey: ['lessons', 'list', { scope, limit, courseId, locale }],
    queryFn: ({ signal }) => listLessons({ scope, limit, courseId: courseId ?? undefined }, { signal }),
  });
}
