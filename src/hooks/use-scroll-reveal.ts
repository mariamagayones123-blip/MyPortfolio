import { useRef } from 'react'
import { useInView } from 'framer-motion'
import { usePrefersReducedMotion } from '@hooks/use-reduced-motion'

export interface UseScrollRevealOptions {
  /** Fraction of the element that must be visible before it triggers. */
  amount?: number
  /** Only animate the first time the element enters the viewport. */
  once?: boolean
}

/**
 * Returns a ref to attach to an element and whether it should currently
 * be shown as "revealed". Pair with the `fadeInUp` / `staggerContainer`
 * variants in lib/motion.ts:
 *
 * @example
 * const { ref, isInView } = useScrollReveal()
 * <motion.div ref={ref} variants={fadeInUp} initial="hidden" animate={isInView ? 'visible' : 'hidden'} />
 *
 * When the user prefers reduced motion, `isInView` is forced to `true`
 * immediately so content isn't gated behind a scroll-triggered animation.
 */
export function useScrollReveal({ amount = 0.3, once = true }: UseScrollRevealOptions = {}) {
  const ref = useRef<HTMLDivElement>(null)
  const inView = useInView(ref, { amount, once })
  const prefersReducedMotion = usePrefersReducedMotion()

  return { ref, isInView: prefersReducedMotion || inView }
}
