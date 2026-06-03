import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import { useCoursesListQuery } from '../queries/useCoursesListQuery';
import type { Course } from '../types';
import { CourseList } from '../components/CourseList';
import { listLessons } from '../../lessons/api/lessonsApi';

type CategorySection = {
  id: string;
  name: string;
  slug: string;
  courses: Course[];
};

function toCategoryId(course: Course) {
  return course.categoryId || 'uncategorized';
}

function toCategoryName(course: Course) {
  return course.categoryName?.trim() || 'Uncategorized';
}

function toCategorySlug(name: string): string {
  return name
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '') || 'uncategorized';
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
  const { t } = useTranslation();
  const { data: courses = [], isLoading, error } = useCoursesListQuery({ scope: 'all' });
  const [activeId, setActiveId] = useState<string | null>(null);

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
      const id = toCategoryId(course);
      const name = toCategoryName(course);
      const existing = byCategory.get(id);
      if (existing) {
        existing.courses.push(course);
      } else {
        byCategory.set(id, { id, name, slug: toCategorySlug(name), courses: [course] });
      }
    }

    const result = Array.from(byCategory.values());
    for (const section of result) {
      section.courses.sort(compareCourseOrder);
    }
    result.sort((a, b) => a.name.localeCompare(b.name));
    return result;
  }, [courses]);

  useEffect(() => {
    const getActiveId = () => {
      const threshold = window.innerHeight * 0.3;
      let result: string | null = null;
      for (const section of sections) {
        const el = document.getElementById(`category-${section.slug}`);
        if (!el) continue;
        if (el.getBoundingClientRect().top <= threshold) {
          result = section.id;
        }
      }
      return result;
    };

    const handleScroll = () => {
      const next = getActiveId();
      if (next !== null) setActiveId(next);
    };

    handleScroll();
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [sections]);

  if (isLoading) return <CircularProgress />;
  if (error) return <Alert severity="error">{error.message}</Alert>;

  return (
    <Container sx={{ py: 3 }}>
      <Typography variant="h4" sx={{ mb: 3 }}>
        {t('courses.pageTitle')}
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
          <Typography variant="h6" sx={{ mb: 1.5 }}>
            {t('courses.categories')}
          </Typography>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {sections.map((section) => {
              const active = activeId === section.id;
              return (
                <Box
                  key={section.id}
                  component="a"
                  href={`#category-${section.slug}`}
                  sx={{
                    position: 'relative',
                    display: 'flex',
                    alignItems: 'center',
                    px: 1.5,
                    py: 0.75,
                    borderRadius: 1,
                    border: '1.5px solid',
                    borderColor: active ? 'primary.main' : 'divider',
                    color: active ? 'primary.main' : 'text.primary',
                    fontWeight: active ? 600 : 400,
                    fontSize: '0.875rem',
                    textDecoration: 'none',
                    transition: 'border-color 0.15s, color 0.15s',
                    '&:hover': {
                      borderColor: 'primary.main',
                      color: 'primary.main',
                    },
                  }}
                >
                  {section.name}
                  <Box
                    sx={{
                      position: 'absolute',
                      right: 0,
                      top: '50%',
                      transform: 'translate(1.5px, -50%)',
                      width: 0,
                      height: 0,
                      borderTop: '9px solid transparent',
                      borderBottom: '9px solid transparent',
                      borderRight: '12px solid',
                      borderRightColor: active ? 'primary.main' : 'transparent',
                      transition: 'border-right-color 0.15s',
                    }}
                  />
                </Box>
              );
            })}
          </Box>
        </Box>

        <Box sx={{ flex: 1, minWidth: 0 }}>
          {sections.map((section) => (
            <Box key={section.id} id={`category-${section.slug}`} sx={{ mb: 4, scrollMarginTop: 80 }}>
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
