def upload_file(file)
  content = File.read(file)
  tempfile = Tempfile.open
  tempfile.write content
  tempfile.rewind

  Rack::Test::UploadedFile.new(tempfile)
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Any factory that takes more than .5 seconds to create will show in the
  # console when running the tests.
  config.before(:suite) do
    ActiveSupport::Notifications.subscribe("factory_bot.run_factory") do |name, start, finish, id, payload|
      execution_time_in_seconds = finish - start

      if execution_time_in_seconds >= 0.5
        warn "Slow factory: #{payload[:name]} takes #{execution_time_in_seconds} seconds using strategy #{payload[:strategy]}"
      end
    end
  end

  # This will output records as they are created. Handy for debugging but very
  # noisy.
  # config.before(:each) do
  #   ActiveSupport::Notifications.subscribe("factory_bot.run_factory") do |name, start, finish, id, payload|
  #     $stderr.puts "FactoryBot: #{payload[:strategy]}(:#{payload[:name]})"
  #   end
  # end

  # This will output total database records being created. Commented out to
  # keep the spec output clean.

  factory_bot_results = {}
  config.before(:suite) do
    ActiveSupport::Notifications.subscribe("factory_bot.run_factory") do |name, start, finish, id, payload|
      factory_name = payload[:name]
      strategy_name = payload[:strategy]
      factory_bot_results[factory_name] ||= {}
      factory_bot_results[factory_name][:total] ||= 0
      factory_bot_results[factory_name][:total] += 1
      factory_bot_results[factory_name][strategy_name] ||= 0
      factory_bot_results[factory_name][strategy_name] += 1
    end
  end

  config.after(:suite) do
    if ENV.fetch("SPEC_OUTPUT_FACTORY_BOT_OBJECT_CREATION_STATS", "false") == "true"
      puts "How many objects did factory_bot create? (probably too many- let's tune some factories...)"
      pp factory_bot_results
    end
  end
end
