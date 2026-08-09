# Interactive Developer Portfolio

Production-grade developer portfolio built with React 19, TypeScript, Vite, and Tailwind CSS v4.

> **Status:** Phase 2 — Design System & Theme Architecture — complete. No portfolio content
> sections (Hero, About, Projects, Contact, ...) are implemented yet. **Next: Phase 3 — Supabase
> Backend & Database.** See [docs/01_Project/Project_Roadmap.md](docs/01_Project/Project_Roadmap.md)
> for the full, authoritative 16-phase implementation order — it is final and must not be
> reordered or reinterpreted.

## Stack

- **Framework:** React 19 + TypeScript + Vite
- **Styling:** Tailwind CSS v4, CSS-variable design tokens, `next-themes` (light/dark/system)
- **Typography:** Inter, Bricolage Grotesque, Geist Sans/Mono — self-hosted via `@fontsource`
- **Routing:** React Router v7
- **Data:** TanStack Query, Supabase (`@supabase/supabase-js`)
- **Forms:** React Hook Form + Zod (installed, ready for the first real form in a content phase)
- **Motion:** Framer Motion, GSAP, Lenis (smooth scroll) — foundation utilities only, not yet
  applied to any page
- **UI primitives:** shadcn/ui conventions (`components.json`, Radix UI, `class-variance-authority`)
- **Command palette:** `cmdk` (Ctrl/Cmd+K)
- **Toasts:** `sonner`
- **Tooling:** ESLint (flat config), Prettier (+ Tailwind plugin), strict TypeScript

## Getting started

```bash
npm install
cp .env.example .env.local   # fill in Supabase project values
npm run dev
```

Visit `/design-system` for a live reference of every token and component built in Phase 2.

## Scripts

| Script                 | Purpose                                        |
| ---------------------- | ---------------------------------------------- |
| `npm run dev`          | Start the Vite dev server                      |
| `npm run build`        | Type-check (`tsc -b`) and build for production |
| `npm run preview`      | Preview the production build locally           |
| `npm run lint`         | Lint with ESLint                               |
| `npm run lint:fix`     | Lint and auto-fix                              |
| `npm run format`       | Format the codebase with Prettier              |
| `npm run format:check` | Check formatting without writing               |
| `npm run typecheck`    | Type-check only, no emit                       |

## Project structure

```text
src/
├── assets/          Images, fonts, icons
├── components/
│   ├── ui/            Design-system primitives (Button, Card, Dialog, Command palette, ...)
│   ├── layout/         Layout primitives (Container, Section, Stack, Grid, PageWrapper)
│   ├── motion/          Motion-foundation components (Reveal)
│   ├── common/           Cross-page chrome (header, footer, command menu)
│   └── theme/             Theme provider + toggle
├── config/          Environment variable schema (Zod-validated)
├── features/        Feature-first modules (hero, about, projects, contact, ...) — empty scaffolds
├── hooks/           Shared hooks (media query, reduced motion, scroll reveal, command palette, ...)
├── layouts/         Route-level layout shells
├── lib/             Framework-agnostic utilities (cn, motion variants, z-index scale, gsap setup)
├── providers/       App-wide React context providers (theme, query client, tooltip, toaster)
├── routes/          Router config, route paths, route-level page components
├── styles/          Tailwind entrypoint, design tokens, self-hosted font loading
└── types/           Shared TypeScript types
```

## Path aliases

`@`, `@components`, `@features`, `@layouts`, `@lib`, `@hooks`, `@routes`, `@styles`, `@types`,
`@assets`, `@config`, `@providers` all resolve to their matching `src/*` folder — configured in
both `vite.config.ts` and `tsconfig.app.json`.

## Environment variables

See `.env.example`. All client env vars are validated at startup via `src/config/env.ts`
(Zod schema) — in dev, invalid/missing values log a warning and fall back to placeholders so the
shell still boots; in production, invalid config throws immediately.

## Design tokens

All tokens live in `src/styles/globals.css` as semantic HSL/value custom properties, mapped into
Tailwind's `@theme` so they're consumable as ordinary utility classes (`bg-background`,
`shadow-md`, `duration-(--duration-base)`, `text-h2`, `font-display`, `z-(--z-modal)`, etc.):

- **Color** — background/foreground/surface/primary/secondary/muted/accent/brand/success/warning/
  destructive/info, each with light + dark values
- **Typography** — `--text-display` through `--text-code`, each a paired size/line-height/
  letter-spacing token; three font families (`--font-sans`, `--font-display`, `--font-ui`,
  `--font-mono`)
- **Radius** — `--radius-xs` through `--radius-2xl`
- **Shadow** — `--shadow-sm/md/lg/xl` + `--shadow-glow`, tinted per theme via `--shadow-color`
- **Gradient** — `--gradient-brand`, `--gradient-radial-glow`, `--gradient-mesh`
- **Motion** — `--duration-*` (100–600ms) and `--ease-out/in-out/spring` cubic-béziers
- **Blur** — `--blur-glass`
- **Z-index** — semantic layers (`--z-dropdown` … `--z-toast`), mirrored as a TS constant in
  `src/lib/z-index.ts`
- **Breakpoints** — Tailwind defaults plus `xs` (30rem) and `3xl` (120rem)

Placeholder brand color values — replace once `docs/04_Design/Color_System.md` exists.

## Theming

Light/dark/system modes are handled by `next-themes`, toggling a `.dark` class on `<html>`.
Switching themes fades color-related properties smoothly (see the `.theme-transition` rule in
`globals.css`), scoped to `background-color`/`border-color`/`color`/`fill`/`stroke`/`box-shadow`
only — layout and transform-based motion elsewhere are unaffected — and is disabled entirely
under `prefers-reduced-motion: reduce`.

## Component library

Built on Radix UI primitives + `class-variance-authority`, all reading from the tokens above and
supporting dark/light mode out of the box: Button, Card, Badge, Input, Textarea, Label, Select,
Checkbox, Switch, Tooltip, Dialog, Sheet, Dropdown Menu, Tabs, Accordion, Avatar, Skeleton,
Spinner, Separator, Toast (`sonner`), and a Command Palette (`cmdk`, bound to Ctrl/Cmd+K — see
`hooks/use-command-palette.ts`). Plus supporting primitives: `Text` (typography scale), `Icon`
(lucide-react wrapper), `VisuallyHidden`.

Browse them all live at `/design-system`.

### Adding shadcn/ui components

This sandbox couldn't reach `ui.shadcn.com` to run the CLI, so components were hand-authored
following shadcn conventions. In a normal dev environment with network access, add further
components the standard way — `components.json` is already configured with the project's aliases:

```bash
npx shadcn@latest add <component>
```

## Layout foundation

`Container` (max-width + gutters), `Section` (semantic `<section>` + vertical rhythm), `Stack`
(flex with a shared gap scale), `Grid` (responsive column presets), `PageWrapper` (per-route
scroll-reset + document title) — all in `src/components/layout/`.

## Motion foundation

Shared Framer Motion variants and transition presets in `src/lib/motion.ts` (fade, slide, scale,
stagger), a `<Reveal>` scroll-triggered wrapper component, and hooks: `useScrollReveal`,
`usePrefersReducedMotion`, `useMediaQuery`, `useMagneticHover` (GSAP-based). **None of these are
applied to any page yet** — they're building blocks for the content phases.

## Environment/network note

This sandbox's outbound network is limited to package registries (npm, PyPI, crates, GitHub) —
`ui.shadcn.com` and font CDNs aren't reachable. Fonts are self-hosted via `@fontsource` packages
instead of a Google Fonts `<link>`, and shadcn components were hand-authored rather than pulled
via its CLI, both of which work identically in a normal environment.

## Documentation

Project documentation lives under `docs/`, organized by concern:

- [`docs/01_Project/Project_Roadmap.md`](docs/01_Project/Project_Roadmap.md) — the final,
  authoritative 16-phase implementation order. Never reordered.
- [`docs/03_Development/AI_Development_Specification.md`](docs/03_Development/AI_Development_Specification.md)
  — engineering standards, tech stack, and workflow rules.
- [`docs/12_AI/AI_Project_Instructions.md`](docs/12_AI/AI_Project_Instructions.md) — rules
  governing AI-assisted work on this project, including Roadmap Compliance.

If any other document (this README included) ever appears to conflict with the roadmap, the
roadmap wins.
