import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import '@styles/fonts'
import '@styles/globals.css'
import { App } from '@/App'
import { AppProviders } from '@providers/app-providers'

const rootElement = document.getElementById('root')

if (!rootElement) {
  throw new Error('Root element #root not found in index.html')
}

createRoot(rootElement).render(
  <StrictMode>
    <AppProviders>
      <App />
    </AppProviders>
  </StrictMode>,
)
