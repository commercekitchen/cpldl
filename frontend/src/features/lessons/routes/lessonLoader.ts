import type { LoaderFunctionArgs } from 'react-router-dom';
import { lessonQuery } from '../queries/lessonQuery';
import { queryClient } from '../../../app/queryClient';
import { withSurveyRedirect } from '../../survey/surveyRequired';

export async function lessonLoader({ params }: LoaderFunctionArgs) {
  const lessonId = params.lessonId!;
  await withSurveyRedirect(() => queryClient.ensureQueryData(lessonQuery(lessonId)));
  return null;
}
