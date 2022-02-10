require "rails_helper"

RSpec.describe "casa_admins/new", type: :system do
  let(:admin) { create :casa_admin }

  it "validates and creates new admin" do
    visit casa_admins_path
    expect(page).to have_content "You need to sign in before continuing."

    sign_in admin
    visit casa_admins_path
    click_on "New Admin"
    expect(page).to have_content "Create New Casa Admin"

    click_button "Submit"
    expect(page).to have_content "2 errors prohibited this Casa admin from being saved:"
    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content "Display name can't be blank"

    fill_in "Email", with: "invalid email"
    fill_in "Display name", with: "Freddy"
    click_button "Submit"
    expect(page).to have_content "1 error prohibited this Casa admin from being saved:"
    expect(page).to have_content "Email is invalid"

    fill_in "Email", with: "valid@example.com"
    fill_in "Display name", with: "Freddy Valid"
    click_button "Submit"
    expect(page).to have_content "New admin created successfully"
    expect(page).to have_content "valid@example.com"

    last_email = ActionMailer::Base.deliveries.last
    expect(last_email.to).to eq ["valid@example.com"]
    expect(last_email.subject).to have_text "CASA Console invitation instructions"
    expect(last_email.html_part.body.encoded).to have_text "your new CasaAdmin account."

    click_on "New Admin"
    fill_in "Email", with: "valid@example.com"
    fill_in "Display name", with: "Freddy Valid"
    click_button "Submit"
    expect(page).to have_content "Email has already been taken"

    expect(CasaAdmin.find_by(email: "valid@example.com").invitation_created_at).not_to be_nil
  end
end
