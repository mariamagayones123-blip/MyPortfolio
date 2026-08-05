import * as React from 'react'
import { Slot } from '@radix-ui/react-slot'
import type { VariantProps } from 'class-variance-authority'
import { cn } from '@lib/utils'
import { textVariants, textDefaultElement } from '@components/ui/text-variants'

type TextVariant = NonNullable<VariantProps<typeof textVariants>['variant']>

export interface TextProps
  extends React.HTMLAttributes<HTMLElement>, VariantProps<typeof textVariants> {
  /** Render as a different element/component (Radix Slot pattern). */
  asChild?: boolean
  /** Override the semantic element used for this variant. */
  as?: React.ElementType
}

/**
 * Single source of truth for all text styling. Prefer this over
 * hand-writing `text-*`/`font-*` utility combinations so the typography
 * scale in styles/globals.css stays the only place sizes are defined.
 *
 * @example
 * <Text variant="display">Building for the web</Text>
 * <Text variant="body" as="span">Inline body copy</Text>
 * <Text variant="code">npm run build</Text>
 */
const Text = React.forwardRef<HTMLElement, TextProps>(
  ({ className, variant = 'body', asChild = false, as, ...props }, ref) => {
    const resolvedVariant = (variant ?? 'body') as TextVariant
    const Component = asChild ? Slot : (as ?? textDefaultElement[resolvedVariant])

    return (
      <Component
        ref={ref}
        className={cn(textVariants({ variant: resolvedVariant }), className)}
        {...props}
      />
    )
  },
)
Text.displayName = 'Text'

export { Text }
