import Box from '@mui/material/Box';

export function CourseCompletedBadge() {
  return (
    <Box
      component="span"
      sx={{
        display: 'inline-flex',
        alignItems: 'center',
        px: 1.5,
        py: 0.5,
        borderRadius: '999px',
        border: '1.5px solid',
        borderColor: 'success.main',
        color: 'success.main',
        bgcolor: 'success.50',
        fontSize: '0.75rem',
        fontWeight: 600,
        letterSpacing: 0.4,
        whiteSpace: 'nowrap',
        lineHeight: 1.5,
      }}
    >
      Completed
    </Box>
  );
}
