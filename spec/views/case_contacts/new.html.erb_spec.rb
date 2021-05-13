require "rails_helper"

RSpec.describe "case_contacts/new", :disable_bullet, type: :view do
  subject { render template: "case_contacts/new" }

  before do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]
    assign :contact_types, []
    assign :current_organization_groups, []
  end

  context "while signed-in as a volunteer" do
    before do
      sign_in_as_volunteer
    end

    let(:current_time) { Time.zone.now.strftime("%Y-%m-%d") }

    it { is_expected.to have_field("Occurred at", with: current_time) }
    it { is_expected.to have_selector("textarea", id: "case_contact_notes") }
    it { is_expected.to have_selector("a", text: "Return to Dashboard") }
  end
end
