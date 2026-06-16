import { apiFetch } from '../../../app/api/apiFetch';

export type CmsPage = {
  slug: string;
  title: string;
  body: string;
  seo_page_title: string | null;
  meta_desc: string | null;
};

export async function fetchCmsPage(slug: string, opts: { signal?: AbortSignal } = {}): Promise<CmsPage> {
  const res = await apiFetch(`/api/v1/cms_pages/${encodeURIComponent(slug)}`, { signal: opts.signal });
  if (!res.ok) throw new Error(`Failed to load page: ${res.status}`);
  return (await res.json()) as CmsPage;
}
