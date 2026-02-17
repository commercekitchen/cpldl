import Box from '@mui/material/Box';

type Props = {
  label: string;
};

export function CourseCategoryPill({ label }: Props) {
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
          bgcolor: 'primary.main',
          color: 'primary.contrastText',
          fontSize: '0.75rem',
          fontWeight: 600,
        }}
      >
        {label}
      </Box>
    </Box>
  );
}
