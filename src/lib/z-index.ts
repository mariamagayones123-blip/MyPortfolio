/**
 * Semantic z-index layers. Mirrors the --z-* custom properties defined in
 * styles/globals.css. Prefer these constants (or the matching CSS var)
 * over ad-hoc `z-50` guesses so stacking order stays consistent across
 * overlays, menus, and toasts.
 */
export const zIndex = {
  base: 0,
  dropdown: 1000,
  sticky: 1100,
  fixed: 1200,
  overlay: 1300,
  modal: 1400,
  popover: 1500,
  tooltip: 1600,
  toast: 1700,
} as const

export type ZIndexLayer = keyof typeof zIndex
