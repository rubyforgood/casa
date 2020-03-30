require "rails_helper"

RSpec.feature "volunteer adds a case contact", type: :feature do
  scenario "is successful" do
    volunteer = create(:user, :volunteer, :with_casa_case)

    sign_in volunteer
    login_as volunteer

    visit '/'
    select "school", from: "Contact type"

    click_on "Create Case contact"

    expect(CaseContact.first.contact_type).to eq "school"
  end
end
