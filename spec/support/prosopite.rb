# frozen_string_literal: true

return unless defined?(Prosopite)

# Test configuration — this file owns all Prosopite settings for the test env
Prosopite.enabled = true
# Raising is opted into per example via Prosopite.start_raise (see the around
# hook below) so that the directories listed in .prosopite_ignore can still be
# scanned and logged without failing the build.
Prosopite.raise = false
Prosopite.rails_logger = true
Prosopite.prosopite_logger = true

# Allowlist for known acceptable N+1 patterns (e.g., test matchers)
Prosopite.allow_stack_paths = [
  "shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb",
  "shoulda/matchers/active_model/validate_presence_of_matcher.rb",
  "shoulda/matchers/active_model/validate_inclusion_of_matcher.rb",
  "shoulda/matchers/active_model/allow_value_matcher.rb",

  # Per-record validations and has_one initialisers. These run exactly one query per record
  # saved, by design -- eager loading cannot remove them, so any loop that saves N records will
  # always look like an N+1. Matched on method name rather than line number so they survive
  # edits to the surrounding file.
  "UserValidator#validate_uniqueness",
  "User#create_preference_set",
  "Api#initialize_api_credentials",

  # Operations that write one record at a time on purpose. Each iteration runs its own INSERT plus
  # the belongs_to presence checks for that row, so they read as an N+1 no matter how much is
  # preloaded -- there is no set of records to eager load. Listed here rather than wrapped in
  # Prosopite.pause so that test tooling stays out of the application code. Remove an entry if the
  # loop is ever reworked into a bulk insert.
  "app/lib/importers/",                                          # CSV import, row by row
  "generate_for_org!",                                           # default contact types/topics/hearing types on org creation
  "app/models/supervisor_volunteer.rb",                          # same-org validation, per assignment saved
  "SupervisorVolunteersController#assign_volunteer_to_supervisor",
  "SupervisorVolunteersController#unassign_volunteers_supervisor",
  "CaseContacts::FormController#create_additional_case_contacts", # one copied contact per selected case
  "BulkCourtDatesController#create_court_dates",                  # one court date per case in the group
  "config/initializers/sent_email_event.rb"                       # fires once per delivered email
]

# Load ignore list from file for gradual rollout — examples under a directory
# listed in .prosopite_ignore are still scanned, and any N+1 is written to
# log/prosopite.log, but they do not fail the build. Remove a directory from
# that file to start enforcing it.
PROSOPITE_IGNORE = if File.exist?("spec/.prosopite_ignore")
  File.read("spec/.prosopite_ignore")
    .lines
    .map(&:chomp)
    .reject { |line| line.empty? || line.start_with?("#") }
else
  []
end

# Prosopite reports every repeated query in an example, including ones the spec itself causes by
# looping over records to build an expectation. Those are not application N+1s, so enforcement
# only fails an example when the N+1 is attributable to app/ or lib/. Rails' backtrace cleaner
# silences everything else (spec/ included), so a report with no app frame came from test code.
class ProsopiteAppOnlyReporter
  APP_FRAME = %r{^\s+(app|lib)/}

  def initialize
    @reports = []
  end

  def warn(report)
    @reports << report
  end

  def app_n_plus_one?
    @reports.any? { |report| report.match?(APP_FRAME) }
  end

  def message
    @reports.join("\n")
  end
end

RSpec.configure do |config|
  # Pause Prosopite during factory creation to prevent false positives from
  # per-record validations and callbacks (uniqueness checks, has_one
  # initialisers) firing once per created record.
  #
  # This patches FactoryBot::Syntax::Methods, which is the module RSpec includes
  # into example groups, so it covers `create` called from specs, `let` blocks
  # and factory callbacks alike. Patching FactoryBot::SyntaxRunner instead has
  # no effect on specs, which never go through that class.
  #
  # create_list/create_pair delegate to create, and Prosopite.pause restores the
  # previous scan state on exit, so the nesting is safe.
  config.before(:suite) do
    if defined?(FactoryBot)
      FactoryBot::Syntax::Methods.module_eval do
        alias_method :create_without_prosopite_pause, :create

        def create(...)
          if defined?(Prosopite) && Prosopite.enabled?
            Prosopite.pause { create_without_prosopite_pause(...) }
          else
            create_without_prosopite_pause(...)
          end
        end
      end
    end
  end

  config.around do |example|
    case prosopite_mode(example)
    when :off
      original_enabled = Prosopite.enabled?
      Prosopite.enabled = false
      begin
        example.run
      ensure
        Prosopite.enabled = original_enabled
      end
    when :log_only
      Prosopite.scan { example.run }
    else
      reporter = ProsopiteAppOnlyReporter.new
      Prosopite.custom_logger = reporter
      begin
        Prosopite.scan { example.run }
      ensure
        Prosopite.custom_logger = false
      end

      raise Prosopite::NPlusOneQueriesError, reporter.message if reporter.app_n_plus_one?
    end
  end
end

# :off      - not scanned at all, so nothing is detected or logged
# :log_only - scanned and any N+1 is logged, but the example still passes
# :enforce  - scanned, and an N+1 attributable to app/ or lib/ fails the example
def prosopite_mode(example)
  # Explicit metadata takes precedence
  return :off if example.metadata[:disable_prosopite]
  return :enforce if example.metadata[:enable_prosopite]

  prosopite_ignored?(example) ? :log_only : :enforce
end

def prosopite_ignored?(example)
  PROSOPITE_IGNORE.any? do |path|
    File.fnmatch?("./#{path}/*", example.metadata[:rerun_file_path].to_s)
  end
end
