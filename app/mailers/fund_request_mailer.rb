class FundRequestMailer < ApplicationMailer
  layout "fund_layout"

  def send_request(_user, fund_request)
    to_recipient_email = ENV["FUND_REQUEST_RECIPIENT_EMAIL"]
    Bugsnag.notify("No user for FUND_REQUEST_RECIPIENT_EMAIL for fund request from: #{fund_request.submitter_email}") unless to_recipient_email
    @fund_request = fund_request
    pdf_attachment = PdfService.new(
      inputs: @fund_request,
      pdf_template_path: File.join(["data", "fund_request.pdf"]),
      basename: ["fund_request", "pdf"]
    ).write_to_file
    submitter_name = fund_request.submitter_email.split("@").first
    attachments.inline["fund-request-#{Date.today}-#{submitter_name}.pdf"] = pdf_attachment
    mail(layout: nil, to: [to_recipient_email, fund_request.submitter_email], subject: "Fund request from #{fund_request.submitter_email}")
  end
end
