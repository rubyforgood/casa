require "rails_helper"

RSpec.describe "Learning Hours Index", type: :system do
  let!(:supervisor) { create(:supervisor, :with_volunteers) }
  let!(:volunteer) { supervisor.volunteers.first }
  let!(:learning_hours) { create_list(:learning_hour, 2, user: volunteer) }

  before do
    login_as user, scope: :user
  end

  context "when the user is a volunteer" do
    let(:user) { volunteer }

    it "displays the volunteer learning hours" do
      visit learning_hours_path
      expect(page).to have_content("Learning Hours")
      expect(page).to have_content("Title")
      expect(page).to have_content("Time Spent")
      expect(page).to have_link("Record Learning Hours", href: new_learning_hour_path)
    end
  end

  context "when the user is a supervisor or admin" do
    let(:user) { supervisor }

    before do
      visit learning_hours_path
    end

    it "displays a list of volunteers and the learning hours they completed", js: true do
      expect(page).to have_content("Learning Hours")
      expect(page).to have_content("Volunteer")
      expect(page).to have_content(volunteer.display_name)
      expect(page).to have_content("Time Completed")
      expect(page).to have_content("#{volunteer.learning_hours.sum(:duration_hours)} hours")
    end

    it "when clicking on a volunteer's name it redirects to the `learning_hours_volunteer_path` for the volunteer" do
      click_on volunteer.display_name
      expect(page).to have_current_path(learning_hours_volunteer_path(volunteer.id))
    end

    shared_examples_for "functioning sort buttons" do
      it "sorts table columns" do
        expect(page).to have_selector("tr:nth-child(1)", text: expected_first_ordered_value)

        find("th", text: column_to_sort).click

        expect(page).to have_selector("th.sorting_asc", text: column_to_sort)
        expect(page).to have_selector("tr:nth-child(1)", text: expected_last_ordered_value)
      end
    end

    it "shows pagination", js: true do
      expect(page).to have_content("Previous")
      expect(page).to have_content("Next")
    end
  end
end
