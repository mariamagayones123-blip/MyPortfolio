import { Link } from 'react-router-dom'
import { Command } from 'lucide-react'
import { ThemeToggle } from '@components/theme/theme-toggle'
import { CommandMenu } from '@components/common/command-menu'
import { VisuallyHidden } from '@components/ui/visually-hidden'
import { useCommandPalette } from '@hooks/use-command-palette'

/**
 * Placeholder shell header for Phase 1/2. Navigation links and branding
 * will be implemented in the content build-out per
 * docs/04_Design/UI_UX_Guidelines.md.
 */
export function SiteHeader() {
  const { open, setOpen } = useCommandPalette()

  return (
    <header className="border-border bg-background/80 sticky top-0 z-(--z-sticky) border-b backdrop-blur">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link to="/" className="text-sm font-semibold tracking-tight">
          Portfolio
        </Link>
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setOpen(true)}
            className="border-border bg-surface text-body-sm text-muted-foreground hover:bg-accent hover:text-accent-foreground focus-visible:ring-ring focus-visible:ring-offset-background inline-flex h-9 items-center gap-2 rounded-lg border px-3 transition-colors focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:outline-none"
          >
            <Command className="h-4 w-4" />
            {/* "Search" is only shown visually from `sm` up (the `kbd` hint
                needs the room); VisuallyHidden keeps an accessible name for
                everyone else instead of leaving the button icon-only. */}
            <span className="hidden sm:inline" aria-hidden="true">
              Search
            </span>
            <VisuallyHidden>Open search / command menu</VisuallyHidden>
            <kbd className="border-border bg-background hidden rounded border px-1.5 py-0.5 text-xs sm:inline">
              ⌘K
            </kbd>
          </button>
          <ThemeToggle />
        </div>
      </div>
      <CommandMenu open={open} onOpenChange={setOpen} />
    </header>
  )
}
