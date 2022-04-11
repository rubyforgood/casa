require "rails_helper"

RSpec.describe "casa_admins/edit", type: :system do
  let(:admin) { create :casa_admin }

  before { sign_in admin }

  context "with valid data" do
    it "can successfully edit user email and display name" do
      expected_email = "root@casa.com"
      expected_display_name = "Root Admin"
      expected_phone_number = "+14163218092"

      visit edit_casa_admin_path(admin)

      fill_in "Email", with: expected_email
      fill_in "Display name", with: expected_display_name
      fill_in "Phone number", with: expected_phone_number

      click_on "Submit"

      admin.reload

      expect(page).to have_text "New admin created successfully"
      expect(admin.email).to eq expected_email
      expect(admin.display_name).to eq expected_display_name
      expect(admin.phone_number).to eq expected_phone_number
    end
  end

  context "with invalid data" do
    it "shows error message for phone number < 12 digits" do
      visit edit_casa_admin_path(admin)

      fill_in "Email", with: "newemail@example.com"
      fill_in "Display name", with: "Lumine"
      fill_in "Phone number", with: "+141632489"

      click_on "Submit"

      expect(page).to have_text "Phone number must be 12 digits including country code (+1)"
    end

    it "shows error message for phone number > 12 digits" do
      visit edit_casa_admin_path(admin)

      fill_in "Email", with: "newemail@example.com"
      fill_in "Display name", with: "Kadehara Kazuha"
      fill_in "Phone number", with: "+141632180923"

      click_on "Submit"

      expect(page).to have_text "Phone number must be 12 digits including country code (+1)"
    end

    it "shows error message for bad phone number" do
      visit edit_casa_admin_path(admin)

      fill_in "Email", with: "newemail@example.com"
      fill_in "Display name", with: "Nyan Cat"
      fill_in "Phone number", with: "+141632u809o"

      click_on "Submit"

      expect(page).to have_text "Phone number must have correct format"
    end

    it "shows error message for phone number without country code" do
      visit edit_casa_admin_path(admin)

      fill_in "Email", with: "newemail@example.com"
      fill_in "Display name", with: "Patrick Star"
      fill_in "Phone number", with: "+24163218092"

      click_on "Submit"

      expect(page).to have_text "Phone number must have a valid country code (+1)"
    end

    it "shows error message for empty email" do
      visit edit_casa_admin_path(admin)

      fill_in "Email", with: ""
      fill_in "Display name", with: ""

      click_on "Submit"

      expect(page).to have_text "Email can't be blank"
      expect(page).to have_text "Display name can't be blank"
    end
  end

  it "can successfully deactivate", js: true do
    another = create(:casa_admin)
    visit edit_casa_admin_path(another)

    dismiss_confirm do
      click_on "Deactivate"
    end

    expect(page).not_to have_text("Admin was deactivated.")

    accept_confirm do
      click_on "Deactivate"
    end

    expect(page).to have_text("Admin was deactivated.")
    expect(another.reload.active).to be_falsey
  end

  it "can resend invitation to a another admin", js: true do
    another = create(:casa_admin)
    visit edit_casa_admin_path(another)

    click_on "Resend Invitation"

    expect(page).to have_content("Invitation sent")

    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq(1)
    expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
  end

  it "can convert the admin to a supervisor", js: true do
    another = create(:casa_admin)
    visit edit_casa_admin_path(another)

    click_on "Change to Supervisor"

    expect(page).to have_text("Admin was changed to Supervisor.")
    expect(User.find(another.id)).to be_supervisor
  end

  it "is not able to edit last sign in" do
    visit edit_casa_admin_path(admin)

    expect(page).to have_text "Added to system "
    expect(page).to have_text "Invitation email sent never"
    expect(page).to have_text "Last logged in"
    expect(page).to have_text "Invitation accepted never"
    expect(page).to have_text "Password reset last sent never"
  end
end
