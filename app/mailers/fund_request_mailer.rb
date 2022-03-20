class FundRequestMailer < ApplicationMailer
  layout "fund_layout"

  def send_request(_user, fund_request)
    to_recipient_email = ENV["FUND_REQUEST_RECIPIENT_EMAIL"]

    submitter_email = fund_request.submitter_email
    Bugsnag.notify("No user for FUND_REQUEST_RECIPIENT_EMAIL for fund request from: #{submitter_email}") unless to_recipient_email
    @inputs = fund_request.as_json
    submitter_name = fund_request.submitter_email.split("@").first
    begin
      pdf_attachment = FdfInputsService.new(
        inputs: @inputs,
        pdf_template_path: File.join(["data", "fund_request.pdf"]),
        basename: ["fund_request", "pdf"]
      ).write_to_file.read
      attachments.inline["fund-request-#{Date.today}-#{submitter_name}.pdf"] = pdf_attachment
    rescue => e
      Bugsnag.notify(e)
    end
    mail(layout: nil, to: [to_recipient_email, submitter_email], subject: "Fund request from #{submitter_email}")
  end
end
