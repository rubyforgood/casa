require "rails_helper"

RSpec.describe "casa_cases/fund_requests/new", type: :system do
  it "creates a fund request for the casa case" do
    org = create(:casa_org)
    volunteer = create(:volunteer, :with_casa_cases, casa_org: org)
    casa_case = volunteer.casa_cases.first

    sign_in volunteer
    visit new_casa_case_fund_request_path(casa_case)

    aggregate_failures do
      expect(page).to have_field "Your email", with: volunteer.email
      expect(page).to have_field "Name or case number of youth", with: casa_case.case_number
      expect(page).to have_field "Requested by & relationship to youth", with: "#{volunteer.display_name} CASA Volunteer"
    end

    fill_in "Amount of payment", with: "100"
    fill_in "Deadline", with: "2022-12-31"
    fill_in "Request is for", with: "Fun outing"
    fill_in "Name of payee", with: "Minnie Mouse"
    fill_in "Other source of funding", with: "some other agency"
    fill_in "How will this funding positively impact", with: "provide support"
    fill_in "Please use this space", with: "foo bar"

    expect {
      click_on "Submit Fund Request"
    }.to change(FundRequest, :count).by(1)

    expect(page).to have_text "Fund Request was sent for case #{casa_case.case_number}"

    fr = FundRequest.last
    aggregate_failures do
      expect(fr.deadline).to eq "2022-12-31"
      expect(fr.extra_information).to eq "foo bar"
      expect(fr.impact).to eq "provide support"
      expect(fr.other_funding_source_sought).to eq "some other agency"
      expect(fr.payee_name).to eq "Minnie Mouse"
      expect(fr.payment_amount).to eq "100"
      expect(fr.request_purpose).to eq "Fun outing"
      expect(fr.requested_by_and_relationship).to eq "#{volunteer.display_name} CASA Volunteer"
      expect(fr.submitter_email).to eq volunteer.email
      expect(fr.youth_name).to eq casa_case.case_number
    end
  end
end
