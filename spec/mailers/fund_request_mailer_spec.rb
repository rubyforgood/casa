require "rails_helper"

RSpec.describe FundRequestMailer, type: :mailer do
  let(:fund_request) { FundRequest.new } # TODO add factory
  let(:mail) { described_class.send_request(nil, fund_request) }
  xit "TODO" do
    email_body = mail.html_part.body.to_s.squish
    expect(email_body).to include("Fund Request") # TODO add asserts
  end
end
