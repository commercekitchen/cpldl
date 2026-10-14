import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';

export function PageLoader() {
  return (
    <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', py: 6, width: '100%' }}>
      <CircularProgress />
    </Box>
  );
}
