require "rails_helper"

RSpec.describe "dashboard/show", type: :system do
  let(:supervisor) { create(:supervisor, :with_volunteers) }

  before do
    sign_in supervisor
  end

  it "???" do
    visit root_path
    expect(page).to have_text("???")
  end
end
