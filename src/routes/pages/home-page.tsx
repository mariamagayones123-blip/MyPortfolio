/**
 * Placeholder landing route for Phase 1 (project foundation).
 * Intentionally minimal — the Hero and subsequent sections are
 * out of scope until Phase 2 (see docs/01_Project/Project_Roadmap.md).
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
