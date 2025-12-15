require "rails_helper"

RSpec.describe "Inviting volunteers", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before do
    # Stub the request to the URL shortener service (needed if phone is provided)
    stub_request(:post, "https://api.short.io/links")
      .to_return(
        status: 200,
        body: {shortURL: "https://short.url/example"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    sign_in admin
  end

  describe "creating and sending invitation" do
    it "creates a new volunteer and sends invitation email" do
      visit new_volunteer_path

      fill_in "Email", with: "new_volunteer@example.com"
      fill_in "Display name", with: "Jane Doe"
      fill_in "Date of birth", with: Date.new(1995, 5, 15)

      expect {
        click_on "Create Volunteer"
      }.to change(Volunteer, :count).by(1)

      volunteer = Volunteer.find_by(email: "new_volunteer@example.com")
      expect(volunteer).to be_present
      expect(volunteer.invitation_created_at).not_to be_nil
      expect(volunteer.invitation_accepted_at).to be_nil

      # Verify invitation email was sent
      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to eq ["new_volunteer@example.com"]
      expect(last_email.subject).to have_text "CASA Console invitation instructions"
      expect(last_email.html_part.body.encoded).to have_text "your new Volunteer account"
    end

    it "sets invitation_created_at timestamp" do
      visit new_volunteer_path

      fill_in "Email", with: "volunteer_with_token@example.com"
      fill_in "Display name", with: "John Smith"
      fill_in "Date of birth", with: Date.new(1990, 1, 1)

      click_on "Create Volunteer"

      volunteer = Volunteer.find_by(email: "volunteer_with_token@example.com")
      expect(volunteer.invitation_created_at).to be_present
      expect(volunteer.invitation_accepted_at).to be_nil
    end
  end

  describe "accepting invitation" do
    let(:volunteer) { create(:volunteer, casa_org: organization, phone_number: nil) }
    let!(:invitation_token) do
      volunteer.invite!(admin)
      volunteer.raw_invitation_token
    end

    before do
      sign_out admin
    end

    it "shows the invitation acceptance form" do
      visit accept_user_invitation_path(invitation_token: invitation_token)

      expect(page).to have_text "Set my password"
      expect(page).to have_field("Password")
      expect(page).to have_field("Password confirmation")
      expect(page).to have_button("Set my password")
    end

    it "allows volunteer to set password and accept invitation" do
      visit accept_user_invitation_path(invitation_token: invitation_token)

      expect(page).to have_text "Set my password"

      fill_in "Password", with: "SecurePassword123!"
      fill_in "Password confirmation", with: "SecurePassword123!"

      click_on "Set my password"

      volunteer.reload
      expect(volunteer.invitation_accepted_at).not_to be_nil

      # Should be redirected to dashboard after accepting invitation
      expect(page).to have_text("My Cases")
    end

    it "shows error when passwords don't match" do
      visit accept_user_invitation_path(invitation_token: invitation_token)

      fill_in "Password", with: "SecurePassword123!"
      fill_in "Password confirmation", with: "DifferentPassword456!"

      click_on "Set my password"

      expect(page).to have_text "Password confirmation doesn't match"

      volunteer.reload
      expect(volunteer.invitation_accepted_at).to be_nil
    end

    it "shows error when password is too short" do
      visit accept_user_invitation_path(invitation_token: invitation_token)

      fill_in "Password", with: "short"
      fill_in "Password confirmation", with: "short"

      click_on "Set my password"

      expect(page).to have_text "Password is too short"

      volunteer.reload
      expect(volunteer.invitation_accepted_at).to be_nil
    end

    it "shows error when password is blank" do
      visit accept_user_invitation_path(invitation_token: invitation_token)

      fill_in "Password", with: ""
      fill_in "Password confirmation", with: ""

      click_on "Set my password"

      expect(page).to have_text "can't be blank"

      volunteer.reload
      expect(volunteer.invitation_accepted_at).to be_nil
    end
  end

  describe "resending invitation" do
    let(:volunteer) { create(:volunteer, casa_org: organization, phone_number: nil) }

    before do
      volunteer.invite!(admin)
    end

    it "allows admin to resend invitation to volunteer who hasn't accepted" do
      visit edit_volunteer_path(volunteer)

      expect {
        click_on "Resend Invitation"
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(page).to have_text "Invitation sent"

      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to eq [volunteer.email]
      expect(last_email.subject).to have_text "CASA Console invitation instructions"
    end

    it "hides resend button after invitation is accepted" do
      volunteer.update!(invitation_accepted_at: Time.current)

      visit edit_volunteer_path(volunteer)

      expect(page).not_to have_link("Resend Invitation")
    end
  end

  describe "supervisor creating volunteer" do
    let(:supervisor) { create(:supervisor, casa_org: organization) }

    before do
      sign_out admin
      sign_in supervisor
    end

    it "allows supervisor to create and invite a volunteer" do
      visit new_volunteer_path

      fill_in "Email", with: "supervisor_volunteer@example.com"
      fill_in "Display name", with: "Supervisor's Volunteer"
      fill_in "Date of birth", with: Date.new(1992, 3, 20)

      expect {
        click_on "Create Volunteer"
      }.to change(Volunteer, :count).by(1)

      volunteer = Volunteer.find_by(email: "supervisor_volunteer@example.com")
      expect(volunteer).to be_present
      expect(volunteer.invitation_created_at).not_to be_nil

      # Verify invitation email was sent
      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to eq ["supervisor_volunteer@example.com"]
    end
  end

  describe "volunteer user trying to create another volunteer" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }

    before do
      sign_out admin
      sign_in volunteer
    end

    it "denies access with error message" do
      visit new_volunteer_path

      expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
    end
  end

  describe "invitation expiration" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }

    it "volunteers have invitation valid for 1 year" do
      volunteer.invite!(admin)

      # Check that volunteer model has correct invitation period
      expect(Volunteer.invite_for).to eq(1.year)
    end
  end
end
