export type Lesson = {
  id: string;
  courseId?: string;
  courseTitle?: string;
  title: string;
  summary: string;
  duration: number;
  storylineUrl: string;
  seoPageTitle: string;
  seoMetaDescription: string;
  isAssessment: boolean;
  lessonOrder: number;
  level: string;
  previewImageUrl?: string;
  completed?: boolean;
};
