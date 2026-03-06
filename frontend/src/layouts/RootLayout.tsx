import {
  NavLink,
  useLoaderData,
  useRevalidator,
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
  Fab,
  Menu,
  MenuItem,
} from '@mui/material';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { createMuiThemeForOrganization } from '../app/organization/theme';
import { useGaPageViews } from '../app/useGaPageViews';
import type { OrganizationConfig } from '../app/organization/types';
import { AccountCircle, AdminPanelSettings, Category, Home, Language } from '@mui/icons-material';
import SearchIcon from '@mui/icons-material/Search';
import { CourseSearchBar } from '../features/search/components/CourseSearchBar';
import { useAuth } from '../auth/useAuth';
import { LocaleProvider } from '../app/locale/LocaleProvider';
import { useLocale } from '../app/locale/LocaleContext';
import { organizationClient } from '../app/organization/organizationClient';

type NavButtonProps = {
  to: string;
  label: string;
  end?: boolean;
  icon?: React.ReactNode;
};

const LOCALES = [
  { code: 'en', label: 'English' },
  { code: 'es', label: 'Español' },
];

function LocaleToggle() {
  const { locale, setLocale } = useLocale();
  const [anchorEl, setAnchorEl] = useState<HTMLElement | null>(null);
  const currentLabel = LOCALES.find((l) => l.code === locale)?.label ?? locale;

  return (
    <>
      <Button
        variant="text"
        color="inherit"
        size="small"
        startIcon={<Language />}
        onClick={(e) => setAnchorEl(e.currentTarget)}
        sx={{ textTransform: 'none', borderRadius: 0, whiteSpace: 'nowrap', px: 0.5 }}
      >
        {currentLabel}
      </Button>
      <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={() => setAnchorEl(null)}>
        {LOCALES.map((l) => (
          <MenuItem
            key={l.code}
            selected={l.code === locale}
            onClick={() => {
              void setLocale(l.code);
              setAnchorEl(null);
            }}
          >
            {l.label}
          </MenuItem>
        ))}
      </Menu>
    </>
  );
}

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
  const { orgConfig, locale } = useLoaderData() as {
    orgConfig: OrganizationConfig;
    locale: string;
  };
  const { revalidate } = useRevalidator();

  const handleAfterLocaleChange = () => {
    organizationClient.clearCache();
    revalidate();
  };

  return (
    <LocaleProvider initialLocale={locale} onAfterChange={handleAfterLocaleChange}>
      <LayoutContent orgConfig={orgConfig} />
    </LocaleProvider>
  );
}

function LayoutContent({ orgConfig }: { orgConfig: OrganizationConfig }) {
  const { t } = useTranslation();
  const { status, user } = useAuth();
  const theme = createMuiThemeForOrganization(orgConfig);
  const navigate = useNavigate();
  const location = useLocation();
  const isSearchPage = location.pathname === '/search';
  const query = new URLSearchParams(location.search).get('q')?.trim() ?? '';

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchDraft, setSearchDraft] = useState('');
  const [searchFocusSignal, setSearchFocusSignal] = useState(0);
  const searchActive = isSearchPage || isSearchOpen;
  const searchValue = isSearchPage ? query : searchDraft;
  const isAuthenticated = status === 'authenticated';
  const isAdmin = Boolean(user?.is_org_admin);
  const footerLinks = orgConfig.footerLinks ?? [];
  const isHomeActive = Boolean(useMatch({ path: '/', end: true }));
  const isCategoriesActive = Boolean(useMatch({ path: '/courses', end: true }));

  const openSearch = () => {
    setIsSearchOpen(true);
    setSearchFocusSignal((value) => value + 1);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          pb: { xs: '88px', md: 0 },
        }}
      >
        <AppBar
          position="static"
          color="transparent"
          sx={{
            backgroundColor: (theme) => theme.palette.background.default,
            color: (theme) => theme.palette.text.primary,
          }}
          elevation={0}
        >
          <Toolbar
            sx={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              minHeight: { xs: 56, md: 72 },
            }}
          >
            <Box component={NavLink} to="/" sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              {orgConfig.theme.logoUrl ? (
                <Box
                  component="img"
                  src={orgConfig.theme.logoUrl}
                  alt={`${orgConfig.displayName} logo`}
                  sx={{ height: { xs: 32, md: 50 }, width: 'auto' }}
                />
              ) : (
                <Typography variant="h6">{orgConfig.displayName}</Typography>
              )}
            </Box>

            <Box sx={{ display: { xs: 'none', md: 'flex' }, alignItems: 'center', gap: 2 }}>
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
                    focusSignal={searchFocusSignal}
                  />
                </Box>
              ) : (
                <Button
                  variant="text"
                  color="inherit"
                  startIcon={<SearchIcon />}
                  onClick={openSearch}
                  onFocus={openSearch}
                  sx={{
                    textTransform: 'none',
                    borderBottom: '2px solid transparent',
                    borderRadius: 0,
                  }}
                  aria-label={t('nav.openSearch')}
                >
                  {t('nav.search')}
                </Button>
              )}
              <NavButton to="/" label={t('nav.home')} icon={<Home />} />
              <NavButton to="/courses" label={t('nav.categories')} icon={<Category />} />
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
                  {t('nav.adminDashboard')}
                </Button>
              ) : null}
              <NavButton
                to={isAuthenticated ? '/account' : '/login'}
                label={isAuthenticated ? t('nav.account') : t('nav.userLogin')}
                icon={<AccountCircle />}
              />
              <LocaleToggle />
            </Box>

            <Box sx={{ display: { xs: 'flex', md: 'none' }, alignItems: 'center', gap: 2 }}>
              <LocaleToggle />
              <Button
                component={NavLink}
                to={isAuthenticated ? '/account' : '/login'}
                variant="text"
                color="inherit"
                sx={{ minWidth: 0, p: 0.5 }}
              >
                <AccountCircle />
              </Button>
            </Box>
          </Toolbar>

          <Box
            sx={{ display: { xs: searchActive ? 'block' : 'none', md: 'none' }, px: 2, pb: 1.5 }}
          >
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
              focusSignal={searchFocusSignal}
            />
          </Box>
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
            {t('footer.license')}
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
                {t('footer.learnMore')}
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
                  {t('footer.linksComingSoon')}
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
                {t('footer.getInTouch')}
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                {t('footer.feedbackText')}
              </Typography>
              <Button
                variant="outlined"
                color="secondary"
                component="a"
                href="mailto:digitallearnhelp@ala.org"
              >
                {t('footer.sendEmail')}
              </Button>
            </Box>
          </Box>
        </Box>

        <Box
          sx={{
            display: { xs: 'block', md: 'none' },
            position: 'fixed',
            left: 0,
            right: 0,
            bottom: 0,
            zIndex: (theme) => theme.zIndex.appBar + 1,
          }}
        >
          <Box
            sx={{
              position: 'relative',
              borderTop: '1px solid',
              borderColor: 'divider',
              backgroundColor: 'background.paper',
              px: 2,
              pt: 1,
              pb: 'calc(8px + env(safe-area-inset-bottom))',
              display: 'flex',
              alignItems: 'flex-end',
              justifyContent: 'space-between',
            }}
          >
            <Button
              component={NavLink}
              to="/"
              variant="text"
              color={isHomeActive ? 'primary' : 'inherit'}
              sx={{
                textTransform: 'none',
                minWidth: 120,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                lineHeight: 1.1,
                gap: 0.25,
                '& .MuiSvgIcon-root': { fontSize: 28 },
              }}
            >
              <Home />
              {t('nav.home')}
            </Button>

            <Fab
              color="primary"
              aria-label={t('nav.openSearch')}
              onClick={openSearch}
              sx={{
                position: 'absolute',
                left: '50%',
                top: 0,
                transform: 'translate(-50%, -45%)',
              }}
            >
              <SearchIcon />
            </Fab>

            <Button
              component={NavLink}
              to="/courses"
              variant="text"
              color={isCategoriesActive ? 'primary' : 'inherit'}
              sx={{
                textTransform: 'none',
                minWidth: 120,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                lineHeight: 1.1,
                gap: 0.25,
                '& .MuiSvgIcon-root': { fontSize: 28 },
              }}
            >
              <Category />
              {t('nav.categories')}
            </Button>
          </Box>
        </Box>
      </Box>
    </ThemeProvider>
  );
}
