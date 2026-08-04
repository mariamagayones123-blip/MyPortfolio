import { createClient } from '@supabase/supabase-js'
import { env } from '@config/env'

/**
 * Singleton Supabase client for the browser.
 * Uses the public anon key only — never expose the service role key
 * to the client. See docs/06_Supabase/API_Keys.md.
 */
export const supabase = createClient(env.VITE_SUPABASE_URL, env.VITE_SUPABASE_ANON_KEY)
