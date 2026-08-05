import { cva } from 'class-variance-authority'

export const textVariants = cva('text-foreground', {
  variants: {
    variant: {
      display: 'font-display font-semibold tracking-tight text-display',
      h1: 'font-display font-semibold tracking-tight text-h1',
      h2: 'font-display font-semibold tracking-tight text-h2',
      h3: 'font-display font-semibold tracking-tight text-h3',
      h4: 'font-display font-semibold text-h4',
      h5: 'font-ui font-medium text-h5',
      h6: 'font-ui font-medium text-h6',
      'body-lg': 'font-sans text-body-lg',
      body: 'font-sans text-body',
      'body-sm': 'font-sans text-body-sm',
      caption: 'font-sans text-caption text-muted-foreground',
      label: 'font-ui font-medium uppercase tracking-wide text-label text-muted-foreground',
      code: 'font-mono text-code rounded-sm bg-muted px-1.5 py-0.5',
    },
  },
  defaultVariants: {
    variant: 'body',
  },
})

/**
 * Default HTML element rendered for each variant when no explicit `as`
 * prop is supplied. Keeps semantic-by-default while still allowing
 * visual variant to be decoupled from document structure when needed.
 */
export const textDefaultElement = {
  display: 'h1',
  h1: 'h1',
  h2: 'h2',
  h3: 'h3',
  h4: 'h4',
  h5: 'h5',
  h6: 'h6',
  'body-lg': 'p',
  body: 'p',
  'body-sm': 'p',
  caption: 'span',
  label: 'span',
  code: 'code',
} as const
