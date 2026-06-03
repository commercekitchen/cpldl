import type { RouteObject } from 'react-router-dom';
import { lessonLoader } from './lessonLoader';
import { LessonPlayerPage } from '../pages/LessonPlayerPage';
import { LessonErrorPage } from '../pages/LessonErrorPage';

export const lessonRoute: RouteObject = {
  path: 'lessons/:lessonId',
  loader: lessonLoader,
  element: <LessonPlayerPage />,
  errorElement: <LessonErrorPage />,
};
