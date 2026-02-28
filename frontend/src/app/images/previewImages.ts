const PREVIEW_IMAGES = [
  '/preview_images/focused_expression_at_computer.png',
  '/preview_images/focused_expression_at_desk.png',
  '/preview_images/focused_person_at_computer.png',
  '/preview_images/green_shirt_at_desk.png',
  '/preview_images/happy_focused_expression_at_desk.png',
  '/preview_images/happy_focused_woman_at_computer.png',
  '/preview_images/happy_man_at_computer.png',
  '/preview_images/happy_person_at_computer.png',
  '/preview_images/happy_woman_with_laptop.png',
  '/preview_images/man_working_at_computer.png',
  '/preview_images/person_at_desk_on_computer.png',
  '/preview_images/woman_at_computer.png',
  '/preview_images/woman_at_desk_focused_expression.png',
  '/preview_images/woman_with_laptop_computer.png',
] as const;

function hashString(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash * 31 + value.charCodeAt(i)) | 0;
  }
  return hash >>> 0; // ensure non-negative
}

export function previewImageForRecord(id?: string | number | null): string {
  if (id == null) {
    return PREVIEW_IMAGES[0];
  }

  const index = hashString(String(id)) % PREVIEW_IMAGES.length;
  return PREVIEW_IMAGES[index];
}
