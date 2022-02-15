require "rails_helper"

RSpec.describe "case_contacts/new", type: :view do
  subject { render template: "case_contacts/new" }

  before do
    case_contact = build_stubbed(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]
    assign :contact_types, []
    assign :current_organization_groups, []
  end

  context "while signed-in as a volunteer" do
    let(:casa_org) { CasaOrg.first }

    before do
      sign_in_as_volunteer
      allow(view).to receive(:current_organization).and_return(casa_org)
    end

    let(:current_time) { Time.zone.now.strftime("%Y-%m-%d") }

    it { is_expected.to have_field("c. Occurred On", with: current_time) }
    it { is_expected.to have_selector("textarea", id: "case_contact_notes") }
  end
end
