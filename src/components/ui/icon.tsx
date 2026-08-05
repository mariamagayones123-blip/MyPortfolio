import * as React from 'react'
import type { LucideIcon, LucideProps } from 'lucide-react'
import { cn } from '@lib/utils'

const iconSizes = {
  xs: 'h-3 w-3',
  sm: 'h-4 w-4',
  md: 'h-5 w-5',
  lg: 'h-6 w-6',
  xl: 'h-8 w-8',
} as const

export type IconSize = keyof typeof iconSizes

export interface IconProps extends Omit<LucideProps, 'size'> {
  /** Any lucide-react icon component, e.g. `icon={ArrowRight}`. */
  icon: LucideIcon
  size?: IconSize
  /** Accessible label. Omit (default) to keep the icon decorative/aria-hidden. */
  label?: string
}

/**
 * Thin, consistent wrapper around lucide-react icons so size and
 * accessibility semantics stay uniform across the app instead of every
 * call site hand-picking a pixel size and forgetting aria handling.
 *
 * @example
 * <Icon icon={ArrowRight} size="sm" />
 * <Icon icon={Trash2} label="Delete project" className="text-destructive" />
 */
const Icon = React.forwardRef<SVGSVGElement, IconProps>(
  ({ icon: LucideIconComponent, size = 'md', label, className, ...props }, ref) => {
    return (
      <LucideIconComponent
        ref={ref}
        className={cn(iconSizes[size], className)}
        aria-hidden={label ? undefined : true}
        role={label ? 'img' : undefined}
        aria-label={label}
        {...props}
      />
    )
  },
)
Icon.displayName = 'Icon'

export { Icon }
