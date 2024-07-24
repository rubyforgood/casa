RSpec.configure do |config|
  config.before(:each, :flipper) do
    allow(Flipper).to receive(:enabled?)
  end
end
