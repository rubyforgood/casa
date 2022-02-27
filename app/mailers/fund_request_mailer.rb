class FundRequestMailer < ApplicationMailer
  layout "fund_layout"

  def send_request(_user, fund_request)
    to_recipient_email = ENV["FUND_REQUEST_RECIPIENT_EMAIL"]
    Bugsnag.notify("No user for FUND_REQUEST_RECIPIENT_EMAIL for fund request from: #{fund_request.submitter_email}") unless to_recipient_email
    @fund_request = fund_request
    mail(layout: nil, to: [to_recipient_email, fund_request.submitter_email], subject: "Fund request from #{fund_request.submitter_email}")
  end
end
