class VolunteerMailer < UserMailer
  def account_setup(user)
    @user = user
    @casa_organization = user.casa_org
    @token = @user.generate_password_reset_token
    mail(to: @user.email, subject: "Create a password & set up your account")
  end

  def court_report_reminder(user, court_report_due_date)
    @user = user
    @casa_organization = user.casa_org
    @court_report_due_date = court_report_due_date
    mail(to: @user.email, subject: "Your court report is due on: #{court_report_due_date}")
  end

  def case_contacts_reminder(user, cc_recipients)
    @user = user
    @casa_organization = user.casa_org
    mail(to: @user.email, cc: cc_recipients, subject: "Reminder to input case contacts")
  end

  def reimbursement_complete_email(user, case_contact)
    @user = user
    @case_contact = case_contact
    @casa_organization = @user.casa_org
    mail(to: @user.email, subject: "Your reimbursement request has been processed")
  end
end
