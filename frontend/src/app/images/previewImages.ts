const PREVIEW_IMAGES = [
  '/preview_images/digital_learn-lesson-image_001.webp',
  '/preview_images/digital_learn-lesson-image_002.webp',
  '/preview_images/digital_learn-lesson-image_003.webp',
  '/preview_images/digital_learn-lesson-image_004.webp',
  '/preview_images/digital_learn-lesson-image_005.webp',
  '/preview_images/digital_learn-lesson-image_006.webp',
  '/preview_images/digital_learn-lesson-image_007.webp',
  '/preview_images/digital_learn-lesson-image_008.webp',
  '/preview_images/digital_learn-lesson-image_009.webp',
  '/preview_images/digital_learn-lesson-image_010.webp',
  '/preview_images/digital_learn-lesson-image_011.webp',
  '/preview_images/digital_learn-lesson-image_012.webp',
  '/preview_images/digital_learn-lesson-image_013.webp',
  '/preview_images/digital_learn-lesson-image_014.webp',
  '/preview_images/digital_learn-lesson-image_015.webp',
  '/preview_images/digital_learn-lesson-image_016.webp',
  '/preview_images/digital_learn-lesson-image_017.webp',
  '/preview_images/digital_learn-lesson-image_018.webp',
  '/preview_images/digital_learn-lesson-image_019.webp',
  '/preview_images/digital_learn-lesson-image_020.webp',
  '/preview_images/digital_learn-lesson-image_021.webp',
  '/preview_images/digital_learn-lesson-image_022.webp',
  '/preview_images/digital_learn-lesson-image_023.webp',
  '/preview_images/digital_learn-lesson-image_024.webp',
  '/preview_images/digital_learn-lesson-image_025.webp',
  '/preview_images/digital_learn-lesson-image_026.webp',
  '/preview_images/digital_learn-lesson-image_027.webp',
  '/preview_images/digital_learn-lesson-image_028.webp',
  '/preview_images/digital_learn-lesson-image_029.webp',
  '/preview_images/digital_learn-lesson-image_030.webp',
  '/preview_images/digital_learn-lesson-image_031.webp',
  '/preview_images/digital_learn-lesson-image_032.webp',
  '/preview_images/digital_learn-lesson-image_033.webp',
  '/preview_images/digital_learn-lesson-image_034.webp',
  '/preview_images/digital_learn-lesson-image_035.webp',
  '/preview_images/digital_learn-lesson-image_036.webp',
  '/preview_images/digital_learn-lesson-image_037.webp',
  '/preview_images/digital_learn-lesson-image_038.webp',
  '/preview_images/digital_learn-lesson-image_039.webp',
  '/preview_images/digital_learn-lesson-image_040.webp',
  '/preview_images/digital_learn-lesson-image_041.webp',
  '/preview_images/digital_learn-lesson-image_042.webp',
  '/preview_images/digital_learn-lesson-image_043.webp',
  '/preview_images/digital_learn-lesson-image_044.webp',
  '/preview_images/digital_learn-lesson-image_045.webp',
  '/preview_images/digital_learn-lesson-image_046.webp',
  '/preview_images/digital_learn-lesson-image_047.webp',
  '/preview_images/digital_learn-lesson-image_048.webp',
  '/preview_images/digital_learn-lesson-image_049.webp',
  '/preview_images/digital_learn-lesson-image_050.webp',
  '/preview_images/digital_learn-lesson-image_051.webp',
  '/preview_images/digital_learn-lesson-image_052.webp',
  '/preview_images/digital_learn-lesson-image_053.webp',
  '/preview_images/digital_learn-lesson-image_054.webp',
  '/preview_images/digital_learn-lesson-image_055.webp',
  '/preview_images/digital_learn-lesson-image_056.webp',
  '/preview_images/digital_learn-lesson-image_057.webp',
  '/preview_images/digital_learn-lesson-image_058.webp',
  '/preview_images/digital_learn-lesson-image_059.webp',
  '/preview_images/digital_learn-lesson-image_060.webp',
  '/preview_images/digital_learn-lesson-image_061.webp',
  '/preview_images/digital_learn-lesson-image_062.webp',
  '/preview_images/digital_learn-lesson-image_063.webp',
  '/preview_images/digital_learn-lesson-image_064.webp',
  '/preview_images/digital_learn-lesson-image_065.webp',
  '/preview_images/digital_learn-lesson-image_066.webp',
  '/preview_images/digital_learn-lesson-image_067.webp',
  '/preview_images/digital_learn-lesson-image_068.webp',
  '/preview_images/digital_learn-lesson-image_069.webp',
  '/preview_images/digital_learn-lesson-image_070.webp',
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
