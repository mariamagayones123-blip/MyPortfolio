export function SiteFooter() {
  return (
    <footer className="border-border border-t">
      <div className="text-muted-foreground mx-auto max-w-6xl px-4 py-6 text-sm sm:px-6 lg:px-8">
        © {new Date().getFullYear()} — Built with React, TypeScript &amp; Supabase.
      </div>
    </footer>
  )
}
