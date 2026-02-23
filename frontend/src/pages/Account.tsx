import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/useAuth';

export default function Account() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const onLogout = async () => {
    await logout();
    navigate('/', { replace: true });
  };

  return (
    <Container maxWidth="sm" sx={{ py: 4 }}>
      <Paper elevation={0} sx={{ p: 3, border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
        <Stack spacing={2}>
          <Typography variant="h4">Account</Typography>
          <Typography variant="body2" color="text.secondary">
            This is a stub account page. We can expand profile editing here next.
          </Typography>

          {user ? (
            <Box>
              <Typography variant="body1">
                Signed in as <strong>{user.email ?? user.phoneNumber ?? 'Unknown User'}</strong>
              </Typography>
              {user.is_org_admin ? (
                <Alert severity="info" sx={{ mt: 2 }}>
                  You are signed in as an organization admin.
                </Alert>
              ) : null}
            </Box>
          ) : (
            <Alert severity="warning">You are not currently signed in.</Alert>
          )}

          <Button variant="outlined" color="primary" onClick={() => void onLogout()} sx={{ alignSelf: 'flex-start' }}>
            Log Out
          </Button>
        </Stack>
      </Paper>
    </Container>
  );
}
