import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Collapse from '@mui/material/Collapse';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import Paper from '@mui/material/Paper';
import Snackbar from '@mui/material/Snackbar';
import TextField from '@mui/material/TextField';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import DragIndicatorIcon from '@mui/icons-material/DragIndicator';
import EditIcon from '@mui/icons-material/Edit';
import { apiFetch } from '../../../app/api/apiFetch';

interface Lesson {
  id: number;
  title: string;
  summary: string | null;
  duration: number | null;
  lessonOrder: number;
  isAssessment: boolean;
}

interface SortableLessonRowProps {
  lesson: Lesson;
  onEdit: () => void;
  onDelete: () => void;
}

function SortableLessonRow({ lesson, onEdit, onDelete }: SortableLessonRowProps) {
  const { t } = useTranslation();
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } =
    useSortable({ id: lesson.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <Box
      ref={setNodeRef}
      style={style}
      sx={{
        display: 'flex',
        alignItems: 'center',
        gap: 1,
        px: 2,
        py: 1.5,
        borderBottom: '1px solid',
        borderColor: 'divider',
        bgcolor: 'background.paper',
        '&:last-child': { borderBottom: 'none' },
      }}
    >
      <Tooltip title={t('admin.editCoursePage.lessons.dragToReorder')}>
        <IconButton size="small" sx={{ cursor: 'grab', color: 'text.disabled' }} {...attributes} {...listeners}>
          <DragIndicatorIcon fontSize="small" />
        </IconButton>
      </Tooltip>

      <Box sx={{ flex: 1, minWidth: 0 }}>
        <Typography variant="body2" fontWeight={500} noWrap>
          {lesson.title}
          {lesson.isAssessment && (
            <Typography component="span" variant="caption" color="primary" sx={{ ml: 1 }}>
              {t('admin.editCoursePage.lessons.assessment')}
            </Typography>
          )}
        </Typography>
        {lesson.duration != null && (
          <Typography variant="caption" color="text.secondary">
            {lesson.duration} {t('admin.editCoursePage.lessons.mins')}
          </Typography>
        )}
      </Box>

      <Tooltip title={t('admin.editCoursePage.lessons.edit')}>
        <IconButton size="small" onClick={onEdit}>
          <EditIcon fontSize="small" />
        </IconButton>
      </Tooltip>
      <Tooltip title={t('admin.editCoursePage.lessons.delete')}>
        <IconButton size="small" onClick={onDelete} color="error">
          <DeleteIcon fontSize="small" />
        </IconButton>
      </Tooltip>
    </Box>
  );
}

interface AddLessonFormProps {
  onSave: (lesson: { title: string; summary: string; duration: string }) => Promise<void>;
  onCancel: () => void;
  saving: boolean;
}

function AddLessonForm({ onSave, onCancel, saving }: AddLessonFormProps) {
  const { t } = useTranslation();
  const [title, setTitle] = useState('');
  const [summary, setSummary] = useState('');
  const [duration, setDuration] = useState('');

  const handleSave = () => void onSave({ title, summary, duration });

  return (
    <Box sx={{ p: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
      <Typography variant="subtitle2">{t('admin.editCoursePage.lessons.newLesson')}</Typography>
      <TextField
        label={t('admin.editCoursePage.lessons.fieldTitle')}
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        disabled={saving}
        inputProps={{ maxLength: 100 }}
        size="small"
        fullWidth
      />
      <TextField
        label={t('admin.editCoursePage.lessons.fieldSummary')}
        value={summary}
        onChange={(e) => setSummary(e.target.value)}
        disabled={saving}
        inputProps={{ maxLength: 255 }}
        size="small"
        fullWidth
      />
      <TextField
        label={t('admin.editCoursePage.lessons.fieldDuration')}
        value={duration}
        onChange={(e) => setDuration(e.target.value)}
        disabled={saving}
        type="number"
        size="small"
        sx={{ width: 160 }}
        inputProps={{ min: 1 }}
      />
      <Box sx={{ display: 'flex', gap: 1 }}>
        <Button variant="contained" size="small" onClick={handleSave} disabled={saving || !title.trim()}>
          {saving ? t('admin.editCoursePage.lessons.saving') : t('admin.editCoursePage.lessons.save')}
        </Button>
        <Button variant="outlined" size="small" onClick={onCancel} disabled={saving}>
          {t('admin.editCoursePage.lessons.cancel')}
        </Button>
      </Box>
    </Box>
  );
}

export function EditCourseLessonsTab({ courseId }: { courseId: string }) {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [addSaving, setAddSaving] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Lesson | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const [sortError, setSortError] = useState(false);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }),
  );

  useEffect(() => {
    let cancelled = false;
    apiFetch(`/api/v1/admin/courses/${courseId}/lessons`)
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<{ lessons: Lesson[] }>;
      })
      .then((data) => { if (!cancelled) setLessons(data.lessons); })
      .catch(() => { if (!cancelled) setError(t('admin.editCoursePage.lessons.loadError')); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [courseId, t]);

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    const oldIndex = lessons.findIndex((l) => l.id === active.id);
    const newIndex = lessons.findIndex((l) => l.id === over.id);
    const reordered = arrayMove(lessons, oldIndex, newIndex);
    setLessons(reordered);

    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}/lessons/sort`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ order: reordered.map((l) => l.id) }),
      });
      if (!res.ok) throw new Error();
    } catch {
      setLessons(lessons); // revert
      setSortError(true);
    }
  };

  const handleAdd = async ({ title, summary, duration }: { title: string; summary: string; duration: string }) => {
    setAddSaving(true);
    setAddError(null);
    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}/lessons`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ lesson: { title, summary, duration: parseInt(duration, 10) || 0 } }),
      });
      const data = await res.json() as Lesson | { errors: string[] };
      if (!res.ok) {
        setAddError(('errors' in data ? data.errors.join(', ') : null) ?? t('admin.editCoursePage.lessons.addError'));
        return;
      }
      setLessons((prev) => [...prev, data as Lesson]);
      setAdding(false);
    } catch {
      setAddError(t('admin.editCoursePage.lessons.addError'));
    } finally {
      setAddSaving(false);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!deleteTarget) return;
    setDeleteError(null);
    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}/lessons/${deleteTarget.id}`, {
        method: 'DELETE',
      });
      if (!res.ok) throw new Error();
      setLessons((prev) => prev.filter((l) => l.id !== deleteTarget.id));
      setDeleteTarget(null);
    } catch {
      setDeleteError(t('admin.editCoursePage.lessons.deleteError'));
    }
  };

  if (loading) return <CircularProgress />;
  if (error) return <Alert severity="error">{error}</Alert>;

  return (
    <>
      <Paper variant="outlined">
        {lessons.length === 0 && !adding ? (
          <Box sx={{ p: 3, textAlign: 'center' }}>
            <Typography color="text.secondary">{t('admin.editCoursePage.lessons.empty')}</Typography>
          </Box>
        ) : (
          <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={(e) => void handleDragEnd(e)}>
            <SortableContext items={lessons.map((l) => l.id)} strategy={verticalListSortingStrategy}>
              {lessons.map((lesson) => (
                <SortableLessonRow
                  key={lesson.id}
                  lesson={lesson}
                  onEdit={() => navigate(`/admin/courses/${courseId}/lessons/${lesson.id}/edit`)}
                  onDelete={() => setDeleteTarget(lesson)}
                />
              ))}
            </SortableContext>
          </DndContext>
        )}

        <Divider />

        <Collapse in={adding}>
          <AddLessonForm
            onSave={handleAdd}
            onCancel={() => { setAdding(false); setAddError(null); }}
            saving={addSaving}
          />
          {addError && <Alert severity="error" sx={{ mx: 2, mb: 2 }}>{addError}</Alert>}
        </Collapse>

        {!adding && (
          <Box sx={{ p: 1.5 }}>
            <Button startIcon={<AddIcon />} size="small" onClick={() => setAdding(true)}>
              {t('admin.editCoursePage.lessons.addLesson')}
            </Button>
          </Box>
        )}
      </Paper>

      {/* Delete confirmation dialog */}
      <Dialog open={!!deleteTarget} onClose={() => setDeleteTarget(null)}>
        <DialogTitle>{t('admin.editCoursePage.lessons.deleteTitle')}</DialogTitle>
        <DialogContent>
          <DialogContentText>
            {t('admin.editCoursePage.lessons.deleteConfirm', { title: deleteTarget?.title })}
          </DialogContentText>
          {deleteError && <Alert severity="error" sx={{ mt: 1 }}>{deleteError}</Alert>}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteTarget(null)}>{t('admin.editCoursePage.lessons.cancel')}</Button>
          <Button onClick={() => void handleDeleteConfirm()} color="error" variant="contained">
            {t('admin.editCoursePage.lessons.delete')}
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar
        open={sortError}
        autoHideDuration={4000}
        onClose={() => setSortError(false)}
        message={t('admin.editCoursePage.lessons.sortError')}
      />
    </>
  );
}
