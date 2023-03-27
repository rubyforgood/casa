require "rails_helper"

RSpec.describe "/error", type: :request do
  it "raises an error causing an internal server error" do
    expect {
      get error_path
    }.to raise_error(StandardError, /This is an intentional test exception/)
  end
end
