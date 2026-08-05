import * as React from 'react'
import { useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import { cn } from '@lib/utils'

export interface PageWrapperProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Sets `document.title`, prefixed consistently. Omit to leave the title untouched. */
  title?: string
}

/**
 * Wraps an individual route's page content. Handles the two concerns
 * every page needs (scroll-to-top on navigation, document title) so
 * page components stay focused on content. Use inside `routes/pages/*`,
 * not in <RootLayout> — RootLayout is the app shell, this is per-page.
 */
function PageWrapper({ title, className, children, ...props }: PageWrapperProps) {
  const location = useLocation()

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'instant' as ScrollBehavior })
  }, [location.pathname])

  useEffect(() => {
    if (title) {
      const previousTitle = document.title
      document.title = `${title} · Portfolio`
      return () => {
        document.title = previousTitle
      }
    }
  }, [title])

  return (
    <div className={cn(className)} {...props}>
      {children}
    </div>
  )
}

export { PageWrapper }
