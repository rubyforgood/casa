require "rails_helper"

RSpec.describe SupervisorParameters do
  subject { described_class.new(params) }

  let(:params) {
    ActionController::Parameters.new(
      supervisor: ActionController::Parameters.new(
        email: "supervisor@example.com",
        display_name: "Supervisor Name"
      )
    )
  }

  it "wraps params under the supervisor root key" do
    expect(subject["email"]).to eq("supervisor@example.com")
    expect(subject["display_name"]).to eq("Supervisor Name")
  end

  it "raises when the supervisor key is missing" do
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
