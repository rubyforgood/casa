require "rails_helper"

RSpec.describe "case_contacts/new", type: :view do
  subject { render template: "case_contacts/new" }
  let(:casa_org) { CasaOrg.first }
  let(:current_time) { Time.zone.now.strftime("%Y-%m-%d") }

  before do
    case_contact = build_stubbed(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]
    assign :contact_types, []
    assign :current_organization_groups, []

    allow(view).to receive(:current_organization).and_return(casa_org)
    allow(view).to receive(:current_role).and_return(role)
  end

  context "while signed-in as a volunteer" do
    let(:role) { "Volunteer" }

    before do
      sign_in_as_volunteer
    end

    it { is_expected.to have_field("c. Date of contact", with: current_time) }
    it { is_expected.to have_selector("textarea", id: "case_contact_notes") }
  end

  context "while signed-in as an admin" do
    let(:role) { "Casa Admin" }

    before do
      sign_in_as_admin
    end

    context "when the case has no volunteers" do
      it { is_expected.to have_field("c. Date of contact", with: current_time) }
      it { is_expected.to have_selector("textarea", id: "case_contact_notes") }
    end
  end
end
