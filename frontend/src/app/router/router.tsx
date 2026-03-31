import { createBrowserRouter } from 'react-router-dom';
import { rootLoader } from './loaders';
import { RootLayout } from '../../layouts/RootLayout';
import Home from '../../pages/Home';
import Search from '../../pages/Search';
import Login from '../../pages/Login';
import Account from '../../pages/Account';
import CourseRecommendationSurvey from '../../pages/CourseRecommendationSurvey';
import { lessonRoute } from '../../features/lessons/routes/lessonRoute';
import { courseRoute } from '../../features/courses/routes/courseRoute';
import { coursesRoute } from '../../features/courses/routes/coursesRoute';
import { CourseCompletedPage } from '../../features/courses/pages/CourseCompletedPage';
import Signup from '../../pages/Signup';
import ForgotPassword from '../../pages/ForgotPassword';
import ResetPassword from '../../pages/ResetPassword';

export function createAppRouter() {
  const basename = '/';

  return createBrowserRouter(
    [
      {
        id: 'root',
        path: '/',
        loader: rootLoader,
        element: <RootLayout />,
        children: [
          { index: true, element: <Home /> },
          { path: 'search', element: <Search /> },
          { path: 'login', element: <Login /> },
          { path: 'signup', element: <Signup /> },
          { path: 'forgot-password', element: <ForgotPassword /> },
          { path: 'reset-password', element: <ResetPassword /> },
          { path: 'account', element: <Account /> },
          { path: 'survey', element: <CourseRecommendationSurvey /> },
          { path: 'courses/:courseId/completed', element: <CourseCompletedPage /> },
          lessonRoute,
          coursesRoute,
          courseRoute,
          // { path: "courses", element: <Courses /> },
          // { path: "sign-in", element: <SignIn /> },
        ],
      },
    ],
    { basename },
  );
}
