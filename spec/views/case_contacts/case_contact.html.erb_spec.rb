require "rails_helper"

RSpec.describe "case_contacts/case_contact", :disable_bullet, type: :view do
  let(:admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  describe "edit and follow up buttons" do
    before do
      enable_pundit(view, admin)
      allow(view).to receive(:current_user).and_return(admin)
    end

    context "occurred_at is before the last day of the month in the quarter that the case contact was created" do
      let(:case_contact) { create(:case_contact) }
      let(:case_contact2) { create(:case_contact, deleted_at: Time.current) }

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

  describe "delete and undelete buttons" do
    let(:case_contact) { create(:case_contact) }
    let(:case_contact2) { create(:case_contact, deleted_at: Time.current) }

    context "when logged in as admin" do
      before do
        enable_pundit(view, admin)
        allow(view).to receive(:current_user).and_return(admin)
      end

      it "shows delete button" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
        expect(rendered).to have_link("Delete", href: "/case_contacts/#{case_contact.id}")
      end

      it "shows undelete button" do
        assign :case_contact, case_contact2
        assign :casa_cases, [case_contact2.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact2})
        expect(rendered).to have_link("undelete", href: "/case_contacts/#{case_contact2.id}/restore")
      end
    end

    context "when logged in as volunteer" do
      before do
        enable_pundit(view, volunteer)
        allow(view).to receive(:current_user).and_return(volunteer)
      end

      it "should not show delete button" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
        expect(rendered).not_to have_link("Delete", href: "/case_contacts/#{case_contact.id}")
      end

      it "should not show undelete button" do
        assign :case_contact, case_contact2
        assign :casa_cases, [case_contact2.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact2})
        expect(rendered).not_to have_link("undelete", href: "/case_contacts/#{case_contact2.id}/restore")
      end
    end

    context "when logged in as supervisor" do
      before do
        enable_pundit(view, supervisor)
        allow(view).to receive(:current_user).and_return(supervisor)
      end

      it "should not show delete button" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
        expect(rendered).not_to have_link("Delete", href: "/case_contacts/#{case_contact.id}")
      end

      it "should not show undelete button" do
        assign :case_contact, case_contact2
        assign :casa_cases, [case_contact2.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact2})
        expect(rendered).not_to have_link("undelete", href: "/case_contacts/#{case_contact2.id}/restore")
      end
    end
  end
end
