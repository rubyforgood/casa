# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationComponent, type: :component do
  let(:followup_with_note) { create(:followup_notification, :with_note) }
  let(:followup_no_note) { create(:followup_notification, :without_note) }
  let(:followup_read) { create(:followup_notification, :read) }
  let(:emancipation_checklist_reminder) { create(:emancipation_checklist_reminder_notification) }
  let(:youth_birthday) { create(:youth_birthday_notification) }

  it "renders a followup with note" do
    component = described_class.new(notification: followup_with_note)

    render_inline(component)
    expect(page).to have_text("New followup")
    expect(page).to have_text("Note: ")
    expect(page).to have_text(followup_with_note.message)
  end

  it "renders a followup without a note" do
    component = described_class.new(notification: followup_no_note)

    render_inline(component)
    expect(page).to have_text("New followup")
    expect(page).not_to have_text("Note: ")
    expect(page).to have_text(followup_no_note.message)
  end

  it "renders unread followups with the correct styles" do
    component = described_class.new(notification: followup_with_note)

    render_inline(component)
    expect(page).not_to have_css("a.bg-light.text-muted")
    expect(page).to have_css("i.fas.fa-bell")
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
    expect(page).to have_text(emancipation_checklist_reminder.message)
  end

  it "renders a youth birthday notification" do
    component = described_class.new(notification: youth_birthday)

    render_inline(component)
    expect(page).to have_text("Youth Birthday")
    expect(page).to have_text(youth_birthday.message)
  end
end
