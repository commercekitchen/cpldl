import { type FormEvent, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
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

export default function ResetPassword() {
  const { t } = useTranslation();
  const { refresh } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const token = searchParams.get('reset_password_token') ?? '';

  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const passwordMismatch = passwordConfirmation.length > 0 && password !== passwordConfirmation;

  if (!token) {
    return (
      <Container maxWidth="sm" sx={{ py: { xs: 4, sm: 6 } }}>
        <Alert severity="error" role="alert">
          {t('auth.invalidResetToken')}{' '}
          <Button component={Link} to="/forgot-password" size="small" variant="text" sx={{ p: 0, minWidth: 0 }}>
            {t('auth.forgotPassword')}
          </Button>
        </Alert>
      </Container>
    );
  }

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (password !== passwordConfirmation) {
      setError(t('auth.passwordsMustMatch'));
      return;
    }
    setError(null);
    setSubmitting(true);
    try {
      await apiFetch('/api/v1/password_reset', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          reset_password_token: token,
          password,
          password_confirmation: passwordConfirmation,
        }),
      }).then(async (r) => {
        if (!r.ok) {
          const body = await r.json().catch(() => null);
          throw new Error(body?.message || t('auth.resetError'));
        }
      });
      await refresh();
      navigate('/', { replace: true });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : t('auth.resetError'));
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
              {t('auth.resetPasswordTitle')}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {t('auth.resetPasswordSubtitle')}
            </Typography>
          </Box>

          {error ? <Alert severity="error" role="alert">{error}</Alert> : null}

          <Box component="form" onSubmit={onSubmit}>
            <Stack spacing={2}>
              <TextField
                label={t('auth.newPassword')}
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="new-password"
                fullWidth
                required
                autoFocus
              />

              <TextField
                label={t('auth.confirmNewPassword')}
                type="password"
                value={passwordConfirmation}
                onChange={(e) => setPasswordConfirmation(e.target.value)}
                autoComplete="new-password"
                fullWidth
                required
                error={passwordMismatch}
                helperText={passwordMismatch ? t('auth.passwordsMustMatch') : undefined}
              />

              <Button
                type="submit"
                variant="contained"
                size="large"
                disabled={submitting}
                fullWidth
              >
                {submitting ? t('auth.changingPassword') : t('auth.changePassword')}
              </Button>
            </Stack>
          </Box>

          <Typography variant="body2" color="text.secondary">
            <Button component={Link} to="/login" size="small" variant="text" sx={{ p: 0, minWidth: 0 }}>
              {t('auth.backToLogin')}
            </Button>
          </Typography>
        </Stack>
      </Paper>
    </Container>
  );
}
