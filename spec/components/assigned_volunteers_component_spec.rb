# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignedVolunteersComponent, type: :component do
  let(:casa_case) { create(:casa_case) }
  let(:current_user) { create(:user) }

  context "when user is not a volunteer" do
    it "renders assigned volunteers" do
      volunteer = create(:volunteer)
      casa_case.volunteers << volunteer

      component = described_class.new(casa_case, current_user)
      render_inline(component)

      expect(page).to have_selector("span.badge", text: volunteer.display_name)
    end

    it "renders 'Unassigned' when no volunteers present" do
      component = described_class.new(casa_case, current_user)
      render_inline(component)

      expect(page).to have_selector("span.badge", text: "Unassigned")
    end
  end

  context "when user is a volunteer" do
    let(:current_user) { create(:volunteer) }

    it "does not render badge" do
      component = described_class.new(casa_case, current_user)
      render_inline(component)

      expect(page).not_to have_selector("span.badge")
    end
  end
end
