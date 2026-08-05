import type { ReactNode } from 'react'
import { motion, type Variants } from 'framer-motion'
import { useScrollReveal } from '@hooks/use-scroll-reveal'
import { fadeInUp } from '@lib/motion'

export interface RevealProps {
  children: ReactNode
  /** Any Variants object from lib/motion.ts; defaults to fadeInUp. */
  variants?: Variants
  /** Fraction of the element visible before revealing (0–1). */
  amount?: number
  /** Delay in seconds, useful when staggering multiple <Reveal> siblings manually. */
  delay?: number
  className?: string
}

/**
 * Ready-made scroll-reveal wrapper: fades/slides children in once they
 * enter the viewport, and skips the animation entirely under
 * `prefers-reduced-motion`. Not used anywhere yet — available for the
 * content phases to drop around sections, cards, or list items.
 *
 * @example
 * <Reveal><ProjectCard {...project} /></Reveal>
 * <Reveal variants={scaleIn} delay={0.1}>...</Reveal>
 */
export function Reveal({
  children,
  variants = fadeInUp,
  amount = 0.3,
  delay = 0,
  className,
}: RevealProps) {
  const { ref, isInView } = useScrollReveal({ amount })

  return (
    <motion.div
      ref={ref}
      variants={variants}
      initial="hidden"
      animate={isInView ? 'visible' : 'hidden'}
      transition={{ delay }}
      className={className}
    >
      {children}
    </motion.div>
  )
}
