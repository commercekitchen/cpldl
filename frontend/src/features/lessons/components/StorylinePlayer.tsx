import { forwardRef } from 'react';
import Box from '@mui/material/Box';

type Props = {
  src: string;
  title: string;
};

export const StorylinePlayer = forwardRef<HTMLIFrameElement, Props>(function StorylinePlayer(
  { src, title },
  ref,
) {
  return (
    <Box
      sx={{
        width: '100%',
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        bgcolor: 'background.default',
      }}
    >
      <Box sx={{ flex: 1, minHeight: 0 }}>
        <iframe
          ref={ref}
          src={src}
          title={title}
          style={{
            border: 0,
            width: '100%',
            height: '100%',
            display: 'block',
          }}
          // Optional (Storyline sometimes needs fullscreen/media permissions)
          allow="fullscreen; autoplay"
        />
      </Box>
    </Box>
  );
});
