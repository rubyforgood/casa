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
- [ ] Cases index (`casa_cases#index`) — volunteer "My Cases" + admin/supervisor roster.
- [ ] Case show (`casa_cases#show`).
- [ ] Case new / edit.
- [ ] Case contacts index + the case-contact form (multi-step).
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
- [ ] Datatable strategy — the app's server-driven jQuery DataTables need a Tailwind
  theming (or replacement) decision before the roster pages land.
- [ ] Per-page accessibility pass (axe) as each screen migrates.
- [ ] Remove dead legacy code once confirmed unused (e.g. the unrendered
  `app/views/notifications/_notification.html.erb` + its `notification_row_class` /
  `notification_icon` helpers).
- [ ] Decommission the Bootstrap `application` layout + `application.scss` once the last
  page is migrated.
