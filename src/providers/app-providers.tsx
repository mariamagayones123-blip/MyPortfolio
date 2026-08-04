import type { ReactNode } from 'react'
import { ThemeProvider } from '@components/theme/theme-provider'
import { QueryProvider } from '@providers/query-provider'

interface AppProvidersProps {
  children: ReactNode
}

/**
 * Single composition root for all app-wide providers.
 * Keep provider order intentional: Theme wraps everything so it can
 * affect the whole tree; data/query providers sit inside it.
 */
export function AppProviders({ children }: AppProvidersProps) {
  return (
    <ThemeProvider>
      <QueryProvider>{children}</QueryProvider>
    </ThemeProvider>
  )
}
