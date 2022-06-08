require "rails_helper"

RSpec.describe FundRequestsController, type: :controller do
  it "view new page" do
    volunteer = create(:volunteer, :with_casa_cases)
    casa_case = volunteer.casa_cases.first
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
    get :new, params: {casa_case_id: casa_case.id}
    expect(assigns(:casa_case)).to be_present
    expect(assigns(:fund_request)).to be_present
  end

  it "sends email" do
    volunteer = create(:volunteer, :with_casa_cases, email: "volunteer@example.com")
    casa_case = volunteer.casa_cases.first
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
    stub_const("ENV", {"FUND_REQUEST_RECIPIENT_EMAIL" => volunteer.email})
    expect {
      post :create, params: {
          casa_case_id: casa_case.id,
          submitter_email: "submitter_email@example.com",
          youth_name: "youth_name",
          payment_amount: "payment_amount",
          deadline: "deadline",
          request_purpose: "request_purpose",
          payee_name: "payee_name",
          requested_by_and_relationship: "requested_by_and_relationship",
          other_funding_source_sought: "other_funding_source_sought",
          impact: "impact",
          extra_information: "extra_information"
      }
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(assigns(:fund_request)).to be_present
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq("Fund request from submitter_email@example.com")
    expect(mail.to).to match_array(["volunteer@example.com", "submitter_email@example.com"])
    expect(mail.body.encoded).to include("youth_name")
    expect(mail.body.encoded).to include("payment_amount")
    expect(mail.body.encoded).to include("deadline")
    expect(mail.body.encoded).to include("request_purpose")
    expect(mail.body.encoded).to include("payee_name")
    expect(mail.body.encoded).to include("requested_by_and_relationship")
    expect(mail.body.encoded).to include("other_funding_source_sought")
    expect(mail.body.encoded).to include("impact")
    expect(mail.body.encoded).to include("extra_information")
  end
end
