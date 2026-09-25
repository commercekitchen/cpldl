import { useEffect, useRef, useState } from 'react';
import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Link from '@tiptap/extension-link';
import Box from '@mui/material/Box';
import FormHelperText from '@mui/material/FormHelperText';
import FormLabel from '@mui/material/FormLabel';
import IconButton from '@mui/material/IconButton';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import TextField from '@mui/material/TextField';
import FormControlLabel from '@mui/material/FormControlLabel';
import Checkbox from '@mui/material/Checkbox';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import FormatBoldIcon from '@mui/icons-material/FormatBold';
import FormatItalicIcon from '@mui/icons-material/FormatItalic';
import FormatListBulletedIcon from '@mui/icons-material/FormatListBulleted';
import FormatListNumberedIcon from '@mui/icons-material/FormatListNumbered';
import InsertLinkIcon from '@mui/icons-material/InsertLink';
import LinkOffIcon from '@mui/icons-material/LinkOff';

interface Props {
  label: string;
  value: string | null;
  onChange: (html: string) => void;
  disabled?: boolean;
  helperText?: string;
}

export function RichTextEditor({ label, value, onChange, disabled, helperText }: Props) {
  const prevValueRef = useRef(value);
  const [linkDialogOpen, setLinkDialogOpen] = useState(false);
  const [linkUrl, setLinkUrl] = useState('');
  const [linkText, setLinkText] = useState('');
  const [linkNewTab, setLinkNewTab] = useState(false);

  const editor = useEditor({
    extensions: [
      StarterKit,
      Link.configure({
        openOnClick: false,
        // Don't force every link open in a new tab silently — admins opt in
        // per-link via the dialog below, so screen reader users get a heads-up.
        HTMLAttributes: { target: null, rel: null },
      }),
    ],
    content: value ?? '',
    editable: !disabled,
    onUpdate: ({ editor }) => {
      const html = editor.getHTML();
      prevValueRef.current = html;
      onChange(html);
    },
  });

  const openLinkDialog = () => {
    if (!editor) return;
    editor.chain().focus().extendMarkRange('link').run();
    const { from, to, empty } = editor.state.selection;
    const attrs = editor.getAttributes('link');
    setLinkUrl(attrs.href ?? '');
    setLinkText(empty ? '' : editor.state.doc.textBetween(from, to, ' '));
    setLinkNewTab(attrs.target === '_blank');
    setLinkDialogOpen(true);
  };

  const handleLinkSave = () => {
    if (!editor) return;
    const url = linkUrl.trim();
    const text = linkText.trim();
    if (!url || !text) return;

    editor.chain().focus().extendMarkRange('link').run();
    const { from, to, empty } = editor.state.selection;
    const currentText = empty ? '' : editor.state.doc.textBetween(from, to, ' ');
    const attrs = {
      href: url,
      target: linkNewTab ? '_blank' : null,
      rel: linkNewTab ? 'noopener noreferrer' : null,
    };

    if (empty || currentText !== text) {
      editor
        .chain()
        .focus()
        .insertContentAt({ from, to }, { type: 'text', text, marks: [{ type: 'link', attrs }] })
        .run();
    } else {
      editor.chain().focus().setLink(attrs).run();
    }
    setLinkDialogOpen(false);
  };
  useEffect(() => {
    if (!editor || value === prevValueRef.current) return;
    prevValueRef.current = value;
    editor.commands.setContent(value ?? '', { emitUpdate: false });
  }, [value, editor]);

  useEffect(() => {
    if (!editor) return;
    editor.setEditable(!disabled);
  }, [disabled, editor]);

  return (
    <Box>
      <FormLabel
        sx={{
          fontSize: '0.75rem',
          mb: 0.5,
          display: 'block',
          color: disabled ? 'text.disabled' : 'text.secondary',
        }}
      >
        {label}
      </FormLabel>
      <Box
        sx={{
          border: 1,
          borderColor: disabled ? 'action.disabled' : 'rgba(0,0,0,0.23)',
          borderRadius: 1,
          opacity: disabled ? 0.6 : 1,
          '&:hover': disabled ? {} : { borderColor: 'text.primary' },
        }}
      >
        <Box
          sx={{
            display: 'flex',
            gap: 0.25,
            px: 0.5,
            py: 0.25,
            borderBottom: 1,
            borderColor: 'divider',
            flexWrap: 'wrap',
          }}
        >
          <IconButton
            size="small"
            onMouseDown={(e) => {
              e.preventDefault();
              editor?.chain().focus().toggleBold().run();
            }}
            disabled={disabled}
            color={editor?.isActive('bold') ? 'primary' : 'default'}
          >
            <FormatBoldIcon fontSize="small" />
          </IconButton>
          <IconButton
            size="small"
            onMouseDown={(e) => {
              e.preventDefault();
              editor?.chain().focus().toggleItalic().run();
            }}
            disabled={disabled}
            color={editor?.isActive('italic') ? 'primary' : 'default'}
          >
            <FormatItalicIcon fontSize="small" />
          </IconButton>
          <IconButton
            size="small"
            onMouseDown={(e) => {
              e.preventDefault();
              editor?.chain().focus().toggleBulletList().run();
            }}
            disabled={disabled}
            color={editor?.isActive('bulletList') ? 'primary' : 'default'}
          >
            <FormatListBulletedIcon fontSize="small" />
          </IconButton>
          <IconButton
            size="small"
            onMouseDown={(e) => {
              e.preventDefault();
              editor?.chain().focus().toggleOrderedList().run();
            }}
            disabled={disabled}
            color={editor?.isActive('orderedList') ? 'primary' : 'default'}
          >
            <FormatListNumberedIcon fontSize="small" />
          </IconButton>
          <IconButton
            size="small"
            onMouseDown={(e) => {
              e.preventDefault();
              openLinkDialog();
            }}
            disabled={disabled}
            color={editor?.isActive('link') ? 'primary' : 'default'}
            title={editor?.isActive('link') ? 'Edit link' : 'Insert link'}
          >
            <InsertLinkIcon fontSize="small" />
          </IconButton>
          {editor?.isActive('link') && (
            <IconButton
              size="small"
              onMouseDown={(e) => {
                e.preventDefault();
                editor.chain().focus().unsetLink().run();
              }}
              disabled={disabled}
              color="default"
              title="Remove link"
            >
              <LinkOffIcon fontSize="small" />
            </IconButton>
          )}
        </Box>
        <Box
          onClick={() => editor?.commands.focus()}
          sx={{
            p: 1.5,
            minHeight: 120,
            cursor: disabled ? 'default' : 'text',
            '& .ProseMirror': {
              outline: 'none',
              '& p': { margin: '0 0 0.5em 0' },
              '& p:last-child': { marginBottom: 0 },
              '& ul, & ol': { pl: '1.5rem' },
            },
          }}
        >
          <EditorContent editor={editor} />
        </Box>
      </Box>
      {helperText && <FormHelperText>{helperText}</FormHelperText>}
      <Dialog open={linkDialogOpen} onClose={() => setLinkDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editor?.isActive('link') ? 'Edit link' : 'Insert link'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField
              label="Link text"
              value={linkText}
              onChange={(e) => setLinkText(e.target.value)}
              required
              autoFocus
              fullWidth
              helperText="What readers and screen readers will see — required so the link is never blank."
            />
            <TextField
              label="URL"
              value={linkUrl}
              onChange={(e) => setLinkUrl(e.target.value)}
              required
              fullWidth
              placeholder="https://example.com"
            />
            <FormControlLabel
              control={
                <Checkbox
                  checked={linkNewTab}
                  onChange={(e) => setLinkNewTab(e.target.checked)}
                />
              }
              label="Open in a new tab"
            />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setLinkDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleLinkSave} variant="contained" disabled={!linkUrl.trim() || !linkText.trim()}>
            Save
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
