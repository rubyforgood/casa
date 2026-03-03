# frozen_string_literal: true

return unless defined?(Prosopite)

# Test configuration
Prosopite.enabled = true
Prosopite.raise = false  # Log only, don't fail specs
Prosopite.rails_logger = true
Prosopite.prosopite_logger = true

# Allowlist for known acceptable N+1 patterns (e.g., test matchers)
Prosopite.allow_stack_paths = [
  "shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb",
  "shoulda/matchers/active_model/validate_presence_of_matcher.rb",
  "shoulda/matchers/active_model/validate_inclusion_of_matcher.rb",
  "shoulda/matchers/active_model/allow_value_matcher.rb"
]

# Optional: Load ignore list from file for gradual rollout
PROSOPITE_IGNORE = if File.exist?("spec/.prosopite_ignore")
  File.read("spec/.prosopite_ignore").lines.map(&:chomp).reject(&:empty?)
else
  []
end

# Monkey-patch FactoryBot to pause during factory creation
# Prevents false positives from factory callbacks
if defined?(FactoryBot)
  module FactoryBot
    module Strategy
      class Create
        alias_method :original_result, :result

        def result(evaluation)
          if defined?(Prosopite) && Prosopite.enabled?
            Prosopite.pause { original_result(evaluation) }
          else
            original_result(evaluation)
          end
        end
      end
    end
  end
end

# RSpec integration
RSpec.configure do |config|
  config.around do |example|
    if use_prosopite?(example)
      Prosopite.scan { example.run }
    else
      original_enabled = Prosopite.enabled?
      Prosopite.enabled = false
      example.run
      Prosopite.enabled = original_enabled
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
