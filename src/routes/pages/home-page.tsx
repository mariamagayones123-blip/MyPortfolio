/**
 * Placeholder landing route established in Phase 1 (Project Foundation & Setup).
 * Intentionally minimal — Hero and subsequent landing-page content are out of
 * scope until Phase 5 (Landing Page: Hero & Intro), per the official roadmap
 * in docs/01_Project/Project_Roadmap.md. Do not add Hero/section content here
 * before that phase.
 */
export function HomePage() {
  return (
    <div className="mx-auto flex max-w-6xl flex-col items-start gap-2 px-4 py-24 sm:px-6 lg:px-8">
      <p className="text-muted-foreground text-sm font-medium">Phase 1</p>
      <h1 className="text-2xl font-semibold tracking-tight">Project foundation ready</h1>
      <p className="text-muted-foreground max-w-prose">
        Routing, theming, layout, and tooling are configured. Page content will be implemented in
        the next phase.
      </p>
    </div>
  )
}
