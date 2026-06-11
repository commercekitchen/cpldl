import { useState, useEffect } from 'react';
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
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import IconButton from '@mui/material/IconButton';
import Paper from '@mui/material/Paper';
import Snackbar from '@mui/material/Snackbar';
import TextField from '@mui/material/TextField';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import CheckIcon from '@mui/icons-material/Check';
import CloseIcon from '@mui/icons-material/Close';
import DeleteIcon from '@mui/icons-material/Delete';
import DragIndicatorIcon from '@mui/icons-material/DragIndicator';
import EditIcon from '@mui/icons-material/Edit';
import { apiFetch } from '../../app/api/apiFetch';

interface Category {
  id: number;
  name: string;
  categoryOrder: number;
  enabled: boolean;
  courseCount: number;
}

function SortableCategoryRow({
  category,
  onEdit,
  onDelete,
}: {
  category: Category;
  onEdit: () => void;
  onDelete: () => void;
}) {
  const { t } = useTranslation();
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
    id: category.id,
  });

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
      <Tooltip title={t('admin.categoriesPage.dragToReorder')}>
        <IconButton
          size="small"
          sx={{ cursor: 'grab', color: 'text.disabled' }}
          {...attributes}
          {...listeners}
        >
          <DragIndicatorIcon fontSize="small" />
        </IconButton>
      </Tooltip>

      <Box sx={{ flex: 1, minWidth: 0 }}>
        <Typography variant="body2" fontWeight={500}>
          {category.name}
        </Typography>
        <Typography variant="caption" color="text.secondary">
          {t('admin.categoriesPage.courseCount', { count: category.courseCount })}
        </Typography>
      </Box>

      <Tooltip title={t('admin.categoriesPage.rename')}>
        <IconButton size="small" onClick={onEdit}>
          <EditIcon fontSize="small" />
        </IconButton>
      </Tooltip>
      <Tooltip title={t('admin.categoriesPage.delete')}>
        <IconButton size="small" onClick={onDelete} color="error">
          <DeleteIcon fontSize="small" />
        </IconButton>
      </Tooltip>
    </Box>
  );
}

function InlineRenameRow({
  category,
  onSave,
  onCancel,
}: {
  category: Category;
  onSave: (name: string) => Promise<void>;
  onCancel: () => void;
}) {
  const { t } = useTranslation();
  const [name, setName] = useState(category.name);
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    if (!name.trim() || name.trim() === category.name) {
      onCancel();
      return;
    }
    setSaving(true);
    await onSave(name.trim());
    setSaving(false);
  };

  return (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'center',
        gap: 1,
        px: 2,
        py: 1,
        borderBottom: '1px solid',
        borderColor: 'divider',
        bgcolor: 'background.paper',
        '&:last-child': { borderBottom: 'none' },
      }}
    >
      <Box sx={{ width: 34 }} />
      <TextField
        value={name}
        onChange={(e) => setName(e.target.value)}
        size="small"
        autoFocus
        disabled={saving}
        onKeyDown={(e) => {
          if (e.key === 'Enter') void handleSave();
          if (e.key === 'Escape') onCancel();
        }}
        sx={{ flex: 1 }}
        inputProps={{ maxLength: 100 }}
      />
      <Tooltip title={t('admin.categoriesPage.save')}>
        <span>
          <IconButton
            size="small"
            color="primary"
            onClick={() => void handleSave()}
            disabled={saving || !name.trim()}
          >
            {saving ? <CircularProgress size={16} /> : <CheckIcon fontSize="small" />}
          </IconButton>
        </span>
      </Tooltip>
      <Tooltip title={t('admin.categoriesPage.cancel')}>
        <IconButton size="small" onClick={onCancel} disabled={saving}>
          <CloseIcon fontSize="small" />
        </IconButton>
      </Tooltip>
    </Box>
  );
}

export default function AdminCategories() {
  const { t } = useTranslation();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Category | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [newName, setNewName] = useState('');
  const [adding, setAdding] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);
  const [sortError, setSortError] = useState(false);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }),
  );

  useEffect(() => {
    let cancelled = false;
    apiFetch('/api/v1/admin/categories')
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<{ categories: Category[] }>;
      })
      .then((data) => {
        if (!cancelled) setCategories(data.categories);
      })
      .catch(() => {
        if (!cancelled) setError(t('admin.categoriesPage.loadError'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [t]);

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    const oldIndex = categories.findIndex((c) => c.id === active.id);
    const newIndex = categories.findIndex((c) => c.id === over.id);
    const reordered = arrayMove(categories, oldIndex, newIndex);
    setCategories(reordered);

    try {
      const res = await apiFetch('/api/v1/admin/categories/sort', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ order: reordered.map((c) => c.id) }),
      });
      if (!res.ok) throw new Error();
    } catch {
      setCategories(categories);
      setSortError(true);
    }
  };

  const handleRename = async (id: number, name: string) => {
    try {
      const res = await apiFetch(`/api/v1/admin/categories/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ category: { name } }),
      });
      if (!res.ok) {
        const d = (await res.json()) as { errors?: string[] };
        setSuccessMsg(null);
        setError(d.errors?.join(', ') ?? t('admin.categoriesPage.renameError'));
        return;
      }
      setCategories((prev) => prev.map((c) => (c.id === id ? { ...c, name } : c)));
      setEditingId(null);
      setSuccessMsg(t('admin.categoriesPage.renameSuccess'));
    } catch {
      setError(t('admin.categoriesPage.renameError'));
    }
  };

  const handleDeleteConfirm = async () => {
    if (!deleteTarget) return;
    setDeleteError(null);
    setDeleting(true);
    try {
      const res = await apiFetch(`/api/v1/admin/categories/${deleteTarget.id}`, {
        method: 'DELETE',
      });
      if (!res.ok) throw new Error();
      setCategories((prev) => prev.filter((c) => c.id !== deleteTarget.id));
      setDeleteTarget(null);
      setSuccessMsg(t('admin.categoriesPage.deleteSuccess'));
    } catch {
      setDeleteError(t('admin.categoriesPage.deleteError'));
    } finally {
      setDeleting(false);
    }
  };

  const handleAdd = async () => {
    setAddError(null);
    if (!newName.trim()) {
      setAddError(t('admin.categoriesPage.nameRequired'));
      return;
    }
    setAdding(true);
    try {
      const res = await apiFetch('/api/v1/admin/categories', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ category: { name: newName.trim() } }),
      });
      const data = (await res.json()) as { category?: Category; errors?: string[] };
      if (!res.ok) {
        setAddError(data.errors?.join(', ') ?? t('admin.categoriesPage.addError'));
        return;
      }
      setCategories((prev) => [...prev, data.category!]);
      setNewName('');
      setSuccessMsg(t('admin.categoriesPage.addSuccess'));
    } catch {
      setAddError(t('admin.categoriesPage.addError'));
    } finally {
      setAdding(false);
    }
  };

  if (loading) return <CircularProgress />;
  if (error && categories.length === 0) return <Alert severity="error">{error}</Alert>;

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>
        {t('admin.categories')}
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      <Paper variant="outlined" sx={{ mb: 3, maxWidth: 600 }}>
        {categories.length === 0 ? (
          <Box sx={{ p: 3, textAlign: 'center' }}>
            <Typography color="text.secondary">{t('admin.categoriesPage.empty')}</Typography>
          </Box>
        ) : (
          <DndContext
            sensors={sensors}
            collisionDetection={closestCenter}
            onDragEnd={(e) => void handleDragEnd(e)}
          >
            <SortableContext
              items={categories.map((c) => c.id)}
              strategy={verticalListSortingStrategy}
            >
              {categories.map((category) =>
                editingId === category.id ? (
                  <InlineRenameRow
                    key={category.id}
                    category={category}
                    onSave={(name) => handleRename(category.id, name)}
                    onCancel={() => setEditingId(null)}
                  />
                ) : (
                  <SortableCategoryRow
                    key={category.id}
                    category={category}
                    onEdit={() => setEditingId(category.id)}
                    onDelete={() => setDeleteTarget(category)}
                  />
                ),
              )}
            </SortableContext>
          </DndContext>
        )}
      </Paper>

      <Paper variant="outlined" sx={{ p: 3, maxWidth: 600 }}>
        <Typography variant="subtitle2" sx={{ mb: 2 }}>
          {t('admin.categoriesPage.addTitle')}
        </Typography>
        {addError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {addError}
          </Alert>
        )}
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start' }}>
          <TextField
            label={t('admin.categoriesPage.nameLabel')}
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            size="small"
            disabled={adding}
            onKeyDown={(e) => {
              if (e.key === 'Enter') void handleAdd();
            }}
            inputProps={{ maxLength: 100 }}
            sx={{ flex: 1 }}
          />
          <Button
            variant="contained"
            startIcon={adding ? <CircularProgress size={16} color="inherit" /> : <AddIcon />}
            onClick={() => void handleAdd()}
            disabled={adding}
            sx={{ mt: 0.25 }}
          >
            {adding ? t('admin.categoriesPage.adding') : t('admin.categoriesPage.add')}
          </Button>
        </Box>
      </Paper>

      <Dialog open={Boolean(deleteTarget)} onClose={() => !deleting && setDeleteTarget(null)}>
        <DialogTitle>{t('admin.categoriesPage.deleteTitle')}</DialogTitle>
        <DialogContent>
          {deleteError && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {deleteError}
            </Alert>
          )}
          <DialogContentText>
            {t('admin.categoriesPage.deleteConfirm', { name: deleteTarget?.name ?? '' })}
          </DialogContentText>
          {deleteTarget && deleteTarget.courseCount > 0 && (
            <Alert severity="warning" sx={{ mt: 2 }}>
              {t('admin.categoriesPage.deleteWarning', { count: deleteTarget.courseCount })}
            </Alert>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteTarget(null)} disabled={deleting}>
            {t('admin.categoriesPage.cancel')}
          </Button>
          <Button color="error" onClick={() => void handleDeleteConfirm()} disabled={deleting}>
            {deleting ? <CircularProgress size={18} /> : t('admin.categoriesPage.deleteConfirmBtn')}
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar
        open={sortError}
        autoHideDuration={4000}
        onClose={() => setSortError(false)}
        message={t('admin.categoriesPage.sortError')}
      />
      <Snackbar
        open={Boolean(successMsg)}
        autoHideDuration={3000}
        onClose={() => setSuccessMsg(null)}
        message={successMsg}
      />
    </Box>
  );
}
