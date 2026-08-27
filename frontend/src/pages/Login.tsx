import { type FormEvent, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { usePageMetadata } from '../app/metadata/usePageMetadata';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useRouteLoaderData } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import type { OrganizationConfig } from '../app/organization/types';
import { useAuth } from '../auth/useAuth';
import { migrateGuestProgress } from '../features/progress/guestProgress';
import { completeLesson } from '../features/lessons/api/lessonsApi';

export default function Login() {
  const { t } = useTranslation();
  usePageMetadata({ title: 'Sign In' });
  const { login, loginWithPhone } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const rootData = useRouteLoaderData('org') as { orgConfig: OrganizationConfig } | undefined;
  const phoneNumberSignIn = rootData?.orgConfig.features.phoneNumberSignIn === true;
  const [showAdminLogin, setShowAdminLogin] = useState(false);
  const usePhoneLogin = phoneNumberSignIn && !showAdminLogin;

  const from =
    typeof location.state === 'object' &&
    location.state !== null &&
    'from' in location.state &&
    typeof (location.state as { from?: { pathname?: string } }).from?.pathname === 'string'
      ? (location.state as { from: { pathname: string } }).from.pathname
      : '/';

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [phone, setPhone] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const session = usePhoneLogin ? await loginWithPhone(phone) : await login(email, password);

      // A guest may have completed lessons before logging into an existing
      // account (as opposed to signing up fresh) — carry that progress over.
      await migrateGuestProgress((lessonId, courseId) => completeLesson({ lessonId, courseId }));

      if (session?.redirect_to) {
        const target = session.redirect_to;
        if (
          target.startsWith('http://') ||
          target.startsWith('https://') ||
          target.startsWith('/oauth')
        ) {
          window.location.assign(target);
        } else {
          navigate(target, { replace: true });
        }
        return;
      }
      if (session?.is_org_admin) {
        navigate('/admin', { replace: true });
        return;
      }
      navigate(from, { replace: true });
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : t('auth.loginFailed');
      setError(message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ py: { xs: 4, sm: 6 } }}>
      <Paper
        elevation={0}
        sx={{
          p: { xs: 3, sm: 4 },
          border: '1px solid',
          borderColor: 'divider',
          borderRadius: 3,
          background: 'linear-gradient(180deg, rgba(255,255,255,1) 0%, rgba(249,250,251,1) 100%)',
        }}
      >
        <Stack spacing={2.5}>
          <Box>
            <Typography variant="h4" component="h1" sx={{ mb: 0.75 }}>
              {usePhoneLogin ? t('auth.continueWithPhone') : t('auth.login')}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {usePhoneLogin ? t('auth.continueWithPhoneSubtitle') : t('auth.loginSubtitle')}
            </Typography>
          </Box>

          {error ? (
            <Alert severity="error" role="alert">
              {error}
            </Alert>
          ) : null}

          <Box component="form" onSubmit={onSubmit}>
            <Stack spacing={2}>
              {usePhoneLogin ? (
                <TextField
                  label={t('auth.phoneNumber')}
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  autoComplete="tel"
                  fullWidth
                  required
                  helperText={t('auth.phoneNumberHelperText')}
                />
              ) : (
                <>
                  <TextField
                    label={t('auth.email')}
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    autoComplete="email"
                    fullWidth
                    required
                  />

                  <TextField
                    label={t('auth.password')}
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    autoComplete="current-password"
                    fullWidth
                    required
                  />
                </>
              )}

              <Button
                type="submit"
                variant="contained"
                size="large"
                disabled={submitting}
                fullWidth
              >
                {submitting ? t('auth.signingIn') : usePhoneLogin ? t('auth.continue') : t('auth.signIn')}
              </Button>

              {!usePhoneLogin ? (
                <Typography variant="body2" color="text.secondary" sx={{ textAlign: 'right' }}>
                  <Button
                    component={Link}
                    to="/forgot-password"
                    size="small"
                    variant="text"
                    sx={{ p: 0, minWidth: 0 }}
                  >
                    {t('auth.forgotPassword')}
                  </Button>
                </Typography>
              ) : null}
            </Stack>
          </Box>

          {phoneNumberSignIn ? (
            <Typography
              component="div"
              variant="body2"
              color="text.secondary"
              sx={{ display: 'flex', alignItems: 'center', gap: 0.75 }}
            >
              <Box component="span">{usePhoneLogin ? t('auth.organizationAdmin') : t('auth.notAnAdmin')}</Box>
              <Button
                size="small"
                variant="text"
                sx={{ p: 0, minWidth: 0 }}
                onClick={() => {
                  setError(null);
                  setShowAdminLogin((v) => !v);
                }}
              >
                {usePhoneLogin ? t('auth.logInAsAdmin') : t('auth.usePhoneInstead')}
              </Button>
            </Typography>
          ) : null}

          {!usePhoneLogin ? (
            <Typography
              component="div"
              variant="body2"
              color="text.secondary"
              sx={{ display: 'flex', alignItems: 'center', gap: 0.75 }}
            >
              <Box component="span">{t('auth.noAccount')}</Box>
              <Button
                component={Link}
                to="/signup"
                size="small"
                variant="text"
                sx={{ p: 0, minWidth: 0 }}
              >
                {t('auth.createOne')}
              </Button>
            </Typography>
          ) : null}
        </Stack>
      </Paper>
    </Container>
  );
}
