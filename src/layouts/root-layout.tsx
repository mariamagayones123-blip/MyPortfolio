import { Outlet } from 'react-router-dom'
import { SiteHeader } from '@components/common/site-header'
import { SiteFooter } from '@components/common/site-footer'

/**
 * Top-level application shell. All routed pages render inside <Outlet />.
 * Keep this file free of page-specific content — it should only ever
 * host structural, cross-page chrome (header, footer, skip links).
 */
export function RootLayout() {
  return (
    <div className="bg-background text-foreground flex min-h-dvh flex-col">
      <a
        href="#main-content"
        className="focus:bg-primary focus:text-primary-foreground sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:rounded-md focus:px-4 focus:py-2"
      >
        Skip to content
      </a>
      <SiteHeader />
      <main id="main-content" className="flex-1">
        <Outlet />
      </main>
      <SiteFooter />
    </div>
  )
}
