class DebugPreviewMailer < ActionMailer::Base
  def invalid_user(role)
    mail(
      from: "reply@example.com",
      to: "missing_#{role}@example.com",
      subject: "invalid_user_id",
      body: "User does not exist or is not a #{role}"
    )
  end

  # Use when the looked-up user is valid but has no related record to preview
  # with, e.g. a volunteer with no case contact wanting reimbursement. Keeps
  # the "missing_#{role}@example.com" convention so existing preview specs
  # asserting on that address don't need to change.
  def no_data(role)
    mail(
      from: "reply@example.com",
      to: "missing_#{role}@example.com",
      subject: "no_preview_data",
      body: "No #{role} record was found to preview"
    )
  end
end
