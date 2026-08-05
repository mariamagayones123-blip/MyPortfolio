import type { ReactNode } from 'react'
import { ThemeProvider } from '@components/theme/theme-provider'
import { QueryProvider } from '@providers/query-provider'
import { TooltipProvider } from '@components/ui/tooltip'
import { Toaster } from '@components/ui/sonner'

interface AppProvidersProps {
  children: ReactNode
}

/**
 * Single composition root for all app-wide providers.
 * Keep provider order intentional: Theme wraps everything so it can
 * affect the whole tree; data/query providers sit inside it; Tooltip
 * (which is stateless/context-only) sits innermost alongside the app.
 * <Toaster> is mounted once here so `toast()` can be called from
 * anywhere without re-mounting the host.
 */
export function AppProviders({ children }: AppProvidersProps) {
  return (
    <ThemeProvider>
      <QueryProvider>
        <TooltipProvider delayDuration={200}>
          {children}
          <Toaster />
        </TooltipProvider>
      </QueryProvider>
    </ThemeProvider>
  )
}
