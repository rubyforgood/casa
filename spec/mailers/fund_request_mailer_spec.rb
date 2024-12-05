require "rails_helper"

RSpec.describe FundRequestMailer, type: :mailer do
  let(:fund_request) { build(:fund_request) }
  let(:mail) { described_class.send_request(nil, fund_request) }

  it "sends email" do
    email_body = mail.body.encoded.squish
    expect(email_body).to include("Fund Request")
  end
end
