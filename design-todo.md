# CASA design migration — backlog

The live "what's left" list for moving the CASA UI off Bootstrap and onto the Tailwind
design system on the `casadesign` branch.

- **How** to build anything here is defined in [`design.md`](design.md) — the permanent
  source of truth. This file is only the ordered **what's-left**.
- Roughly ordered by value ÷ effort. Check items off, then commit + push at every
  checkpoint (see the workflow in `design.md`).
- `[x]` done · `[~]` in progress · `[ ]` not started.

## Phase 0 — Stabilize what's shipped
- [x] Fix stale supervisor dashboard request spec (it still asserted a redirect after
  the dashboard began rendering).
- [ ] Add a `SupervisorDashboard` service spec (stats, per-volunteer status,
  `needs_attention`).
- [ ] Sweep shipped pages for Font Awesome `fas fa-*` icons (they don't render on
  Tailwind layouts) and for stray Bootstrap classes doing layout work.
- [ ] Fix a latent, order-dependent test flake (pre-existing, not design work):
  `CaseContact` validates `occurred_at` with `less_than: Time.zone.tomorrow + 1.day`
  in `app/models/case_contact.rb` — a value captured at class-load time, so if the
  class first loads while a spec is time-traveled to the past, the "future" cutoff
  freezes and later specs fail with "Date can't be in the future". Make it a lambda
  (`less_than: -> { Time.zone.tomorrow + 1.day }`).

## Phase 1 — App-shell coherence (leaf pages reached from the new shell)
- [x] Notifications (`notifications#index`).
- [x] Edit profile (`users#edit`) — profile, change password, change email, languages.
  Rebuilt the Bootstrap collapse accordions with a `disclosure` Stimulus controller.
- [ ] Impersonation banner inside `casa_app` (currently only in the legacy header).
- [ ] Help link + sign-out in the account menu reach a consistent destination.
- [ ] Flash / notifier parity — reconcile the `casa_app` flash strip with the legacy
  SweetAlert notifier.

## Phase 2 — Role landing dashboards
- [x] Volunteer dashboard / landing — triage (active cases, cases needing a contact,
  hours), keeping the single-active-case fast-path to "log a contact". Added an org
  announcement banner to the shell so it isn't lost on dashboard pages.
- [x] Admin dashboard — org-wide triage (active volunteers/cases, unassigned cases,
  cases needing a contact) using batched/aggregate queries, not per-row.

## Phase 3 — Core workflows (highest traffic)
- [x] Cases index (`casa_cases#index`) — bespoke table + server-side filter selects + Pagy
  pagination. Replaced the two always-empty Hearing Type / Judge columns (their case-level
  columns were removed in 2023 — that data lives on court dates now) with a single
  "Next court date" column (preloaded, no N+1); sentence-cased the column headers.
  Follow-ups: column-visibility picker intentionally not planned (only 6 columns; a responsive layout is the
  better mobile investment); free-text search shipped (case number + active
  volunteer name, submit-on-Enter) with live as-you-type search as a follow-up; sortable headers shipped
  (server-side ?sort=, aria-sort, double-caret indicator); action-button
  labels kept Title Case (spec-coupled).
- [ ] Case show (`casa_cases#show`).
- [ ] Case new / edit.
- [ ] Case contacts index (server-side DataTable — also needs the `dashboard.js`
  `columns.render` rewrite) + the case-contact form (multi-step).
- [ ] Case contacts "new design" table (`case_contacts/case_contacts_new_design`).

## Phase 4 — Management & rosters
- [ ] Volunteers index + edit.
- [ ] Supervisors index + edit.
- [ ] Case assignments.
- [ ] Learning hours (volunteer + supervisor/admin views).
- [ ] Reimbursements.
- [ ] Reports hub + individual reports / exports.
- [ ] Organization settings (`casa_org#edit`).

## Phase 5 — Admin long-tail CRUD
- [ ] Contact types, contact type groups, contact topics.
- [ ] Hearing types, judges, languages.
- [ ] Mileage rates, placement types, placements.
- [ ] Banners, custom org links, checklist items.
- [ ] Imports, court dates / bulk court dates, emancipation.
- [x] Health / metrics page (`health#index`): rebuilt as bespoke server-rendered SVG
  (line charts with a distinct line-style + marker per series, heatmap-as-table, table
  twins, stat tiles with correct totals, and zero / no-data / empty states) on a minimal
  `metrics` layout; retired the Chart.js + jQuery `display_app_metric.js`. Follow-ups (date-range filter, Stimulus hover, and the unused chart.js deps removal now shipped): a validated dark-mode
  palette.

## Phase 6 — Edges
- [ ] All-CASA-admin area (its own sidebar / shell).
- [ ] Devise edge pages (unlock / confirmation, if enabled) and error pages.
- [ ] Static / marketing pages.

## Cross-cutting / infrastructure
- [ ] Finish the sentence-case pass on interactive copy that is shared across pages —
  button/field labels like "Update Profile", "Change Password", "New Password",
  "Enable Twilio For Text Messaging" live on the users / volunteers / all-CASA-admin
  edit pages and a shared spec example, so rename them (and their
  `click_on` / `fill_in` / `have_field` specs) holistically, not page-by-page.
- [ ] Contrast audit of shipped pages: replace remaining `text-slate-400` body/meta text
  with `slate-500` for WCAG AA; re-check pills and badges.
- [ ] **Vendor Bootstrap Icons** into the asset pipeline; drop the CDN link.
- [ ] Move the inline nav-toggle `<script>` in `casa_app.html.erb` to a Stimulus
  controller (aligns with the jQuery -> Stimulus migration, issue #5016).
- [x] Table strategy (revised) — build tables bespoke in Tailwind (server-side filters +
  Pagy pagination + Turbo Drive), matching the dashboard; retire jQuery DataTables
  page-by-page. Theming DataTables was rejected (couldn't meet WCAG/design). Cases index
  is the reference pattern (`shared/_pagination`, `auto-submit` controller).
- [ ] Per-page accessibility pass (axe) as each screen migrates.
- [x] Responsive pass on each migrated page: verify mobile / tablet / desktop; give data
  tables a stacked / card layout on small screens rather than horizontal scroll. Complete:
  cases index, health metrics, supervisor + volunteer dashboards, notifications, edit profile,
  and the casa_auth pages (sign-in, forgot / reset password, accept invitation). All verified by
  measurement at true 375 / 414 / 768 / 1024 / 1280 widths via a CDP device-metrics override
  (`bin/measure-responsive.mjs`), which bypasses headless Chrome's 500px minimum-window clamp so media
  queries evaluate at real phone width. The health heatmap is a density matrix, so it keeps
  horizontal scroll + a sticky day-of-week axis rather than card-stacking (which would destroy
  the visualization); its chart-twin data tables are months-as-rows (narrow) inside a collapsed
  `<details>`. A contrast pass over the swept pages fixed three AA misses: notification /
  patch-note timestamps and all input placeholders slate-400 -> slate-500, and the auth aside
  footer white/60 -> white/80.
- [ ] Remove dead legacy code once confirmed unused (e.g. the unrendered
  `app/views/notifications/_notification.html.erb` + its `notification_row_class` /
  `notification_icon` helpers; the vestigial `CasaCase#hearing_type` / `#judge`
  `belongs_to` + `hearing_type_name` / `judge_name` delegates whose columns were dropped
  in 2023 — still referenced by `supervisors/index` and the legacy case pages).
- [ ] Decommission the Bootstrap `application` layout + `application.scss` once the last
  page is migrated.

## Stakeholder / product questions (confirm before finalizing)
- [ ] **Hearing type & judge on case lists.** The old cases index (and `supervisors/index`)
  showed per-case "Hearing Type" and "Judge" columns, but their backing columns were removed
  from `casa_cases` in 2023 (migration `20230729213608`) — that data moved to court dates, so
  those columns have rendered blank for every case since. The migrated cases index now shows
  "Next court date" instead. Ask stakeholders: is next court date the right thing to surface on
  the roster, or do they want the upcoming hearing's type/judge (sourced from court dates)? The
  answer decides whether we also fix `supervisors/index` and whether to delete the dead
  `CasaCase` associations.
