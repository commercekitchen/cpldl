import { useParams } from 'react-router-dom';
import Alert from '@mui/material/Alert';
import CircularProgress from '@mui/material/CircularProgress';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import DOMPurify from 'dompurify';
import { useCmsPageQuery } from '../features/cms_pages/queries/cmsPageQuery';
import { usePageMetadata } from '../app/metadata/usePageMetadata';

export default function CmsPage() {
  const { slug = '' } = useParams();
  const { data: page, isLoading, error } = useCmsPageQuery(slug);

  usePageMetadata(
    page
      ? {
          title: page.seo_page_title?.trim() || page.title,
          description: page.meta_desc ?? undefined,
        }
      : { title: '' },
  );

  if (isLoading) return <CircularProgress />;
  if (error || !page) return <Alert severity="error">{error?.message ?? 'Page not found'}</Alert>;

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        {page.title}
      </Typography>
      <Box
        sx={{ '& p': { mt: 0 }, '& p:last-child': { mb: 0 }, '& ul': { pl: 3 }, '& ol': { pl: 3 } }}
        dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(page.body) }}
      />
    </Container>
  );
}
