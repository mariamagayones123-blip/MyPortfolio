import * as VisuallyHiddenPrimitive from '@radix-ui/react-visually-hidden'

/**
 * Renders content that's read by screen readers but not shown visually —
 * e.g. a label for an icon-only button. Prefer this over the `.sr-only`
 * utility class when the hidden content needs to remain in the
 * accessibility tree as a real (not just visually clipped) element.
 */
const VisuallyHidden = VisuallyHiddenPrimitive.Root

export { VisuallyHidden }
