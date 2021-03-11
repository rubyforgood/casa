require "rails_helper"

RSpec.describe "case_contacts/case_contact", type: :view do
  let(:user) { build_stubbed(:casa_admin) }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
  end

  context "occured_at is before the last day of the month in the quarter that the case contact was created" do
    let(:case_contact) { create(:case_contact) }

    it "shows edit button" do
      assign :case_contact, case_contact
      assign :casa_cases, [case_contact.casa_case]

      render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
      expect(rendered).to have_link(nil, href: "/case_contacts/#{case_contact.id}/edit")
    end

    it "shows follow up button" do
      assign :case_contact, case_contact
      assign :casa_cases, [case_contact.casa_case]

      render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
      expect(rendered).to have_button("Follow up")
    end
  end

  context "occured_at is after the last day of the month in the quarter that the case contact was created" do
    let(:case_contact) { create(:case_contact, occurred_at: Time.zone.now - 1.year) }

    it "does not show edit button" do
      assign :case_contact, case_contact
      assign :casa_cases, [case_contact.casa_case]

      render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
      expect(rendered).to have_no_link(nil, href: "/case_contacts/#{case_contact.id}/edit")
    end

    it "does not show follow up button" do
      assign :case_contact, case_contact
      assign :casa_cases, [case_contact.casa_case]

      render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
      expect(rendered).to_not have_text("Follow up")
    end
  end
end
