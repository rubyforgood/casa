# Flipper's engine swaps the default adapter for an in-memory one in the test
# env (flipper/test_help). These helpers let a spec run against the real
# production stack from config/initializers/flipper.rb (ActiveSupportCacheStore
# wrapping the Active Record adapter) and count the SQL queries it issues.
module FlipperRealAdapter
  # Re-runs config/initializers/flipper.rb against a fresh configuration so the
  # default Flipper instance uses the real Active Record + cache adapter stack
  # (the test env normally swaps in an in-memory adapter via flipper/test_help),
  # then restores the previous configuration afterwards.
  def with_real_flipper_adapter
    previous_configuration = Flipper.configuration
    Flipper.configuration = Flipper::Configuration.new
    load Rails.root.join("config/initializers/flipper.rb")
    Flipper.instance = nil
    yield
  ensure
    Flipper.configuration = previous_configuration
    Flipper.instance = nil
  end

  # The wrapped adapter chain of the default Flipper instance, outermost first.
  def flipper_adapter_chain
    chain = []
    adapter = Flipper.adapter
    while adapter && !chain.include?(adapter)
      chain << adapter
      adapter = adapter.adapter if adapter.respond_to?(:adapter)
    end
    chain
  end

  # Counts SQL queries against the flipper_features / flipper_gates tables.
  def count_flipper_queries
    count = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      count += 1 if payload[:name] != "SCHEMA" && payload[:sql].match?(/flipper_(features|gates)/)
    end
    yield
    count
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end

RSpec.configure do |config|
  config.include FlipperRealAdapter
end
