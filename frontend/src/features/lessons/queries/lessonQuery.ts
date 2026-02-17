import { useQuery, type QueryFunctionContext } from '@tanstack/react-query';
import { fetchLesson } from '../api/lessonsApi';
import type { Lesson } from '../types';

export const lessonQuery = (lessonId: string) => ({
  queryKey: ['lesson', lessonId] as const,
  queryFn: ({ signal }: QueryFunctionContext) => fetchLesson(lessonId, { signal }),
});

export function useLessonQuery(lessonId: string) {
  return useQuery<Lesson, Error>({
    ...lessonQuery(lessonId),
    enabled: Boolean(lessonId),
  });
}
