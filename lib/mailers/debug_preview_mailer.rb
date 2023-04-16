class DebugPreviewMailer < ActionMailer::Base
  def invalid_user(_user, role)
    mail(
      from: "reply@example.com",
      to: "missing_#{role}@example.com",
      subject: "invalid_user_id",
      body: "User does not exist or is not a #{role}"
    )
  end
end
