import { useQuery, type QueryFunctionContext } from '@tanstack/react-query';
import { fetchCmsPage, type CmsPage } from '../api/cmsPagesApi';

export const cmsPageQuery = (slug: string) => ({
  queryKey: ['cms_page', slug] as const,
  queryFn: ({ signal }: QueryFunctionContext) => fetchCmsPage(slug, { signal }),
});

export function useCmsPageQuery(slug: string) {
  return useQuery<CmsPage, Error>({
    ...cmsPageQuery(slug),
    enabled: Boolean(slug),
  });
}
