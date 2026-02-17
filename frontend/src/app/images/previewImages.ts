const PREVIEW_IMAGES = [
  '/preview_images/JPG_Test.jpg',
  '/preview_images/cat.jpg',
  '/preview_images/cat2.jpg',
  '/preview_images/cat3.jpg',
  '/preview_images/cat4.jpg',
] as const;

function hashString(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash * 31 + value.charCodeAt(i)) | 0;
  }
  return hash >>> 0; // ensure non-negative
}

export function previewImageForRecord(
  id?: string | number | null
): string {
  if (id == null) {
    return PREVIEW_IMAGES[0];
  }

  const index = hashString(String(id)) % PREVIEW_IMAGES.length;
  return PREVIEW_IMAGES[index];
}
