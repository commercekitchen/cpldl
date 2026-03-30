import { type FormEvent, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
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

export default function Login() {
  const { t } = useTranslation();
  const { login, loginWithPhone } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const rootData = useRouteLoaderData('root') as { orgConfig: OrganizationConfig } | undefined;
  const signUpAllowed = rootData?.orgConfig.features.signUpAllowed !== false;
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
      const session = usePhoneLogin
        ? await loginWithPhone(phone)
        : await login(email, password);
      if (session?.redirect_to) {
        window.location.assign(session.redirect_to);
        return;
      }
      if (session?.is_org_admin) {
        window.location.assign('/admin');
        return;
      }
      navigate(from, { replace: true });
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Login failed';
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
          background:
            'linear-gradient(180deg, rgba(255,255,255,1) 0%, rgba(249,250,251,1) 100%)',
        }}
      >
        <Stack spacing={2.5}>
          <Box>
            <Typography variant="h4" sx={{ mb: 0.75 }}>
              {usePhoneLogin ? 'Continue with Phone Number' : 'Log in'}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {usePhoneLogin
                ? 'Enter your phone number to continue and track your course progress.'
                : 'Sign in with your DigitalLearn account to track progress and continue courses.'}
            </Typography>
          </Box>

          {error ? <Alert severity="error">{error}</Alert> : null}

          <Box component="form" onSubmit={onSubmit}>
            <Stack spacing={2}>
              {usePhoneLogin ? (
                <TextField
                  label="Phone Number"
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  autoComplete="tel"
                  fullWidth
                  required
                  helperText="Numbers only are fine; formatting will be ignored."
                />
              ) : (
                <>
                  <TextField
                    label="Email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    autoComplete="email"
                    fullWidth
                    required
                  />

                  <TextField
                    label="Password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    autoComplete="current-password"
                    fullWidth
                    required
                  />
                </>
              )}

              <Button type="submit" variant="contained" size="large" disabled={submitting} fullWidth>
                {submitting ? 'Signing in…' : usePhoneLogin ? 'Continue' : 'Sign in'}
              </Button>

              {!usePhoneLogin ? (
                <Typography variant="body2" color="text.secondary" sx={{ textAlign: 'right' }}>
                  <Button component={Link} to="/forgot-password" size="small" variant="text" sx={{ p: 0, minWidth: 0 }}>
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
              <Box component="span">{usePhoneLogin ? 'Organization admin?' : 'Not an admin?'}</Box>
              <Button
                size="small"
                variant="text"
                sx={{ p: 0, minWidth: 0 }}
                onClick={() => {
                  setError(null);
                  setShowAdminLogin((v) => !v);
                }}
              >
                {usePhoneLogin ? 'Log in as admin' : 'Use phone number instead'}
              </Button>
            </Typography>
          ) : null}

          {signUpAllowed && !usePhoneLogin ? (
            <Typography variant="body2" color="text.secondary">
              No account?{' '}
              <Button component={Link} to="/signup" size="small" variant="text" sx={{ p: 0, minWidth: 0 }}>
                Create one
              </Button>
            </Typography>
          ) : null}
        </Stack>
      </Paper>
    </Container>
  );
}
