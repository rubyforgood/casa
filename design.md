# CASA Design System

> Living design system for the CASA UI refresh (`casadesign` branch). This is the
> source of truth for the new aesthetic — read it before building UI, and keep it
> updated as patterns solidify.

## Status & approach

Migrating the UI to **Tailwind CSS v4** with a clean, modern look (reference points:
Stripe, Airbnb — calm, trustworthy, generous whitespace).

Tailwind runs **alongside the legacy Bootstrap 5 UI**. Migrate **page-by-page**:
new/redesigned screens use a Tailwind-only layout; untouched screens keep the
Bootstrap `application` layout. Never load both CSS resets on the same page.

- Tailwind source: `app/assets/stylesheets/tailwind.css` (CSS-first `@theme`).
- Build: `npm run build:tailwind` (one-off) / `build:tailwind:dev` (watch); the `tw`
  process in `Procfile.dev` runs the watcher. Output -> `app/assets/builds/`.

## Foundations

### Typography
- **Figtree** (Google Fonts), weights 400/500/600/700/800. Warm humanist sans.
- Scale:
  - Page title (h1): `text-2xl font-bold tracking-tight text-slate-900`
  - Section title (h2): `text-base font-semibold text-slate-900`
  - Body: `text-sm text-slate-600`
  - Label: `text-sm font-medium text-slate-700`
  - Muted / meta: `text-xs text-slate-400`

### Color
Brand = indigo. Neutrals = slate. Semantic colors below.

| Token | Value | Use |
|---|---|---|
| brand-50…900 | indigo `#eef2ff`…`#312e81` | primary actions, active nav, accents |
| slate-50…900 | neutrals | text, borders, surfaces |
| emerald | — | success / "on track" |
| amber | — | warning / notices |
| rose | — | danger / "needs follow-up" |
| sky, violet, teal | — | avatar / accent variety |

Brand scale lives in `tailwind.css` `@theme` as `--color-brand-*`.

### Spacing, radius, elevation
- 4px spacing base (Tailwind default).
- Radius: controls `rounded-lg`; cards/panels `rounded-2xl`; icon tiles `rounded-xl`.
- Surfaces: white, `border border-slate-200`, `shadow-sm`.
- Page background: `bg-slate-50`.

### Iconography
- **Bootstrap Icons** (`bi-*`), loaded via CDN in the shell layout for now — matches the
  approved mockups. Vendor into the asset pipeline before production.
- **Icon tile pattern** — icons representing a *stat or status* sit on a soft
  colored rounded background:
  `grid place-items-center h-9 w-9 rounded-xl bg-{semantic}-50 text-{semantic}-600`.
  Use for KPI cards, section headers, and list-item leading icons.
  **Do not** use bare floating icons or ringed white "avatar" circles for status
  contexts — reserve initial-avatars for representing *people* only.

## Components

### Buttons
- Primary: `rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-brand-700`
- Secondary: `rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50`
- Danger-outline: `... border border-rose-200 text-rose-700 hover:bg-rose-50`
- All: `focus:outline-none focus:ring-2 focus:ring-brand-500/40`

### Inputs
`block w-full rounded-lg border border-slate-300 px-3.5 py-2.5 text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-brand-500 focus:ring-2 focus:ring-brand-500/30 focus:outline-none`

### Card / panel
`rounded-2xl border border-slate-200 bg-white shadow-sm` (pad `p-5`).

### KPI stat card
Icon tile (semantic) -> number (`text-3xl font-bold`) -> label (`text-sm text-slate-500`)
-> optional meta (`text-xs text-slate-400`). Danger stats use a rose number + `ring-1 ring-rose-100`.

### Status pill
Base: `inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium`
- On track: `bg-emerald-50 text-emerald-700` + check icon
- Needs follow-up: `bg-rose-50 text-rose-700` + exclamation icon
- No active cases: `bg-slate-100 text-slate-500` + minus icon

### Person avatar (initials)
`grid place-items-center h-9 w-9 rounded-full text-xs font-semibold` with a soft color
pair (e.g. `bg-sky-100 text-sky-700`). **People only — never for status.**

### Names
User names render **without honorific prefixes** (Mrs./Mr./…), first + last only, on
**every page**. Use the `display_person(user)` helper for the name and `avatar_initials`
for initials (both backed by `NamePresentation`). This is presentation-only — the
stored `display_name` is never mutated (it must round-trip raw input for security).

### Tag
"mine" etc.: `rounded bg-brand-50 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-brand-600`.

### Empty states (3 patterns)
1. **Cold start** (no data yet): centered icon tile + heading + one-line explainer +
   primary/secondary CTAs. Never show all-zero stat cards.
2. **Success / all caught up**: positive confirmation panel
   (`border-emerald-100 bg-emerald-50/40`, check icon) instead of a blank section.
3. **No results** (filters/search): centered search icon + message tied to the active
   filters + a "Clear filters" action.

## App shell
- **Sidebar** (256px, `border-r border-slate-200 bg-white`): org **name only** in the
  header (no logo/brand mark — not a value-add at this size, and avoids image/variant
  infrastructure), then nav links (active = `bg-brand-50 text-brand-700`, idle =
  `text-slate-600 hover:bg-slate-100`). Nav visibility follows Pundit policies.
  Collapses to an off-canvas drawer below `lg`.
- **Top bar** (`border-b border-slate-200 bg-white/80 backdrop-blur`): mobile nav
  toggle, notifications, and the avatar **account menu** — the single place for identity
  + account actions (no duplicate identity block in the sidebar).
- **Content**: `bg-slate-50`, generous padding, cards. Full org logo is reserved for
  contexts with room (sign-in, court reports / exports), not the shell.

## Key patterns
- **Triage dashboard** (supervisor landing): greeting -> KPI row -> "Needs your
  attention" list -> roster table. Lead with what needs action; power tools live in a
  "More" menu.

## Migration checklist
- [x] Tailwind v4 foundation + design tokens
- [x] Typeface: Figtree
- [x] Sign-in page
- [x] App shell (sidebar + top bar)
- [x] Supervisor dashboard / Volunteers landing
- [x] Remaining auth pages (forgot/reset password, invitation accept)
- [ ] Volunteer & admin dashboards
- [ ] Cases, case contacts, reports, settings

## Workflow
- On the `casadesign` branch: **commit and push at every checkpoint.**
