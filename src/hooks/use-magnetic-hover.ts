import { useEffect, useRef } from 'react'
import { gsap } from '@lib/gsap'
import { usePrefersReducedMotion } from '@hooks/use-reduced-motion'

export interface UseMagneticHoverOptions {
  /** How strongly the element follows the cursor (0–1). */
  strength?: number
}

/**
 * Attaches a GSAP-driven "magnetic" pull-toward-cursor effect, commonly
 * used on primary CTA buttons. Returns a ref to attach to the target
 * element. No-ops under `prefers-reduced-motion`. Not applied anywhere
 * yet — available for the Hero/CTA build-out in Phase 5 (Landing Page:
 * Hero & Intro), per docs/01_Project/Project_Roadmap.md.
 *
 * @example
 * const magneticRef = useMagneticHover()
 * <Button ref={magneticRef}>Get in touch</Button>
 */
export function useMagneticHover({ strength = 0.3 }: UseMagneticHoverOptions = {}) {
  const ref = useRef<HTMLElement>(null)
  const prefersReducedMotion = usePrefersReducedMotion()

  useEffect(() => {
    const element = ref.current
    if (!element || prefersReducedMotion) return

    function handlePointerMove(event: PointerEvent) {
      const bounds = element!.getBoundingClientRect()
      const x = (event.clientX - bounds.left - bounds.width / 2) * strength
      const y = (event.clientY - bounds.top - bounds.height / 2) * strength
      gsap.to(element, { x, y, duration: 0.3, ease: 'power3.out' })
    }

    function handlePointerLeave() {
      gsap.to(element, { x: 0, y: 0, duration: 0.4, ease: 'elastic.out(1, 0.4)' })
    }

    element.addEventListener('pointermove', handlePointerMove)
    element.addEventListener('pointerleave', handlePointerLeave)

    return () => {
      element.removeEventListener('pointermove', handlePointerMove)
      element.removeEventListener('pointerleave', handlePointerLeave)
    }
  }, [strength, prefersReducedMotion])

  return ref
}
