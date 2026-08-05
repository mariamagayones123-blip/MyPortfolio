import * as React from 'react'
import { cn } from '@lib/utils'
import { Container } from '@components/layout/container'

const spacingY = {
  none: '',
  sm: 'py-12',
  md: 'py-16 md:py-24',
  lg: 'py-24 md:py-32',
} as const

export interface SectionProps extends React.HTMLAttributes<HTMLElement> {
  spacing?: keyof typeof spacingY
  containerSize?: React.ComponentProps<typeof Container>['size']
  /** Set false to render children full-bleed without the inner <Container>. */
  contained?: boolean
}

/**
 * Top-level page section: a semantic <section>, consistent vertical
 * rhythm, and (by default) a centered max-width container. Every
 * portfolio section (Hero, About, Projects, ...) should be built as a
 * <Section>, not a raw <div>, so spacing stays consistent site-wide.
 */
const Section = React.forwardRef<HTMLElement, SectionProps>(
  (
    { className, spacing = 'md', containerSize = 'lg', contained = true, children, ...props },
    ref,
  ) => {
    return (
      <section ref={ref} className={cn(spacingY[spacing], className)} {...props}>
        {contained ? <Container size={containerSize}>{children}</Container> : children}
      </section>
    )
  },
)
Section.displayName = 'Section'

export { Section }
