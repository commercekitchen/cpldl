import type { RouteObject } from 'react-router-dom';
import { CoursePage } from '../pages/CoursePage';
import { CourseErrorPage } from '../pages/CourseErrorPage';
import { courseLoader } from './courseLoader';

export const courseRoute: RouteObject = {
  path: 'courses/:courseId',
  loader: courseLoader,
  element: <CoursePage />,
  errorElement: <CourseErrorPage />,
};
