import Container from '@mui/material/Container';
import { CourseListContainer } from '../features/courses/components/CourseListContainer';
import { LessonListContainer } from '../features/lessons/components/LessonListContainer';

export default function Home() {
  return (
    <Container sx={{ py: 3 }}>
      <CourseListContainer title="Featured Classes" params={{ scope: 'homepage', limit: 10 }} />
      <LessonListContainer title="Popular Lessons" params={{ scope: 'popular', limit: 10 }} />
    </Container>
  );
}
