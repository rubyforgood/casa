require "rails_helper"

RSpec.describe "Learning Hours Index", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:supervisor) { create(:supervisor) }
  let(:learning_hours) { create_list(:learning_hour, 5, user: volunteer) }

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

    it "displays the supervisor/admin learning hours", js: true do
      expect(page).to have_content("Learning Hours")
      expect(page).to have_content("Volunteer")
      expect(page).to have_content("Time Completed")
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
