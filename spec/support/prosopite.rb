# frozen_string_literal: true

return unless defined?(Prosopite)

# Test configuration — this file owns all Prosopite settings for the test env
Prosopite.enabled = true
Prosopite.raise = true
Prosopite.rails_logger = true
Prosopite.prosopite_logger = true

# Allowlist for known acceptable N+1 patterns (e.g., test matchers)
Prosopite.allow_stack_paths = [
  "shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb",
  "shoulda/matchers/active_model/validate_presence_of_matcher.rb",
  "shoulda/matchers/active_model/validate_inclusion_of_matcher.rb",
  "shoulda/matchers/active_model/allow_value_matcher.rb"
]

# Load ignore list from file for gradual rollout — directories listed in
# .prosopite_ignore are scanned but won't raise, only log.
PROSOPITE_IGNORE = if File.exist?("spec/.prosopite_ignore")
  File.read("spec/.prosopite_ignore")
    .lines
    .map(&:chomp)
    .reject { |line| line.empty? || line.start_with?("#") }
else
  []
end

RSpec.configure do |config|
  # Pause Prosopite during factory creation to prevent false positives
  # from factory callbacks and associations
  config.before(:suite) do
    if defined?(FactoryBot)
      FactoryBot::SyntaxRunner.class_eval do
        alias_method :original_create, :create

        def create(*args, **kwargs, &block)
          if defined?(Prosopite) && Prosopite.enabled?
            Prosopite.pause { original_create(*args, **kwargs, &block) }
          else
            original_create(*args, **kwargs, &block)
          end
        end
      end
    end
  end

  config.around do |example|
    if use_prosopite?(example)
      Prosopite.scan { example.run }
    else
      original_enabled = Prosopite.enabled?
      Prosopite.enabled = false
      begin
        example.run
      ensure
        Prosopite.enabled = original_enabled
      end
    end
  end
end

def use_prosopite?(example)
  # Explicit metadata takes precedence
  return false if example.metadata[:disable_prosopite]
  return true if example.metadata[:enable_prosopite]

  # Check against ignore list
  PROSOPITE_IGNORE.none? do |path|
    File.fnmatch?("./#{path}/*", example.metadata[:rerun_file_path].to_s)
  end
end
