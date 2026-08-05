import * as React from 'react'
import { cn } from '@lib/utils'

const containerSizes = {
  sm: 'max-w-2xl',
  md: 'max-w-4xl',
  lg: 'max-w-6xl',
  xl: 'max-w-7xl',
  full: 'max-w-none',
} as const

export interface ContainerProps extends React.HTMLAttributes<HTMLDivElement> {
  size?: keyof typeof containerSizes
  as?: React.ElementType
}

/**
 * Horizontally-centered max-width wrapper with consistent gutter padding.
 * Use inside <Section> (or standalone) to constrain content width.
 */
const Container = React.forwardRef<HTMLDivElement, ContainerProps>(
  ({ className, size = 'lg', as: Component = 'div', ...props }, ref) => {
    return (
      <Component
        ref={ref}
        className={cn('mx-auto w-full px-4 sm:px-6 lg:px-8', containerSizes[size], className)}
        {...props}
      />
    )
  },
)
Container.displayName = 'Container'

export { Container }
