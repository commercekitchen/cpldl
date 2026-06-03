import { createBrowserRouter, Navigate } from 'react-router-dom';
import { rootLoader } from './loaders';
import { OrgConfigLayout } from '../../layouts/OrgConfigLayout';
import { UserLayout } from '../../layouts/UserLayout';
import { AdminLayout } from '../../layouts/AdminLayout';
import Home from '../../pages/Home';
import Search from '../../pages/Search';
import Login from '../../pages/Login';
import Account from '../../pages/Account';
import CourseRecommendationSurvey from '../../pages/CourseRecommendationSurvey';
import AdminReports from '../../pages/admin/Reports';
import AdminCourses from '../../pages/admin/Courses';
import AdminEditCourse from '../../pages/admin/EditCourse';
import AdminEditLesson from '../../pages/admin/EditLesson';
import AdminPlaCatalog from '../../pages/admin/PlaCatalog';
import AdminUsers from '../../pages/admin/Users';
import AdminSettings from '../../pages/admin/Settings';
import { lessonRoute } from '../../features/lessons/routes/lessonRoute';
import { courseRoute } from '../../features/courses/routes/courseRoute';
import { coursesRoute } from '../../features/courses/routes/coursesRoute';
import { CourseCompletedPage } from '../../features/courses/pages/CourseCompletedPage';
import Signup from '../../pages/Signup';
import ForgotPassword from '../../pages/ForgotPassword';
import ResetPassword from '../../pages/ResetPassword';
import TermsOfUse from '../../pages/TermsOfUse';
import PrivacyPolicy from '../../pages/PrivacyPolicy';

export function createAppRouter() {
  const basename = '/';

  return createBrowserRouter(
    [
      {
        id: 'org',
        path: '/',
        loader: rootLoader,
        element: <OrgConfigLayout />,
        children: [
          {
            path: 'admin',
            element: <AdminLayout />,
            children: [
              { index: true, element: <Navigate to="/admin/courses" replace /> },
              { path: 'reports', element: <AdminReports /> },
              { path: 'courses', element: <AdminCourses /> },
              { path: 'courses/:courseId/edit', element: <AdminEditCourse /> },
              { path: 'courses/:courseId/lessons/:lessonId/edit', element: <AdminEditLesson /> },
              { path: 'pla-catalog', element: <AdminPlaCatalog /> },
              { path: 'users', element: <AdminUsers /> },
              { path: 'settings', element: <AdminSettings /> },
            ],
          },
          {
            element: <UserLayout />,
            children: [
              { index: true, element: <Home /> },
              { path: 'search', element: <Search /> },
              { path: 'login', element: <Login /> },
              { path: 'signup', element: <Signup /> },
              { path: 'forgot-password', element: <ForgotPassword /> },
              { path: 'reset-password', element: <ResetPassword /> },
              { path: 'account', element: <Account /> },
              { path: 'survey', element: <CourseRecommendationSurvey /> },
              { path: 'terms-of-use', element: <TermsOfUse /> },
              { path: 'privacy-policy', element: <PrivacyPolicy /> },
              { path: 'courses/:courseId/completed', element: <CourseCompletedPage /> },
              lessonRoute,
              coursesRoute,
              courseRoute,
            ],
          },
        ],
      },
    ],
    { basename },
  );
}
