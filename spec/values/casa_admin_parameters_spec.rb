require "rails_helper"

RSpec.describe CasaAdminParameters do
  subject { described_class.new(params) }

  let(:params) {
    ActionController::Parameters.new(
      casa_admin: ActionController::Parameters.new(
        email: "admin@example.com",
        display_name: "Admin Name"
      )
    )
  }

  it "wraps params under the casa_admin root key" do
    expect(subject["email"]).to eq("admin@example.com")
    expect(subject["display_name"]).to eq("Admin Name")
  end

  it "raises when the casa_admin key is missing" do
    expect {
      described_class.new(ActionController::Parameters.new(user: {}))
    }.to raise_error(ActionController::ParameterMissing)
  end

  it "inherits builder methods from UserParameters" do
    result = subject.with_password("new-password")

    expect(result).to equal(subject)
    expect(subject["password"]).to eq("new-password")
  end
end
