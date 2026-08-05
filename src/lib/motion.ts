import type { Transition, Variants } from 'framer-motion'

/**
 * Motion foundation: shared Framer Motion variants and transition presets,
 * keyed to the duration/easing tokens in styles/globals.css so animation
 * timing stays consistent with the rest of the design system.
 *
 * Nothing here is wired into any page yet — these are building blocks for
 * the content phases (Hero, About, Projects, ...) to import and apply.
 */

export const duration = {
  instant: 0.1,
  fast: 0.15,
  base: 0.25,
  slow: 0.4,
  slower: 0.6,
} as const

export const easing = {
  out: [0.16, 1, 0.3, 1],
  inOut: [0.65, 0, 0.35, 1],
  spring: [0.34, 1.56, 0.64, 1],
} as const satisfies Record<string, Transition['ease']>

export const transitions = {
  base: { duration: duration.base, ease: easing.out },
  slow: { duration: duration.slow, ease: easing.out },
  spring: { type: 'spring', stiffness: 300, damping: 24 },
} as const satisfies Record<string, Transition>

export const fadeIn: Variants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: transitions.base },
}

export const fadeInUp: Variants = {
  hidden: { opacity: 0, y: 16 },
  visible: { opacity: 1, y: 0, transition: transitions.base },
}

export const fadeInDown: Variants = {
  hidden: { opacity: 0, y: -16 },
  visible: { opacity: 1, y: 0, transition: transitions.base },
}

export const slideInLeft: Variants = {
  hidden: { opacity: 0, x: -24 },
  visible: { opacity: 1, x: 0, transition: transitions.base },
}

export const slideInRight: Variants = {
  hidden: { opacity: 0, x: 24 },
  visible: { opacity: 1, x: 0, transition: transitions.base },
}

export const scaleIn: Variants = {
  hidden: { opacity: 0, scale: 0.96 },
  visible: { opacity: 1, scale: 1, transition: transitions.spring },
}

/** Apply to a parent; children using `staggerItem` animate in sequence. */
export const staggerContainer = (staggerDelay = 0.08): Variants => ({
  hidden: {},
  visible: {
    transition: {
      staggerChildren: staggerDelay,
    },
  },
})

export const staggerItem: Variants = {
  hidden: { opacity: 0, y: 12 },
  visible: { opacity: 1, y: 0, transition: transitions.base },
}

/** Subtle hover lift, for cards and interactive tiles. */
export const hoverLift = {
  rest: { y: 0, scale: 1 },
  hover: { y: -4, scale: 1.01, transition: transitions.base },
}

/** Subtle hover scale, for buttons and icon targets. */
export const hoverScale = {
  rest: { scale: 1 },
  hover: { scale: 1.03, transition: transitions.base },
  tap: { scale: 0.97, transition: { duration: duration.instant } },
}
