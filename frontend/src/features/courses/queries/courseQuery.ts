import { useQuery, type QueryFunctionContext } from '@tanstack/react-query';
import { fetchCourse } from '../api/coursesApi';
import type { Course } from '../types';

export const courseQuery = (courseId: string) => ({
  queryKey: ['course', courseId] as const,
  queryFn: ({ signal }: QueryFunctionContext) => fetchCourse(courseId, { signal }),
});

export function useCourseQuery(courseId: string) {
  return useQuery<Course, Error>({
    ...courseQuery(courseId),
    enabled: Boolean(courseId),
  });
}
