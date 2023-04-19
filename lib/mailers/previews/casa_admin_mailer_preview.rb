require_relative "../debug_preview_mailer"
class CasaAdminMailerPreview < ActionMailer::Preview
  def account_setup
    casa_admin = params.has_key?(:id) ? CasaAdmin.find_by(id: params[:id]) : CasaAdmin.last
    if casa_admin.nil?
      DebugPreviewMailer.invalid_user("casa_admin")
    else
      CasaAdminMailer.account_setup(casa_admin)
    end
  end

  def deactivation
    casa_admin = params.has_key?(:id) ? CasaAdmin.find_by(id: params[:id]) : CasaAdmin.last
    if casa_admin.nil?
      DebugPreviewMailer.invalid_user("casa_admin")
    else
      CasaAdminMailer.deactivation(casa_admin)
    end
  end
end
