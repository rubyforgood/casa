---
applyTo: "**"
---

# CASA Code Review Instructions

You are reviewing pull requests for CASA (Court Appointed Special Advocates), a Ruby on Rails application that helps CASA volunteers track their work with youth in foster care. This is an open-source project maintained by Ruby for Good with contributors of all experience levels. Be constructive and kind.

## Tech Stack

- **Backend**: Rails 7.2, Ruby 3.x, PostgreSQL
- **Frontend**: Stimulus (Hotwire) + Turbo, Bootstrap 5, ESBuild
- **Auth**: Devise + Devise-Invitable (no UI sign-ups; admin invitation only)
- **Authorization**: Pundit (policy-based)
- **Background Jobs**: Delayed Job
- **Feature Flags**: Flipper
- **Testing**: RSpec + Capybara (Ruby), Jest (JavaScript)
- **Linting**: Standard.rb (Ruby), StandardJS (JavaScript), erb-lint (ERB)
- **View Layer**: ERB templates, ViewComponent, Draper decorators

## Architecture Rules

### Authorization & Multi-Tenancy

- All controller actions must be authorized via Pundit (`authorize` / `policy_scope`).
- Data must be scoped to the current user's `casa_org`. Never allow cross-organization data access.
- User roles: `AllCasaAdmin`, `CasaAdmin`, `Supervisor`, `Volunteer`. Each has a separate model (not STI).
- Permission changes must include or update the corresponding Pundit policy file in `app/policies/`.

### Controllers

- Controllers should be thin. Complex logic belongs in service objects or models.
- Controllers must call `authorize` and typically use `after_action :verify_authorized`.
- Use `policy_scope` for index actions to scope records to the current org/user.

### Models

- Models use `include ByOrganizationScope` for org-scoped queries where applicable.
- Prefer scopes over class methods for query logic.
- Soft deletes via the Paranoia gem: `destroy` marks records deleted, does not hard-delete.
- Use Strong Migrations: flag any unsafe migration operations (e.g., removing a column without `safety_assured`, adding an index without `algorithm: :concurrently`).

### Views & Frontend

- Use ERB (not HAML). Complex view logic should live in a Draper decorator (`app/decorators/`), not in the template.
- Use ViewComponent (`app/components/`) for reusable UI elements.
- Style with Bootstrap 5 utility classes and existing project SCSS. UI changes should match the rest of the site.
- JavaScript should use Stimulus controllers. Avoid inline `<script>` tags or jQuery for new code.
- Email views require inline CSS (email client compatibility — see ADR 0007).

### Services & Decorators

- Service objects live in `app/services/` and follow the pattern: `ServiceName.new(args).perform`.
- Decorators live in `app/decorators/` and handle presentation logic that doesn't belong in models or views.

## Review Checklist

### Security

- [ ] No mass-assignment vulnerabilities: strong parameters used for all user input.
- [ ] No raw SQL interpolation — use parameterized queries or ActiveRecord methods.
- [ ] No `html_safe` or `raw` on user-supplied content (XSS risk).
- [ ] Pundit authorization is present on all controller actions.
- [ ] Data is scoped to the user's organization — no cross-tenant leaks.
- [ ] File uploads validated (type, size) before storage.
- [ ] Secrets and credentials are not committed.

### Testing

- [ ] New features have tests. Bug fixes include a test that would fail without the fix.
- [ ] System tests (Capybara) are preferred for UI changes over controller tests (see ADR 0006).
- [ ] Factories use traits for scenario variations (e.g., `create(:casa_case, :active)`).
- [ ] Tests cover edge cases: nil/empty values, missing optional fields, special characters.
- [ ] No `sleep` calls in tests — use Capybara's built-in waiting/retry mechanisms.
- [ ] Flaky tests are disabled with a tracking issue, not deleted.

### Code Quality

- [ ] Follows Standard.rb style (Ruby) and StandardJS style (JavaScript).
- [ ] No N+1 queries introduced — use `includes`, `preload`, or `eager_load` as needed.
- [ ] ActiveRecord collections iterated with `find_each` instead of `each` for large sets.
- [ ] Multi-record writes wrapped in `ActiveRecord::Base.transaction`.
- [ ] No business logic in controllers or views — delegate to models, services, or decorators.
- [ ] Dead code and unused variables removed.

### Pull Request Quality

- [ ] PR references a GitHub issue (`Resolves #XXXX`).
- [ ] Small, focused diff. Multiple small PRs preferred over one large PR.
- [ ] Migrations are reversible and safe (no data loss, follows Strong Migrations).
- [ ] No unrelated formatting changes that inflate the diff.

## What to Flag

- **Authorization gaps**: Any controller action missing `authorize` or `policy_scope`.
- **Cross-org data access**: Queries that don't scope to `casa_org`.
- **Missing tests**: New behavior without corresponding test coverage.
- **N+1 queries**: Loading associations inside loops without eager loading.
- **Unsafe migrations**: Column removals, type changes, or index additions without safety guards.
- **XSS vectors**: `html_safe`, `raw`, or `sanitize` misuse on user content.
- **Large PRs**: Suggest splitting if the diff touches many unrelated areas.

## What NOT to Flag

- Older migration files (2020–2024) — these are excluded from linting intentionally.
- Minor style issues already handled by Standard.rb or StandardJS linters.
- Lack of TypeScript — this project uses plain JavaScript with Stimulus.
- jQuery usage in existing code — new code should use Stimulus, but don't flag legacy jQuery.

## Tone

This is a volunteer-driven open-source project. Contributors range from first-time open source contributors to experienced Rails developers. Be encouraging, explain the "why" behind suggestions, and link to relevant docs or examples in the codebase when possible. Avoid nitpicks on subjective style — trust the linters for formatting.
