export type Course = {
  id: string;
  title: string;
  summary: string;
  description: string;
  contributor: string;
  courseOrder: string;
  format: string;
  surveyUrl: string;
  attCourse: boolean;
  notes: string;
  categoryId: string;
  categoryName?: string;
  level?: string;
  totalDuration?: string;
  lessonsCount?: number;
  lessonsCompletedCount?: number;
  previewImageUrl?: string;
  attachments?: {
    url: string;
    docType: 'text-copy' | 'additional-resource';
    contentType: string;
    fileName: string;
  }[];
  seoPageTitle: string;
  seoMetaDescription: string;
};
