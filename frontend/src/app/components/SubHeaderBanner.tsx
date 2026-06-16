import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import DOMPurify from 'dompurify';

const DEFAULT_HEADER = 'Digital Literacy Hub';
const DEFAULT_SUBHEADER = 'Gain skills and confidence for today\'s digital world.';

type Props = {
  header?: string;
  subheader?: string;
};

export function SubHeaderBanner({ header, subheader }: Props) {
  const displayHeader = header || DEFAULT_HEADER;
  const displaySubheader = subheader || DEFAULT_SUBHEADER;

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
        {displayHeader}
      </Typography>
      <Typography
        variant="body1"
        component="p"
        sx={{ fontSize: '16px', lineHeight: 1.5, fontWeight: 400 }}
        dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(displaySubheader) }}
      />
    </Box>
  );
}
