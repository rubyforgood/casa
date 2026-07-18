# CASA design migration — backlog

The live "what's left" list for moving the CASA UI off Bootstrap and onto the Tailwind
design system on the `casadesign` branch.

- **How** to build anything here is defined in [`design.md`](design.md) — the permanent
  source of truth. This file is only the ordered **what's-left**.
- Roughly ordered by value ÷ effort. Check items off, then commit + push at every
  checkpoint (see the workflow in `design.md`).
- `[x]` done · `[~]` in progress · `[ ]` not started.

## Next up — resume here
The volunteer edit page migration (below) is **shipped**. Good next candidates: the volunteers
index (Phase 4) or the deferred sentence-case sweep, which can now also fold in this page's
spec-locked Title Case labels.

## Volunteer edit page migration — [x] SHIPPED
Built as ONE self-contained casa_app view (`volunteers#edit` on `layout: "casa_app"`); the shared
Bootstrap user-edit partials stay for the supervisor/admin edit pages. All **745 system-spec
examples green** (incl. the 2 previously-red impersonation examples, fixed by the new casa_app
impersonation banner), the view + request specs green, and no horizontal overflow at 375–1280.
The select chevron was darkest-pixel verified (minima 114 = slate-500). See the **Person edit
page** pattern in `design.md`.
- [x] Header: back-to-case-or-volunteers + "Edit volunteer" + Impersonate. (Reminder is a visible
  inline card, not a Dialog — the non-JS specs check/uncheck it directly.)
- [x] Profile form: email, display name, phone, DOB, mailing address, reimbursement checkbox
  (editable vs read-only per `update_user_setting?`; confirmable email-change flow).
- [x] Account card: org, invited / accepted / last-login dates, learning hours.
- [x] Status / activation card: active pill, deactivate (UJS `data-confirm`, since a `:js` spec
  drives `accept_confirm`), activate, resend invitation, reactivation SMS.
- [x] Manage cases card (card list) + assign-a-case form.
- [x] Manage supervisor card + assign form (supervisor name is dark text, not a flow-trap link).
- Follow-up: this page's spec-locked Title Case labels (Submit, Assign Case, Resend Invitation,
  Current Supervisor:, Assign/Select a Supervisor, Save Note, ...) are queued for the sweep below.

## Phase 0 — Stabilize what's shipped
- [x] Fix stale supervisor dashboard request spec (it still asserted a redirect after
  the dashboard began rendering).
- [ ] Add a `SupervisorDashboard` service spec (stats, per-volunteer status,
  `needs_attention`).
- [ ] Sweep shipped pages for Font Awesome `fas fa-*` icons (they don't render on
  Tailwind layouts) and for stray Bootstrap classes doing layout work.
- [x] Fix a latent, order-dependent test flake (pre-existing, not design work):
  `CaseContact` validates `occurred_at` with `less_than: Time.zone.tomorrow + 1.day`
  in `app/models/case_contact.rb` — a value captured at class-load time, so if the
  class first loads while a spec is time-traveled to the past, the "future" cutoff
  freezes and later specs fail with "Date can't be in the future". Make it a lambda
  (`less_than: -> { Time.zone.tomorrow + 1.day }`).

## Phase 1 — App-shell coherence (leaf pages reached from the new shell)
- [x] Notifications (`notifications#index`).
- [x] Edit profile (`users#edit`) — profile, change password, change email, languages.
  Rebuilt the Bootstrap collapse accordions with a `disclosure` Stimulus controller.
- [x] Impersonation banner inside `casa_app` (`layouts/_impersonation_banner`, above the top
  bar; `.header` hook + amber-400/amber-950 ~8:1). Fixed the 2 impersonation examples that had
  been red since the volunteer dashboard moved to casa_app.
- [ ] Help link + sign-out in the account menu reach a consistent destination.
- [x] Flash / notifier parity — the `casa_app` flash strip now carries the flash key as a class
  (`.notice` / `.alert`) alongside `role="status"/"alert"`, so legacy-notifier specs match on
  casa_app (a richer SweetAlert-style toast is still optional, not required).

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
- [x] Case show (`casa_cases#show`) on `casa_app`: Tailwind fact card, court dates,
  assigned volunteers + reminder, and the case-contact list (new `casa_cases/_case_contact_card`).
  Report generation is a native `<dialog>` (modal + court-report Stimulus controllers, no
  Bootstrap modal / jQuery), the thank-you dialog auto-opens on the success redirect, and
  Add-to-Calendar uses the `add-to-calendar` controller. Infra added: modal / add-to-calendar /
  court-report / local-storage-reset controllers and `CaseContactDecorator#medium_icon`.
  Follow-ups: consolidate the show-specific contact card + reminder form with the shared
  Bootstrap partials when the contacts index / volunteers-edit migrate. Verified responsive
  (375-1280) and WCAG AA.
- [ ] Case new / edit.
- [ ] Case contacts index (server-side DataTable — also needs the `dashboard.js`
  `columns.render` rewrite) + the case-contact form (multi-step).
- [ ] Case contacts "new design" table (`case_contacts/case_contacts_new_design`).

## Phase 4 — Management & rosters
- [~] Volunteers index + edit. (`volunteers#edit` shipped — the casa_app person-edit reference;
  index still Bootstrap.)
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
  `notification_icon` helpers; `casa_cases/_generate_report_modal` (orphaned now that Case show
  uses the native-dialog report modal); the vestigial `CasaCase#hearing_type` / `#judge`
  `belongs_to` + `hearing_type_name` / `judge_name` delegates whose columns were dropped
  in 2023 — still referenced by `supervisors/index` and the legacy case pages).
- [ ] **Sentence-case sweep (do once pages are migrated).** Fix the remaining Title Case UI
  copy / defined terms: the case-details fact labels ("Transition Aged Youth:", "Youth's Date
  in Care:", "Next Court Date:", "Court Report Status:", "No Court Dates"), the same term on
  `volunteers/index` + `reports/index`, and any other Title Case labels/headings. It is
  cross-cutting and locked by ~15 specs (some are `fill_in` field-label locators, not display
  text), so do it as one deliberate pass. Proper nouns/acronyms (CASA, IEP) excepted; never
  force-case free-form org data. (See the sentence-case scan rule in `design.md`.)
- [ ] **Contact-type default rename (guarded after-party, do once pages are migrated).** For
  existing orgs, rename the contact types + the "Social Services" group whose names **exactly**
  match the old Title Case defaults to the new sentence-case defaults ("Foster Parent" ->
  "Foster parent", etc., per `ContactTypeGroup::DEFAULT_CONTACT_TYPE_GROUPS`). Exact-match only
  so org customizations are left alone; associations are by id so contacts are unaffected;
  **guard the per-org name-uniqueness edge case** (skip a rename if the sentence-case name
  already exists in that org). New orgs already seed the new names.
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
