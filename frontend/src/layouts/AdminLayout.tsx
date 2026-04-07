import { NavLink, Navigate, Outlet, useNavigate } from 'react-router-dom';
import Box from '@mui/material/Box';
import Divider from '@mui/material/Divider';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';
import BarChartIcon from '@mui/icons-material/BarChart';
import PeopleIcon from '@mui/icons-material/People';
import SchoolIcon from '@mui/icons-material/School';
import SettingsIcon from '@mui/icons-material/Settings';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../auth/useAuth';

const DRAWER_WIDTH = 240;

const NAV_ITEMS = [
  { key: 'reports', path: '/admin/reports', icon: <BarChartIcon /> },
  { key: 'courses', path: '/admin/courses', icon: <SchoolIcon /> },
  { key: 'users', path: '/admin/users', icon: <PeopleIcon /> },
  { key: 'settings', path: '/admin/settings', icon: <SettingsIcon /> },
] as const;

export function AdminLayout() {
  const { t } = useTranslation();
  const { status, user } = useAuth();
  const navigate = useNavigate();

  if (status === 'loading') {
    return (
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  if (status === 'unauthenticated' || !user?.is_org_admin) {
    return <Navigate to="/" replace />;
  }

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
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
          },
        }}
      >
        <Box sx={{ px: 2, py: 2.5 }}>
          <Typography variant="h6" fontWeight={700} noWrap>
            Admin
          </Typography>
        </Box>

        <Divider />

        <List sx={{ flex: 1, pt: 1 }}>
          {NAV_ITEMS.map(({ key, path, icon }) => (
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
            <ListItemButton
              onClick={() => navigate('/')}
              sx={{ borderRadius: 1, mx: 0.5 }}
            >
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
  );
}
