import { z } from 'zod'

/**
 * Schema for all client-exposed environment variables.
 * Vite only exposes variables prefixed with `VITE_` to the client bundle.
 *
 * Add new variables here AND in `.env.example` so the contract stays
 * documented and validated in one place.
 */
const envSchema = z.object({
  VITE_SUPABASE_URL: z.string().url({ message: 'VITE_SUPABASE_URL must be a valid URL' }),
  VITE_SUPABASE_ANON_KEY: z.string().min(1, 'VITE_SUPABASE_ANON_KEY is required'),
  VITE_SITE_URL: z.string().url().optional(),
  VITE_APP_ENV: z.enum(['development', 'staging', 'production']).default('development'),
})

type Env = z.infer<typeof envSchema>

function loadEnv(): Env {
  const parsed = envSchema.safeParse(import.meta.env)

  if (!parsed.success) {
    // Fail fast and loud in dev; in production a misconfigured env should
    // never silently ship broken behavior.
    const formatted = parsed.error.issues
      .map((issue) => `  - ${issue.path.join('.')}: ${issue.message}`)
      .join('\n')

    if (import.meta.env.DEV) {
      console.warn(
        `⚠️  Environment validation failed. Some features may not work until these are set:\n${formatted}\n\nCopy .env.example to .env.local and fill in the values.`,
      )
      // Return a permissive fallback in dev so the app can still boot and
      // render the foundation/shell before Supabase keys are wired up.
      return {
        VITE_SUPABASE_URL: import.meta.env.VITE_SUPABASE_URL ?? 'http://localhost:54321',
        VITE_SUPABASE_ANON_KEY: import.meta.env.VITE_SUPABASE_ANON_KEY ?? 'dev-placeholder-key',
        VITE_SITE_URL: import.meta.env.VITE_SITE_URL,
        VITE_APP_ENV: 'development',
      }
    }

    throw new Error(`Invalid environment configuration:\n${formatted}`)
  }

  return parsed.data
}

export const env = loadEnv()
