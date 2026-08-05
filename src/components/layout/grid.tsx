import * as React from 'react'
import { cn } from '@lib/utils'

const colsMap = {
  1: 'grid-cols-1',
  2: 'grid-cols-1 sm:grid-cols-2',
  3: 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3',
  4: 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-4',
  6: 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-6',
  12: 'grid-cols-12',
} as const

const gapScale = {
  0: 'gap-0',
  2: 'gap-2',
  4: 'gap-4',
  6: 'gap-6',
  8: 'gap-8',
  12: 'gap-12',
} as const

export interface GridProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Column count at the largest breakpoint; responsively reduces at smaller ones. */
  cols?: keyof typeof colsMap
  gap?: keyof typeof gapScale
  as?: React.ElementType
}

/**
 * Responsive CSS grid primitive with pre-defined, mobile-first column
 * breakpoints. For bespoke layouts, use `grid-cols-*` utilities directly
 * instead of forcing them through this component.
 */
const Grid = React.forwardRef<HTMLDivElement, GridProps>(
  ({ className, cols = 3, gap = 6, as: Component = 'div', ...props }, ref) => {
    return (
      <Component
        ref={ref}
        className={cn('grid', colsMap[cols], gapScale[gap], className)}
        {...props}
      />
    )
  },
)
Grid.displayName = 'Grid'

export { Grid }
