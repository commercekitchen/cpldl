import Box from '@mui/material/Box';

type Props = {
  label: string;
  variant?: 'filled' | 'outlined';
};

export function CourseCategoryPill({ label, variant = 'filled' }: Props) {
  return (
    <Box sx={{ mb: 2 }}>
      <Box
        component="span"
        sx={{
          display: 'inline-flex',
          alignItems: 'center',
          px: 1.5,
          py: 0.5,
          borderRadius: 999,
          border: '1.5px solid',
          ...(variant === 'filled'
            ? {
                bgcolor: 'primary.main',
                borderColor: 'primary.main',
                color: 'primary.contrastText',
              }
            : {
                bgcolor: 'transparent',
                borderColor: 'primary.contrastText',
                color: 'primary.contrastText',
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
