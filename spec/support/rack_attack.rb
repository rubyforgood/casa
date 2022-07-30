RSpec.configure do |config|
  config.before(:each) do
    Rack::Attack.enabled = false
  end
end
