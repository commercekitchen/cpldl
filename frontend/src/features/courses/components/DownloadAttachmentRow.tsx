import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import DownloadIcon from '@mui/icons-material/Download';

type Props = {
  fileName: string;
  url: string;
  contentType?: string;
};

function fileTypeLabel(contentType?: string): string {
  if (!contentType) return 'File';
  if (contentType.includes('pdf')) return 'PDF';
  if (contentType.includes('word') || contentType.includes('docx')) return 'Word';
  if (contentType.includes('excel') || contentType.includes('xlsx')) return 'Excel';
  if (contentType.includes('powerpoint') || contentType.includes('pptx')) return 'PowerPoint';
  if (contentType.includes('zip')) return 'ZIP';
  const ext = contentType.split('/').pop()?.toUpperCase();
  return ext ?? 'File';
}

function isBrowserOpenable(contentType?: string): boolean {
  if (!contentType) return false;
  return contentType.includes('pdf') || contentType.startsWith('image/');
}

export function DownloadAttachmentRow({ fileName, url, contentType }: Props) {
  const openable = isBrowserOpenable(contentType);
  return (
    <Paper
      component="a"
      href={url}
      target="_blank"
      rel="noopener noreferrer"
      {...(!openable && { download: true })}
      variant="elevation"
      sx={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        px: 2,
        py: 1.5,
        textDecoration: 'none',
        color: 'inherit',
        cursor: 'pointer',
        '&:hover': { backgroundColor: 'action.hover' },
      }}
    >
      <Typography variant="body2">{fileName}</Typography>
      <Typography
        variant="body2"
        color="primary"
        sx={{ display: 'flex', alignItems: 'center', gap: 0.5, whiteSpace: 'nowrap' }}
      >
        Download {fileTypeLabel(contentType)}
        <DownloadIcon fontSize="small" />
      </Typography>
    </Paper>
  );
}
