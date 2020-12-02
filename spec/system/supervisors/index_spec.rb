require "rails_helper"

RSpec.describe "supervisors/index", type: :system do
  let(:organization) { create(:casa_org) }
  let(:user) { create(:supervisor, casa_org: organization) }

  it "can edit supervisor by clicking on the edit link from the supervisors list page" do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name, casa_org: organization)
    sign_in user

    visit supervisors_path

    expect(page).to have_text(supervisor_name)

    within "#supervisors" do
      click_on "Edit", match: :first
    end

    expect(page).to have_text("Editing Supervisor")
  end

  it "can edit supervisor by clicking on the supervisor's name from the supervisors list page" do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name, casa_org: organization)
    sign_in user

    visit supervisors_path

    within "#supervisors" do
      click_on supervisor_name, match: :first
    end

    expect(page).to have_text("Editing Supervisor")
  end
end
