import { ThemeProvider as NextThemesProvider } from 'next-themes'
import type { ReactNode } from 'react'

interface ThemeProviderProps {
  children: ReactNode
}

/**
 * Wraps the app with theme context, enabling `light`, `dark`, and `system`
 * modes. The `.dark` class is toggled on <html>, matching the
 * `@custom-variant dark` selector configured in styles/globals.css.
 *
 * `disableTransitionOnChange` is intentionally left `false`: index.html
 * carries a permanent `.theme-transition` class that animates only
 * color-related properties (see styles/globals.css), so switching themes
 * fades smoothly instead of snapping instantly or flashing unstyled
 * content. The transition is scoped to color/background/border/shadow —
 * layout and transform-based motion elsewhere are unaffected — and is
 * disabled entirely under `prefers-reduced-motion: reduce`.
 */
export function ThemeProvider({ children }: ThemeProviderProps) {
  return (
    <NextThemesProvider attribute="class" defaultTheme="system" enableSystem>
      {children}
    </NextThemesProvider>
  )
}
