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
  Link as MuiLink,
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
  const footerLinks = orgConfig.footerLinks ?? [];

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Box sx={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
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

        <Box sx={{ flex: 1 }}>
          <Outlet />
        </Box>

        <Box
          component="footer"
          sx={{
            width: '100%',
            borderRadius: 0,
            py: 4,
            px: 2,
            textAlign: 'center',
            background: (theme) =>
              `linear-gradient(135deg, ${theme.palette.secondary.main} 0%, ${theme.palette.primary.main} 100%)`,
            color: '#fff',
          }}
        >
          <Typography variant="body1" sx={{ mb: 2 }}>
            This work is licensed under an MIT License
          </Typography>

          <Box
            sx={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 3,
              flexWrap: 'wrap',
            }}
          >
            {orgConfig.theme.footerLogoUrl ? (
              orgConfig.theme.footerLogoDestinationUrl ? (
                <MuiLink
                  href={orgConfig.theme.footerLogoDestinationUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  underline="none"
                  sx={{ display: 'inline-flex' }}
                >
                  <Box
                    component="img"
                    src={orgConfig.theme.footerLogoUrl}
                    alt={`${orgConfig.displayName} footer logo`}
                    sx={{ maxHeight: 56, width: 'auto' }}
                  />
                </MuiLink>
              ) : (
                <Box
                  component="img"
                  src={orgConfig.theme.footerLogoUrl}
                  alt={`${orgConfig.displayName} footer logo`}
                  sx={{ maxHeight: 56, width: 'auto' }}
                />
              )
            ) : null}

            {orgConfig.theme.plaFooterLogoUrl ? (
              <MuiLink
                href={orgConfig.theme.plaFooterLogoDestinationUrl || 'http://www.ala.org/pla/'}
                target="_blank"
                rel="noopener noreferrer"
                underline="none"
                sx={{ display: 'inline-flex' }}
              >
                <Box
                  component="img"
                  src={orgConfig.theme.plaFooterLogoUrl}
                  alt="Public Library Association Logo"
                  sx={{ maxHeight: 56, width: 'auto' }}
                />
              </MuiLink>
            ) : (
              <Box
                component="img"
                src="/assets/pla_logo_footer.png"
                alt="Public Library Association Logo"
                sx={{ maxHeight: 56, width: 'auto' }}
              />
            )}
          </Box>
        </Box>

        <Box sx={{ p: 1, backgroundColor: (theme) => theme.palette.background.default }}>
          <Box
            sx={{
              display: 'flex',
              flexDirection: { xs: 'column', md: 'row' },
              gap: 1,
            }}
          >
            <Box
              sx={{
                flex: 1,
                border: '2px solid',
                borderColor: 'primary.main',
                borderRadius: 0,
                p: 2,
              }}
            >
              <Typography component="h3" variant="h6" sx={{ mb: 1.5 }}>
                Learn More
              </Typography>
              {footerLinks.length > 0 ? (
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.75 }}>
                  {footerLinks.map((link) => (
                    <Box key={`${link.title}-${link.url}`}>
                      <MuiLink
                        href={link.url}
                        target={link.openInNewTab ? '_blank' : undefined}
                        rel={link.openInNewTab ? 'noopener noreferrer' : undefined}
                      >
                        {link.title}
                      </MuiLink>
                    </Box>
                  ))}
                </Box>
              ) : (
                <Typography variant="body2" color="text.secondary">
                  Links coming soon.
                </Typography>
              )}
            </Box>

            <Box
              sx={{
                flex: 1,
                border: '2px solid',
                borderColor: 'secondary.main',
                borderRadius: 0,
                p: 2,
              }}
            >
              <Typography component="h3" variant="h6" sx={{ mb: 1.5 }}>
                Get in Touch
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Provide feedback, ask a question, or request additional content. Click the button
                to send us an email.
              </Typography>
              <Button
                variant="outlined"
                color="secondary"
                component="a"
                href="mailto:digitallearnhelp@ala.org"
              >
                Send us an Email
              </Button>
            </Box>
          </Box>
        </Box>
      </Box>
    </ThemeProvider>
  );
}
