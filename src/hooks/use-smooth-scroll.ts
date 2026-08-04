import { useEffect } from 'react'
import Lenis from 'lenis'

/**
 * Initializes Lenis smooth-scroll and drives it from requestAnimationFrame.
 * Call once near the app root once a scroll-driven section is introduced.
 * Left unused in Phase 1 intentionally — no scroll animation exists yet.
 */
export function useSmoothScroll() {
  useEffect(() => {
    const lenis = new Lenis()

    let frameId: number
    function raf(time: number) {
      lenis.raf(time)
      frameId = requestAnimationFrame(raf)
    }
    frameId = requestAnimationFrame(raf)

    return () => {
      cancelAnimationFrame(frameId)
      lenis.destroy()
    }
  }, [])
}
