/**
 * Self-hosted font faces, loaded once at app entry (see main.tsx).
 *
 * - Inter Variable            → body copy            (--font-sans)
 * - Bricolage Grotesque Var.  → display / headings    (--font-display)
 * - Geist Sans (400/500/600)  → UI chrome / labels     (--font-ui)
 * - Geist Mono (400/500)      → code / technical text  (--font-mono)
 *
 * Using npm-distributed @fontsource packages instead of a Google Fonts
 * CDN link keeps fonts self-hosted (no third-party request, no CLS from
 * an external stylesheet, works offline in dev).
 */
import '@fontsource-variable/inter'
import '@fontsource-variable/bricolage-grotesque'
import '@fontsource/geist-sans/400.css'
import '@fontsource/geist-sans/500.css'
import '@fontsource/geist-sans/600.css'
import '@fontsource/geist-mono/400.css'
import '@fontsource/geist-mono/500.css'
