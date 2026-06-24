import { useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Typography from '@mui/material/Typography';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';

const DISMISSED_KEY = 'staging_banner_dismissed_v1';

function isStagingHost(): boolean {
  return window.location.hostname.toLowerCase().includes('staging');
}

export function StagingBanner() {
  const [dismissed, setDismissed] = useState(
    () => sessionStorage.getItem(DISMISSED_KEY) === 'true',
  );

  if (!isStagingHost() || dismissed) return null;

  const handleDismiss = () => {
    sessionStorage.setItem(DISMISSED_KEY, 'true');
    setDismissed(true);
  };

  return (
    <Box
      role="status"
      sx={{
        bgcolor: 'warning.main',
        color: 'warning.contrastText',
        px: 2,
        py: 0.75,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 1,
        flexWrap: 'wrap',
        position: 'relative',
      }}
    >
      <WarningAmberIcon fontSize="small" aria-hidden="true" />
      <Typography variant="body2" component="span" fontWeight={600}>
        Staging environment. Changes made here are not mirrored in Production.
      </Typography>
      <Button
        size="small"
        onClick={handleDismiss}
        aria-label="Dismiss staging notice"
        sx={{
          color: 'inherit',
          minWidth: 0,
          p: '2px 6px',
          fontWeight: 700,
          fontSize: '1.1rem',
          lineHeight: 1,
          ml: 0.5,
          '&:hover': { bgcolor: 'rgba(0,0,0,0.12)' },
        }}
      >
        ×
      </Button>
    </Box>
  );
}
