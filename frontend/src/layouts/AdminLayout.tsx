import { NavLink, Navigate, Outlet, useNavigate, useRouteLoaderData } from 'react-router-dom';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Divider from '@mui/material/Divider';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';
import BarChartIcon from '@mui/icons-material/BarChart';
import CollectionsBookmarkIcon from '@mui/icons-material/CollectionsBookmark';
import PeopleIcon from '@mui/icons-material/People';
import SchoolIcon from '@mui/icons-material/School';
import LabelIcon from '@mui/icons-material/Label';
import SettingsIcon from '@mui/icons-material/Settings';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../auth/useAuth';
import type { OrganizationConfig } from '../app/organization/types';

const DRAWER_WIDTH = 240;

export function AdminLayout() {
  const { t } = useTranslation();
  const { status, user } = useAuth();
  const navigate = useNavigate();
  const { orgConfig } = useRouteLoaderData('org') as { orgConfig: OrganizationConfig };
  const isAuthenticated = status === 'authenticated';

  const navItems = [
    { key: 'reports', path: '/admin/reports', icon: <BarChartIcon /> },
    { key: 'courses', path: '/admin/courses', icon: <SchoolIcon /> },
    ...(!orgConfig.mainSite
      ? [{ key: 'plaCatalog', path: '/admin/pla-catalog', icon: <CollectionsBookmarkIcon /> }]
      : []),
    { key: 'categories', path: '/admin/categories', icon: <LabelIcon /> },
    { key: 'users', path: '/admin/users', icon: <PeopleIcon /> },
    { key: 'settings', path: '/admin/settings', icon: <SettingsIcon /> },
  ];

  if (status === 'loading') {
    return (
      <Box
        sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}
      >
        <CircularProgress />
      </Box>
    );
  }

  if (status === 'unauthenticated' || !user?.is_org_admin) {
    return <Navigate to="/" replace />;
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <AppBar
        position="static"
        color="transparent"
        elevation={0}
        sx={{
          backgroundColor: (theme) => theme.palette.background.default,
          color: (theme) => theme.palette.text.primary,
          borderBottom: '1px solid',
          borderColor: 'divider',
          zIndex: (theme) => theme.zIndex.drawer + 1,
        }}
      >
        <Toolbar sx={{ minHeight: { xs: 56, md: 64 } }}>
          <Box sx={{ flex: 1, display: 'flex', alignItems: 'center' }}>
            <Box
              component={NavLink}
              to="/"
              sx={{ display: 'flex', alignItems: 'center', gap: 2, textDecoration: 'none' }}
            >
              {orgConfig.theme.logoUrl ? (
                <Box
                  component="img"
                  src={orgConfig.theme.logoUrl}
                  alt={`${orgConfig.displayName} logo`}
                  sx={{ height: { xs: 32, md: 40 }, width: 'auto' }}
                />
              ) : (
                <Typography variant="h6" color="text.primary">
                  {orgConfig.displayName}
                </Typography>
              )}
            </Box>
          </Box>

          <Typography
            variant="h6"
            fontWeight={600}
            sx={{ position: 'absolute', left: '50%', transform: 'translateX(-50%)' }}
          >
            {t('nav.adminDashboard')}
          </Typography>

          <Box sx={{ flex: 1, display: 'flex', justifyContent: 'flex-end' }}>
            <Button
              component={NavLink}
              to={isAuthenticated ? '/account' : '/login'}
              variant="text"
              color="inherit"
              startIcon={<AccountCircleIcon />}
              sx={{ textTransform: 'none' }}
            >
              {isAuthenticated ? t('nav.account') : t('nav.userLogin')}
            </Button>
          </Box>
        </Toolbar>
      </AppBar>

      <Box sx={{ display: 'flex', flex: 1 }}>
        <Drawer
          variant="permanent"
          sx={{
            width: DRAWER_WIDTH,
            flexShrink: 0,
            '& .MuiDrawer-paper': {
              width: DRAWER_WIDTH,
              boxSizing: 'border-box',
              display: 'flex',
              flexDirection: 'column',
              position: 'relative',
            },
          }}
        >
          <List sx={{ flex: 1, pt: 1 }}>
            {navItems.map(({ key, path, icon }) => (
              <ListItem key={key} disablePadding>
                <ListItemButton
                  component={NavLink}
                  to={path}
                  sx={{
                    borderRadius: 1,
                    mx: 0.5,
                    '&.active': {
                      backgroundColor: 'action.selected',
                      fontWeight: 700,
                    },
                  }}
                >
                  <ListItemIcon sx={{ minWidth: 36 }}>{icon}</ListItemIcon>
                  <ListItemText primary={t(`admin.${key}`)} />
                </ListItemButton>
              </ListItem>
            ))}
          </List>

          <Divider />

          <List>
            <ListItem disablePadding>
              <ListItemButton onClick={() => navigate('/')} sx={{ borderRadius: 1, mx: 0.5 }}>
                <ListItemIcon sx={{ minWidth: 36 }}>
                  <ArrowBackIcon />
                </ListItemIcon>
                <ListItemText primary={t('admin.backToSite')} />
              </ListItemButton>
            </ListItem>
          </List>
        </Drawer>

        <Box component="main" sx={{ flex: 1, p: 3, minWidth: 0 }}>
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
}
