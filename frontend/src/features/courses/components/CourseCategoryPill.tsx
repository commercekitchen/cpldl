import Box from '@mui/material/Box';
import { Link as RouterLink } from 'react-router-dom';

type Props = {
  label: string;
  variant?: 'filled' | 'outlined';
};

function toCategorySlug(name: string): string {
  return name
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-');
}

export function CourseCategoryPill({ label, variant = 'filled' }: Props) {
  const slug = toCategorySlug(label);

  return (
    <Box sx={{ mb: 2 }}>
      <Box
        component={RouterLink}
        to={`/courses#category-${slug}`}
        sx={{
          display: 'inline-flex',
          alignItems: 'center',
          px: 1.5,
          py: 0.5,
          borderRadius: 999,
          border: '1.5px solid',
          textDecoration: 'none',
          ...(variant === 'filled'
            ? {
                bgcolor: 'primary.main',
                borderColor: 'primary.main',
                color: 'primary.contrastText',
                '&:hover': { filter: 'brightness(0.9)' },
              }
            : {
                bgcolor: 'transparent',
                borderColor: 'primary.contrastText',
                color: 'primary.contrastText',
                '&:hover': { filter: 'brightness(0.85)' },
              }),
          fontSize: '0.75rem',
          fontWeight: 600,
        }}
      >
        {label}
      </Box>
    </Box>
  );
}
