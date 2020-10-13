require "rails_helper"

RSpec.describe "volunteer edits a case contact", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

  it "is successful" do
    case_contact =  create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer)
    sign_in volunteer  
    visit edit_case_contact_path(case_contact)

    choose "Yes"
    select "Letter", from: "case_contact[medium_type]"

    click_on "Submit"

    case_contact.reload
    expect(case_contact.casa_case_id).to eq casa_case.id
    expect(case_contact.duration_minutes).to eq 105
    expect(case_contact.medium_type).to eq "letter"
    expect(case_contact.contact_made).to eq true

  end

  it "is not has 'Edit' link after end of quarter" do
    past_date = 94.days.ago
    case_contact =  create(:case_contact, duration_minutes: 105,
                            casa_case: casa_case, creator: volunteer, occurred_at: past_date)
                            
    sign_in volunteer

    expect(page).not_to have_text('Edit')
  end

end
