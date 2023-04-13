class CasaAdminMailerPreview < ActionMailer::Preview
  def account_setup
    casa_admin = params.has_key?(:id) ? CasaAdmin.find_by(id: params[:id]) : CasaAdmin.last
    if casa_admin.nil?
      ActiveSupport::Notifications.unsubscribe("process.action_mailer")
      ActionMailer::Base.mail(
        from: "no-rply@example.com",
        to: "missing_casa_admin@example.com",
        subject: "No Casa Admin has been found",
        body: "This is a debugging message letting you know no Casa admin has been found"
      )
    else
      CasaAdminMailer.account_setup(casa_admin)
    end
  end

  def deactivation
    casa_admin = params.has_key?(:id) ? CasaAdmin.find_by(id: params[:id]) : CasaAdmin.last
    if casa_admin.nil?
      ActiveSupport::Notifications.unsubscribe("process.action_mailer")
      ActionMailer::Base.mail(
        from: "no-rply@example.com",
        to: "missing_casa_admin@example.com",
        subject: "No Casa Admin has been found",
        body: "This is a debugging message letting you know no Casa admin has been found"
      )
    else
      CasaAdminMailer.deactivation(casa_admin)
    end
  end
end
