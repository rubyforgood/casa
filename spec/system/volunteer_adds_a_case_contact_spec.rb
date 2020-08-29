require "rails_helper"

RSpec.describe "volunteer adds a case contact", type: :system do
  it "is successful" do
    volunteer = create(:volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first

    sign_in volunteer

    visit new_case_contact_path

    find(:css, "input.casa-case-id-check[value='#{volunteer_casa_case_one.id}']").set(true)
    check "School"
    check "Therapist"
    choose "Yes"
    select "Video", from: "case_contact[medium_type]"
    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    expect(page).not_to have_text("error")
    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1)
    expect(CaseContact.first.casa_case_id).to eq volunteer_casa_case_one.id
    expect(CaseContact.first.contact_types).to include "school"
    expect(CaseContact.first.contact_types).to include "therapist"
    expect(CaseContact.first.duration_minutes).to eq 105
  end

  context "with invalid inputs" do
    context "with javascript" do
      it "does not submit the form" do
        volunteer = create(:volunteer, :with_casa_cases)
        volunteer_casa_case_one = volunteer.casa_cases.first

        sign_in volunteer

        visit new_case_contact_path

        find(:css, "input.casa-case-id-check[value='#{volunteer_casa_case_one.id}']").set(true)

        expect {
          click_on "Submit"
        }.not_to change(CaseContact, :count)
      end
    end

    context "without javascript" do
      it "re-renders the form with error messages", js: false do
        volunteer = create(:volunteer, :with_casa_cases)
        volunteer_casa_case_one = volunteer.casa_cases.first

        sign_in volunteer

        visit new_case_contact_path

        find(:css, "input.casa-case-id-check[value='#{volunteer_casa_case_one.id}']").set(true)

        expect {
          click_on "Submit"
        }.not_to change(CaseContact, :count)

        expect(page).to have_text("Contact types can't be blank")
        expect(page).to have_text("Medium type can't be blank")
      end
    end
  end
end
