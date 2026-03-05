import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import MenuItem from '@mui/material/MenuItem';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';
import Link from '@mui/material/Link';
import { type FormEvent, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiFetch } from '../app/api/apiFetch';
import { useAuth } from '../auth/useAuth';

type LanguageOption = { id: number; name: string };
type ProfilePayload = {
  profile: { firstName: string | null; zipCode: string | null; languageId: number | null };
  languages: LanguageOption[];
};
type AccountPayload = {
  account: { email: string | null };
};

export default function Account() {
  const { user, refresh, logout } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [profileSaving, setProfileSaving] = useState(false);
  const [accountSaving, setAccountSaving] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [profileError, setProfileError] = useState<string | null>(null);
  const [profileSuccess, setProfileSuccess] = useState<string | null>(null);
  const [accountError, setAccountError] = useState<string | null>(null);
  const [accountSuccess, setAccountSuccess] = useState<string | null>(null);
  const [languages, setLanguages] = useState<LanguageOption[]>([]);
  const [languageId, setLanguageId] = useState<number | ''>('');
  const [firstName, setFirstName] = useState('');
  const [zipCode, setZipCode] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');

  const onLogout = async () => {
    await logout();
    navigate('/', { replace: true });
  };

  useEffect(() => {
    const loadProfile = async () => {
      setLoading(true);
      setLoadError(null);
      try {
        const [profileRes, accountRes] = await Promise.all([
          apiFetch('/api/v1/profile', { method: 'GET' }),
          apiFetch('/api/v1/account', { method: 'GET' }),
        ]);
        if (!profileRes.ok) throw new Error(`Failed to load profile (${profileRes.status})`);
        if (!accountRes.ok) throw new Error(`Failed to load account (${accountRes.status})`);

        const profileData = (await profileRes.json()) as ProfilePayload;
        const accountData = (await accountRes.json()) as AccountPayload;

        setLanguages(profileData.languages);
        setLanguageId(profileData.profile.languageId ?? '');
        setFirstName(profileData.profile.firstName ?? '');
        setZipCode(profileData.profile.zipCode ?? '');
        setEmail(accountData.account.email ?? '');
      } catch (err: unknown) {
        setLoadError(err instanceof Error ? err.message : 'Failed to load account');
      } finally {
        setLoading(false);
      }
    };

    void loadProfile();
  }, []);

  const onSubmitProfile = async (e: FormEvent) => {
    e.preventDefault();
    setProfileSaving(true);
    setProfileError(null);
    setProfileSuccess(null);
    try {
      const res = await apiFetch('/api/v1/profile', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          profile: {
            language_id: languageId || null,
            first_name: firstName,
            zip_code: zipCode,
          },
        }),
      });

      if (!res.ok) {
        const body = (await res.json().catch(() => null)) as {
          errors?: string[];
          message?: string;
        } | null;
        const message =
          body?.errors?.join(', ') || body?.message || `Failed to save profile (${res.status})`;
        throw new Error(message);
      }

      setProfileSuccess('Profile saved.');
    } catch (err: unknown) {
      setProfileError(err instanceof Error ? err.message : 'Failed to save profile');
    } finally {
      setProfileSaving(false);
    }
  };

  const onSubmitAccount = async (e: FormEvent) => {
    e.preventDefault();
    setAccountSaving(true);
    setAccountError(null);
    setAccountSuccess(null);
    try {
      const res = await apiFetch('/api/v1/account', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          account: {
            email,
            password,
            password_confirmation: passwordConfirmation,
          },
        }),
      });

      if (!res.ok) {
        const body = (await res.json().catch(() => null)) as {
          errors?: string[];
          message?: string;
        } | null;
        const message =
          body?.errors?.join(', ') ||
          body?.message ||
          `Failed to update login information (${res.status})`;
        throw new Error(message);
      }

      setPassword('');
      setPasswordConfirmation('');
      setAccountSuccess('Login information saved.');
      await refresh();
    } catch (err: unknown) {
      setAccountError(err instanceof Error ? err.message : 'Failed to update login information');
    } finally {
      setAccountSaving(false);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ py: 4 }}>
      <Paper
        elevation={0}
        sx={{ p: 3, border: '1px solid', borderColor: 'divider', borderRadius: 2 }}
      >
        <Stack spacing={2}>
          <Typography variant="h4">Account</Typography>
          <Typography variant="body2" color="text.secondary">
            Manage your profile details below.
          </Typography>

          {loading ? <CircularProgress /> : null}
          {user ? (
            <Box>
              <Typography variant="body1">
                Signed in as <strong>{user.email ?? user.phoneNumber ?? 'Unknown User'}</strong>
              </Typography>
              {user.is_org_admin ? (
                <Alert severity="info" sx={{ mt: 2 }}>
                  You are signed in as an organization admin.{' '}
                  <Link href="/admin">Go to Admin Dashboard</Link>
                </Alert>
              ) : null}
            </Box>
          ) : (
            <Alert severity="warning">You are not currently signed in.</Alert>
          )}

          {loadError ? <Alert severity="error">{loadError}</Alert> : null}
          {profileError ? <Alert severity="error">{profileError}</Alert> : null}
          {profileSuccess ? <Alert severity="success">{profileSuccess}</Alert> : null}
          {accountError ? <Alert severity="error">{accountError}</Alert> : null}
          {accountSuccess ? <Alert severity="success">{accountSuccess}</Alert> : null}

          {!loading ? (
            <Box component="form" onSubmit={onSubmitProfile}>
              <Stack spacing={2}>
                <FormControl fullWidth>
                  <InputLabel id="language-label">Preferred Language</InputLabel>
                  <Select
                    labelId="language-label"
                    value={languageId}
                    label="Preferred Language"
                    onChange={(e) => setLanguageId(Number(e.target.value) || '')}
                  >
                    {languages.map((language) => (
                      <MenuItem key={language.id} value={language.id}>
                        {language.name}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>

                <TextField
                  label="First Name"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  fullWidth
                  required
                />

                <TextField
                  label="ZIP Code"
                  value={zipCode}
                  onChange={(e) => setZipCode(e.target.value)}
                  fullWidth
                />

                <Button type="submit" variant="contained" disabled={profileSaving}>
                  {profileSaving ? 'Saving…' : 'Save Profile'}
                </Button>
              </Stack>
            </Box>
          ) : null}
        </Stack>
      </Paper>

      <Paper
        elevation={0}
        sx={{ p: 3, border: '1px solid', borderColor: 'divider', borderRadius: 2, mt: 4 }}
      >
        <Stack spacing={2}>
          {!loading ? (
            <Box component="form" onSubmit={onSubmitAccount}>
              <Stack spacing={2}>
                <Typography variant="h6">Login Information</Typography>
                <TextField
                  label="Email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  type="email"
                  fullWidth
                />
                <TextField
                  label="Password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  type="password"
                  fullWidth
                  helperText="Leave blank to keep your current password."
                />
                <TextField
                  label="Password Confirmation"
                  value={passwordConfirmation}
                  onChange={(e) => setPasswordConfirmation(e.target.value)}
                  type="password"
                  fullWidth
                />

                <Button type="submit" variant="contained" disabled={accountSaving}>
                  {accountSaving ? 'Saving…' : 'Save Login Information'}
                </Button>
              </Stack>
            </Box>
          ) : null}

          <Button
            variant="outlined"
            color="primary"
            onClick={() => void onLogout()}
            sx={{ alignSelf: 'flex-start' }}
          >
            Log Out
          </Button>
        </Stack>
      </Paper>
    </Container>
  );
}
