import { createBrowserRouter } from 'react-router-dom'
import { RootLayout } from '@layouts/root-layout'
import { HomePage } from '@routes/pages/home-page'
import { StyleGuidePage } from '@routes/pages/style-guide-page'
import { NotFoundPage } from '@routes/pages/not-found-page'
import { paths } from '@routes/paths'

/**
 * Route tree. Feature routes should be added here as thin references
 * to page components — feature implementation lives under
 * `src/features/<feature>`, not inline in this file.
 */
export const router = createBrowserRouter([
  {
    path: paths.home,
    element: <RootLayout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: paths.styleGuide.slice(1), element: <StyleGuidePage /> },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
])
