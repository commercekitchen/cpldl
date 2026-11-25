import { createBrowserRouter, Navigate } from 'react-router-dom';
import { rootLoader } from './loaders';
import { OrgConfigLayout } from '../../layouts/OrgConfigLayout';
import { UserLayout } from '../../layouts/UserLayout';
import Home from '../../pages/Home';
import Search from '../../pages/Search';
import Login from '../../pages/Login';
import Account from '../../pages/Account';
import CourseRecommendationSurvey from '../../pages/CourseRecommendationSurvey';
import { lessonRoute } from '../../features/lessons/routes/lessonRoute';
import { courseRoute } from '../../features/courses/routes/courseRoute';
import { coursesRoute } from '../../features/courses/routes/coursesRoute';
import { completedCoursesRoute } from '../../features/courses/routes/completedCoursesRoute';
import { CourseCompletedPage } from '../../features/courses/pages/CourseCompletedPage';
import Signup from '../../pages/Signup';
import ForgotPassword from '../../pages/ForgotPassword';
import ResetPassword from '../../pages/ResetPassword';
import AcceptInvitation from '../../pages/AcceptInvitation';
import TermsOfUse from '../../pages/TermsOfUse';
import PrivacyPolicy from '../../pages/PrivacyPolicy';
import CmsPage from '../../pages/CmsPage';

// Admin pages (rich text editor, drag-and-drop) and the static redesign page
// are code-split so learners don't download them on first load.
const lazyPage = (load: () => Promise<{ default: React.ComponentType }>) => async () => ({
  Component: (await load()).default,
});

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
            lazy: async () => ({
              Component: (await import('../../layouts/AdminLayout')).AdminLayout,
            }),
            children: [
              { index: true, element: <Navigate to="/admin/courses" replace /> },
              { path: 'reports', lazy: lazyPage(() => import('../../pages/admin/Reports')) },
              { path: 'courses', lazy: lazyPage(() => import('../../pages/admin/Courses')) },
              { path: 'courses/new', lazy: lazyPage(() => import('../../pages/admin/NewCourse')) },
              { path: 'courses/:courseId/edit', lazy: lazyPage(() => import('../../pages/admin/EditCourse')) },
              { path: 'courses/:courseId/lessons/:lessonId/edit', lazy: lazyPage(() => import('../../pages/admin/EditLesson')) },
              { path: 'pla-catalog', lazy: lazyPage(() => import('../../pages/admin/PlaCatalog')) },
              { path: 'users', lazy: lazyPage(() => import('../../pages/admin/Users')) },
              { path: 'settings', lazy: lazyPage(() => import('../../pages/admin/Settings')) },
              { path: 'categories', lazy: lazyPage(() => import('../../pages/admin/Categories')) },
              { path: 'cms_pages', lazy: lazyPage(() => import('../../pages/admin/CmsPages')) },
              { path: 'cms_pages/new', lazy: lazyPage(() => import('../../pages/admin/NewCmsPage')) },
              { path: 'cms_pages/:pageId/edit', lazy: lazyPage(() => import('../../pages/admin/EditCmsPage')) },
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
              { path: 'accept-invitation', element: <AcceptInvitation /> },
              { path: 'account', element: <Account /> },
              { path: 'survey', element: <CourseRecommendationSurvey /> },
              { path: 'terms-of-use', element: <TermsOfUse /> },
              { path: 'privacy-policy', element: <PrivacyPolicy /> },
              { path: 'redesign', lazy: lazyPage(() => import('../../pages/Redesign')) },
              { path: 'courses/:courseId/completed', element: <CourseCompletedPage /> },
              { path: 'cms_pages/:slug', element: <CmsPage /> },
              lessonRoute,
              completedCoursesRoute,
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
