
RSpec.configure do |config|
  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end

RSpec::Matchers.define :exceed_query_limit do |expected|
  supports_block_expectations
  queries = 0

  match do |block|
    raise ArgumentError, "A block must be provided to the exceed_query_limit matcher" if block.nil?

    ActiveSupport::Notifications.subscribe("sql.active_record") { |_| queries += 1 }

    block.call
    queries > expected
  end

  failure_message_when_negated { |_| "Expected #{expected} queries, got #{queries}" }
end