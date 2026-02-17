import type { RouteObject } from 'react-router-dom';
import { CoursesPage } from '../pages/CoursesPage';

export const coursesRoute: RouteObject = {
  path: 'courses',
  element: <CoursesPage />,
};
