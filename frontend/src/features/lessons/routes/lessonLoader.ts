import type { LoaderFunctionArgs } from 'react-router-dom';
import { lessonQuery } from '../queries/lessonQuery';
import { queryClient } from '../../../app/queryClient';

export async function lessonLoader({ params }: LoaderFunctionArgs) {
  const lessonId = params.lessonId!;
  await queryClient.ensureQueryData(lessonQuery(lessonId));
  return null;
}
