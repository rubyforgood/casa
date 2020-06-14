require "rails_helper"

RSpec.describe "Admin: Editing Volunteers", type: :system do
  let(:admin) { create(:user, :casa_admin) }
  let(:volunteer) { create(:user, :volunteer) }

  it "saves the user as inactive, but only if the admin confirms" do
    sign_in admin
    visit edit_volunteer_path(volunteer)

    dismiss_confirm do
      choose "Inactive"
    end
    expect(find_field("statusRadio2")).not_to be_checked

    accept_confirm do
      choose "Inactive"
    end
    expect(find_field("statusRadio2")).to be_checked

    click_on "Submit"
    expect {
      volunteer.reload
    }.to change { volunteer.role }.from("volunteer").to("inactive")
  end
end
