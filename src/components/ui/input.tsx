import * as React from 'react'
import { cn } from '@lib/utils'

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  /** Marks the field as invalid; pairs with aria-describedby pointing to the error message. */
  invalid?: boolean
}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type = 'text', invalid, ...props }, ref) => {
    return (
      <input
        type={type}
        ref={ref}
        aria-invalid={invalid || props['aria-invalid']}
        className={cn(
          'border-input bg-background text-body-sm flex h-9 w-full rounded-md border px-3 py-1 shadow-sm transition-colors',
          'placeholder:text-muted-foreground',
          'focus-visible:ring-ring focus-visible:ring-offset-background focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:outline-none',
          'disabled:cursor-not-allowed disabled:opacity-50',
          'aria-[invalid=true]:border-destructive aria-[invalid=true]:focus-visible:ring-destructive',
          'file:border-0 file:bg-transparent file:text-sm file:font-medium',
          className,
        )}
        {...props}
      />
    )
  },
)
Input.displayName = 'Input'

export { Input }
