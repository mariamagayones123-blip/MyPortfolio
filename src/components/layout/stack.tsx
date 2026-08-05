import * as React from 'react'
import { cn } from '@lib/utils'

const gapScale = {
  0: 'gap-0',
  1: 'gap-1',
  2: 'gap-2',
  3: 'gap-3',
  4: 'gap-4',
  6: 'gap-6',
  8: 'gap-8',
  12: 'gap-12',
  16: 'gap-16',
} as const

const alignMap = {
  start: 'items-start',
  center: 'items-center',
  end: 'items-end',
  stretch: 'items-stretch',
  baseline: 'items-baseline',
} as const

const justifyMap = {
  start: 'justify-start',
  center: 'justify-center',
  end: 'justify-end',
  between: 'justify-between',
  around: 'justify-around',
} as const

export interface StackProps extends React.HTMLAttributes<HTMLDivElement> {
  /** `column` (default) stacks vertically; `row` lays out horizontally. */
  direction?: 'row' | 'column'
  gap?: keyof typeof gapScale
  align?: keyof typeof alignMap
  justify?: keyof typeof justifyMap
  wrap?: boolean
  as?: React.ElementType
}

/**
 * Flexbox layout primitive for consistent spacing between children.
 * Prefer this over ad-hoc `flex flex-col gap-*` combinations so gap
 * values stay on the shared scale.
 */
const Stack = React.forwardRef<HTMLDivElement, StackProps>(
  (
    {
      className,
      direction = 'column',
      gap = 4,
      align,
      justify,
      wrap = false,
      as: Component = 'div',
      ...props
    },
    ref,
  ) => {
    return (
      <Component
        ref={ref}
        className={cn(
          'flex',
          direction === 'row' ? 'flex-row' : 'flex-col',
          gapScale[gap],
          align && alignMap[align],
          justify && justifyMap[justify],
          wrap && 'flex-wrap',
          className,
        )}
        {...props}
      />
    )
  },
)
Stack.displayName = 'Stack'

export { Stack }
