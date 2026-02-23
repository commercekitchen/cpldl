import {
  NavLink,
  useLoaderData,
  Outlet,
  useMatch,
  useNavigate,
  useLocation,
} from 'react-router-dom';
import {
  ThemeProvider,
  CssBaseline,
  AppBar,
  Toolbar,
  Typography,
  Button,
  Box,
} from '@mui/material';
import { useState } from 'react';
import { createMuiThemeForOrganization } from '../app/organization/theme';
import { useGaPageViews } from '../app/useGaPageViews';
import type { OrganizationConfig } from '../app/organization/types';
import { AccountCircle, AdminPanelSettings, Category, Home } from '@mui/icons-material';
import SearchIcon from '@mui/icons-material/Search';
import { CourseSearchBar } from '../features/search/components/CourseSearchBar';
import { useAuth } from '../auth/useAuth';

type NavButtonProps = {
  to: string;
  label: string;
  end?: boolean;
  icon?: React.ReactNode;
};

function NavButton({ to, label, end = true, icon }: NavButtonProps) {
  const isActive = Boolean(useMatch({ path: to, end }));

  return (
    <Button
      component={NavLink}
      to={to}
      variant="text"
      color="inherit"
      startIcon={icon}
      sx={{
        textTransform: 'none',
        borderBottom: '2px solid transparent',
        borderRadius: 0,
        ...(isActive && { borderBottomColor: 'currentColor' }),
      }}
    >
      {label}
    </Button>
  );
}

export function RootLayout() {
  useGaPageViews();
  const { orgConfig } = useLoaderData() as { orgConfig: OrganizationConfig };
  const { status, user } = useAuth();
  const theme = createMuiThemeForOrganization(orgConfig);
  const navigate = useNavigate();
  const location = useLocation();
  const isSearchPage = location.pathname === '/search';
  const query = new URLSearchParams(location.search).get('q')?.trim() ?? '';

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchDraft, setSearchDraft] = useState('');
  const searchActive = isSearchPage || isSearchOpen;
  const searchValue = isSearchPage ? query : searchDraft;
  const isAuthenticated = status === 'authenticated';
  const isAdmin = Boolean(user?.is_org_admin);

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AppBar
        position="static"
        color="transparent"
        sx={{
          backgroundColor: (theme) => theme.palette.background.default,
          color: (theme) => theme.palette.text.primary,
        }}
        elevation={0}
      >
        <Toolbar sx={{ display: 'flex', justifyContent: 'space-between' }}>
          <Box component={NavLink} to="/" sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            {orgConfig.theme.logoUrl ? (
              <Box
                component="img"
                src={orgConfig.theme.logoUrl}
                alt={`${orgConfig.displayName} logo`}
                sx={{ height: 50, width: 'auto' }}
              />
            ) : (
              <Typography variant="h6">{orgConfig.displayName}</Typography>
            )}
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            {searchActive ? (
              <Box sx={{ width: { xs: 220, sm: 320, md: 420 } }}>
                <CourseSearchBar
                  value={searchValue}
                  onValueChange={setSearchDraft}
                  onSelect={(course) => {
                    setIsSearchOpen(false);
                    setSearchDraft('');
                    navigate(`/courses/${course.id}`);
                  }}
                  onSubmit={(nextQuery) => {
                    const trimmed = nextQuery.trim();
                    if (!trimmed) return;
                    setIsSearchOpen(true);
                    setSearchDraft(trimmed);
                    navigate(`/search?q=${encodeURIComponent(trimmed)}`);
                  }}
                  autoFocus
                  fullWidth
                />
              </Box>
            ) : (
              <Button
                variant="text"
                color="inherit"
                startIcon={<SearchIcon />}
                onClick={() => setIsSearchOpen(true)}
                onFocus={() => setIsSearchOpen(true)}
                sx={{
                  textTransform: 'none',
                  borderBottom: '2px solid transparent',
                  borderRadius: 0,
                }}
                aria-label="Open search"
              >
                Search
              </Button>
            )}
            <NavButton to="/" label="Home" icon={<Home />} />
            <NavButton to="/courses" label="Categories" icon={<Category />} />
            {isAdmin ? (
              <Button
                variant="text"
                color="inherit"
                startIcon={<AdminPanelSettings />}
                onClick={() => window.location.assign('/admin')}
                sx={{
                  textTransform: 'none',
                  borderBottom: '2px solid transparent',
                  borderRadius: 0,
                }}
              >
                Admin Dashboard
              </Button>
            ) : null}
            <NavButton
              to={isAuthenticated ? '/account' : '/login'}
              label={isAuthenticated ? 'Account' : 'User Login (Optional)'}
              icon={<AccountCircle />}
            />
          </Box>
        </Toolbar>
      </AppBar>
      <Outlet />
    </ThemeProvider>
  );
}
