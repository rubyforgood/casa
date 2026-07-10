# CASA Design System

> **Permanent, living record** of the CASA UI refresh (`casadesign` branch) — the
> **single source of truth** for the new design system and the decisions behind it.
> **Refer to it for all UI work** so this direction never has to be rediscovered or
> rebuilt. Read it before building UI, and keep it current as patterns solidify.
> The live "what's left" backlog lives in [`design-todo.md`](design-todo.md).

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
  - Muted / meta: `text-xs text-slate-500` (never `text-slate-400` for text — fails AA)

### Sentence case
All UI copy — page titles, section headings, subtitles, table headers, field labels,
buttons, badges and nav — uses **sentence case**: capitalise only the first word and
proper nouns (CASA, Twilio, people's names). So "Track volunteer progress", not "Track
Volunteer Progress" and never the shouty all-caps "TRACK…". Do **not** apply the
`uppercase` CSS transform to labels; use size, weight and colour for hierarchy instead.

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

### Accessibility (WCAG 2.1 AA)
Everything ships to **WCAG 2.1 AA** — it's part of "done", not a follow-up.
- **Contrast** ≥ 4.5:1 for text (3:1 for large ≥24px/bold text and for UI borders/icons).
  Muted text is `slate-500` on white — **not `slate-400`, which fails AA** — and
  `slate-600` on tinted surfaces. Never signal meaning by colour alone; pair a status
  colour with an icon or word.
- **Structure**: one `h1` per page, in-order headings, landmarks (`main`/`nav`/`aside`),
  real lists, and `<caption>` + `scope` on tables.
- **Forms**: every control has a real `<label>`; the error summary uses `role="alert"`
  and names the field; invalid/required state is never colour-only.
- **Keyboard & focus**: fully keyboard-operable, visible `focus-visible` rings, a skip
  link, logical order; icon-only controls carry an `aria-label`, decorative icons are
  `aria-hidden`.
- **Motion**: respect `prefers-reduced-motion` (`motion-reduce:` variants).

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
**every page**. Use `display_person(user)` (new UI) or `formatted_name(name)` (existing `.display_name`
call sites) for the name, and `avatar_initials` for initials (all backed by
`NamePresentation`). This is presentation-only — the
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

### Form errors
Streamlined `role="alert"` card shown above a form when saving fails:
`rounded-xl border border-rose-200 bg-rose-50 p-4` with a leading rose
`bi-exclamation-circle-fill` icon, a `text-rose-800` heading, and a tidy bulleted list in
`text-rose-700`. Use the `shared/_form_errors` partial on Tailwind pages (the legacy
`shared/_error_messages` stays for Bootstrap pages). Honours the `@custom_error_header`
override.

### Disclosure (collapsible panel)
Secondary actions (e.g. Change Password / Change Email) hide behind a full-width trigger
button; the `disclosure` Stimulus controller toggles a `hidden` panel and keeps
`aria-expanded` in sync. Keep the trigger a real `<button>` so it stays keyboard- and
test-reachable.

## App shell
- **Sidebar** (256px, `border-r border-slate-200 bg-white`): org **name only** in the
  header (no logo/brand mark — not a value-add at this size, and avoids image/variant
  infrastructure), then nav links (active = `bg-brand-50 text-brand-700`, idle =
  `text-slate-600 hover:bg-slate-100`). Nav visibility follows Pundit policies.
  Collapses to an off-canvas drawer below `lg`.
- **Top bar** (`border-b border-slate-200 bg-white/80 backdrop-blur`): mobile nav
  toggle, notifications, and the avatar **account menu** — the single place for identity
  + account actions (no duplicate identity block in the sidebar). Its header shows name,
  email, and a **role badge** — `current_role` as a soft pill colour-coded by role
  (Volunteer = sky, Supervisor = violet, Casa Admin = amber) — the single place the
  user's role is surfaced.
- **Content**: `bg-slate-50`, generous padding, cards. Full org logo is reserved for
  contexts with room (sign-in, court reports / exports), not the shell.

## Key patterns
- **Triage dashboard** (supervisor landing): greeting -> KPI row -> "Needs your
  attention" list -> roster table. Lead with what needs action; power tools live in a
  "More" menu.

## Design decisions (rationale)

The *why* behind the system, so choices aren't re-litigated or lost.

- **Tailwind v4 runs alongside legacy Bootstrap, migrated page-by-page.** A big-bang
  rewrite is too risky for a volunteer-run app; each page is moved wholesale onto one
  system so the two CSS resets never collide. A page is "migrated" only when it renders
  on a Tailwind layout with no Bootstrap classes doing layout work.
- **Pages opt in to the new UI at the controller.** Render with `layout: "casa_app"`
  (in-app shell) or set `layout "casa_auth"` (split auth). The default
  `ApplicationController` layout stays the Bootstrap `application` layout, so untouched
  screens are unaffected. Set `@active_nav` to the sidebar key (e.g. `"volunteers"`) to
  light up the matching nav item. There is no global flag — the switch is
  per-controller-action and reversible.
- **Brand = indigo, neutrals = slate.** Calm, professional, high-contrast and
  accessible; visibly distinct from the old teal/lineicons look so progress is legible.
- **Figtree** as the typeface — a warm humanist sans that reads friendly but credible,
  and is free via Google Fonts.
- **Bootstrap Icons (`bi-*`), loaded by CDN — temporary.** They match the approved
  mockups and were fast to adopt, but MUST be vendored into the asset pipeline before
  production (tracked in `design-todo.md`). Font Awesome (`fas fa-*`) is **not** loaded
  on Tailwind pages — using it renders nothing. Use `bi-*`.
- **Icon tiles for status, initial-avatars for people — never mixed.** A soft colored
  rounded tile behind an icon means "a stat/status"; a colored initials circle means
  "a person". Keeping these disjoint avoids visual ambiguity.
- **Sidebar shows the org name only (no logo mark); identity lives in one top-bar
  account menu.** Dropping the logo avoids image/variant infrastructure that adds little
  at 256px, and consolidating identity removes the duplicate sidebar identity block. The
  full org logo is reserved for roomy contexts (sign-in, reports).
- **Honorific-free names are presentation-only.** Show first + last (no Mr./Mrs./…) on
  every page via `display_person` (new UI), `formatted_name` (legacy `.display_name`
  sites) and `avatar_initials`, all backed by `NamePresentation`. The stored
  `display_name` is **never** mutated — it must round-trip raw input for security.
- **Landing pages use the triage pattern.** Greeting -> KPI row -> "needs your attention"
  -> roster/table. Lead with what needs action, not vanity metrics; push power tools into
  a "More" menu. (See the supervisor dashboard for the reference implementation.)
- **Every screen designs its empty state** using one of the three patterns (cold-start /
  all-caught-up / no-results). Never ship all-zero stat cards or a blank section.
- **Accessibility is part of "done".** Skip link, `aria-current` on the active nav,
  `aria-label` on icon-only controls, visible `focus-visible` rings, `sr-only` table
  captions/labels, `role="status"`/`"alert"` on flashes, and `motion-reduce` on the
  drawer. The shell already meets this bar — keep new pages there.
- **Build:** `npm run build:tailwind` (minified) or `build:tailwind:dev` (watch, the `tw`
  process in `Procfile.dev`). Class names are discovered via the `@source` globs in
  `tailwind.css`. The output `app/assets/builds/tailwind.css` is **gitignored** and built
  on deploy — don't commit it.

## Migrating a page (playbook)

Repeatable steps for moving one screen off Bootstrap:

1. **Read first** — this doc, plus the page's existing specs (know what behavior is
   pinned before you touch markup).
2. **Opt the action into a Tailwind layout** — `render ..., layout: "casa_app"` (or
   `layout "casa_auth"`), and set `@active_nav` when it maps to a sidebar item.
3. **Rebuild the view with the components above.** Wrap page content in
   `px-4 py-6 sm:px-6 lg:px-8`; use the h1/section-title scale; reuse the card, button,
   input, pill, KPI, and empty-state patterns instead of inventing new ones.
4. **Names:** `display_person` / `formatted_name` / `avatar_initials` — never raw
   `display_name`. **Icons:** `bi-*` only. **Status vs people:** icon tile vs avatar.
5. **Design the empty state** (pick the right one of the three).
6. **Keep behavior specs green.** When a spec is coupled to a presentational class, move
   it to a semantic hook (a `data-*` attribute) rather than weakening the assertion.
   Prefer system specs for new UI behavior (ADR 0006).
7. **Verify:** `npm run build:tailwind`, run the page's specs, then `bin/lint`.
8. **Checkpoint:** commit and push to `casadesign`, tick the item off in
   `design-todo.md`, and update the status below.

## Migration status

High-level progress; the granular, prioritized backlog lives in
[`design-todo.md`](design-todo.md).

- [x] Tailwind v4 foundation + design tokens
- [x] Typeface: Figtree
- [x] Auth pages (sign-in, forgot/reset password, invitation accept)
- [x] App shell — sidebar + top bar (`casa_app` layout)
- [x] Supervisor dashboard (triage-pattern reference)
- [x] Notifications
- [x] Edit profile
- [ ] Other app-shell leaf pages (impersonation banner, help link, flash parity)
- [ ] Volunteer & admin dashboards
- [ ] Cases, case contacts, reports, settings
- [ ] Management rosters, admin CRUD long-tail, all-CASA-admin area

## Workflow
- On the `casadesign` branch: **commit and push at every checkpoint.**
