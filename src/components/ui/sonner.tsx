import type React from 'react'
import { useTheme } from 'next-themes'
import { Toaster as Sonner, type ToasterProps } from 'sonner'

/**
 * App-wide toast host. Mount once near the root (see providers/app-providers.tsx)
 * and trigger toasts anywhere via `import { toast } from 'sonner'`.
 */
function Toaster(props: ToasterProps) {
  const { theme = 'system' } = useTheme()

  return (
    <Sonner
      theme={theme as ToasterProps['theme']}
      className="toaster group"
      position="bottom-right"
      style={
        {
          '--normal-bg': 'hsl(var(--surface-raised))',
          '--normal-text': 'hsl(var(--surface-foreground))',
          '--normal-border': 'hsl(var(--border))',
          '--success-bg': 'hsl(var(--success))',
          '--success-text': 'hsl(var(--success-foreground))',
          '--error-bg': 'hsl(var(--destructive))',
          '--error-text': 'hsl(var(--destructive-foreground))',
        } as React.CSSProperties
      }
      {...props}
    />
  )
}

export { Toaster }
