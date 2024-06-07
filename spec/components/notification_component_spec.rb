# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationComponent, type: :component do
  let(:user) { create(:user, display_name: "John Doe") }
  let(:casa_case) { create(:casa_case, case_number: "CINA-1234") }
  let(:followup_with_note) { create(:notification, :followup_with_note, created_by: user) }
  let(:followup_no_note) { create(:notification, :followup_without_note, created_by: user) }
  let(:followup_read) { create(:notification, :followup_read, created_by: user) }
  let(:emancipation_checklist_reminder) { create(:notification, :emancipation_checklist_reminder, casa_case: casa_case) }
  let(:youth_birthday) { create(:notification, :youth_birthday, casa_case: casa_case) }

  it "renders a followup with note" do
    component = described_class.new(notification: followup_with_note)

    render_inline(component)
    expect(page).to have_text("New followup")
    expect(page).to have_text("Note: ")
    expect(page).to have_text("#{user.display_name} has flagged a Case Contact that needs follow up.")
  end

  it "renders a followup without a note" do
    component = described_class.new(notification: followup_no_note)

    render_inline(component)
    expect(page).to have_text("New followup")
    expect(page).not_to have_text("Note: ")
    expect(page).to have_text("#{user.display_name} has flagged a Case Contact that needs follow up. Click to see more.")
  end

  it "renders read followups with the correct styles" do
    component = described_class.new(notification: followup_read)

    render_inline(component)
    expect(page).to have_css("a.bg-light.text-muted")
    expect(page).not_to have_css("i.fas.fa-bell")
  end

  it "renders an emancipation checklist reminder" do
    component = described_class.new(notification: emancipation_checklist_reminder)

    render_inline(component)
    expect(page).to have_text("Emancipation Checklist Reminder")
    expect(page).to have_text("Your case #{casa_case.case_number} is a transition aged youth. We want to make sure that along the way, we’re preparing our youth for emancipation. Make sure to check the emancipation checklist.")
  end

  it "renders a youth birthday notification" do
    component = described_class.new(notification: youth_birthday)

    render_inline(component)
    expect(page).to have_text("Youth Birthday")
    expect(page).to have_text("Your youth, case number: #{casa_case.case_number} has a birthday next month.")
  end
end
