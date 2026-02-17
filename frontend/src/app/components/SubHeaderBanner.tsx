import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';

type Props = {
  text: string;
};

export function SubHeaderBanner({ text }: Props) {
  return (
    <Box
      sx={{
        backgroundColor: (theme) => theme.palette.primary.main,
        color: (theme) => theme.palette.primary.contrastText,
        borderRadius: 0,
        px: { xs: 2, sm: 3 },
        py: { xs: 2, sm: 2.5 },
      }}
    >
      <Typography
        variant="h1"
        component="h1"
        sx={{
          opacity: 0.95,
          letterSpacing: 0,
          display: 'block',
          fontSize: '32px',
          lineHeight: 1.2,
          fontWeight: 700,
          mb: 0.5,
        }}
      >
        Digital Literacy Hub
      </Typography>
      <Typography
        variant="h2"
        component="h2"
        sx={{ fontSize: '16px', lineHeight: 1.5, fontWeight: 400 }}
      >
        {text}
      </Typography>
    </Box>
  );
}
