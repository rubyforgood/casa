require "rails_helper"

RSpec.describe BannerParameters do
  subject { described_class.new(params, user, timezone) }

  let(:params) {
    ActionController::Parameters.new(
      banner: ActionController::Parameters.new(
        active: "1",
        content: "content",
        name: "name"
      )
    )
  }

  let(:user) { create(:user) }

  let(:timezone) { nil }

  it "returns data" do
    expect(subject["active"]).to eq("1")
    expect(subject["content"]).to eq("content")
    expect(subject["name"]).to eq("name")
    expect(subject["expires_at"]).to be_blank
    expect(subject["user"]).to eq(user)
  end

  context "when expires_at is set" do
    let(:params) {
      ActionController::Parameters.new(
        banner: ActionController::Parameters.new(
          expires_at: "2024-06-10T12:12"
        )
      )
    }

    let(:timezone) { "America/Los_Angeles" }

    it "attaches timezone information to expires_at" do
      expect(subject["expires_at"]).to eq("2024-06-10 12:12:00 -0700")
    end
  end
end
