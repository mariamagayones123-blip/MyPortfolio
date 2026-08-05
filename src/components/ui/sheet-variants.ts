import { cva } from 'class-variance-authority'

export const sheetVariants = cva(
  'fixed z-(--z-modal) gap-4 border-border bg-surface-raised p-6 text-surface-foreground shadow-xl transition ease-in-out',
  {
    variants: {
      side: {
        top: 'inset-x-0 top-0 border-b data-[state=open]:animate-slide-in-from-top data-[state=closed]:animate-fade-out',
        bottom:
          'inset-x-0 bottom-0 border-t data-[state=open]:animate-slide-in-from-bottom data-[state=closed]:animate-fade-out',
        left: 'inset-y-0 left-0 h-full w-3/4 border-r data-[state=open]:animate-slide-in-from-left data-[state=closed]:animate-fade-out sm:max-w-sm',
        right:
          'inset-y-0 right-0 h-full w-3/4 border-l data-[state=open]:animate-slide-in-from-right data-[state=closed]:animate-fade-out sm:max-w-sm',
      },
    },
    defaultVariants: {
      side: 'right',
    },
  },
)
