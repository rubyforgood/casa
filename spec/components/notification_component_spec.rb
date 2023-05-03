# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationComponent, type: :component do
  let(:followup_with_note) { create(:notification, :followup_with_note) }
  let(:followup_no_note) { create(:notification, :followup_without_note) }
  let(:followup_read) { create(:notification, :followup_read) }

  it "renders a followup with note" do
    component = described_class.new(notification: followup_with_note.to_notification)

    render_inline(component)
    expect(page).to have_text("New followup")
    expect(page).to have_text("Note: ")
    expect(page).to have_text(followup_with_note.to_notification.message)
  end

  it "renders a followup without a note" do
    component = described_class.new(notification: followup_no_note.to_notification)

    render_inline(component)
    expect(page).to have_text("New followup")
    expect(page).not_to have_text("Note: ")
    expect(page).to have_text(followup_no_note.to_notification.message)
  end

  it "renders unread followups with the correct styles" do
    component = described_class.new(notification: followup_with_note.to_notification)

    render_inline(component)
    expect(page).not_to have_css("a.bg-light.text-muted")
    expect(page).to have_css("i.fas.fa-bell")
  end

  it "renders read followups with the correct styles" do
    component = described_class.new(notification: followup_read.to_notification)

    render_inline(component)
    expect(page).to have_css("a.bg-light.text-muted")
    expect(page).not_to have_css("i.fas.fa-bell")
  end
end
