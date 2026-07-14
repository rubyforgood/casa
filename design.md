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
- **Leading-icon alignment** — an icon that precedes a label (menu items, list rows) is
  **top-aligned to the first line** (`items-start`), like a list marker, never centered
  against a wrapped block. Single-line labels look identical either way; `items-start` keeps
  it correct once a label wraps. (Material and Primer both top-align multi-line leading
  elements.)

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
Use the **`button_classes(:variant)`** helper (`DesignSystemHelper`) as the single source of
truth. Never hand-write button class strings in views; they drift (that is how the variants
ended up mismatched). Variants:
- `:primary` (filled brand): `bg-brand-600 text-white font-semibold hover:bg-brand-700`
- `:secondary` (outlined): `border border-slate-200 bg-white text-slate-700 font-medium hover:bg-slate-50`
- `:danger` (filled rose): `bg-rose-600 text-white font-semibold hover:bg-rose-700`

Every variant shares a base of `inline-flex h-10 items-center justify-center gap-2 rounded-lg
px-4 text-sm shadow-sm` plus a `focus-visible` brand ring and `disabled:` states. The fixed
**`h-10` (40px) height token** is deliberate: with `box-sizing: border-box` it absorbs the
outlined variant's 1px border, so filled and outlined buttons are the same height by
construction (40px is the mainstream medium-button height: Material 3, Chakra, shadcn). **Do
not** re-equalize sizes with `border border-transparent` on the filled variants; that is a
fragile compensation pinned to the secondary's exact border width, and the height token
already handles it.

- Tertiary (ghost): `rounded-lg px-2 py-1 text-sm font-medium text-slate-600 hover:bg-slate-100 hover:text-slate-900`.
  No border, fill, or shadow: the lowest-emphasis action, for repeated row / toolbar actions so they recede from brand
  links. Not part of `button_classes` (it is a low-emphasis action, not a CTA). Neutral ink stays at or above AA
  (slate-600 is about 7:1; never `slate-400` under visible text). Leading icon via `gap-1.5` plus a `bi-*` glyph.
  Right-aligned in a table's trailing actions cell, give that cell extra end padding (`pr-6`) so the control clears the
  card edge rather than skewing the button's own padding.

### Inputs
`block w-full rounded-lg border border-slate-300 px-3.5 py-2.5 text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-brand-500 focus:ring-2 focus:ring-brand-500/30 focus:outline-none`

### Card / panel
`rounded-2xl border border-slate-200 bg-white shadow-sm` (pad `p-5`).

### Table (in a card)
Full-bleed table inside an `overflow-hidden rounded-2xl` card: a header row
(`border-b border-slate-100 p-4`), then `thead`/`tbody` with cells `px-4 py-3` and
`divide-y divide-slate-50` between rows. Add `pb-2` to the card so the last row clears
the rounded bottom corner instead of butting against it (use `py-2` for a header-less
list card — e.g. notifications — so the first row clears the top corner too). Keep rows
a uniform height (a taller last row reads as a bug).

### Tables (bespoke) + pagination
Hand-built Tailwind (dashboard tables + cases index), not DataTables. `overflow-hidden
rounded-2xl` card (+ `py-2` inset), full-bleed table, `thead th` = `text-xs font-semibold
text-slate-600`, cells `px-4 py-3`, `divide-y divide-slate-50`, `hover:bg-slate-50/70`.
Keep the `thead` even when empty and put an empty-state row in the `tbody`. Filtering /
sort / pagination are **server-side** (params + Pagy); the filter bar is plain selects that
submit on change (`auto-submit` controller). Pagination: the `shared/_pagination` partial
renders a Pagy instance as a bottom bar — "Showing X–Y of Z" left, page controls right
(`nav` + `aria-label`, `aria-current`, `rel=prev/next`), preserving filter params. Don't render
decorative emoji as data (e.g. the 🦋/🐛 transition-aged icons) — use a plain label or pill.
Verify a column's data source before carrying one forward: the legacy cases index kept
Hearing Type / Judge columns that had rendered blank for every case since a 2023 migration
moved that data onto court dates — drop dead columns or re-source them (the migrated index
shows "Next court date" instead).

**Responsive:** render the full table in `hidden md:block` and a stacked-card list below `md`
(`md:hidden`, one card per row with a `<dl>` of labeled fields). A data table never relies on
horizontal scroll alone. The exception is a density **matrix** (the health heatmap), which keeps
horizontal scroll with a sticky axis column (`sticky left-0 z-10 bg-white`); stacking a 2D matrix
into cards would destroy the visualization.

### Charts (data viz)
Charts are **bespoke server-rendered SVG** (no canvas, no Chart.js), built in `HealthHelper`
and rendered on the metrics page. Validated with the data-viz method:
- **Series identity is never color alone.** Each line carries a distinct **line style**
  (solid, dashed, dotted, dash-dot) **and marker shape** (circle, square, triangle, diamond)
  on top of a validated categorical palette (indigo, emerald, amber, rose; worst adjacent
  CVD deltaE 31.3, all AA on white). The legend shows the line + marker key, not a swatch.
- **A table twin per chart:** a `<details>` "View as table" with a real `<table>` (scope
  headers); the SVG carries `role="img"` + `<title>` / `<desc>`; no value is color-only.
- **Heatmaps are accessible tables:** a day x hour grid as a `<table>` with a sequential
  single-hue background and the count in every cell (color plus number).
- **Marks:** 2px lines, hairline solid gridlines, markers with a 2px surface ring, direct
  end-value labels, muted axis ink (slate-500 / 600, AA).
- **Totals live in stat tiles, never a row sum.** Correct range totals only (sums for
  additive metrics, a distinct count for unique loggers, footnoted). Never sum
  non-additive columns.
- **States:** a genuine zero shows a muted `0`; a missing value shows "No data" (never a
  fake 0); a section with no data swaps in an empty state; loading uses skeletons; error is
  distinct with a retry.
- Palette checked with the data-viz skill's `validate_palette.js`. Dark mode is deferred
  (off-the-shelf Tailwind steps miss the dark lightness band; needs hand-tuned OKLCH).

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
Streamlined single-line `role="alert"` card shown above a form when saving fails:
`rounded-xl border border-rose-200 bg-rose-50 p-4` with a rose danger **icon tile** (same
style as the dashboard) and one sentence — **"Unable to save:"** followed by the messages
joined with `to_sentence`, no bulleted list. Use the `shared/_form_errors` partial on
Tailwind pages; the legacy `shared/_error_messages` stays for Bootstrap pages.

### Dropdown / popover
Menus (the header account menu, the cases-page "More" actions menu) are a native
`<details>/<summary>` disclosure: the `<summary>` is the trigger (styled as a button,
`[&::-webkit-details-marker]:hidden`), the panel an `absolute right-0 z-20 mt-2 w-56
rounded-xl border border-slate-200 bg-white py-1 shadow-lg` card of links. The `dropdown`
Stimulus controller enhances it — native toggle plus close on outside-click and Escape
(focus returns to the summary) — and degrades to the plain native toggle without JS. Keep
menus a disclosure-of-links (not a full ARIA `menu` widget) unless a screen needs arrow-key
roving. (Distinct from `disclosure`, which is for inline panels like the edit-profile forms
that should stay open.)

The `<summary>` wears `button_classes(:secondary)` so the trigger matches the primary CTA's
40px height. Menu items are `flex items-start gap-2 px-4 py-2 text-sm`: the leading icon is
**top-aligned to the first line** (`items-start`), never centered, so a label that wraps
still reads with its icon (see Iconography). A form-driven modal can be a menu item by
rendering `Dialog::GroupComponent(wrapper_class: "contents")` so its trigger and dialog sit
directly in the menu.

**Header action pattern.** A page header shows **one primary CTA plus a `More` overflow
disclosure**, not a flat row of equal buttons. Keep frequently-used, core actions visible and
overflow only the occasional ones: the cases index overflows admin navigation (Case Groups,
Bulk Court Date); the case show keeps New Case Contact and Edit visible and overflows
Generate Court Report, Emancipation, and New Fund Request. Do not bury a core action in `More`, it
is both a UX cost (an extra click on a common action) and a testability cost (rack_test
cannot open a native `<details>`, so non-JS specs that click it break).

On **mobile**, collapse the remaining visible secondaries into `More` too, so only the primary
CTA and `More` share the top line. Render such an action twice with responsive visibility: a
button wrapped in `hidden sm:contents` (shown `sm+`) and a `sm:hidden` menu item (shown on
mobile). This keeps it no-JS and unambiguous, and a non-JS click still finds the visible
button (rack_test ignores the `hidden` class but respects the closed `<details>`).

### Disclosure (collapsible panel)
Secondary actions (e.g. Change Password / Change Email) hide behind a full-width trigger
button; the `disclosure` Stimulus controller toggles a `hidden` panel and keeps
`aria-expanded` in sync. Keep the trigger a real `<button>` so it stays keyboard- and
test-reachable.

### Modal (native dialog)
Built on the native `<dialog>` element driven by the `modal` Stimulus controller: `open`
calls `showModal()` (focus-trapping, Escape-to-close, and an inert background for free),
`close` closes it, a backdrop click closes it, and an `openOnConnect` value auto-opens on
load (e.g. the case-show thank-you dialog on the `?success` redirect). Tailwind's reset zeroes
the UA centering margin, so `tailwind.css` re-centers `dialog[data-modal-target="dialog"]`
(fixed, horizontally centered, `top: 24vh`, and `18vh` under 640px).

**One template for every task/confirm modal.** Panel: `w-[calc(100vw-2rem)] max-w-md
overflow-hidden rounded-2xl p-0 shadow-xl backdrop:bg-slate-900/40`, then three regions:
1. **Header** `flex items-center gap-3 border-b border-slate-100 px-5 py-4`: an optional 32px
   status badge, the `<h2>` title (`flex-1`), then a 32px close button (`bi-x-lg`,
   `text-slate-500`, `aria-label="Close"`).
2. **Body** `px-5 py-4`.
3. **Footer** `flex items-center justify-end gap-2 border-t border-slate-100 px-5 py-4`:
   `button_classes(:secondary)` (Cancel) then the primary or `:danger` action, right-aligned.

The template is the **`Dialog::` ViewComponent suite**: `Dialog::GroupComponent` (the
<dialog> shell plus the trigger slot, size, aria label, and controller wiring) composed with
`Dialog::HeaderComponent`, `Dialog::BodyComponent`, and `Dialog::FooterComponent`. Compose
those (they work even inside a `form_with`) so the three regions cannot drift. This is the
native-dialog replacement for the Bootstrap `Modal::*` suite.

Shipped instances: the court-report generator (form modal; submit posts via the
`court-report` controller) and `shared/_confirm_button` (destructive confirm; the danger
action posts via `button_to`, and the trigger, title, message, and labels are locals). A
separate **status variant** (the success/thank-you dialog) centers a 48px hero badge + title
+ single Close instead of a header bar. This replaces the legacy Bootstrap `Modal::*`
components on Tailwind pages; do not restyle Bootstrap `.modal` markup (its CSS is not loaded
on `casa_app`).

**Status badge token** (the modal icon): one shape, `rounded-full`, two sizes: **32px**
(`h-8 w-8`) inline in a header, **48px** (`h-12 w-12`) centered as a hero. Colored by intent
(`bg-rose-100 text-rose-600` destructive, `bg-emerald-50 text-emerald-600` success). This is
distinct from the stat/KPI **icon tile** (`rounded-xl`).

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
- **Content**: `bg-slate-50`, generous padding, cards. Org announcement banners render
  at the top of the content area (`layouts/_casa_banner`). Full org logo is reserved for
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
- **Tables are bespoke, not jQuery DataTables (reversed).** Theming DataTables couldn't
  match the dashboard tables or meet WCAG — its generated chrome fights the design system.
  Build tables in Tailwind instead (matching the dashboard): server-side filtering +
  **Pagy** pagination + optional sortable header links, with **Turbo Drive** smoothing the
  GET navigations. Reuse each `*Datatable` class's query logic server-side; retire the
  DataTables JS as each page migrates. See the cases index for the reference pattern.

## Migrating a page (playbook)

Repeatable steps for moving one screen off Bootstrap:

1. **Read first** — this doc, plus the page's existing specs (know what behavior is
   pinned before you touch markup). Confirm each column / field you plan to keep still has a
   live data source; don't carry blank legacy columns forward (see Tables, above).
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
7. **Verify:** `npm run build:tailwind`, run the page's specs, then `bin/lint`. Confirm the
   page fits at true 375 / 414 / 768 / 1024 / 1280 widths, measured with a CDP device-metrics
   override (`bin/measure-responsive.mjs`) rather than `--window-size` (headless Chrome clamps its minimum
   window to ~500px, so `--window-size=375` silently measures 500).
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
- [x] Volunteer dashboard (triage: cases, follow-ups, hours)
- [x] Admin dashboard (org triage: unassigned & stale cases)
- [x] Cases index (bespoke table + server-side filter selects + Pagy pagination)
- [ ] Case show/new/edit, case contacts, reports, settings
- [ ] Management rosters, admin CRUD long-tail, all-CASA-admin area

## Workflow
- On the `casadesign` branch: **commit and push at every checkpoint.**
