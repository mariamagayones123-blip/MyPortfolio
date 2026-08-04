<<<<<<< HEAD

# Interactive Developer Portfolio

Production-grade developer portfolio built with React 19, TypeScript, Vite, and Tailwind CSS v4.

> **Status:** Phase 1 — project foundation. No portfolio content/pages are implemented yet;
> this establishes architecture, tooling, theming, and routing scaffolding only.

## Stack

- **Framework:** React 19 + TypeScript + Vite
- **Styling:** Tailwind CSS v4, CSS-variable design tokens, `next-themes` (light/dark/system)
- **Routing:** React Router v7
- **Data:** TanStack Query, Supabase (`@supabase/supabase-js`)
- **Forms:** React Hook Form + Zod
- **Motion:** Framer Motion, GSAP, Lenis (smooth scroll)
- **UI primitives:** shadcn/ui conventions (`components.json`, `class-variance-authority`)
- **Tooling:** ESLint (flat config), Prettier (+ Tailwind plugin), strict TypeScript

## Getting started

```bash
npm install
cp .env.example .env.local   # fill in Supabase project values
npm run dev
```

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
│   ├── ui/           shadcn/ui primitives (Button, ...)
│   ├── common/        Cross-page chrome (header, footer)
│   └── theme/          Theme provider + toggle
├── config/          Environment variable schema (Zod-validated)
├── features/        Feature-first modules (hero, about, projects, contact, ...)
├── hooks/           Shared hooks
├── layouts/         Route-level layout shells
├── lib/             Framework-agnostic utilities (cn, supabase client, gsap setup)
├── providers/       App-wide React context providers (theme, query client)
├── routes/          Router config, route paths, route-level page components
├── styles/          Tailwind entrypoint + design tokens
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

## Theming

Light/dark/system modes are handled by `next-themes`, toggling a `.dark` class on `<html>`.
Design tokens live in `src/styles/globals.css` as HSL CSS variables mapped into Tailwind's
`@theme`. Replace the placeholder token values once the brand color system is finalized.

## Adding shadcn/ui components

This sandbox couldn't reach `ui.shadcn.com` to run the CLI, so `Button` was hand-authored
following shadcn conventions. In a normal dev environment with network access, add further
components the standard way:

```bash
npx shadcn@latest add <component>
```

`components.json` is already configured with the project's aliases.
=======

# MyPortfolio

> > > > > > > c41f0a95a56ff099e37cc1a35001037a38dc168f
