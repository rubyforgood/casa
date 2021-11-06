class CasaAdminMailerPreview < ActionMailer::Preview
  def account_setup
    casa_admin = if params.has_key?(:id) then CasaAdmin.find_by(id: params[:id]) else CasaAdmin.last end
    CasaAdminMailer.account_setup(casa_admin)
  end

  def deactivation
    casa_admin = if params.has_key?(:id) then CasaAdmin.find_by(id: params[:id]) else CasaAdmin.last end
    CasaAdminMailer.deactivation(casa_admin)
  end
end
