import { type FormEvent, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { apiFetch } from '../app/api/apiFetch';
import { useAuth } from '../auth/useAuth';
import { migrateGuestProgress } from '../features/progress/guestProgress';
import { completeLesson } from '../features/lessons/api/lessonsApi';

export default function Signup() {
  const { t } = useTranslation();
  const { refresh } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const from =
    typeof location.state === 'object' &&
    location.state !== null &&
    'from' in location.state &&
    typeof (location.state as { from?: { pathname?: string } }).from?.pathname === 'string'
      ? (location.state as { from: { pathname: string } }).from.pathname
      : '/';

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const passwordMismatch = passwordConfirmation.length > 0 && password !== passwordConfirmation;

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (password !== passwordConfirmation) {
      setError(t('auth.passwordsMustMatch'));
      return;
    }
    setError(null);
    setSubmitting(true);
    try {
      await apiFetch('/api/v1/registration', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, password_confirmation: passwordConfirmation }),
      }).then(async (r) => {
        if (!r.ok) {
          const body = await r.json().catch(() => null);
          throw new Error(body?.error || body?.message || `Signup failed: ${r.status}`);
        }
      });

      await migrateGuestProgress((lessonId, courseId) =>
        completeLesson({ lessonId, courseId }),
      );
      await refresh();
      navigate(from, { replace: true });
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : t('auth.signupFailed');
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
            <Typography variant="h4" component="h1" sx={{ mb: 0.75 }}>
              {t('auth.createAccount')}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {t('auth.signupSubtitle')}
            </Typography>
          </Box>

          {error ? <Alert severity="error" role="alert">{error}</Alert> : null}

          <Box component="form" onSubmit={onSubmit}>
            <Stack spacing={2}>
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
                autoComplete="new-password"
                fullWidth
                required
              />

              <TextField
                label={t('auth.confirmPassword')}
                type="password"
                value={passwordConfirmation}
                onChange={(e) => setPasswordConfirmation(e.target.value)}
                autoComplete="new-password"
                fullWidth
                required
                error={passwordMismatch}
                helperText={passwordMismatch ? t('auth.passwordsMustMatch') : undefined}
              />

              <Button type="submit" variant="contained" size="large" disabled={submitting} fullWidth>
                {submitting ? t('auth.creatingAccount') : t('auth.createAccount')}
              </Button>
            </Stack>
          </Box>

          <Typography variant="body2" color="text.secondary">
            {t('auth.alreadyHaveAccount')}{' '}
            <Button component={Link} to="/login" size="small" variant="text" sx={{ p: 0, minWidth: 0 }}>
              {t('auth.login')}
            </Button>
          </Typography>
        </Stack>
      </Paper>
    </Container>
  );
}
