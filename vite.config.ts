import path from 'node:path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, './src'),
      '@components': path.resolve(import.meta.dirname, './src/components'),
      '@features': path.resolve(import.meta.dirname, './src/features'),
      '@layouts': path.resolve(import.meta.dirname, './src/layouts'),
      '@lib': path.resolve(import.meta.dirname, './src/lib'),
      '@hooks': path.resolve(import.meta.dirname, './src/hooks'),
      '@routes': path.resolve(import.meta.dirname, './src/routes'),
      '@styles': path.resolve(import.meta.dirname, './src/styles'),
      '@types': path.resolve(import.meta.dirname, './src/types'),
      '@assets': path.resolve(import.meta.dirname, './src/assets'),
      '@config': path.resolve(import.meta.dirname, './src/config'),
      '@providers': path.resolve(import.meta.dirname, './src/providers'),
    },
  },
  server: {
    port: 5173,
    strictPort: false,
  },
  build: {
    sourcemap: true,
  },
})
