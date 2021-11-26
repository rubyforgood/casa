class CasaAdminMailerPreview < ActionMailer::Preview
  def account_setup
    CasaAdminMailer.account_setup(get_casa_admin)
  end

  def deactivation
    CasaAdminMailer.deactivation(get_casa_admin)
  end

  def get_casa_admin
    CasaAdmin.find_by(id: params[:id]) || CasaAdmin.last
  end
end
