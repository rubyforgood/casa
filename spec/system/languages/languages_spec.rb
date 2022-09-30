require "rails_helper"

RSpec.describe "languages/new", type: :system do
  let(:admin) { create(:casa_admin) }
  let(:organization) { admin.casa_org }

  before do
    sign_in admin

    visit new_language_path
  end

  it "requires name text field" do
    expect(page).to have_selector("input[required=required]", id: "language_name")
  end
end
