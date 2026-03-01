import { useEffect, useRef, useState } from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import CircularProgress from '@mui/material/CircularProgress';
import TextField from '@mui/material/TextField';
import InputAdornment from '@mui/material/InputAdornment';
import SearchIcon from '@mui/icons-material/Search';
import type { CourseSearchSuggestion } from '../api/searchApi';
import { searchCourseSuggestions } from '../api/searchApi';

type Props = {
  value: string;
  onValueChange: (value: string) => void;
  onSelect: (course: CourseSearchSuggestion) => void;
  onSubmit: (query: string) => void;
  autoFocus?: boolean;
  fullWidth?: boolean;
  focusSignal?: number;
};

export function CourseSearchBar({
  value,
  onValueChange,
  onSelect,
  onSubmit,
  autoFocus = false,
  fullWidth = false,
  focusSignal = 0,
}: Props) {
  const inputRef = useRef<HTMLInputElement | null>(null);
  const [options, setOptions] = useState<CourseSearchSuggestion[]>([]);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (autoFocus) {
      const id = window.setTimeout(() => inputRef.current?.focus(), 0);
      return () => window.clearTimeout(id);
    }
    return;
  }, [autoFocus]);

  useEffect(() => {
    if (focusSignal === 0) return;
    const id = window.setTimeout(() => inputRef.current?.focus(), 0);
    return () => window.clearTimeout(id);
  }, [focusSignal]);

  useEffect(() => {
    const trimmed = value.trim();
    if (trimmed.length === 0) {
      setOptions([]);
      return;
    }

    const controller = new AbortController();
    const id = window.setTimeout(async () => {
      setLoading(true);
      try {
        const results = await searchCourseSuggestions(trimmed, { signal: controller.signal });
        setOptions(results);
      } catch (err) {
        if (!controller.signal.aborted) setOptions([]);
      } finally {
        if (!controller.signal.aborted) setLoading(false);
      }
    }, 250);

    return () => {
      controller.abort();
      window.clearTimeout(id);
    };
  }, [value]);

  return (
    <Autocomplete
      disablePortal
      clearOnBlur={false}
      options={options}
      getOptionLabel={(option) => option.title}
      loading={loading}
      open={open && options.length > 0}
      onOpen={() => setOpen(true)}
      onClose={() => setOpen(false)}
      onChange={(_, selected) => {
        if (selected) onSelect(selected);
      }}
      inputValue={value}
      onInputChange={(_, newValue, reason) => {
        if (reason === 'blur') return;
        onValueChange(newValue);
      }}
      renderInput={(params) => (
        <TextField
          {...params}
          placeholder="Search courses"
          inputRef={inputRef}
          onKeyDown={(event) => {
            if (event.key === 'Enter') {
              const q = value.trim();
              if (q) onSubmit(q);
            }
          }}
          InputProps={{
            ...params.InputProps,
            startAdornment: (
              <InputAdornment position="start" sx={{ ml: 0.5 }}>
                <SearchIcon fontSize="small" color="action" />
              </InputAdornment>
            ),
            endAdornment: (
              <>
                {loading ? <CircularProgress color="inherit" size={16} /> : null}
                {params.InputProps.endAdornment}
              </>
            ),
            sx: {
              borderRadius: 999,
              pr: 1,
            },
          }}
          fullWidth={fullWidth}
          size="medium"
        />
      )}
      sx={{
        '& .MuiOutlinedInput-root': {
          borderRadius: 999,
          backgroundColor: 'background.paper',
        },
      }}
    />
  );
}
