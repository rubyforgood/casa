class CasaAdminMailerPreview < ActionMailer::Preview
  def account_setup
    casa_admin = params.has_key?(:id) ? CasaAdmin.find_by(id: params[:id]) : CasaAdmin.last
    CasaAdminMailer.account_setup(casa_admin)
  end

  def deactivation
    casa_admin = params.has_key?(:id) ? CasaAdmin.find_by(id: params[:id]) : CasaAdmin.last
    CasaAdminMailer.deactivation(casa_admin)
  end
end
