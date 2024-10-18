require "rails_helper"

RSpec.describe "case_contacts/case_contact", type: :view do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { build_stubbed(:casa_admin, casa_org:) }
  let(:volunteer) { create(:volunteer, casa_org:) }
  let(:supervisor) { build_stubbed(:supervisor, casa_org:) }

  describe "case contact notes" do
    before do
      enable_pundit(view, admin)
      allow(view).to receive(:current_user).and_return(admin)
    end

    context "when case contact has contact topic responses" do
      let(:case_contact) do
        build_stubbed(:case_contact, contact_topic_answers: [contact_topic_answer1, contact_topic_answer2], creator: volunteer)
      end

      let(:contact_topic1) { build_stubbed(:contact_topic, question: "Some question") }
      let(:contact_topic2) { build_stubbed(:contact_topic, question: "Hidden question") }

      let(:contact_topic_answer1) do
        build_stubbed(:contact_topic_answer, contact_topic: contact_topic1, value: "Some answer")
      end

      let(:contact_topic_answer2) do
        build_stubbed(:contact_topic_answer, contact_topic: contact_topic2, value: "")
      end

      it "shows the contact topic responses" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})

        expect(rendered).to have_text("Some question:")
        expect(rendered).to have_text("Some answer")
        expect(rendered).to_not have_text("Hidden question")
      end
    end

    context "when case contact has no notes" do
      let(:case_contact) { build_stubbed(:case_contact, notes: nil) }

      it "does not show the notes" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})

        expect(rendered).not_to have_text("Additional Notes:")
      end
    end

    context "when case contact has notes" do
      let(:case_contact) { build_stubbed(:case_contact, notes: "This is a note") }

      it "shows the notes" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})

        expect(rendered).to have_text("Additional Notes:")
        expect(rendered).to have_text("This is a note")
      end
    end
  end

  describe "edit and make reminder buttons" do
    before do
      enable_pundit(view, admin)
      allow(view).to receive(:current_user).and_return(admin)
    end

    context "occurred_at is before the last day of the month in the quarter that the case contact was created" do
      let(:case_contact) { build_stubbed(:case_contact, creator: volunteer) }
      let(:case_contact2) { build_stubbed(:case_contact, deleted_at: Time.current, creator: volunteer) }

      it "shows edit button" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
        expect(rendered).to have_link(nil, href: "/case_contacts/#{case_contact.id}/edit")
      end

      it "shows make reminder button" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
        expect(rendered).to have_button("Make Reminder")
      end
    end
  end

  describe "delete and undelete buttons" do
    let(:case_contact) { build_stubbed(:case_contact, creator: volunteer) }
    let(:case_contact2) { build_stubbed(:case_contact, deleted_at: Time.current, creator: volunteer) }

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

      it "shows delete button" do
        assign :case_contact, case_contact
        assign :casa_cases, [case_contact.casa_case]

        render(partial: "case_contacts/case_contact", locals: {contact: case_contact})
        expect(rendered).to have_link("Delete", href: "/case_contacts/#{case_contact.id}")
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
