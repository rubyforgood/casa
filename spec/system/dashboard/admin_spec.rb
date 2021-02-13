require "rails_helper"

RSpec.describe "dashboard/show", type: :system do
  let(:casa_admin) { create(:casa_admin, :with_casa_cases) }

  before do
    sign_in casa_admin
  end

  it "???" do
    visit root_path
    expect(page).to have_text("???")
  end
end
