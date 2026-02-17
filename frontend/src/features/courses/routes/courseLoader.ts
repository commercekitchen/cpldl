import type { LoaderFunctionArgs } from 'react-router-dom';
import { courseQuery } from '../queries/courseQuery';
import { queryClient } from '../../../app/queryClient';

export async function courseLoader({ params }: LoaderFunctionArgs) {
  const courseId = params.courseId!;
  await queryClient.ensureQueryData(courseQuery(courseId));
  return null;
}
