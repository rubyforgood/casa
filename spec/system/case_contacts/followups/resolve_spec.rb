require "rails_helper"

RSpec.describe "followups/resolve", type: :system do
  let(:admin) { create(:casa_admin) }
  let(:case_contact) { create(:case_contact) }
  let!(:followup) { create(:followup, case_contact: case_contact) }

  it "changes status of followup to resolved" do
    sign_in admin
    visit casa_case_path(case_contact.casa_case)

    click_button "Resolve"

    expect(case_contact.followups.count).to eq(1)
    expect(case_contact.followups.first.resolved?).to be_truthy
  end
end
