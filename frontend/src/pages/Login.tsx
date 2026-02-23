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
import type { OrganizationConfig } from '../app/organization/types';
import { useAuth } from '../auth/useAuth';

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const rootData = useRouteLoaderData('root') as { orgConfig: OrganizationConfig } | undefined;
  const signUpAllowed = rootData?.orgConfig.features.signUpAllowed !== false;

  const from =
    typeof location.state === 'object' &&
    location.state !== null &&
    'from' in location.state &&
    typeof (location.state as { from?: { pathname?: string } }).from?.pathname === 'string'
      ? (location.state as { from: { pathname: string } }).from.pathname
      : '/';

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const session = await login(email, password);
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
              Log in
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Sign in with your DigitalLearn account to track progress and continue courses.
            </Typography>
          </Box>

          {error ? <Alert severity="error">{error}</Alert> : null}

          <Box component="form" onSubmit={onSubmit}>
            <Stack spacing={2}>
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

              <Button type="submit" variant="contained" size="large" disabled={submitting} fullWidth>
                {submitting ? 'Signing in…' : 'Sign in'}
              </Button>
            </Stack>
          </Box>

          {signUpAllowed ? (
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
