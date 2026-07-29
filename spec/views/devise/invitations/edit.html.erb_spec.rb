require "rails_helper"

RSpec.describe "users/invitations/edit", type: :view do
  it "displays title" do
    render template: "devise/invitations/edit"
    expect(rendered).to have_text("Set your password")
  end

  it "displays fields for user to set password" do
    render template: "devise/invitations/edit"
    expect(rendered).to have_field("user_invitation_token", type: :hidden)
    expect(rendered).to have_text("Password")
    expect(rendered).to have_field("user_password")
    expect(rendered).to have_text("Confirm password")
    expect(rendered).to have_field("user_password_confirmation")
    expect(rendered).to have_button("Activate account")
  end
end
