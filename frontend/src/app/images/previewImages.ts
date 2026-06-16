const PREVIEW_IMAGES = [
  '/preview_images/digital_learn-lesson-image_001.jpg',
  '/preview_images/digital_learn-lesson-image_002.jpg',
  '/preview_images/digital_learn-lesson-image_003.jpg',
  '/preview_images/digital_learn-lesson-image_004.jpg',
  '/preview_images/digital_learn-lesson-image_005.jpg',
  '/preview_images/digital_learn-lesson-image_006.jpg',
  '/preview_images/digital_learn-lesson-image_007.jpg',
  '/preview_images/digital_learn-lesson-image_008.jpg',
  '/preview_images/digital_learn-lesson-image_009.jpg',
  '/preview_images/digital_learn-lesson-image_010.jpg',
  '/preview_images/digital_learn-lesson-image_011.jpg',
  '/preview_images/digital_learn-lesson-image_012.jpg',
  '/preview_images/digital_learn-lesson-image_013.jpg',
  '/preview_images/digital_learn-lesson-image_014.jpg',
  '/preview_images/digital_learn-lesson-image_015.jpg',
  '/preview_images/digital_learn-lesson-image_016.jpg',
  '/preview_images/digital_learn-lesson-image_017.jpg',
  '/preview_images/digital_learn-lesson-image_018.jpg',
  '/preview_images/digital_learn-lesson-image_019.jpg',
  '/preview_images/digital_learn-lesson-image_020.jpg',
  '/preview_images/digital_learn-lesson-image_021.jpg',
  '/preview_images/digital_learn-lesson-image_022.jpg',
  '/preview_images/digital_learn-lesson-image_023.jpg',
  '/preview_images/digital_learn-lesson-image_024.jpg',
  '/preview_images/digital_learn-lesson-image_025.jpg',
  '/preview_images/digital_learn-lesson-image_026.jpg',
  '/preview_images/digital_learn-lesson-image_027.jpg',
  '/preview_images/digital_learn-lesson-image_028.jpg',
  '/preview_images/digital_learn-lesson-image_029.jpg',
  '/preview_images/digital_learn-lesson-image_030.jpg',
  '/preview_images/digital_learn-lesson-image_031.jpg',
  '/preview_images/digital_learn-lesson-image_032.jpg',
  '/preview_images/digital_learn-lesson-image_033.jpg',
  '/preview_images/digital_learn-lesson-image_034.jpg',
  '/preview_images/digital_learn-lesson-image_035.jpg',
  '/preview_images/digital_learn-lesson-image_036.jpg',
  '/preview_images/digital_learn-lesson-image_037.jpg',
  '/preview_images/digital_learn-lesson-image_038.jpg',
  '/preview_images/digital_learn-lesson-image_039.jpg',
  '/preview_images/digital_learn-lesson-image_040.jpg',
  '/preview_images/digital_learn-lesson-image_041.jpg',
  '/preview_images/digital_learn-lesson-image_042.jpg',
  '/preview_images/digital_learn-lesson-image_043.jpg',
  '/preview_images/digital_learn-lesson-image_044.jpg',
  '/preview_images/digital_learn-lesson-image_045.jpg',
  '/preview_images/digital_learn-lesson-image_046.jpg',
  '/preview_images/digital_learn-lesson-image_047.jpg',
  '/preview_images/digital_learn-lesson-image_048.jpg',
  '/preview_images/digital_learn-lesson-image_049.jpg',
  '/preview_images/digital_learn-lesson-image_050.jpg',
  '/preview_images/digital_learn-lesson-image_051.jpg',
  '/preview_images/digital_learn-lesson-image_052.jpg',
  '/preview_images/digital_learn-lesson-image_053.jpg',
  '/preview_images/digital_learn-lesson-image_054.jpg',
  '/preview_images/digital_learn-lesson-image_055.jpg',
  '/preview_images/digital_learn-lesson-image_056.jpg',
  '/preview_images/digital_learn-lesson-image_057.jpg',
  '/preview_images/digital_learn-lesson-image_058.jpg',
  '/preview_images/digital_learn-lesson-image_059.jpg',
  '/preview_images/digital_learn-lesson-image_060.jpg',
  '/preview_images/digital_learn-lesson-image_061.jpg',
  '/preview_images/digital_learn-lesson-image_062.jpg',
  '/preview_images/digital_learn-lesson-image_063.jpg',
  '/preview_images/digital_learn-lesson-image_064.jpg',
  '/preview_images/digital_learn-lesson-image_065.jpg',
  '/preview_images/digital_learn-lesson-image_066.jpg',
  '/preview_images/digital_learn-lesson-image_067.jpg',
  '/preview_images/digital_learn-lesson-image_068.jpg',
  '/preview_images/digital_learn-lesson-image_069.jpg',
  '/preview_images/digital_learn-lesson-image_070.jpg',
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
