---
applyTo: "**/*.rb"
---

# Ruby / Rails Review Instructions

## Authorization (Pundit)

Every controller action that reads or writes data must be authorized.

```ruby
# Required pattern
def index
  authorize Model
  @records = policy_scope(current_organization.models)
end

def show
  authorize @record
end
```

- Controllers must include `after_action :verify_authorized` (with exceptions listed in `except:`).
- Index actions must use `policy_scope` to scope records to the current organization.
- Custom policy methods are called with `authorize @record, :custom_action?`.
- Policy files live in `app/policies/`. Permission changes must update the corresponding policy.
- Policies define `permitted_attributes` that return role-based field lists — check that new fields are added there when models gain attributes.

Flag: any controller action missing `authorize` or `policy_scope`.

## Multi-Tenancy

All data access must be scoped to the user's `casa_org`.

- Models include `ByOrganizationScope` which provides `.by_organization(casa_org)`.
- Policy scopes must filter by organization: `scope.by_organization(user.casa_org)`.
- `current_organization` (from the `Organizational` concern) returns the signed-in user's org.

Flag: queries that could return records from another organization.

## Controllers

- Keep controllers thin. Business logic belongs in models or service objects (`app/services/`).
- Complex view logic belongs in Draper decorators (`app/decorators/`), not controllers or ERB.
- Use parameter objects (`app/values/`) for strong params when the logic is non-trivial. They follow a builder pattern: `FooParameters.new(params).with_password(pw).without_active`.
- Standard flash pattern:
  ```ruby
  if @record.save
    redirect_to path, notice: "Record created successfully."
  else
    render :new, status: :unprocessable_content
  end
  ```
- Use `respond_to` blocks when supporting multiple formats (HTML, JSON, CSV).
- Set up models with `before_action :set_model` and list exceptions in `except:`.

## Models

- Prefer scopes over class methods for query logic.
- Scope naming: descriptive, chainable (`.active`, `.by_organization`, `.with_assigned_cases`).
- Use `find_each` (not `each`) when iterating over ActiveRecord collections.
- Wrap multi-record writes in `ActiveRecord::Base.transaction`.
- Enums use the prefix syntax: `enum :status, {active: 0, inactive: 1}, prefix: :status`.
- Soft deletes via Paranoia — `destroy` marks as deleted, does not hard-delete.
- Extract complex validations into concern modules (e.g., `CasaCase::Validations`).
- Associations with conditions use lambdas:
  ```ruby
  has_many :active_assignments, -> { active }, class_name: "CaseAssignment"
  ```
- `accepts_nested_attributes_for` with `reject_if` guards for blank entries.

## Services

Service objects follow a consistent pattern:

```ruby
class MyService
  def initialize(args)
    @args = args
  end

  def perform
    # single responsibility logic
  end
end
```

Called as `MyService.new(args).perform`. Services should preload associations to avoid N+1 queries.

## Decorators

- Draper decorators in `app/decorators/` handle presentation logic.
- Access view helpers via `h.helper_method` inside decorators.
- Called via `.decorate` on model instances or collections.

Flag: presentation logic (formatting dates, conditional display text) in models or controllers.

## Concerns

- Use `extend ActiveSupport::Concern` for shared behavior.
- `included do ... end` block for validations, scopes, callbacks.
- Place model concerns in `app/models/concerns/`, controller concerns in `app/controllers/concerns/`.

## Migrations

- Must be reversible.
- Use Strong Migrations: flag unsafe operations (removing columns without `safety_assured`, adding indexes without `algorithm: :concurrently` on large tables, changing column types).
- New columns with NOT NULL constraints need a default value or a multi-step migration.

## Common Anti-Patterns to Flag

- **N+1 queries**: Loading associations inside loops without `includes`, `preload`, or `eager_load`.
- **Cross-org data leaks**: Queries missing organization scope.
- **Business logic in views**: ERB files with complex conditionals or calculations — should be in a decorator.
- **Fat controllers**: More than a few lines of logic — extract to a service or model method.
- **Raw SQL interpolation**: Use parameterized queries or ActiveRecord methods.
- **`html_safe` / `raw` on user input**: XSS risk.
- **Missing authorization**: Controller actions without `authorize`.
- **`.each` on AR collections**: Use `find_each` for batch processing.
- **Unscoped `destroy`**: Verify soft-delete behavior is intended; Paranoia intercepts `destroy`.

## Testing (RSpec)

- System tests (Capybara) are preferred for UI flows over controller tests.
- Model tests use shoulda-matchers for associations and validations:
  ```ruby
  it { is_expected.to have_many(:case_assignments).dependent(:destroy) }
  it { is_expected.to validate_uniqueness_of(:case_number).scoped_to(:casa_org_id) }
  ```
- Use `build` for unit tests, `create` only when persistence is needed.
- Use `let` for lazy evaluation, `let!` when the record must exist before the test runs.
- Factory traits for scenario variations: `create(:casa_case, :active)`.
- Context blocks describe the scenario: `context "when the user is a supervisor"`.
- Test edge cases: nil values, empty strings, special characters, missing optional fields.
- No `sleep` in tests — use Capybara's built-in waiting.
- Flaky tests are disabled with a tracking issue (`xit` + comment), never deleted.

## Style

This project uses Standard.rb (not vanilla RuboCop). Do not flag style issues that Standard.rb handles automatically (spacing, string quotes, trailing commas). Focus review on logic, security, and architecture.
