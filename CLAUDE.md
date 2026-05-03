# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this app is

CASA is a Rails app used by CASA (Court Appointed Special Advocate) chapters to track volunteer work with foster youth. The domain shape: a **CasaCase** (a youth) is assigned to a **Volunteer**, who logs **CaseContacts**; **Supervisors** oversee volunteers; **CasaAdmins** run the chapter. The app is **multi-tenant** — every record belongs to a `CasaOrg`, and cross-org data leaks are the most important class of bug to avoid.

## Common commands

| Task | Command |
|---|---|
| One-time setup | `bin/setup` |
| Run app (web + JS/CSS watchers) | `bin/dev` then visit http://localhost:3000 |
| Run full RSpec suite | `bin/rails spec` |
| Run a single spec file | `bundle exec rspec spec/path/to/file_spec.rb` |
| Run a single example | `bundle exec rspec spec/path/to/file_spec.rb:LINE` |
| Run JS tests | `npm run test` |
| Run all linters w/ autofix | `bin/lint` (standardrb + erb_lint + standardjs + factory_bot:lint) |
| Update env after pulling main | `bin/update` (migrate, bundle, npm, after_party) |
| Run post-deploy tasks | `bundle exec rake after_party:run` |
| Local mailer previews | http://localhost:3000/rails/mailers |

Seed login credentials (password `12345678` for all):
- `volunteer1@example.com`, `supervisor1@example.com`, `casa_admin1@example.com` at `/users/sign_in`
- `allcasaadmin@example.com` at `/all_casa_admins/sign_in`

## Tech stack

Rails 7.2 on Ruby (`.ruby-version`), PostgreSQL, Hotwire (Turbo + Stimulus), Bootstrap 5, ESBuild, Devise + Devise-Invitable, Pundit, Draper, ViewComponent, Delayed Job, Flipper, Paranoia (soft deletes), Strong Migrations. Linting: Standard.rb + standard-rails, StandardJS, erb-lint. Testing: RSpec + Capybara (system tests via Selenium/Chrome), Jest. There is **no UI sign-up** — users are admin-invited only (ADR 0002).

## Architecture: things that require reading multiple files to understand

### Two user tables (ADR 0003)
There are **two separate Devise models**: `User` (with subclasses `Volunteer`, `Supervisor`, `CasaAdmin` — these are real STI subclasses, each with its own model file) and `AllCasaAdmin` (a separate top-level model and table for super-admins who span orgs). Devise is configured for both in `config/routes.rb`, and there is a parallel `app/controllers/all_casa_admins/` namespace + `app/models/all_casa_admins/` for the all-casa flows. When touching auth, check both sides.

### Multi-tenancy is enforced in three places
1. Models include `ByOrganizationScope` (`app/models/concerns/by_organization_scope.rb`) which gives `.by_organization(casa_org)`.
2. The `Organizational` controller concern (`app/controllers/concerns/organizational.rb`) provides `current_organization` from the signed-in user.
3. Pundit policy scopes filter by org: `scope.by_organization(user.casa_org)`.

Every controller index action should call `policy_scope`; every show/update/destroy should call `authorize`. Controllers typically use `after_action :verify_authorized` (with explicit `except:`). When adding a new model with org-scoped data, all three places must be wired up or queries will leak across orgs.

### Authorization is policy-based (Pundit)
Policies live in `app/policies/`. They define both predicate methods (`update?`, `destroy?`) and `permitted_attributes` (role-based field allowlists for strong params). When adding a model attribute that admins/supervisors/volunteers should be able to set, update `permitted_attributes` in the policy — not just the controller.

### Layering: where logic goes
- **Controllers** stay thin. Standard pattern: `set_record` before_action, `authorize`, save/render with `:unprocessable_content` on failure.
- **Service objects** (`app/services/`) — `ServiceName.new(args).perform`. Used for CSV exports, SMS reminders, complex multi-record operations.
- **Decorators** (`app/decorators/`, Draper) — presentation logic. Access view helpers via `h.helper_method`. Called as `model.decorate`. Date formatting, conditional display strings, etc. belong here, NOT in models or ERB.
- **ViewComponents** (`app/components/`) — reusable UI primitives (badges, modals, sidebar, dropdown menus, form bits).
- **Parameter objects** (`app/values/`) — builder-pattern wrappers for non-trivial strong-params logic, e.g. `VolunteerParameters.new(params).with_password(pw).without_active`.
- **Concerns** (`app/{models,controllers}/concerns/`) — shared behavior via `extend ActiveSupport::Concern`. Notable model concerns: `ByOrganizationScope`, `Roles`, `Api`, and a `CasaCase/` directory of concern modules used by the `CasaCase` model.

### Frontend
Hotwire-first: Turbo for navigation/forms, Stimulus controllers in `app/javascript/controllers/`. There is an [in-progress migration](https://github.com/rubyforgood/casa/issues/5016) from inline JS / jQuery to Stimulus — new code should be Stimulus, but legacy jQuery is not flagged. JS is bundled via ESBuild (`bin/asset_bundling_scripts/build_js.js`); SCSS via the `sass` CLI. Both have watchers in `Procfile.dev`. Email views require **inline CSS** for client compatibility (ADR 0007).

### Notable conventions
- **Soft deletes** via Paranoia: `destroy` marks deleted, doesn't hard-delete. Be deliberate when reasoning about uniqueness or "where is this record."
- **Strong Migrations** is enabled and will block unsafe DDL (column removal without `safety_assured`, non-concurrent index adds on large tables, type changes). Reversibility is required.
- **Soft-deletion-aware uniqueness**: `validate_uniqueness_of(...).scoped_to(:casa_org_id)` is the typical pattern — uniqueness is per-org.
- **Enums** use prefix syntax: `enum :status, {active: 0, inactive: 1}, prefix: :status`.
- **Post-deployment tasks** run via After Party (`bundle exec rake after_party:run`), invoked automatically by `bin/update` and on Heroku release.

### Testing conventions
- **System tests are preferred** over controller tests (ADR 0006 — `app/controllers/concerns/users/` and `spec/controllers/` exist but are minimal). New UI behavior should land in `spec/system/`.
- Factories use **traits** for variants: `create(:casa_case, :active)`. `bin/lint` runs `factory_bot:lint` to catch invalid factories.
- Use `build` for unit tests; `create` only when persistence is required. `let` for lazy, `let!` when the record must exist before the example.
- shoulda-matchers handles association/validation tests.
- No `sleep` in tests — rely on Capybara waiting.
- Flaky tests are disabled with `xit` + a tracking issue, never deleted.

## Style
This project uses **Standard.rb** (not vanilla RuboCop). Don't fight it on spacing/quotes/trailing commas. There is also a `.standard_todo.yml` of grandfathered violations — leave older files alone unless touching them substantively. Older migration files (2020–2024) are intentionally excluded from linting.

## Where to look for more
- `.github/instructions/ruby.instructions.md` and `.github/instructions/copilot-review.instructions.md` — the project's own review checklist; the source of truth for "what is a bug-shaped change here."
- `doc/architecture-decisions/` — ADRs (especially 0002 no-UI-signup, 0003 two-user-tables, 0006 few-controller-tests, 0007 inline-email-CSS).
- `doc/productsense.md` — product philosophy.
- `db/schema.rb` — paste into [dbdiagram.io](https://dbdiagram.io/d) for an ERD.
