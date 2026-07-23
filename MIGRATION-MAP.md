# Migration map — legacy Bootstrap → casadesign (Tailwind v4)

**Status: every user-facing page is migrated.** This map was built by inspecting the code (commit
`cbff2ed4e`), not by trusting the design.md checklist: each page-rendering controller resolves to a
Tailwind shell (class-level `layout "casa_app"`, an inline `render …, layout: "casa_app"`, or an
inherited/own Tailwind layout), and a scan for Bootstrap markers (`btn btn-`, `col-*`, `card-body`,
`data-bs-`, DataTables) surfaced only **dead (0-render) legacy files, mailers, and false positives** —
no live Bootstrap page.

"Migrated" = renders on a Tailwind shell AND uses the design system (Tailwind utilities +
`button_classes`/`ghost_class`/`display_person`/`Dialog::`/Pagy), not Bootstrap classes or jQuery
DataTables.

## Shells — the frame every page hangs in

| Legacy (removed) | Redesign shell | Used by |
|---|---|---|
| `application.html.erb` (Bootstrap navbar + jQuery) | **`layouts/casa_app.html.erb`** — 256px sidebar + top bar | all signed-in chapter pages |
| Bootstrap auth | **`layouts/casa_auth.html.erb`** | sign-in, password reset, invitation accept (user + all-CASA) |
| Bootstrap all-CASA | **`layouts/all_casa_admin.html.erb`** | the all-CASA-admin console (inherited from `AllCasaAdminsController`) |
| — | self-contained Tailwind (`layout false`) | public `static#index` landing |
| — | **`layouts/error.html.erb`** | error page |

## Page coverage — all migrated

| Area | Pages | Shell |
|---|---|---|
| Auth | sign-in, forgot/reset password, invitation accept | casa_auth |
| App shell | sidebar, top bar, banners, flash, impersonation banner, notifications, edit profile | casa_app |
| Dashboards | volunteer, supervisor, admin (triage) | casa_app |
| Cases | index, show, new, edit; court dates + bulk; placements; emancipation checklist; court-report generator | casa_app |
| Case contacts | index, multi-step autosave form, drafts, followups, additional expenses, new-design table | casa_app |
| Volunteers | index (+ filter), edit, notes, manage cases/supervisor/active | casa_app |
| Supervisors | index (+ unassigned/assign type-ahead), edit | casa_app |
| Learning hours | index, form, volunteer/supervisor views | casa_app |
| Reimbursements | queue + complete toggle | casa_app |
| Reports | hub + CSV exports (learning-hours / followup / mileage / missing-data / placement / case-contact) | casa_app |
| Other duties | index / new / edit | casa_app |
| Org settings | casa_org edit + judges, languages, contact types/groups/topics, hearing types (+ checklist items), placement types, learning-hour types/topics, custom org links, mileage rates, banners | casa_app |
| Imports | volunteers / supervisors / cases + SMS opt-in | casa_app |
| Analytics | per-chapter charts (admin + supervisor) | casa_app |
| All-CASA admin | dashboard, casa_orgs, casa_admins, edit/new, patch notes, **Metrics** console | all_casa_admin |
| Public / ops | `static#index` landing (Tailwind); `error` page (Tailwind); `/health` (minimal ops status — intentionally not app UI) | own |

**Non-page controllers** (no HTML views — nothing to migrate): case_assignments, supervisor_volunteers,
additional_expenses, contact_topic_answers, case_court_orders, preference_sets, android_app_associations,
the `*_reports` CSV exporters, case_contacts/followups (redirect / JSON / CSV only).

## Element / pattern mapping (current → redesign)

| Current (Bootstrap / jQuery) | Redesign (casadesign) |
|---|---|
| `.card` | `rounded-2xl border border-slate-200 bg-white p-5 shadow-sm` |
| `.btn .btn-primary/secondary/danger/success` | **`button_classes(:primary\|:secondary\|:danger\|:danger_outline\|:success)`** — one 40px (`h-10`) token |
| link/row actions (Edit, Delete, Detail view, Assign) | **`ghost_class`** (neutral) / **`ghost_class(:danger)`** (destructive: slate at rest, rose on hover) |
| jQuery **DataTables** (serverSide) | bespoke Tailwind `<table>` + server-side filter scopes + `?sort=` + **Pagy** (`shared/_pagination`, in-card footer) |
| Bootstrap `.modal` / `Modal::*` / `data-bs-*` | **`Dialog::` ViewComponent** suite (native `<dialog>` + `modal` Stimulus controller) |
| native `confirm()` / SweetAlert delete | **`shared/_confirm_button`** (Dialog-gated) |
| `.form-group` + `.form-control` | Tailwind inputs (`rounded-lg border-slate-300 px-3.5 py-2.5 …`) + `field_error` / `shared/_form_errors` |
| select2 / jQuery multiselect | **TomSelect** — `multiple-select`; searchable single-select `searchable-select` |
| Bootstrap grid `.row .col-*` | Tailwind `flex` / `grid grid-cols-*` |
| Bootstrap `.alert` flash | `shared/_flashes` + **`alert_classes`** |
| Bootstrap dropdown (`data-toggle`) | native `<details>` + `dropdown` controller (page-header **More** overflow) |
| honorific names (`.display_name`) | **`display_person`** (new UI) / **`formatted_name`** (legacy sites) — first + last only |
| in-content links | **`name_link_class`** (people: dark + underline) / **`record_link_class`** (records: brand) |

## Loose ends (not blocking — tracked)

- **Reachability — a real gap I initially missed** (page-level migration != reachable): a full sweep of
  casa_app pages for inbound nav links found **6 orphaned pages** (migrated, but linked nowhere):
  - **FIXED** — Mileage rates, Banners, Imports, Manage admins: now linked from **Settings →
    Administration** (all return 200).
  - **Still orphaned** — `other_duties` (a conditional volunteer feature; only its *enable* toggle is on
    Settings, no link to the pages) and `emancipation_checklists#index` (an index-only page). Both need a
    home or retirement — placement TBD.
  - Everything else is reachable (sidebar / the Settings inline CRUD / case-child pages such as fund
    requests via the case show). **My earlier "all migrated" checked Tailwind-on-a-shell, not
    navigability — that was the miss.**
- **Dead legacy files — DELETED** (verified 0 references across views / rb / js / specs; superseded by
  `Dialog::` and the casa_app twins): `shared/_court_order_form`, `shared/_court_order_list`,
  `casa_cases/_thank_you_modal`, `case_contacts/_confirm_note_content_dialog`, `layouts/_mobile_navbar`,
  `devise/shared/_links`, `all_casa_admins/shared/_links`.
- **Footer — DELETED**: `layouts/footers/_logged_in` + `_not_logged_in` + `spec/.../footer.html.erb_spec.rb`
  (rendered by no layout). Their links survive on the `all_casa_admin` layout footer + the `static`
  landing. **Note:** `casa_app` (the main chapter app) has **no footer** — so the SMS Terms & Conditions
  and Report-a-site-issue links aren't shown to signed-in chapter users. Pre-existing gap (the footer was
  dropped, not migrated onto casa_app), worth a product call.
- **Emancipation — dead code, decision pending** (I mis-labelled this twice): `shared/_emancipation_link`
  is rendered by `CasaCaseDecorator#transition_aged_youth`, which **no view calls** (only the decorator
  spec). The migrated cases index built its **own** transition-aged column (a plain Yes/No violet pill)
  and dropped the emancipation quick-link; the checklist is still reachable from the case **show** page.
  So this is dead legacy code, not a displayed element. Options: **(a)** delete the dead cluster
  (`_emancipation_link` + the `transition_aged_youth` method + its spec examples), or **(b)** re-add the
  quick-link to the migrated index, design-system-styled.
- **Mailers are intentionally NOT part of the UI redesign** — emails use inline CSS (ADR 0007):
  volunteer / supervisor / casa_admin / user / fund_request / learning_hours mailers + the devise mailer.
- **`[~]` help-link destination** — the one open item on the design.md checklist (app-shell leaf).
- **`/health`** — deliberately minimal ops status page, off the app shell by design (not a gap).
