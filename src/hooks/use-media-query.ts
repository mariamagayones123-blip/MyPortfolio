import { useSyncExternalStore } from 'react'

/**
 * Reactively evaluates an arbitrary media query string, e.g.
 * `useMediaQuery('(min-width: 64rem)')`. Prefer Tailwind responsive
 * classes for styling; reach for this only when a layout decision
 * needs to branch in JS (e.g. swapping components, not just classes).
 */
export function useMediaQuery(query: string) {
  const subscribe = (callback: () => void) => {
    const mediaQueryList = window.matchMedia(query)
    mediaQueryList.addEventListener('change', callback)
    return () => mediaQueryList.removeEventListener('change', callback)
  }

  const getSnapshot = () => window.matchMedia(query).matches
  const getServerSnapshot = () => false

  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
}

/** Convenience wrapper matching the design system's `md` breakpoint (48rem / 768px). */
export function useIsDesktop() {
  return useMediaQuery('(min-width: 48rem)')
}
