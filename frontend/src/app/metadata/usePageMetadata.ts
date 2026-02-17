import { useEffect } from 'react';

type PageMetadata = {
  title?: string;
  description?: string;
  robots?: string;
};

export function usePageMetadata(meta: PageMetadata | null) {
  useEffect(() => {
    if (!meta) return;

    const prevTitle = document.title;
    const prevDescription =
      document.querySelector<HTMLMetaElement>('meta[name="description"]')?.content ?? null;
    const prevRobots =
      document.querySelector<HTMLMetaElement>('meta[name="robots"]')?.content ?? null;

    if (meta.title) {
      document.title = meta.title;
    }

    if (meta.description !== undefined) {
      setMetaTag('description', meta.description);
    }

    if (meta.robots !== undefined) {
      setMetaTag('robots', meta.robots);
    }

    return () => {
      document.title = prevTitle;
      restoreMetaTag('description', prevDescription);
      restoreMetaTag('robots', prevRobots);
    };
  }, [meta]);
}

function setMetaTag(name: string, content?: string) {
  let tag = document.querySelector<HTMLMetaElement>(`meta[name="${name}"]`);

  if (!content) {
    if (tag) tag.remove();
    return;
  }

  if (!tag) {
    tag = document.createElement('meta');
    tag.name = name;
    document.head.appendChild(tag);
  }

  tag.content = content;
}

function restoreMetaTag(name: string, content: string | null) {
  if (content === null) {
    document.querySelector(`meta[name="${name}"]`)?.remove();
  } else {
    setMetaTag(name, content);
  }
}
