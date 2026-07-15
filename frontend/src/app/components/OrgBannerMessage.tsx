import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';

export function OrgBannerMessage({ message }: { message?: string }) {
  if (!message) return null;

  return (
    <Box
      role="region"
      aria-label="Organization announcement"
      sx={{
        bgcolor: 'primary.main',
        color: 'primary.contrastText',
        px: 2,
        py: 0.75,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        textAlign: 'center',
      }}
    >
      <Typography variant="body2" component="span">
        {message}
      </Typography>
    </Box>
  );
}
