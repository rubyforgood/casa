require "rails_helper"

RSpec.describe "casa_admins/edit", type: :system do
  let(:admin) { create :casa_admin }

  before { sign_in admin }

  context "with valid data" do
    it "can successfully edit user display name and phone number" do
      expected_display_name = "Root Admin"
      expected_phone_number = "+14398761234"

      visit edit_casa_admin_path(admin)

      fill_in "Display name", with: expected_display_name
      fill_in "Phone number", with: expected_phone_number

      click_on "Submit"

      admin.reload

      expect(page).to have_text "Casa Admin was successfully updated."

      expect(admin.display_name).to eq expected_display_name
      expect(admin.phone_number).to eq expected_phone_number
    end
  end

  context "with valid email data" do
    before do
      visit edit_casa_admin_path(admin)
      @old_email = admin.email
      fill_in "Email", with: "new_admin_email@example.com"

      click_on "Submit"
      admin.reload
    end

    it "sends a confirmation email upon submission and does not change the user's displayed email" do
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("You can confirm your account email through the link below:")

      expect(page).to have_text "Admin was successfully updated. Confirmation Email Sent."
      expect(page).to have_field("Email", with: @old_email)
      expect(admin.unconfirmed_email).to eq("new_admin_email@example.com")
    end

    it "succesfully updates the user email once the user confirms the changes" do
      admin.confirm
      admin.reload
      visit edit_casa_admin_path(admin)

      expect(page).to have_field("Email", with: "new_admin_email@example.com")
      expect(admin.old_emails).to eq([@old_email])
    end
  end

  context "with invalid data" do
    let(:role) { "admin" }
    before do
      visit edit_casa_admin_path(admin)
      fill_in "Email", with: "newemail@example.com"
      fill_in "Display name", with: "Kaedehara Kazuha"
    end

    it_should_behave_like "shows error for invalid phone numbers"

    it "shows error message for empty email" do
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

    retries = 0
    while retries < 4
      retries += 1
      sleep 1
      deliveries = ActionMailer::Base.deliveries
      next unless deliveries.count > 0
      expect(deliveries.count).to eq(1)
      expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
    end
    raise "could not find mail delivery proof" if retries > 4
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
