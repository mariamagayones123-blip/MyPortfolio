import { Loader2 } from 'lucide-react'
import { cn } from '@lib/utils'

export interface SpinnerProps {
  className?: string
  /** Accessible label announced to screen readers while loading. */
  label?: string
}

function Spinner({ className, label = 'Loading' }: SpinnerProps) {
  return (
    <span role="status" className="inline-flex items-center">
      <Loader2 className={cn('text-muted-foreground h-4 w-4 animate-spin', className)} />
      <span className="sr-only">{label}</span>
    </span>
  )
}

export { Spinner }
