require "rails_helper"

RSpec.describe "supervisor views Volunteers page", type: :system do
  let(:organization) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  # Add back when Travis CI correctly handles large screen size
  xit "can filter volunteers" do
    create_list(:volunteer, 3, casa_org: organization)
    create_list(:volunteer, 2, :inactive, casa_org: organization)

    sign_in supervisor

    visit volunteers_path
    expect(page).to have_selector(".volunteer-filters")

    # by default, only active users are shown, so result should be 4 here
    expect(page.all("table#volunteers tr").count).to eq 4

    click_on "Status"
    find(:css, 'input[data-value="Active"]').set(false)

    # when all users are hidden, the tr count will be 2 for header and "no results" row
    expect(page.all("table#volunteers tr").count).to eq 2

    find(:css, 'input[data-value="Inactive"]').set(true)

    expect(page.all("table#volunteers tr").count).to eq 3
  end

  it "can show/hide columns on volunteers table" do
    sign_in supervisor

    visit volunteers_path
    expect(page).to have_text("Pick displayed columns")

    click_on "Pick displayed columns"
    expect(page).to have_text("Name")
    expect(page).to have_text("Status")
    expect(page).to have_text("Contact Made In Past 60 Days")
    expect(page).to have_text("Last Contact Made")
    check "Name"
    check "Status"
    uncheck "Contact Made In Past 60 Days"
    uncheck "Last Contact Made"
    within(".modal-dialog") do
      click_button "Close"
    end

    expect(page).to have_text("Name")
    expect(page).to have_text("Status")
    expect(page).not_to have_text("Contact Made In Past 60 Days")
    expect(page).not_to have_text("Last Contact Made")
  end
end
