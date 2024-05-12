# frozen_string_literal: true

require "rails_helper"

RSpec.describe VolunteerHelper, type: :helper do
  let(:casa_case) { create(:casa_case) }
  let(:current_user) { create(:user) }

  context "when user is not a volunteer" do
    it "returns the assigned volunteers' names" do
      volunteer = create(:volunteer)
      casa_case.volunteers << volunteer

      badge_html = helper.volunteer_badge(casa_case, current_user)

      expect(badge_html).to include("badge")
      expect(badge_html).to include(volunteer.display_name)
    end

    it "returns 'Unassigned' when no volunteers are present" do
      badge_html = helper.volunteer_badge(casa_case, current_user)

      expect(badge_html).to include("badge")
      expect(badge_html).to include("Unassigned")
    end
  end

  context "when user is a volunteer" do
    let(:current_user) { create(:volunteer) }

    it "returns an empty string" do
      badge_html = helper.volunteer_badge(casa_case, current_user)

      expect(badge_html).to eq("")
    end
  end
end
