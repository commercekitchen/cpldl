import { useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Typography from '@mui/material/Typography';
import Link from '@mui/material/Link';
import { NavLink } from 'react-router-dom';
import CelebrationIcon from '@mui/icons-material/Celebration';

const DISMISSED_KEY = 'announcement_banner_dismissed_v1';

export function AnnouncementBanner() {
  const [dismissed, setDismissed] = useState(() => localStorage.getItem(DISMISSED_KEY) === 'true');

  if (dismissed) return null;

  const handleDismiss = () => {
    localStorage.setItem(DISMISSED_KEY, 'true');
    setDismissed(true);
  };

  return (
    <Box
      role="region"
      aria-label="Site announcement"
      sx={{
        bgcolor: 'secondary.main',
        color: 'secondary.contrastText',
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
      <CelebrationIcon fontSize="small" aria-hidden="true" />
      <Typography variant="body2" component="span">
        Welcome to the NEW DigitalLearn.org!{' '}
        <Link
          component={NavLink}
          to="/redesign"
          color="inherit"
          underline="always"
          sx={{ fontWeight: 700 }}
        >
          Learn more about the new site here.
        </Link>
      </Typography>
      <Button
        size="small"
        onClick={handleDismiss}
        aria-label="Dismiss announcement"
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
