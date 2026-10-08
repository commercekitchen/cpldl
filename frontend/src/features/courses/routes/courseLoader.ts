import type { LoaderFunctionArgs } from 'react-router-dom';
import { courseQuery } from '../queries/courseQuery';
import { queryClient } from '../../../app/queryClient';
import { withSurveyRedirect } from '../../survey/surveyRequired';

export async function courseLoader({ params }: LoaderFunctionArgs) {
  const courseId = params.courseId!;
  await withSurveyRedirect(() => queryClient.ensureQueryData(courseQuery(courseId)));
  return null;
}
