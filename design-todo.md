# CASA design migration — backlog

The live "what's left" list for moving the CASA UI off Bootstrap and onto the Tailwind
design system on the `casadesign` branch.

- **How** to build anything here is defined in [`design.md`](design.md) — the permanent
  source of truth. This file is only the ordered **what's-left**.
- Roughly ordered by value ÷ effort. Check items off, then commit + push at every
  checkpoint (see the workflow in `design.md`).
- `[x]` done · `[~]` in progress · `[ ]` not started.

## Next up — resume here
**All migration phases (0–6) are shipped**, including the opt-in `case_contacts_new_design` table
(now a bespoke server-rendered casa_app table; its dead DataTable stack was removed). But a
straggler audit found several reachable **leaf pages never in the phase plan that are still on the
Bootstrap `application` layout** — see **Straggler pages** below. They block deleting the Bootstrap
layout, so **resume there** — `fund_requests#new`, `casa_admins`, `other_duties`, and `notes#edit`
and the `error#index` test page are done; `case_assignments#index` was orphaned dead code (deleted).
**All straggler HTML pages are now migrated.** Next: verify no controller still renders an HTML page
on the Bootstrap `application` layout (the remaining default-layout controllers are data-only —
CSV/XLSX reports, `preference_sets`, `api/*`, and AJAX sub-resources), then the endgame — the
deferred **sentence-case sweep**, the contrast audit, vendoring Bootstrap Icons, dead-code removal,
and finally deleting the `application` layout + `application.scss`. Remaining product question:
hearing type / judge on case lists (stakeholder).

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
- [x] Sweep shipped pages for Font Awesome `fas fa-*` icons (they don't render on Tailwind
  layouts). Verified: 0 `fas/far/fal fa-*` usages remain in casa_app views — the migrated pages
  use `bi bi-*`.
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
- [x] Flash / notifier parity — the `casa_app` flash strip carries a base `alert` class **plus**
  the flash key (`.notice` / `.alert`) alongside `role="status"/"alert"`, mirroring the Bootstrap
  `flash_class` mapping so both legacy hooks match: `.notice` for the SweetAlert-notifier specs and
  `.alert` for the shared not-authorized redirect (it ships as `flash[:notice]`, locked by ~dozens
  of request specs, so it only reads as an alert because every flash box is an `.alert`). A richer
  SweetAlert-style toast is still optional, not required.

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
- [x] Case new / edit (`casa_cases#new`/`#edit`). Both already render on `layout: "casa_app"`
  (Tailwind cards, chevron selects, `shared/form_errors`, the court-orders + volunteer-assignment
  twins, `month_year_select`, the shared contact-type TomSelect, and a `confirm_button` deactivate).
  The orphaned Bootstrap `casa_cases/_form.html.erb` is dead (new/edit render inline) — see
  dead-code. Verified green this session (52 examples; the lone failure, a supervisor-unassign
  `:js` example, is a load-only Selenium flake that passes 3/3 in isolation).
- [x] Case contacts index + drafts **shipped** on casa_app. The main index keeps **filterrific**
  (the `.filter-form` auto-submits on `.filter-input` change, targeting the `:case_contacts`
  turbo-frame) — its Bootstrap collapse was swapped for the `disclosure` controller (panel always
  in the DOM so rack_test finds "Other filters", but `hidden` unless `expand_filters?` so JS users
  see it collapsed). The `_case_contact` card + `_followup` were rewritten in place (both pages are
  casa_app now): Tailwind card, `TruncatedTextComponent` reused, and the reminder JS hooks kept
  (`.followup-button` / `#followup-button-<id>` / `#resolve`, `data-turbo:false`). Inert class
  hooks the specs use (`.full-card`, `.container-fluid.mb-1`, `.card-title`) preserved; the
  `strong.text-primary` color assertion + the view-spec title sentence-cased. Chevrons
  darkest-pixel verified (114); no overflow 375-1280. The opt-in `case_contacts_new_design`
  table is now migrated too (below), so the whole case area is on casa_app.
- [x] Case-contact multi-step **form** (`case_contacts/form/details` + the `_contact_topic_answer`
  and `shared/_additional_expense_form` nested rows) — SHIPPED on casa_app. Wicked single-step
  wizard rendered on `layout "casa_app"` (the JSON autosave path skips the layout). Rebuilt in
  Tailwind card sections (Details / Notes / Reimbursement) preserving all three Stimulus
  contracts verbatim: **autosave** (`data-autosave-target="form"` + `input->autosave#save` on the
  text fields + the `<small role="alert" data-autosave-target="alert">No changes have been
  saved.</small>` lines a non-JS spec asserts), **case-contact-form** (reimbursement show/hide —
  its JS now toggles Tailwind `hidden` instead of Bootstrap `d-none`, safe since only this form
  uses the controller), and **casa-nested-form** (`.nested-form-wrapper` + template/target/wrapper
  targets + hidden id/_destroy fields). Contact types stay grouped `.contact-form-type-checkbox`
  checkboxes; relevant cases stay the shared `Form::MultipleSelectComponent` (TomSelect). Swapped
  `shared/error_messages` for the Tailwind `shared/form_errors`. Duration is an inline Tailwind
  twin (like learning hours), so `Form::HourMinuteDurationComponent` is now dead (see dead-code).
  `form_title` + the field/action Title Case labels are spec-locked (queued for the sweep). One
  non-JS spec ("selects the only case") was updated: it matched the legacy sidebar's case list, so
  it now asserts the widget selection (`have_select`) with `:js` like its multi-case sibling.
  Chevron darkest-pixel verified (114 = slate-500); no overflow 375-1280; 55 form-spec examples
  green bar the pre-existing cross-org `edit_spec:76`. (Two expense `:js` specs flake only under
  full-dir concurrent load; they pass 5/5 in isolation — pre-existing timing, JS logic unchanged.)
  See the **Case-contact form** pattern in `design.md`.
- [x] `case_contacts_new_design` (feature flag `:new_case_contact_table`) — **SHIPPED** on casa_app
  as a bespoke server-rendered table, retiring the jQuery serverSide DataTable. Reuses the existing
  `CaseContact` filter scopes server-side (contact-type as a subquery so multi-type rows don't
  duplicate) + `?sort=` + Pagy; a `disclosure` filter panel that auto-submits, with the case picker
  a reused `multiple-select` TomSelect (chevron darkest-pixel verified to match the single-selects,
  153 vs 151 at DPR-1). Rows expand (multi-`<tbody>` `disclosure`) to topic answers + notes; row
  actions are inline (icon ghost buttons + Dialog delete-confirm / set-reminder note), never a
  dropdown (clipped by `overflow-x-auto`). Dropped the DataTables column-visibility picker (design
  already rejected it for the cases index). `followups#create/#resolve` now `redirect_back_or_to`
  and `case_contacts#destroy` already `redirect_to request.referer`, so reminders/delete stay on the
  list. 38 request + 22 system examples green. See **Expandable rows + inline row actions** in
  `design.md`. Also **removed** the now-dead datatable stack: the `#datatable` action + its route,
  `CaseContactDatatable` (+ spec), and the `defineCaseContactsTable` block in `dashboard.js` (+ its
  jest test + the POST /datatable request examples).

## Phase 4 — Management & rosters
- [x] Volunteers index + edit. Both on casa_app. The **index** is a bespoke Tailwind table
  (server-side filters + search + sortable headers + Pagy) that reuses `VolunteerDatatable`'s
  SQL via `#index_relation` / `#index_count` (GET filters mapped into the DataTables param
  shape); the column-visibility picker is dropped (design.md); bulk supervisor assignment is
  preserved (select-all + native-dialog modal + disable-form, desktop-only checkboxes).
  Retired the jQuery DataTable by moving `#volunteers` off the `<table>` onto its wrapper so
  `dashboard.js`'s `$('table#volunteers').DataTable()` no longer matches. Follow-ups: the
  now-unused `volunteers#datatable` JSON action + `dashboard.js` volunteer block are dead
  (see the dead-code item); `hours_spent_in_days(30)` is still per-row (N+1 parity with the
  retired datatable). The **new / invite forms** (`volunteers#new` + `supervisors#new`) are also
  on casa_app now — self-contained Tailwind forms using `shared/_form_errors`; the shared
  not-authorized denial renders a `.alert` via the flash-parity base class (fixed the 3
  `.alert` new/invite specs).
- [x] Supervisors index + edit. Both on casa_app. The **index** is bespoke Tailwind: a supervisor
  roster + a "volunteers without supervisors" list + a "CASA cases without court dates" list, with
  a server-side status filter (auto-submit). Retired the serverSide DataTable by moving
  `#supervisors` off the `<table>` onto its wrapper (like volunteers). The per-supervisor contact
  stats are now labeled pills (color + icon + word: N attempting / N not attempting / N
  transition-aged, or "No assigned volunteers") instead of the old color-only bar chart; the
  transition-aged column is a Yes/No pill, not the 🦋/🐛 emoji; the always-blank Hearing type /
  Judge columns are dropped (court-date-less cases never have them). The **edit** page is a
  self-contained casa_app column (Profile / Account / Status / Volunteers): `supervisors/_manage_active`
  is now Tailwind and a new `supervisors/_manage_volunteers` twin replaces the shared Bootstrap
  `manage_volunteers` — the shared `_edit_form` / `_invite_login` stay for the casa_admin edit page,
  rebuilt inline here. "Edit supervisor" heading; Deactivate keeps the UJS `data-confirm`. Both
  view + system specs rewritten to semantic hooks (`[data-stat]`, `.supervisor-filters`,
  `[data-test=cases-without-court-dates]`); chevrons darkest-pixel verified (114 = slate-500); no
  overflow 375–1280. Follow-ups: the now-dead `supervisors#datatable` JSON action + `dashboard.js`
  supervisor block + the now-unused `shared/_manage_volunteers` (see the dead-code item); the
  per-supervisor stat methods stay per-row (N+1 parity with the retired datatable).
- [x] Case assignments — no standalone page to migrate: the assign / unassign / reimbursement
  actions are already casa_app via the `volunteers/_manage_cases`, `casa_cases/_volunteer_assignment`,
  and `supervisors/_manage_volunteers` twins (the `case_assignments#index` view is orphaned — no
  route points at it).
- [x] Learning hours (volunteer + supervisor/admin views + show + new/edit). All on casa_app.
  Volunteer index = a bespoke entries table (desktop table + mobile card twin, reused by the
  supervisor/admin `volunteers#show`). Supervisor/admin index = a per-volunteer roster with a
  YTD total, server-rendered + **Pagy** paginated, retiring the client-side DataTable (dropped the
  `table#learning-hours` id `learning_hours.js` targets). The new/edit form rebuilds the
  Hour(s)/Minute(s) inputs as a Tailwind twin of `Form::HourMinuteDurationComponent` (left
  untouched — still used by the Bootstrap case-contacts form); form-field + submit labels are
  spec-locked (queued for the sweep). Show is a fact card + Edit/Delete. Column headers
  sentence-cased ("Learning type", "Time spent", "Time completed this year"); the system + request
  specs updated to match. Chevrons darkest-pixel verified (114 = slate-500); no overflow 375-1280.
  Follow-up: the now-dead `learning_hours.js` DataTable init + the unrendered
  `learning_hours/_confirm_note` partial (see the dead-code item).
- [x] Reimbursements (`reimbursements#index`). On casa_app: a bespoke Tailwind table (desktop
  table + mobile card twin) reusing the controller's policy-scoped query + **Pagy**, retiring the
  jQuery serverSide DataTable (the `#reimbursements-datatable` table is gone, so the globally-
  required `src/reimbursements.js` no-ops). Server-side filters via the `auto-submit` controller:
  a single-select **Volunteer** dropdown (was a select2 multi; options come from the status-scoped
  set so selecting one does not collapse the list) + an occurred-at date range (the controller's
  date parse switched to `Date.parse` so native date inputs' ISO values work; volunteer filter
  guarded with `.present?` so "All" doesn't `where(creator_id: "")`). "Needs review" /
  "Reimbursement complete" tabs (sentence-cased) + column headers sentence-cased; "Download
  mileage report" CSV stays. Mark-complete is a per-row PATCH toggle (`_reimbursement_toggle`,
  checkbox auto-submits — CSP-safe, no inline onchange). Added a **Reimbursements** item to the
  casa_app sidebar (guarded by `policy(:reimbursement).index?`) so the page is reachable. Deleted
  5 orphaned partials (`_datatable`, `_table`, `_reimbursement_complete`, `_filter_trigger`,
  `_occurred_at_filter_input`). Chevron darkest-pixel 114; no overflow 375-1280; system + request
  + view + datatable + policy + notifier specs green (49). Follow-up: the now-dead
  `src/reimbursements.js` + `reimbursements#datatable` action + `ReimbursementDatatable` +
  `with_datatable` route (see dead-code).
- [x] Reports hub (`reports#index`). On casa_app: a "Quick exports" grid (6 one-click CSV
  buttons) + the filterable "Case Contacts Report" builder. Kept the `.report-form-submit` +
  `data-disable-with` contract (`src/reports.js` native-submits so the CSV download bypasses
  Turbo; the leading icons are pointer-events-none so `event.target` is the button). The 4 filter
  selects stay NATIVE `<select multiple>` with their spec-locked ids (multiple-select-field1..4) —
  select2 dropped (it hid the native select, breaking `select .. from:` / `have_select`);
  person-name options are now honorific-free (`formatted_name`). The column filter moved from a
  Bootstrap modal to a native `<details>`; deleted the orphaned `reports/_filter`. Individual
  report endpoints are CSV downloads (no HTML views). Spec-locked Title Case headings / labels /
  button names kept verbatim (sweep). No overflow 375-1280; specs green bar 2 pre-existing
  volunteer not-authorized redirects (they land on "/" not `casa_cases_path` — the app-wide
  redirect-target issue, unrelated to this view).
- [x] Organization settings (`casa_org#edit`). On casa_app: the org-profile form (name, logo,
  court-report template + download, feature toggles) + the Twilio credentials, revealed by a new
  `twilio` Stimulus controller that flips the fields' visibility + required/disabled from the
  "Enable Twilio" checkbox — replacing (and deleting) the jQuery + Bootstrap-collapse
  `src/casa_org.js`, which had to go because it also disabled the twilio fields by id globally and
  clobbered the controller. The 11 admin entity lists (contact types/groups/topics, judges,
  hearing types, languages, learning types/topics, placement types, custom links, sent emails) are
  restyled Tailwind tables keeping their spec-locked ids + cells + row ids + Edit/New links;
  contact-topic + custom-link deletes moved from the Bootstrap dropdown/`Modal::` to the Dialog
  `shared/confirm_button`. Section anchor ids (#contact-types, #case-contact-topics, ...) kept for
  deep links. Title-Case headings/labels kept verbatim (sweep). 33 view + system + request
  examples green; no page overflow 375-1280. The 11 admin tables now **card-stack on mobile**
  (`hidden md:block` table + `md:hidden` `<dl>` cards per design.md; measured fitting 375-1280).
  The entity CRUD pages the New/Edit links point at
  (contact_types#new, judges, ...) are still Bootstrap (Phase 5).
- [x] Court report generator (`case_court_reports#index`). On casa_app: reuses the `court-report`
  Stimulus controller + Dialog from the case-show modal (posts the case + date range to the JSON
  generate endpoint, spinner, opens the docx). The case picker is a new **searchable single-select
  TomSelect** (`searchable-select` controller) — its text search covers the volunteer names
  embedded in the option labels, so the select2 volunteer-name search is preserved (and both
  volunteers and admins now get it). Dropped select2; native `#case-selection` stays (TomSelect
  hides it, so option assertions use `visible: :all`) with its data-lookup/transition option
  attributes. Dates are native date inputs (ISO) like the show-page modal. Added a **Court
  reports** sidebar item (guarded by `see_court_reports_page?`). Rewrote the ~250-line select2 +
  Bootstrap-modal system spec + `CaseCourtReportHelpers` for the Dialog + TomSelect; the two
  old client-validation examples (hide-error-on-select, clear-on-reopen) were dropped — the empty
  selection now surfaces the server's "not found" error via the shared controller. 49 system +
  view + request examples green; no overflow 375-1280; TomSelect chevron is the documented global
  `.ts-wrapper::after` caret.

## Phase 5 — Admin long-tail CRUD
- [x] **Simple settings CRUD forms (batch 1)** — judges, languages, placement types, and
  learning-hour types + topics. Each `_form` now renders one shared **`shared/_settings_form`**
  (casa_app card: name + optional `Active?` checkbox + optional description + Submit; delegates
  `form_with model:` so it infers the url/param key), and each controller got `layout "casa_app"`
  + `@active_nav = "settings"`. Reached from the settings page (New/Edit links); redirects back to
  settings on save. The old breadcrumb was dropped (no `current_organization` dependency, so the
  no-layout view specs pass). 41 system + view + request examples green; no overflow. Reuse
  `shared/_settings_form` for the remaining name(+active) resources below.
- [x] Contact types, contact type groups, contact topics (**batch 2**). Contact type groups reuses
  `shared/_settings_form` (name + Active? + description); contact types + contact topics get custom
  casa_app forms — contact types adds a group **chevron-select** (id
  `contact_type_contact_type_group_id` kept for the system spec), contact topics has
  question/details + Active? + Exclude from Court Report?. Controllers on `layout "casa_app"` +
  `@active_nav = "settings"`. 45 system + request examples green; chevron darkest-pixel 114; no
  overflow.
- [x] Hearing types + checklist items + custom org links (**batch 3**). The hearing-type form is
  name + Active? in a card, plus (once persisted) a Tailwind checklist-items table with New/Edit
  links and a `button_to` Delete (turbo_confirm only — a non-JS destroy spec drives "Delete", so no
  Dialog). checklist_items new/edit is a custom casa_app form (Category / Description / Mandatory)
  nested under the hearing type; custom org links is a casa_app form (Display text / URL / Active?).
  57 system + view + request examples green; the checklist table now **card-stacks on mobile**
  (`md:hidden` `<dl>` cards per design.md), like the settings admin tables.
- [x] Mileage rates, placements, banners (**batch 4**). Mileage rates: a casa_app settings index
  (date / amount / Active? / Edit, no delete) + a date+currency+Active? form. Placements (nested
  under a case): a casa_app index whose per-row Delete is a **Dialog** with a visible "Close" +
  `button_to "Confirm"` so the **non-`:js`** destroy spec passes (rack_test can't match an
  aria-label X); a date + chevron-select form; a fact-card show. Banners: a casa_app `#banners`
  table (kept `td.min-width` for a system spec) with a `shared/_confirm_button` Delete, and a form
  with the **rich-text** content editor + a live `reveal` warning (new Stimulus controller) when
  another banner is already active. **Trix** needed its stylesheet folded into the casa_app tailwind
  bundle (`@import "trix/dist/trix.css"`) — without it the toolbar was unstyled and overflowed the
  page to ~900px. 58 system + view + request examples green; chevron darkest-pixel 114; pages fit
  375–1280 (tables + the Trix toolbar scroll within their own containers).
- [x] Court dates + bulk court dates (**batch 5**). Both nested court-date forms render on casa_app,
  sharing court_dates/_fields (date + due-date + judge/hearing chevron-selects) and the casa_app
  court-orders twin (casa_cases/_court_orders, siblings off, resource "court_date"), so the
  court-order-form nested sub-form + its dialogs are shared with the case-edit page. Submit stays
  inside .top-page-actions (spec hook); the show page keeps its <dt><h6>Label:</h6></dt><dd> xpath
  structure (Title-Case colons ride the sweep) and deletes a future date via UJS method: :delete +
  data-confirm (native window.confirm, like the volunteer deactivate). 80 examples green; chevron
  114; pages fit 375-1280. (bulk new_spec:15 is a pre-existing travel_to flake — fails identically
  on the legacy views when run after the edit spec.)
- [x] Imports (**batch 5b**). CSV import page on casa_app: the Bootstrap JS tabs became server-side
  link tabs keyed on ?import_type= (ids + "Import X" labels kept for the system spec), only the
  active panel renders, and the CSV error is an inline alert (was a Bootstrap modal). The SMS
  opt-in step is an inline amber panel that keeps id="smsOptIn" + the file/button ids + the
  enable-on-check script, so the global src/import.js (button enable + localStorage file
  persistence across the opt-in reload) keeps working. 21 system + request examples green; page
  fits 375-1280 (tabs scroll within their nav on the narrowest screen).
- [x] Emancipation (**batch 5c**). The emancipation checklist show page is on casa_app with every
  AJAX/collapse hook preserved verbatim (the .emancipation-category h6 + data-is-open, its child
  .category-collapse-icon, the adjacent .category-options sibling the Toggler reads via .next(),
  the .emacipation-category-input-label-pair div, .check-item options, and a #notifications element
  so the Notifier — hence the whole src/case_emancipation.js — constructs and binds). The checklist
  index is a plain Tailwind table (dropped the all-case-emancipations id so the src/emancipations.js
  DataTable no-ops). 42 system + view + request examples green; pages fit 375-1280.

**Phase 5 (admin long-tail CRUD) is complete.**

## Phase 6 — all-CASA-admin area, Devise edges, static pages
- [x] All-CASA-admin **shell + org management (6a)**. New Tailwind `all_casa_admin` layout (own
  sidebar: CASA organizations / Patch Notes / Edit Profile / Feature Flags / Pg Dashboard + Log
  Out; simplified topbar; footer with the Ruby For Good / site-issue / SMS-terms links; inline
  flash keeping a .header-flash hook). Set on the base AllCasaAdminsController (patch_notes stays
  on `application` until 6b). Migrated the dashboard (org table), casa_orgs new/show (+ metrics),
  and casa_admins new/edit/_form to Tailwind cards/tables/forms; the profile edit uses the
  disclosure controller for the change-password panel (kept id=collapseOne; specs moved off
  Bootstrap .collapse/.show to .hidden). Kept shared/error_messages (specs lock #error_explanation
  + the "N errors prohibited" format). 89 examples green (the one red, all_casa_admin_spec:14
  casa_admin "/" -> /supervisors, is a pre-existing regular-app routing failure — red on legacy too).
- [x] All-CASA-admin **patch_notes index (6b)** — the JS clone-CRUD page. Kept the exact DOM the
  jQuery reads (`#patch-note-list` child order; each `.card-body`'s direct textarea /
  .label-and-select x2 / .patch-note-button-controls; the .button-edit/.button-delete hooks) and
  restyled to Tailwind cards/native-selects; the shell now also loads the separate `all_casa_admin`
  JS bundle (its `tables` DataTable no-ops on the plain Tailwind tables) and renders the
  `layouts/components/_notifier` (the Notifier needs its `.messages` container). Ported the JS's
  injected Edit/Delete/Save/Cancel buttons from Bootstrap+FontAwesome to button_classes strings +
  bi-* icons. Also fixed the emancipation show page, which had the same bare `#notifications` (its
  AJAX save feedback was silently dropped). **The all-CASA-admin authenticated area is now fully on
  the shell.** 23 patch_notes + 91 all-casa examples green (only pre-existing all_casa_admin_spec:14
  red); page fits 375-1280.
- [x] All-CASA-admin **auth (6c)**: sessions/new + passwords/new rebuilt on the casa_auth
  split-screen shell to match devise/sessions/new (kept the "All CASA Log In" heading, Email/Password
  labels, the .actions wrapper + "Log in", and flash for the sign-out landing). 13 examples green;
  pages fit 375-1280.
- [x] **static#index landing page** — the public marketing page rebuilt on the design system
  (compiled tailwind.css + Figtree + brand palette + a brand-gradient hero, replacing the Tailwind
  CDN + Alpine). Kept the spec-locked #organizations section, .org_logo images, and the "CASA
  Organizations Powered by Our App" heading. 4 examples green; page fits 375-1280 (the header's
  decorative blur is clipped by overflow-hidden, like casa_auth).

**Phase 6 is complete** — the all-CASA-admin area (shell + org management + auth + patch notes)
and the public landing page are all on the design system. (The regular-user Devise pages —
sign-in / password / invitation — were done in the foundation phase.)
- [x] Health / metrics page (`health#index`): rebuilt as bespoke server-rendered SVG
  (line charts with a distinct line-style + marker per series, heatmap-as-table, table
  twins, stat tiles with correct totals, and zero / no-data / empty states) on a minimal
  `metrics` layout; retired the Chart.js + jQuery `display_app_metric.js`. Follow-ups (date-range filter, Stimulus hover, and the unused chart.js deps removal now shipped): a validated dark-mode
  palette.

## Straggler pages (still on the Bootstrap `application` layout) — block decommission
Found by auditing controllers not on casa_app / casa_auth / all_casa / metrics (Bootstrap markers
present, zero casa_app markers). These reachable leaf pages were never in the phase plan and must
migrate before `application.html.erb` + `application.scss` can be deleted.
- [x] `fund_requests#new` — **SHIPPED** on casa_app (`layout "casa_app"`, `@active_nav = "cases"`,
  back-link to the case). Reused the casa_cases/new form pattern (max-w-2xl card, 2-col grid of
  short fields + full-width textareas, `shared/form_errors`, bottom primary submit); kept the field
  label substrings the spec fills by + the `* / **` footnotes. Sentence-cased the feature copy
  (h1/page-title, "Submit fund request", the flash, and the case-show link), updating the 2 spec
  assertions. 2 system + 11 request examples green; no overflow at 500/768/1280.
- [x] `casa_admins#index/new/edit` — **SHIPPED** on casa_app (`layout "casa_app"`). Rebuilt as
  self-contained casa_app views mirroring the supervisors sibling: a bespoke index table (`#admins`
  hook on the wrapper, "Deactivated" tag), a minimal new form, and an edit page (Profile / Account /
  Status) whose Deactivate keeps the UJS `data-confirm` the `:js` spec drives. Kept the legacy
  "N errors prohibited this Casa admin from being saved:" format + `#error_explanation` via a
  casa_app-styled `casa_admins/_errors` partial. Retired the shared `casa_admins/_form` + its
  `shared/_edit_form` + `shared/_invite_login` (now dead — see dead-code). Spec-locked Title Case
  ("Create New Casa Admin", "Receive Monthly Learning Hours Report", "Resend Invitation", "Change to
  Supervisor") kept verbatim, queued for the sentence-case sweep. 53 examples green; no overflow
  500/768/1280.
- [x] `other_duties#index/new/edit` — **SHIPPED** on casa_app (`layout "casa_app"`). Index is a
  bespoke Tailwind table grouped by volunteer (desktop table + mobile card twin); new/edit stay thin
  `render "form"` wrappers over a rebuilt casa_app `_form` (the Hour(s)/Minute(s) duration twin like
  learning hours; the controller's `convert_duration_minutes` still combines them). Notes keeps
  `required` + the default `#other_duty_notes` id (a `:js` spec asserts the HTML5 validation
  message). Swapped `shared/error_messages` for `shared/form_errors` (no spec locks the legacy
  format here). Spec-locked Title Case ("Other Duties", "New Duty", "Editing Duty", "Occurred On",
  "Duty Duration", "Enter Notes") kept verbatim, queued for the sweep. 26 examples green (view +
  system + request); no overflow 500/768/1280.
- [x] `notes#edit` — **SHIPPED** on casa_app (`layout "casa_app"`, `@active_nav = "volunteers"`). A
  single volunteer-note edit form (max-w-2xl card, back-link to the volunteer edit page); Note has
  no validations so update always redirects back. Kept `note[content]` + the spec-locked "Update
  Note" button (queued for the sweep). 23 examples green (system + request).
- [x] `case_assignments#index` — **not a page**: `resources :case_assignments, only: %i[create
  destroy]` has no index route or action, and the view set no `@volunteer`, so
  `case_assignments/index.html.erb` was orphaned dead code that could never render (it even used
  the DataTable `id='casa_cases'`). **Deleted** it rather than migrate. 45 request examples green.
- [x] `error#index` — **SHIPPED**. This is the public dev/QA "Intentional error test" page
  (`GET /error`; a button POSTs to raise a test exception), **not** the 404/422/500 handler (those
  stay static `public/*.html`). Since it's viewable logged-out, it can't use the casa_app shell
  (needs `current_user`), so added a minimal logged-out `layouts/error.html.erb` (compiled tailwind
  + Figtree, no app JS) and rebuilt the page as a centered Tailwind card. 2 request examples green.

_Data-only actions on the default layout render no HTML and need no migration: the `*_reports`
CSV/XLSX exports, `preference_sets`, `android_app_associations`, and the `api/*` endpoints._

## Cross-cutting / infrastructure
- [x] **Edit-profile shared labels — DONE (sweep batch 3).** "Update Profile", "Change Password",
  "New Password"(+ Confirmation), "Current Password", "Update Password", "Change Email", and
  "Enable Twilio For Text Messaging" (Twilio kept) sentence-cased across users/edit +
  all_casa_admins/edit + all_casa_admins/casa_admins/edit and every coupled spec (incl. the shared
  phone-error example + the standalone "Password Confirmation" substring locators).
- [ ] Contrast audit of shipped pages: replace remaining `text-slate-400` body/meta text
  with `slate-500` for WCAG AA; re-check pills and badges.
- [x] **Vendor Bootstrap Icons + Figtree — DONE.** Self-hosted: font binaries under
  `public/vendor/{bootstrap-icons,figtree}/`, the `@font-face`/glyph CSS vendored under
  `app/assets/stylesheets/vendor/` and `@import`ed by `tailwind.css`; dropped the Google Fonts +
  jsdelivr CDN `<link>`s from all six shells (casa_app, casa_auth, all_casa_admin, error, metrics,
  static landing). Absolute `url()`s so the Tailwind CLI (Lightning CSS) leaves them untouched;
  served from `public/` by the same static middleware as the compiled `tailwind.css`.
- [x] **Nav-toggle -> Stimulus — DONE** (aligns with the jQuery -> Stimulus migration, #5016).
  The inline mobile-nav `<script>` in `casa_app.html.erb` *and* the identical one in
  `all_casa_admin.html.erb` are replaced by a shared `nav-drawer` controller
  (`app/javascript/controllers/nav_drawer_controller.js`): `sidebar`/`backdrop`/`button` targets;
  `click->nav-drawer#toggle` on the button, `click->nav-drawer#close` on the backdrop, and
  `keydown.esc@window->nav-drawer#close`. Jest-covered (open/close/backdrop/Escape).
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
- [x] **Dead-code removal — DONE** (7 verified batches, each committed with specs/build green):
  1. orphaned partials + `Form::HourMinuteDurationComponent` (+spec) +
     `CaseContactDecorator#form_page_notes` (`notifications/_notification` + its
     `notification_row_class`/`notification_icon` helpers, `shared/_manage_volunteers`,
     `shared/_edit_form`, `shared/_invite_login`, `casa_cases/_form`, `learning_hours/_confirm_note`).
  2. Bootstrap sidebar/header layout partials (`layouts/_sidebar`, `_header`,
     `_all_casa_admin_sidebar` + specs) + `Sidebar::Link`/`GroupComponent` (kept `SidebarHelper`,
     live via `cases_index_title`).
  3. reimbursements serverSide DataTable stack (`src/reimbursements.js` + its `application.js`
     require, `reimbursements#datatable` + its sole-caller helper, `ReimbursementDatatable` + spec,
     `with_datatable` off the reimbursements route).
  4. `dashboard.js` (466 lines) + `volunteers#datatable` / `supervisors#datatable` actions + the
     `with_datatable` concern (all three refs, incl. case_contacts whose action never existed) +
     `SupervisorDatatable` (+spec) + its `brakeman.ignore` entry. **Kept** `VolunteerDatatable`
     (live: volunteers index reuses its SQL) + `Notifier` (shared).
  5. the now-dead `datatable?` Pundit predicates in volunteer/supervisor/casa_admin/case_contact
     policies + `ReimbursementPolicy#datatable?` (+ their spec coverage).
  6. `learning_hours.js` DataTable init (**kept** `datatable.js`, still used by
     `all_casa_admin/tables.js`).
  7. the 33 orphaned Bootstrap-era SCSS partials under `shared/` (except the manifest-linked
     `noscript.css`), `pages/`, and `base/` — their compiled root `application.scss` was already
     gone and the CSS build is Tailwind-only.
  `casa_cases/_generate_report_modal` was already gone. **Not dead — needs a deliberate migration,
  not a sweep:** `CasaCase#hearing_type` / `#judge` + the `hearing_type_name` / `judge_name`
  delegates are still consumed by `case_court_report_context.rb` and `PreferenceSet`'s
  case-column-visibility keys, so removing them would entangle the court report + column prefs.
  Follow-up (done): dropped the now-unused `sass` + `bootstrap-scss` deps from `package.json`
  (no `build:css`/importer remained after the SCSS + CDN removal).
- [x] **Sentence-case sweep — DONE.** Proper nouns/acronyms (CASA, IEP, Twilio) kept; free-form org
  data untouched. Done in verified batches, each with its coupled system/view/request specs updated
  in lockstep (incl. specs that matched old labels by case-sensitive substring, e.g.
  `fill_in "Court Date"` / `"Password Confirmation"`): 1 case-detail labels · 2 court_dates ·
  3 edit-profile · 4a casa_admins/other_duties/notes · 4b volunteer/supervisor edit + manage
  partials · 4c learning hours + ~12 settings CRUD forms · 4d case-contact form + CTAs + dialog
  titles · 4e/4f remaining headings/buttons/field labels. **Left as data (not headings):** CSV/XLSX
  export column headers, the emancipation DOCX filename/template, model validation messages, mailer
  copy, and the notifier "Emancipation Checklist Reminder". Dead Bootstrap shared partials skipped
  (see dead-code).
- [ ] **Contact-type default rename (guarded after-party, do once pages are migrated).** For
  existing orgs, rename the contact types + the "Social Services" group whose names **exactly**
  match the old Title Case defaults to the new sentence-case defaults ("Foster Parent" ->
  "Foster parent", etc., per `ContactTypeGroup::DEFAULT_CONTACT_TYPE_GROUPS`). Exact-match only
  so org customizations are left alone; associations are by id so contacts are unaffected;
  **guard the per-org name-uniqueness edge case** (skip a rename if the sentence-case name
  already exists in that org). New orgs already seed the new names.
- [x] **Decommission the Bootstrap `application` layout + `application.scss` — DONE.**
  - Deleted `layouts/application.html.erb` (+ its view spec), `layouts/devise.html.erb`,
    `app/assets/stylesheets/application.scss`, and the legacy
    `public/assets/css/{lineicons,materialdesignicons.min,main}.css`.
  - Moved Devise's last un-customized default controllers onto `casa_auth` so nothing needs
    `layouts/devise`: thin `layout "casa_auth"` subclasses `Users::ConfirmationsController`,
    `AllCasaAdmins::PasswordsController`, `AllCasaAdmins::InvitationsController` (routed via
    `devise_for`). Styled `devise/confirmations/new` and rebuilt `devise/invitations/new` on
    casa_auth — this also **fixes** the all-CASA password/invite pages, which had been rendering
    Tailwind views on the CSS-less Bootstrap devise shell (unstyled).
  - Rewired the build off Bootstrap SCSS: dropped `build:css` / `build:css:dev` (package.json) +
    the `css:` `Procfile.dev` process; pointed `bin/setup` + `bin/update` + the assets git hook at
    `build:tailwind`.
  - Verified: all 6 devise HTML pages render 200 on casa_auth; auth specs green; full
    request+view sweep adds **no** new failures.
  - `application.js` stays — `casa_app` + `casa_auth` still load it. Now-orphaned by these deletions
    (queue in dead-code): `layouts/_sidebar`, `_header`, `_all_casa_admin_sidebar`; every Bootstrap
    SCSS partial under `app/assets/stylesheets/` (`shared/*`, `base/*`, bootstrap overrides); and the
    legacy icon-font assets the deleted CSS referenced.
- [x] **Refresh stale view/request specs — DONE.** The pre-existing reds asserted old Bootstrap
  markup for pages migrated in earlier phases. Fixed: `casa_cases/index` (stub the `_filter` +
  `shared/pagination` partials the bespoke view now renders + assign `@pagy`), `casa_cases/new` +
  `casa_cases/show` (sentence-cased labels — "Youth's birth month and year", "Assign a volunteer",
  "Current placement"; `have_content` for the HTML-escaped apostrophe), `casa_cases/edit` (added the
  `#volunteer-assignment` id back to the `_volunteer_assignment` twin), and the devise
  `passwords/new` + `invitations/edit` view specs + `users/invitations` request spec ("Reset your
  password", "Set your password", "Confirm password", "Activate account"). Retired
  `spec/views/volunteers/index.html.erb_spec.rb` per ADR 0006 — the bespoke index is coupled to
  `VolunteerDatatable`'s computed `supervisor_name`, so a view spec feeding plain records can't
  render it, and `spec/system/volunteers/index_spec.rb` already covers the roster + supervisor
  column (incl. the inactive-supervisor case) + New-volunteer nav.

## Stakeholder / product questions (confirm before finalizing)
- [ ] **Hearing type & judge on case lists.** The old cases index (and `supervisors/index`)
  showed per-case "Hearing Type" and "Judge" columns, but their backing columns were removed
  from `casa_cases` in 2023 (migration `20230729213608`) — that data moved to court dates, so
  those columns have rendered blank for every case since. Both migrated indexes have now dropped
  them (the cases index shows "Next court date" instead; `supervisors/index` lists cases
  *without* court dates, so type/judge/next-date are all N/A there). Ask stakeholders: is next
  court date the right thing to surface on the main roster, or do they want the upcoming
  hearing's type/judge (sourced from court dates)? The answer decides whether to delete the dead
  `CasaCase` associations.
