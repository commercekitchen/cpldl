import { createTheme, type Theme } from '@mui/material/styles';
import { darken, lighten, alpha } from '@mui/material/styles';
import type { OrganizationConfig } from './types';
import '@fontsource/nunito/400.css';
import '@fontsource/nunito/600.css';
import '@fontsource/nunito/700.css';
import '@fontsource/plus-jakarta-sans/400.css';
import '@fontsource/plus-jakarta-sans/500.css';
import '@fontsource/plus-jakarta-sans/600.css';

const DEFAULT_PRIMARY = '#002536';
const DEFAULT_SECONDARY = '#226E56';

// Good global baseline (don’t customize these unless you validate contrast)
const LIGHT_BASE_PALETTE = {
  text: {
    primary: 'rgba(0, 0, 0, 0.87)',
    secondary: 'rgba(0, 0, 0, 0.60)',
    disabled: 'rgba(0, 0, 0, 0.38)',
  },
  background: {
    default: '#F9FAFB',
    paper: '#FFFFFF',
  },
  divider: 'rgba(0, 0, 0, 0.12)',
};

export function createMuiThemeForOrganization(organizationConfig: OrganizationConfig): Theme {
  const primaryMain = organizationConfig.theme.primaryColor ?? DEFAULT_PRIMARY;
  const secondaryMain = organizationConfig.theme.secondaryColor ?? DEFAULT_SECONDARY;

  // Create a base theme
  const base = createTheme({
    palette: {
      mode: 'light',
      ...LIGHT_BASE_PALETTE,
      primary: { main: primaryMain },
      secondary: { main: secondaryMain },
    },
    typography: {
      fontFamily: '"Plus Jakarta Sans", system-ui, -apple-system, sans-serif',

      h1: { fontFamily: '"Nunito", sans-serif', fontWeight: 700 },
      h2: { fontFamily: '"Nunito", sans-serif', fontWeight: 700 },
      h3: { fontFamily: '"Nunito", sans-serif', fontWeight: 700 },
      h4: { fontFamily: '"Nunito", sans-serif', fontWeight: 600 },
      h5: { fontFamily: '"Nunito", sans-serif', fontWeight: 600 },
      h6: { fontFamily: '"Nunito", sans-serif', fontWeight: 600 },
    },
    shape: {
      // Must be a number; clamp to a sensible range
      borderRadius: clampNumber(organizationConfig.theme.radius, 0, 16, 8),
    },
  });

  // 2) Derive safe-on-brand palette fields
  // getContrastText chooses black/white based on contrast threshold.
  const primaryContrastText = base.palette.getContrastText(primaryMain);
  const secondaryContrastText = base.palette.getContrastText(secondaryMain);

  // Choose light/dark variants that remain coherent in light mode
  // (These are used by some components/variants)
  const primaryLight = lighten(primaryMain, 0.2);
  const primaryDark = darken(primaryMain, 0.2);
  const secondaryLight = lighten(secondaryMain, 0.2);
  const secondaryDark = darken(secondaryMain, 0.2);

  // Add a subtle tint to selected/hover states in a safe way.
  // Uses alpha() so it won’t dominate and should keep contrast.
  const action = {
    hover: alpha(primaryMain, 0.06),
    selected: alpha(primaryMain, 0.1),
    focus: alpha(primaryMain, 0.12),
    disabled: alpha('#000', 0.26),
    disabledBackground: alpha('#000', 0.12),
  };

  // 3) Return a final theme with derived values
  return createTheme(base, {
    palette: {
      action,
      primary: {
        main: primaryMain,
        light: primaryLight,
        dark: primaryDark,
        contrastText: primaryContrastText,
      },
      secondary: {
        main: secondaryMain,
        light: secondaryLight,
        dark: secondaryDark,
        contrastText: secondaryContrastText,
      },
      // Inject stable defaults
      ...LIGHT_BASE_PALETTE,
    },
  });
}

function clampNumber(value: unknown, min: number, max: number, fallback: number): number {
  const n = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(n)) return fallback;
  return Math.min(max, Math.max(min, n));
}
