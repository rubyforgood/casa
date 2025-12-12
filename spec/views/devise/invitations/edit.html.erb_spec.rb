# frozen_string_literal: true

require "rails_helper"

RSpec.describe "devise/invitations/edit.html.erb", type: :view do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  before do
    volunteer.invite!
    assign(:resource, volunteer)
    assign(:resource_name, :user)
    assign(:devise_mapping, Devise.mappings[:user])
    assign(:minimum_password_length, 6)

    # Set the invitation_token on the resource as the controller does
    volunteer.invitation_token = volunteer.raw_invitation_token

    # Allow the class to respond to require_password_on_accepting
    allow(volunteer.class).to receive(:require_password_on_accepting).and_return(true)

    render
  end

  it "uses form_with with local: true" do
    # form_with local: true should not have data-remote="true"
    expect(rendered).not_to have_selector('form[data-remote="true"]')
  end

  it "includes invitation_token field" do
    expect(rendered).to match(/invitation_token/)
  end

  it "does not have readonly attribute on invitation_token field" do
    expect(rendered).not_to match(/invitation_token.*readonly/)
  end

  it "includes password fields" do
    expect(rendered).to match(/password/)
    expect(rendered).to match(/password_confirmation/)
  end

  it "includes submit button" do
    expect(rendered).to have_button("Set my password")
  end

  it "uses PUT method" do
    expect(rendered).to have_selector('form[method="post"]') # Rails uses POST with _method=put
    expect(rendered).to have_field("_method", type: :hidden, with: "put")
  end

  it "posts to invitation_path" do
    expect(rendered).to have_selector("form[action='#{user_invitation_path}']")
  end
end
