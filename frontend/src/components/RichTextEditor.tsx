import { useEffect, useRef } from 'react';
import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Link from '@tiptap/extension-link';
import Box from '@mui/material/Box';
import FormHelperText from '@mui/material/FormHelperText';
import FormLabel from '@mui/material/FormLabel';
import IconButton from '@mui/material/IconButton';
import FormatBoldIcon from '@mui/icons-material/FormatBold';
import FormatItalicIcon from '@mui/icons-material/FormatItalic';
import FormatListBulletedIcon from '@mui/icons-material/FormatListBulleted';
import FormatListNumberedIcon from '@mui/icons-material/FormatListNumbered';

interface Props {
  label: string;
  value: string | null;
  onChange: (html: string) => void;
  disabled?: boolean;
  helperText?: string;
}

export function RichTextEditor({ label, value, onChange, disabled, helperText }: Props) {
  const editor = useEditor({
    extensions: [
      StarterKit,
      Link.configure({ openOnClick: false }),
    ],
    content: value ?? '',
    editable: !disabled,
    onUpdate: ({ editor }) => onChange(editor.getHTML()),
  });

  const prevValueRef = useRef(value);
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
        </Box>
        <Box
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
    </Box>
  );
}
