require "rails_helper"

RSpec.describe "Scout APM config" do
  let(:context) { ScoutApm::Agent.instance.context }
  let(:config) do
    ScoutApm::Config.with_file(context, Rails.root.join("config/scout_apm.yml").to_s, environment: "production")
  end
  let(:ignored_exceptions) do
    ScoutApm::ErrorService::IgnoredExceptions.new(context, config.value("errors_ignored_exceptions"))
  end

  it "does not report invalid MIME types from junk Accept or Content-Type headers" do
    exception = ActionDispatch::Http::MimeNegotiation::InvalidType.new("not a valid MIME type")

    expect(ignored_exceptions.ignored?(exception)).to be true
  end

  it "keeps ignoring Scout's default exceptions" do
    expect(ignored_exceptions.ignored?(ActiveRecord::RecordNotFound.new)).to be true
    expect(ignored_exceptions.ignored?(ActionController::RoutingError.new("not found"))).to be true
  end

  it "still reports other errors" do
    expect(ignored_exceptions.ignored?(StandardError.new)).to be false
  end
end
