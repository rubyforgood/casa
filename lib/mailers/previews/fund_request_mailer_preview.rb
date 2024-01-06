# Preview all emails at http://localhost:3000/rails/mailers/fund_request_mailer
# :nocov:
require_relative "../debug_preview_mailer"

class FundRequestMailerPreview < ActionMailer::Preview
  def send_request
    # Set the FUND_REQUEST_RECIPIENT_EMAIL environment variable for testing
    ENV["FUND_REQUEST_RECIPIENT_EMAIL"] = "recipient@example.com"

    fund_request = FundRequest.new(
      submitter_email: "casa@example.cmo",
      youth_name: "The youth Name",
      payment_amount: "$123.45",
      deadline: Date.today + 7.days,
      request_purpose: "shoes",
      payee_name: "payee_name",
      requested_by_and_relationship: "Sample Requester",
      other_funding_source_sought: "Sample Funding Source",
      impact: "Sample Impact",
      extra_information: "Sample Extra Information"
    )

    FundRequestMailer.send_request(nil, fund_request, false)
  end
end
