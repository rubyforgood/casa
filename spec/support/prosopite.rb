# frozen_string_literal: true

Prosopite.enabled = true
Prosopite.raise = true # Fail specs on N+1 detection
Prosopite.rails_logger = true
Prosopite.prosopite_logger = true
Prosopite.allow_stack_paths = [
  "shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb",
  "shoulda/matchers/active_model/validate_presence_of_matcher.rb",
  "shoulda/matchers/active_model/validate_inclusion_of_matcher.rb",
]

PROSOPITE_PATHS = [
  "./spec/models/*"
].freeze

# Monkey-patch FactoryBot to pause Prosopite during factory creation
# This prevents N+1 detection in factory callbacks, focusing on actual test code
module FactoryBot
  module Strategy
    class Create
      alias_method :original_result, :result

      def result(evaluation)
        if defined?(Prosopite) && Prosopite.enabled?
          Prosopite.pause do
            original_result(evaluation)
          end
        else
          original_result(evaluation)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.around do |example|
    should_enable = PROSOPITE_PATHS.any? { |pattern|
      File.fnmatch?(pattern, example.metadata[:rerun_file_path]
      )
    }

    if should_enable && !example.metadata[:disable_prosopite]
      Prosopite.scan do
        example.run
      end
    else
      # Disable prosopite globally for this test (works across threads)
      original_enabled = Prosopite.enabled?
      Prosopite.enabled = false
      example.run
      Prosopite.enabled = original_enabled
    end
  end
end
