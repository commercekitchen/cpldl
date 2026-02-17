import { isRouteErrorResponse, useNavigate, useRouteError } from 'react-router-dom';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';

function formatUnknownError(err: unknown) {
  if (err instanceof Error) return err.message;
  return typeof err === 'string' ? err : JSON.stringify(err);
}

export function LessonErrorPage() {
  const error = useRouteError();
  const navigate = useNavigate();

  let title = 'Lesson failed to load';
  let message = 'Something went wrong while loading this lesson.';
  let severity: 'error' | 'warning' = 'error';

  if (isRouteErrorResponse(error)) {
    // Errors thrown as: throw new Response("", { status: 404 })
    // or throw json(..., { status })
    const status = error.status;

    if (status === 404) {
      title = 'Lesson not found';
      message = 'This lesson may have been removed or the link is incorrect.';
      severity = 'warning';
    } else if (status === 401 || status === 403) {
      title = 'Access denied';
      message = 'You do not have permission to view this lesson.';
      severity = 'warning';
    } else {
      title = `Unable to load lesson (${status})`;
      message = error.statusText || message;
    }
  } else if (error) {
    // Thrown Error
    message = formatUnknownError(error);
  }

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'grid',
        placeItems: 'center',
        p: 3,
        bgcolor: 'background.default',
      }}
    >
      <Box sx={{ width: '100%', maxWidth: 640 }}>
        <Typography variant="h5" sx={{ mb: 1 }}>
          {title}
        </Typography>

        <Alert severity={severity} sx={{ mb: 2 }}>
          {message}
        </Alert>

        <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
          <Button variant="contained" onClick={() => navigate('/')}>
            Go to home
          </Button>

          <Button variant="outlined" onClick={() => window.location.reload()}>
            Retry
          </Button>

          <Button variant="text" onClick={() => navigate(-1)}>
            Go back
          </Button>
        </Box>

        {/* Optional: show technical details in non-production */}
        {import.meta.env.DEV && (
          <Box sx={{ mt: 2 }}>
            <Typography variant="caption" component="div" sx={{ opacity: 0.8 }}>
              Debug details:
            </Typography>
            <Box
              component="pre"
              sx={{
                mt: 1,
                p: 2,
                borderRadius: 1,
                overflow: 'auto',
                bgcolor: 'background.paper',
                border: '1px solid',
                borderColor: 'divider',
                fontSize: 12,
              }}
            >
              {isRouteErrorResponse(error)
                ? JSON.stringify(
                    { status: error.status, statusText: error.statusText, data: error.data },
                    null,
                    2,
                  )
                : String(error)}
            </Box>
          </Box>
        )}
      </Box>
    </Box>
  );
}
