require "rails_helper"

RSpec.describe AllCasaAdminParameters do
  subject { described_class.new(params) }

  let(:params) {
    ActionController::Parameters.new(
      all_casa_admin: ActionController::Parameters.new(
        email: "all_admin@example.com",
        password: "password123"
      )
    )
  }

  it "permits the allowed attributes" do
    expect(subject["email"]).to eq("all_admin@example.com")
    expect(subject["password"]).to eq("password123")
  end

  it "filters out attributes that are not permitted" do
    params[:all_casa_admin][:admin] = true
    expect(subject["admin"]).to be_nil
  end

  it "raises when the all_casa_admin key is missing" do
    expect {
      described_class.new(ActionController::Parameters.new(user: {}))
    }.to raise_error(ActionController::ParameterMissing)
  end

  describe "#with_password" do
    it "sets the password and returns self" do
      result = subject.with_password("new-password")

      expect(result).to equal(subject)
      expect(subject["password"]).to eq("new-password")
    end
  end
end
