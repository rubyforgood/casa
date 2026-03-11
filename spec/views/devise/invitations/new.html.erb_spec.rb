require "rails_helper"

RSpec.describe "users/invitations/new", type: :view do
  it "displays title" do
    render template: "devise/invitations/new"
    expect(rendered).to have_text("Send invitation")
  end

  it "displays fields for inviting a user" do
    render template: "devise/invitations/new"
    expect(rendered).to have_text("Email")
    expect(rendered).to have_field("user_email")
    expect(rendered).to have_button("Send an invitation")
  end
end
