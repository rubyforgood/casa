require "rails_helper"

RSpec.describe "LearningHours::Volunteers #show" do
  let(:volunteer) { create(:volunteer) }
  let(:supervisor) { create(:supervisor) }
  let(:learning_hours) { create_list(:learning_hour, 1, user: volunteer) }

  before do
    learning_hours
    sign_in user
  end

  context "when the user is a volunteer" do
    let(:user) { volunteer }

    it "cannot access this page" do
      visit learning_hours_volunteer_path(volunteer)
      expect(page).to have_content("Sorry, you are not authorized to perform this action.")
    end
  end

  context "when the user is a supervisor or admin" do
    let(:user) { supervisor }

    before do
      visit learning_hours_volunteer_path(volunteer)
    end

    it "displays the volunteer's name" do
      expect(page).to have_content("#{volunteer.display_name}'s Learning Hours")
    end

    it "displays the volunteer's first learning hours", :js do
      expect(page).to have_content(learning_hours.first.name)
      expect(page).to have_content(learning_hours.first.occurred_at.strftime("%B %-d, %Y"))
    end

    it "displays the volunteer's last learning hours", :js do
      expect(page).to have_content(learning_hours.last.name)
      expect(page).to have_content(learning_hours.last.occurred_at.strftime("%B %-d, %Y"))
    end
  end
end
