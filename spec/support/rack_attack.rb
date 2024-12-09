RSpec.configure do |config|
  config.before do
    Rack::Attack.enabled = false
  end
end
