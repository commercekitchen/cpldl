import {
  NavLink,
  Navigate,
  Outlet,
  ScrollRestoration,
  useMatch,
  useNavigate,
  useLocation,
  useRouteLoaderData,
} from 'react-router-dom';
import {
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
import { useGaPageViews } from '../app/useGaPageViews';
import type { OrganizationConfig } from '../app/organization/types';
import { AccountCircle, AdminPanelSettings, Category, Home, Language } from '@mui/icons-material';
import SearchIcon from '@mui/icons-material/Search';
import { CourseSearchBar } from '../features/search/components/CourseSearchBar';
import { useAuth } from '../auth/useAuth';
import { useLocale } from '../app/locale/LocaleContext';
import { useGuestProgress } from '../features/progress/useGuestProgress';

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
      aria-current={isActive ? 'page' : undefined}
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

export function UserLayout() {
  useGaPageViews();
  const { t } = useTranslation();
  const { status, user } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const { orgConfig } = useRouteLoaderData('org') as { orgConfig: OrganizationConfig };

  const isSearchPage = location.pathname === '/search';
  const query = new URLSearchParams(location.search).get('q')?.trim() ?? '';

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchDraft, setSearchDraft] = useState(() => (isSearchPage ? query : ''));
  const [searchFocusSignal, setSearchFocusSignal] = useState(0);
  const searchActive = isSearchPage || isSearchOpen;
  const searchValue = searchDraft;

  const [prevPathname, setPrevPathname] = useState(location.pathname);
  const [prevQuery, setPrevQuery] = useState(query);
  if (prevPathname !== location.pathname) {
    setPrevPathname(location.pathname);
    if (location.pathname !== '/search') {
      setIsSearchOpen(false);
      setSearchDraft('');
      if (prevQuery !== '') setPrevQuery('');
    }
  }
  if (isSearchPage && prevQuery !== query) {
    setPrevQuery(query);
    setSearchDraft(query);
  }

  const isAuthenticated = status === 'authenticated';
  const isAdmin = Boolean(user?.is_org_admin);
  const loginRequired = orgConfig.features?.loginRequired === true;

  const isLessonContentPath = location.pathname.startsWith('/lessons/');
  const shouldRedirectToLogin = loginRequired && status === 'unauthenticated' && isLessonContentPath;

  const loginLabel = isAuthenticated
    ? t('nav.account')
    : loginRequired
      ? t('nav.userLoginRequired')
      : t('nav.userLogin');

  const { count: guestCount, clear: clearGuestProgress } = useGuestProgress();
  const showGuestBanner = status === 'unauthenticated' && guestCount > 0;
  const footerLinks = orgConfig.footerLinks ?? [];
  const isHomeActive = Boolean(useMatch({ path: '/', end: true }));
  const isCategoriesActive = Boolean(useMatch({ path: '/courses', end: true }));

  if (shouldRedirectToLogin) return <Navigate to="/login" replace />;

  const handleSearchBlur = (e: React.FocusEvent) => {
    if (!e.currentTarget.contains(e.relatedTarget as Node) && !searchDraft.trim()) {
      setIsSearchOpen(false);
    }
  };

  const openSearch = () => {
    setIsSearchOpen(true);
    setSearchFocusSignal((value) => value + 1);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        pb: { xs: '88px', md: 0 },
      }}
    >
      <Box
        component="a"
        href="#main-content"
        sx={{
          position: 'absolute',
          top: '-100%',
          left: 8,
          zIndex: 9999,
          px: 2,
          py: 1,
          bgcolor: 'background.paper',
          color: 'text.primary',
          border: '2px solid',
          borderColor: 'primary.main',
          borderRadius: 1,
          fontWeight: 600,
          fontSize: '0.875rem',
          textDecoration: 'none',
          '&:focus': { top: 8 },
        }}
      >
        {t('a11y.skipToMainContent')}
      </Box>
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

          <Box component="nav" aria-label={t('a11y.mainNav')} sx={{ display: { xs: 'none', md: 'flex' }, alignItems: 'center', gap: 2 }}>
            {searchActive ? (
              <Box sx={{ width: { xs: 220, sm: 320, md: 420 } }} onBlur={handleSearchBlur}>
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
                onClick={() => navigate('/admin')}
                sx={{
                  textTransform: 'none',
                  borderBottom: '2px solid transparent',
                  borderRadius: 0,
                }}
              >
                {t('nav.adminDashboard')}
              </Button>
            ) : null}
            {(isAuthenticated || orgConfig.features?.signUpAllowed) && (
              <NavButton
                to={isAuthenticated ? '/account' : '/login'}
                label={loginLabel}
                icon={<AccountCircle />}
              />
            )}
            <LocaleToggle />
          </Box>

          <Box sx={{ display: { xs: 'flex', md: 'none' }, alignItems: 'center', gap: 2 }}>
            <LocaleToggle />
            {(isAuthenticated || orgConfig.features?.signUpAllowed) && (
              <Button
                component={NavLink}
                to={isAuthenticated ? '/account' : '/login'}
                variant="text"
                color="inherit"
                aria-label={loginLabel}
                sx={{ minWidth: 0, p: 0.5 }}
              >
                <AccountCircle />
              </Button>
            )}
          </Box>
        </Toolbar>

        <Box
          sx={{ display: { xs: searchActive ? 'block' : 'none', md: 'none' }, px: 2, pb: 1.5 }}
          onBlur={handleSearchBlur}
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

      {showGuestBanner && (
        <Box
          sx={{
            bgcolor: 'secondary.main',
            color: 'secondary.contrastText',
            px: 2,
            py: 0.75,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexWrap: 'wrap',
            gap: { xs: 0.5, sm: 2 },
            fontSize: '0.8125rem',
          }}
        >
          <Typography variant="inherit" component="span">
            {guestCount} lesson{guestCount !== 1 ? 's' : ''} completed as guest.
          </Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
            <Button
              size="small"
              onClick={clearGuestProgress}
              sx={{
                color: 'inherit',
                textDecoration: 'underline',
                textTransform: 'none',
                p: 0,
                minWidth: 0,
                fontSize: 'inherit',
                fontWeight: 600,
                '&:hover': { textDecoration: 'underline', bgcolor: 'transparent' },
              }}
            >
              Clear Progress
            </Button>
            {orgConfig.features?.signUpAllowed && (
              <Button
                component={NavLink}
                to="/signup"
                size="small"
                sx={{
                  color: 'inherit',
                  textDecoration: 'underline',
                  textTransform: 'none',
                  p: 0,
                  minWidth: 0,
                  fontSize: 'inherit',
                  fontWeight: 600,
                  '&:hover': { textDecoration: 'underline', bgcolor: 'transparent' },
                }}
              >
                Sign Up to Save Progress
              </Button>
            )}
          </Box>
        </Box>
      )}

      <ScrollRestoration />
      <Box component="main" id="main-content" sx={{ flex: 1 }}>
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
          <MuiLink
            href="https://opensource.org/license/mit"
            target="_blank"
            rel="noopener noreferrer"
            color="inherit"
            underline="always"
          >
            Platform License: MIT
          </MuiLink>
          {' | '}
          <MuiLink
            href="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode"
            target="_blank"
            rel="noopener noreferrer"
            color="inherit"
            underline="always"
          >
            Content License: CC BY-NC-SA 4.0
          </MuiLink>
        </Typography>
        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', mb: 2 }}>
          <MuiLink component={NavLink} to="/terms-of-use" color="inherit" underline="always">
            {t('footer.termsOfUse')}
          </MuiLink>
          <MuiLink component={NavLink} to="/privacy-policy" color="inherit" underline="always">
            {t('footer.privacyPolicy')}
          </MuiLink>
        </Box>

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
            p: 2,
          }}
        >
          <Box
            sx={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'flex-start',
              mb: 1.5,
            }}
          >
            <Typography component="h3" variant="h6">
              {t('footer.learnMore')}
            </Typography>
            {orgConfig.trainingSiteLink && (
              <MuiLink
                href={orgConfig.trainingSiteLink}
                target="_blank"
                rel="noopener noreferrer"
                variant="body2"
                underline="hover"
              >
                {t('footer.trainerResources')}
              </MuiLink>
            )}
          </Box>
          {footerLinks.length > 0 ? (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.75 }}>
              {footerLinks.map((link) => (
                <Box key={`${link.title}-${link.url}`}>
                  {link.isInternal ? (
                    <MuiLink component={NavLink} to={link.url}>
                      {link.title}
                    </MuiLink>
                  ) : (
                    <MuiLink
                      href={link.url}
                      target={link.openInNewTab ? '_blank' : undefined}
                      rel={link.openInNewTab ? 'noopener noreferrer' : undefined}
                    >
                      {link.title}
                    </MuiLink>
                  )}
                </Box>
              ))}
            </Box>
          ) : (
            <Typography variant="body2" color="text.secondary">
              {t('footer.linksComingSoon')}
            </Typography>
          )}
          <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 2 }}>
            <MuiLink
              component={NavLink}
              to="/login"
              variant="body2"
              color="text.secondary"
              underline="hover"
            >
              Admin Login
            </MuiLink>
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
          component="nav"
          aria-label={t('a11y.mobileNav')}
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
            aria-current={isHomeActive ? 'page' : undefined}
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
            aria-current={isCategoriesActive ? 'page' : undefined}
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
  );
}
