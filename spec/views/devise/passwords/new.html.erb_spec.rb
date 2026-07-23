require "rails_helper"

RSpec.describe "users/password/new", type: :view do
  it "displays title" do
    render template: "devise/passwords/new"
    expect(rendered).to have_text("Reset your password")
  end

  it "displays text above form fields" do
    render template: "devise/passwords/new"
    expect(rendered).to have_text("Enter your email or phone number and we'll send reset instructions.")
  end

  it "displays contact fields for user to reset password" do
    render template: "devise/passwords/new"
    expect(rendered).to have_text("Email")
    expect(rendered).to have_field("user_email")
    expect(rendered).to have_text("Phone number")
    expect(rendered).to have_field("user_phone_number")
  end
end
