require "rails_helper"

RSpec.describe "users/password/new", type: :view do
  it "displays title" do
    render template: "devise/passwords/new"
    expect(rendered).to have_text("Forgot your password?")
  end

  it "displays text above form fields" do
    render template: "devise/passwords/new"
    expect(rendered).to have_text("Please enter email or phone number to recieve reset instructions.")
  end

  it "displays contact fields for user to reset password" do
    render template: "devise/passwords/new"
    expect(rendered).to have_text("Email")
    expect(rendered).to have_field("user_email")
    expect(rendered).to have_text("Phone number")
    expect(rendered).to have_field("user_phone_number")
  end
end
