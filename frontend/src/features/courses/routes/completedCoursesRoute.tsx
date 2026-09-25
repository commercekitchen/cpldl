import type { RouteObject } from 'react-router-dom';
import { CompletedCoursesPage } from '../pages/CompletedCoursesPage';

export const completedCoursesRoute: RouteObject = {
  path: 'completed-courses',
  element: <CompletedCoursesPage />,
};
