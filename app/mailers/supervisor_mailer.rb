class SupervisorMailer < UserMailer
  def account_setup(supervisor)
    @supervisor = supervisor
    @casa_organization = supervisor.casa_org
    @token = @supervisor.generate_password_reset_token
    mail(to: @supervisor.email, subject: "Create a password and set up your account")
  end

  def weekly_digest(supervisor)
    @supervisor = supervisor
    @casa_organization = supervisor.casa_org
    @inactive_messages = inactive_messages(supervisor)
    @show_notes = @inactive_messages.none?
    if supervisor.receive_reimbursement_email
      mileage_report_attachment = MileageReport.new(@casa_organization.id).to_csv
      attachments["mileage-report-#{Time.current.strftime("%Y-%m-%d")}.csv"] = mileage_report_attachment
    end
    mail(
      to: @supervisor.email,
      subject: "Weekly summary of volunteers' activities for the week of #{Date.today - 7.days}"
    )
  end

  def inactive_messages(supervisor)
    supervisor.volunteers.map do |volunteer|
      inactive_cases = CaseAssignment.inactive_this_week(volunteer.id)
      inactive_cases.map do |case_assignment|
        inactive_case_number = case_assignment.casa_case.case_number
        "#{volunteer.display_name} Case #{inactive_case_number} marked inactive this week."
      end
    end.flatten
  end
end
