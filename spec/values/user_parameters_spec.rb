require "rails_helper"

RSpec.describe UserParameters do
  subject { described_class.new(params) }

  let(:params) {
    ActionController::Parameters.new(
      user: ActionController::Parameters.new(
        email: "user@example.com",
        casa_org_id: 1,
        display_name: "User Name",
        phone_number: "1234567890",
        date_of_birth: "2000-01-01",
        password: "password123",
        active: "1",
        receive_reimbursement_email: "1",
        type: "Volunteer",
        monthly_learning_hours_report: "1",
        address_attributes: {id: 1, content: "123 Main St"}
      )
    )
  }

  it "permits the allowed user attributes" do
    aggregate_failures do
      expect(subject["email"]).to eq("user@example.com")
      expect(subject["casa_org_id"]).to eq(1)
      expect(subject["display_name"]).to eq("User Name")
      expect(subject["phone_number"]).to eq("1234567890")
      expect(subject["date_of_birth"]).to eq("2000-01-01")
      expect(subject["password"]).to eq("password123")
      expect(subject["active"]).to eq("1")
      expect(subject["receive_reimbursement_email"]).to eq("1")
      expect(subject["type"]).to eq("Volunteer")
      expect(subject["monthly_learning_hours_report"]).to eq("1")
      expect(subject["address_attributes"].to_h).to eq("id" => 1, "content" => "123 Main St")
    end
  end

  it "filters out attributes that are not permitted" do
    params[:user][:admin] = true
    expect(subject["admin"]).to be_nil
  end

  it "raises when the user key is missing" do
    expect {
      described_class.new(ActionController::Parameters.new(other: {}))
    }.to raise_error(ActionController::ParameterMissing)
  end

  describe "#with_organization" do
    let(:organization) { build_stubbed(:casa_org) }

    it "sets casa_org_id to the organization's id and returns self" do
      result = subject.with_organization(organization)

      expect(result).to equal(subject)
      expect(subject["casa_org_id"]).to eq(organization.id)
    end
  end

  describe "#with_password" do
    it "sets the password and returns self" do
      result = subject.with_password("new-password")

      expect(result).to equal(subject)
      expect(subject["password"]).to eq("new-password")
    end
  end

  describe "#with_type" do
    it "sets the type and returns self" do
      result = subject.with_type("Supervisor")

      expect(result).to equal(subject)
      expect(subject["type"]).to eq("Supervisor")
    end
  end

  describe "#without_type" do
    it "removes the type key and returns self" do
      result = subject.without_type

      expect(result).to equal(subject)
      expect(subject.key?("type")).to be false
    end
  end

  describe "#without_active" do
    it "removes the active key and returns self" do
      result = subject.without_active

      expect(result).to equal(subject)
      expect(subject.key?("active")).to be false
    end
  end

  describe "#with_only" do
    it "slices params down to only the given keys and returns self" do
      result = subject.with_only(:email, :type)

      expect(result).to equal(subject)
      expect(subject.keys).to contain_exactly("email", "type")
    end
  end

  describe "#without" do
    it "removes the key when given a symbol" do
      subject.without(:active)

      expect(subject["active"]).to be_nil
    end

    it "removes the key when given a string" do
      subject.without("active")

      expect(subject["active"]).to be_nil
    end

    it "returns self so it can be chained" do
      result = subject.without(:active)

      expect(result).to equal(subject)
    end
  end
end
