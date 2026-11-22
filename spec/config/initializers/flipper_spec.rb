require "rails_helper"

# Covers the performance fix for https://github.com/rubyforgood/casa/issues/7397:
# every `Flipper.enabled?` used to hit the DB. Now the adapter is wrapped in a
# short-lived Rails.cache cache and the Memoizer middleware caps each flag at
# one adapter load per request.
#
# The test env normally swaps Flipper's default adapter for an in-memory one
# (flipper/test_help), so these examples re-run the real initializer.
RSpec.describe "Flipper configuration" do
  around do |example|
    with_real_flipper_adapter { example.run }
  end

  describe "adapter (config/initializers/flipper.rb)" do
    it "wraps the Active Record adapter in an ActiveSupportCacheStore backed by Rails.cache with a 1 minute TTL" do
      cache_adapter = flipper_adapter_chain.find { |a| a.is_a?(Flipper::Adapters::ActiveSupportCacheStore) }

      expect(cache_adapter).to be_present
      expect(cache_adapter.adapter).to be_a(Flipper::Adapters::ActiveRecord)
      expect(cache_adapter.cache).to eq(Rails.cache)
      expect(cache_adapter.ttl).to eq(1.minute)
    end
  end

  describe "Flipper::Middleware::Memoizer (added by flipper's engine, pinned in config/initializers/flipper.rb)" do
    def call_with_flag_checks(checks)
      app = lambda do |_env|
        checks.times { Flipper.enabled?(:flipper_spec_flag) }
        [200, {"Content-Type" => "text/plain"}, ["OK"]]
      end
      Flipper::Middleware::Memoizer.new(app).call({})
    end

    it "is in the app middleware stack, so it also wraps the Active Storage routes" do
      expect(Rails.application.middleware).to include(Flipper::Middleware::Memoizer)
    end

    it "loads each flag at most once per request no matter how many times it is checked" do
      Flipper.enable(:flipper_spec_flag)

      queries_for_one_check = count_flipper_queries { call_with_flag_checks(1) }
      queries_for_many_checks = count_flipper_queries { call_with_flag_checks(10) }

      expect(queries_for_one_check).to be_positive
      expect(queries_for_many_checks).to eq(queries_for_one_check)
    ensure
      Flipper.disable(:flipper_spec_flag)
    end
  end
end
