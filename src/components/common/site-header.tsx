import { Link } from 'react-router-dom'
import { ThemeToggle } from '@components/theme/theme-toggle'

/**
 * Placeholder shell header for Phase 1. Navigation links and branding
 * will be implemented in the design/build-out phase per
 * docs/04_Design/UI_UX_Guidelines.md.
 */
export function SiteHeader() {
  return (
    <header className="border-border bg-background/80 sticky top-0 z-40 border-b backdrop-blur">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link to="/" className="text-sm font-semibold tracking-tight">
          Portfolio
        </Link>
        <ThemeToggle />
      </div>
    </header>
  )
}
