import { useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Container from '@mui/material/Container';
import List from '@mui/material/List';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Typography from '@mui/material/Typography';
import { useCoursesListQuery } from '../queries/useCoursesListQuery';
import type { Course } from '../types';
import { CourseList } from '../components/CourseList';
import { listLessons } from '../../lessons/api/lessonsApi';

type CategorySection = {
  id: string;
  name: string;
  courses: Course[];
};

function toCategoryId(course: Course) {
  return course.categoryId || 'uncategorized';
}

function toCategoryName(course: Course) {
  return course.categoryName?.trim() || 'Uncategorized';
}

function compareCourseOrder(a: Course, b: Course) {
  const aOrder = Number(a.courseOrder);
  const bOrder = Number(b.courseOrder);
  const aValue = Number.isFinite(aOrder) ? aOrder : 0;
  const bValue = Number.isFinite(bOrder) ? bOrder : 0;
  if (aValue !== bValue) return aValue - bValue;
  return a.title.localeCompare(b.title);
}

export function CoursesPage() {
  const navigate = useNavigate();
  const { data: courses = [], isLoading, error } = useCoursesListQuery({ scope: 'all' });

  const startCourse = async (courseId: string) => {
    try {
      const lessons = await listLessons({ courseId }, {});
      const firstLesson = [...lessons].sort((a, b) => {
        if (a.lessonOrder !== b.lessonOrder) return a.lessonOrder - b.lessonOrder;
        return a.id.localeCompare(b.id);
      })[0];
      if (firstLesson) {
        navigate(`/lessons/${firstLesson.id}`);
        return;
      }
    } catch {
      // Fall through to course detail page.
    }

    navigate(`/courses/${courseId}`);
  };

  const sections = useMemo(() => {
    const byCategory = new Map<string, CategorySection>();
    for (const course of courses) {
      console.log(course);
      const id = toCategoryId(course);
      const name = toCategoryName(course);
      const existing = byCategory.get(id);
      if (existing) {
        existing.courses.push(course);
      } else {
        byCategory.set(id, { id, name, courses: [course] });
      }
    }

    const result = Array.from(byCategory.values());
    for (const section of result) {
      section.courses.sort(compareCourseOrder);
    }
    result.sort((a, b) => a.name.localeCompare(b.name));
    return result;
  }, [courses]);

  if (isLoading) return <CircularProgress />;
  if (error) return <Alert severity="error">{error.message}</Alert>;

  return (
    <Container sx={{ py: 3 }}>
      <Typography variant="h4" sx={{ mb: 3 }}>
        Courses
      </Typography>

      <Box
        sx={{
          display: 'flex',
          flexDirection: { xs: 'column', md: 'row' },
          gap: 4,
        }}
      >
        <Box
          sx={{
            width: { xs: '100%', md: 240 },
            flexShrink: 0,
            position: { md: 'sticky' },
            top: { md: 16 },
            alignSelf: 'flex-start',
            maxHeight: { md: 'calc(100vh - 32px)' },
            overflowY: { md: 'auto' },
            borderRight: { md: '1px solid', xs: 'none' },
            borderColor: { md: 'divider' },
            pr: { md: 2 },
          }}
        >
          <Typography variant="h6" sx={{ mb: 1 }}>
            Categories
          </Typography>
          <List disablePadding>
            {sections.map((section) => (
              <ListItemButton
                key={section.id}
                component="a"
                href={`#category-${section.id}`}
                sx={{ px: 0 }}
              >
                <ListItemText primary={section.name} />
              </ListItemButton>
            ))}
          </List>
        </Box>

        <Box sx={{ flex: 1, minWidth: 0 }}>
          {sections.map((section) => (
            <Box key={section.id} id={`category-${section.id}`} sx={{ mb: 4, scrollMarginTop: 80 }}>
              <Typography variant="h5" sx={{ mb: 1 }}>
                {section.name}
              </Typography>
              <CourseList
                courses={section.courses}
                onViewLessons={(id) => navigate(`/courses/${id}`)}
                onStartCourse={(id) => {
                  void startCourse(id);
                }}
              />
            </Box>
          ))}
        </Box>
      </Box>
    </Container>
  );
}
