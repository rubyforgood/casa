require "rails_helper"

RSpec.describe VolunteerParameters do
  subject { described_class.new(params) }

  let(:params) {
    ActionController::Parameters.new(
      volunteer: ActionController::Parameters.new(
        email: "volunteer@example.com",
        display_name: "Volunteer",
        phone_number: "1(401) 827-9485",
        date_of_birth: "",
        receive_reimbursement_email: "0"
      )
    )
  }

  it "returns data" do
    expect(subject["email"]).to eq("volunteer@example.com")
    expect(subject["display_name"]).to eq("Volunteer")
    expect(subject["phone_number"]).to eq("14018279485")
  end
end
