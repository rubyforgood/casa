require "rails_helper"

RSpec.describe Quarantine do
  it "fails on the first time" do
    raise "error" if RSpec.current_example.attempts == 0 && ENV["CI"]
  end
end
