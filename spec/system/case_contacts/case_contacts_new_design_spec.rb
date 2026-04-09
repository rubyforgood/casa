require "rails_helper"

RSpec.describe "Case contacts new design", type: :system, js: true do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:contact_topic) { create(:contact_topic, casa_org: organization, question: "What was discussed?") }
  let!(:case_contact) do
    create(:case_contact, :active, casa_case: casa_case, notes: "Important follow-up needed")
  end

  before do
    create(:contact_topic_answer,
      case_contact: case_contact,
      contact_topic: contact_topic,
      value: "Youth is doing well in school")
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(true)
    sign_in admin
    visit case_contacts_new_design_path
  end

  describe "row expansion" do
    it "shows the expanded content after clicking the chevron" do
      find(".expand-toggle").click

      expect(page).to have_content("What was discussed?")
      expect(page).to have_content("Youth is doing well in school")
    end

    it "shows notes in the expanded content" do
      find(".expand-toggle").click

      expect(page).to have_content("Additional Notes")
      expect(page).to have_content("Important follow-up needed")
    end

    it "hides the expanded content after clicking the chevron again" do
      find(".expand-toggle").click
      expect(page).to have_content("Youth is doing well in school")

      find(".expand-toggle").click
      expect(page).to have_no_content("Youth is doing well in school")
    end
  end

  describe "action menu" do
    it "opens the dropdown when the ellipsis button is clicked" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_css(".dropdown-menu.show")
    end

    it "shows Edit in the menu" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Edit")
    end

    it "shows Delete in the menu" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Delete")
    end

    it "shows Set Reminder when no followup exists" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Set Reminder")
      expect(page).to have_no_text("Resolve Reminder")
    end

    it "shows Resolve Reminder when a requested followup exists" do
      create(:followup, case_contact: case_contact, status: :requested, creator: admin)
      visit case_contacts_new_design_path

      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Resolve Reminder")
      expect(page).to have_no_text("Set Reminder")
    end

    it "closes the dropdown when clicking outside" do
      find(".cc-ellipsis-toggle").click
      expect(page).to have_css(".dropdown-menu.show")

      find("h1").click
      expect(page).to have_no_css(".dropdown-menu.show")
    end
  end

  describe "Edit action" do
    it "navigates to the edit form when Edit is clicked" do
      find(".cc-ellipsis-toggle").click
      click_link "Edit"

      expect(page).to have_current_path(/case_contacts\/#{case_contact.id}\/form/)
    end
  end

  describe "Delete action" do
    let(:occurred_at_text) { I18n.l(case_contact.occurred_at, format: :full) }

    it "removes the row after confirming the delete dialog" do
      expect(page).to have_text(occurred_at_text)

      find(".cc-ellipsis-toggle").click
      find(".cc-delete-action").click
      click_button "Delete"

      expect(page).to have_no_text(occurred_at_text)
    end

    it "leaves the row in place when the delete dialog is cancelled" do
      expect(page).to have_text(occurred_at_text)

      find(".cc-ellipsis-toggle").click
      find(".cc-delete-action").click
      click_button "Cancel"

      expect(page).to have_text(occurred_at_text)
    end
  end
end
