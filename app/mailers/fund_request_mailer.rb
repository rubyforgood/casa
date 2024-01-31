class FundRequestMailer < ApplicationMailer
  layout "fund_layout"

  def send_request(_user, fund_request, bugsnag_active = true)
    to_recipient_email = ENV["FUND_REQUEST_RECIPIENT_EMAIL"]

    submitter_email = fund_request.submitter_email
    if bugsnag_active && !to_recipient_email
      Bugsnag.notify("No user for FUND_REQUEST_RECIPIENT_EMAIL for fund request from: #{submitter_email}")
    end
    @inputs = fund_request.as_json
    submitter_name = fund_request.submitter_email&.split("@")&.first
    begin
      pdf_attachment = FdfInputsService.new(
        inputs: @inputs,
        pdf_template_path: File.join(["data", "fund_request.pdf"]),
        basename: ["fund_request", "pdf"]
      ).write_to_file.read
      attachments.inline["fund-request-#{Date.today}-#{submitter_name}.pdf"] = pdf_attachment
    rescue => e
      Bugsnag.notify(e) if bugsnag_active
    end
    mail(layout: nil, to: [to_recipient_email, submitter_email], subject: "Fund request from #{submitter_email}")
  end
end
